#!/bin/bash

CONFIG=$1

NR_PTCACHE_PAGES=27500 # --- 2GB per socket

test_and_set_configs() 
{
        CURR_CONFIG=$1
        FIRST_CHAR=${CURR_CONFIG:0:1}
        # --- check page table replication
        LAST_CHAR="${CURR_CONFIG: -1}"
        if [ $FIRST_CHAR == "m" ]; then
                echo 0 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to $0"
                        exit
                fi
                # --- drain first then reserve
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication_cache to $0"
                        exit
                fi
                echo $NR_PTCACHE_PAGES | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication_cache to $NR_PTCACHE_PAGES"
                        exit
                fi
        else
		#CMD_PREFIX+=" --pgtablerepl=$NODE_MAX "
                # --- enable default page table allocation
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to -1"
                        exit
                fi
                # --- drain page table cache
                echo -1 | sudo tee /proc/sys/kernel/pgtable_replication_cache > /dev/null
                if [ $? -ne 0 ]; then
                        echo "ERROR setting pgtable_replication to 0"
                        exit
                fi
        fi

}


# --- prepare the setup
test_and_set_configs $CONFIG
