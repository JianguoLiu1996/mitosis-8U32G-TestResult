#!/bin/bash
CURR_CONFIG=m # pagetable talbe replication cache set sign
NR_PTCACHE_PAGES=51200 # ---512Mb per socket

#SERVERADDR="localhost" # redis server address
SERVERADDR="192.168.1.180" # redis server address

function startRedis(){
	# start memcached
	sudo memcached -d -m 10240 -p 7000 -u root -t 2 -l $SERVERADDR
	sudo memcached -d -m 10240 -p 7001 -u root -t 2 -l $SERVERADDR
	sudo memcached -d -m 10240 -p 7002 -u root -t 2 -l $SERVERADDR
	wait 
	ps auxf | grep memcached
	sleep 1s
	echo "SIGN: success start redis"
}
function startRedisWithPageReplication(){
        sudo numactl -r 0-3 memcached -d -m 10240 -p 7000 -u root -t 2 -l $SERVERADDR
        sudo numactl -r 0-3 memcached -d -m 10240 -p 7001 -u root -t 2 -l $SERVERADDR
        sudo numactl -r 0-3 memcached -d -m 10240 -p 7002 -u root -t 2 -l $SERVERADDR
	wait 
	ps auxf | grep memcached
	sleep 1s
	echo "SIGN: success start redis server with pgreplication"
}
function stopRedis(){
	# stop redis
	sudo service memcached stop
	wait
	sleep 1s
	sudo kill -9 $(ps aux | grep 'memtier_benchmark' | grep -v grep | tr -s ' '| cut -d ' ' -f 2)
	sudo kill -9 $(ps aux | grep 'memcached' | grep -v grep | grep -v 'bash' | tr -s ' '| cut -d ' ' -f 2)
	sleep 1s
	ps aux | grep memcached
	sleep 5s
	#sudo service memcached status
	echo "SIGN: success stop redis"
}
function stopMySQL(){
        sudo service mysql stop
        sleep 1s
	sudo service mysql status
        echo "SIGN: success stop mysql"
}
function disableAutoNUMA(){
	# disable auto numa
	echo 0 | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR setting AutoNUMA to: 0"
                exit
        fi
	wait
	cat /proc/sys/kernel/numa_balancing
	sleep 1s
	echo "SIGN:success disable Auto NUMA"
}
function disableSWAP(){
	sudo swapoff -a
	sleep 1s
	echo "SIGN: success disable SWAP"
}
function setPagetableReplication(){
        #CURR_CONFIG=m
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
		wait
		sleep 1s
		echo "SIGN: success set pagetable cache $NR_PTCACHE_PAGES"
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
		wait
		sleep 1s
		echo "SIGN: success set pgtable replication strategy default, and set pgtable cache size zero"
        fi

}

function clearPgReplication(){
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
	wait
	sleep 1s
	echo "SIGN: success set pgtable replication strategy default, and set pgtable cache size zero"
}

function mainTest(){
	# Test three times
	for ((i=1; i<=3; i++))
	do
		NUMBER=${i}nd
		testOne
	done
}
#stopMySQL
#disableAutoNUMA
#disableSWAP
#setPagetableReplication
#startRedisWithPageReplication
#startRedis
#stopRedis
#clearPgReplication
