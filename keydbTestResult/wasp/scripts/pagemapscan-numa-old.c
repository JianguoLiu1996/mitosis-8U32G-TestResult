/* pagemapscan-numa.c v0.01
 *
 * Copyright (c) 2012 IBM
 *
 * Author: Andrew Theurer
 *
 * This software is licensed to you under the GNU General Public License,
 * version 2 (GPLv2). There is NO WARRANTY for this software, express or
 * implied, including the implied warranties of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
 * along with this software; if not, see
 * http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
 *
 * pagemapscan-numa:  This program will take a Qemu PID and a value
 * equal to the number of NUMA nodes that the VM should have and process
 * /proc/<pid>/pagemap, first finding the mapping that is the for VM memory,
 * and then finding where each page physically resides (which NUMA node)
 * on the host.  This is only useful if you have a mulit-node NUMA
 * topology on your host, and you have a multi-node NUMA topology
 * in your guest, and you want to know where the VM's memory maps to
 * on the host.
 */

#define _LARGEFILE64_SOURCE

#include <sys/types.h>
#include <stdio.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>

#define MAX_NODES 256
#define ALL_NODES (MAX_NODES - 1)
#define MAX_LENGTH 256
#define PAGE_SIZE 4096

int main(int argc, char* argv[]) {

	int pagemapfile = -1;
	int nr_vm_nodes;
	FILE *mapsfile = NULL;
	FILE *zonefile = NULL;
	char pagemappath[MAX_LENGTH];
	char mapspath[MAX_LENGTH];
	char mapsline[MAX_LENGTH];
	char zoneline[MAX_LENGTH];
	long file_offset, offset;
	unsigned long start_addr, end_addr, size_b, size_mib, nr_pages,
	      page, present_pages, present_mib, start_pfn[MAX_NODES],
	      present_pages_node[MAX_NODES][MAX_NODES];

	int i, node, nr_host_nodes, find_node, host_node, vm_node;
	
	if (argc != 3) {
		printf("You must provide two arguments, the Qemu PID and the number of nodes the VM has\n");
		printf("For example:  ./pagemapscan-numa 1234 4\n");
		return 1;
	}
	printf("pid is %s\n", argv[1]);
	sprintf(pagemappath, "/proc/%s/pagemap", argv[1]);
	sprintf(mapspath, "/proc/%s/maps", argv[1]);
	nr_vm_nodes = atoi(argv[2]);
	zonefile = fopen("/proc/zoneinfo", "r");
	// get the number of host nodes and their first pfn
	printf("Processing /proc/zoneinfo for start_pfn's\n");
	if (zonefile) {
		nr_host_nodes = 0;
		find_node = 1;
		while (fgets(zoneline, MAX_LENGTH, zonefile) != NULL) {
			if (find_node == 1) { //search for a "Node %d"
				i = sscanf(zoneline, "Node %d, zone",&node);
				if (i == 1) {//we found it, now search for pfn
					if (start_pfn[node] == 0)
						nr_host_nodes++;
					// printf("i: [%d] node: [%d]\n", i, node);
					find_node = 0;
				}
			} else { //search for a "  start_pfn: %d"
				i = sscanf(zoneline, "  start_pfn: %d",&start_pfn[node]);
				if (i == 1) {//we found pfn, now go back to finding next node
					find_node = 1;
				}
			}
		}
	} else {
		fprintf(stderr,"Could not open /proc/zoneinfo, exiting\n");
		return 1;
	}
	if (nr_host_nodes == 0) {
		fprintf(stderr, "Could not find a single host node, exiting\n");
		return 1;
	}
	for (node = 0; node < nr_host_nodes; node++)
		printf("host node %d start pfn: %lu\n", node, start_pfn[node]);
	mapsfile = fopen(mapspath, "r");
	present_pages = 0;
	if (mapsfile) {
		printf("\nProcessing %s and %s\n\n", mapspath, pagemappath);
		while (fgets(mapsline, 256, mapsfile) != NULL) {
			unsigned long pagemapbitmask, pfn;
			ssize_t t;

			i = sscanf(mapsline, "%lX-%lX", &start_addr, &end_addr);
			if (i == 2) {
				size_b = end_addr - start_addr;
				nr_pages = size_b / PAGE_SIZE;
				size_mib = size_b >> 20;
				// We are looking for only the mapping that is the VM memory.  We are not sure which
				// one it is, so we just look for one that is 2GB or larger, which should 
				// avoid all other qemu mappings.  Worst case, this program will find multiple
				// mappings, one of which is hopefully the VM memory, unless the VM memory is <2GB.
				// Ideally we should come up with a better way to do this.
				if (size_mib > 2048) {
					printf("Found mapping %016llX-%016llX that is >2GiB (%lu MiB, %lu pages)\n",
					       start_addr, end_addr, size_mib, nr_pages);
					pagemapfile = open(pagemappath, O_RDONLY);
					if (pagemapfile == -1) {
						fprintf(stderr, "Error opening %s (errno=%d)\n", pagemappath, errno);
						return 1;
					}
					file_offset = (start_addr / PAGE_SIZE) * sizeof(unsigned long);
					offset = lseek64(pagemapfile, file_offset, SEEK_SET);
					if (offset == -1) {
						fprintf(stderr, "Error seeking to %ld in file (errno=%d)\n", file_offset, errno);
						return 1;
					}
					for (host_node = 0; host_node < nr_host_nodes; host_node++)
						present_pages_node[ALL_NODES][host_node] = 0;
					for (vm_node = 0; vm_node < nr_vm_nodes; vm_node++) {
						present_pages_node[vm_node][ALL_NODES] = 0;
						for (host_node = 0; host_node < nr_host_nodes; host_node++)
							present_pages_node[vm_node][host_node] = 0;
						
						// assume that the mapping is [evenly] divided into N VM nodes
						for (page = 0; page < (nr_pages/nr_vm_nodes); page++) {
							t = read(pagemapfile, &pagemapbitmask, sizeof(unsigned long));
							// first check to see if the page present bit is set
							if (pagemapbitmask & (1ULL << 63)) {
								present_pages++;
								// Determine which host node this page belongs to.
								// This assumes there are no holes in the physical memory and
								// node0 has the lowest start pfn, followed by node1, etc.  This
								// also assumes there are no empty nodes.
								pfn = (pagemapbitmask << 9) >> 9; //get rid of non-pfn bits
								host_node = nr_host_nodes - 1;
								while (host_node > 0) {
									if (pfn >= start_pfn[host_node])
										break;
									host_node--;
								}
								present_pages_node[vm_node][host_node]++;
								present_pages_node[ALL_NODES][host_node]++;
								present_pages_node[vm_node][ALL_NODES]++;
							}
						}
					}
					close(pagemapfile);
				}
			}
		}
		fclose(mapsfile);

		//present_mib = (present_pages * PAGE_SIZE) >> 20;
		//printf("%lu/%lu total pages/MiB present for this process\n\n", present_pages, present_mib);

		printf("Pages present for this mapping:\n");
		printf("vNUMA-node-ID");
		for (host_node = 0; host_node < nr_host_nodes; host_node++) {
			printf("%17s%02d","node", host_node);
		}
		//printf("%21s","all\n");
		printf("\n-------------");
		for (host_node = 0; host_node < nr_host_nodes; host_node++) {
			printf("%19s","-------");
		}
		printf("\n");
		for (vm_node = 0; vm_node < nr_vm_nodes; vm_node++) {
			printf("           %02d", vm_node);
			for (host_node = 0; host_node < nr_host_nodes; host_node++) {
				printf("%19lu", present_pages_node[vm_node][host_node]);
			}
			int pct = (100 * present_pages_node[vm_node][ALL_NODES] / present_pages);
			printf("\n");
			//printf("%19lu|%03d%%\n", present_pages_node[vm_node][ALL_NODES], pct);
		}
		printf("          all     ");
		for (host_node = 0; host_node < nr_host_nodes; host_node++) {
			int pct = (100 * present_pages_node[ALL_NODES][host_node] / present_pages);
			printf("%14lu|%03d%%", present_pages_node[ALL_NODES][host_node], pct);
		}
		//printf("%14lu\n", present_pages);
		printf("\n");
			
	} else
		printf("could not open %s\n", pagemappath);
return 0;
}
