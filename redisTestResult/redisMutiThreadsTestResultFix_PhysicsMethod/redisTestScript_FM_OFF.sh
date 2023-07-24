#!/bin/bash
NUMBER=1nd # test times label
CONFIG=FM_OFF # output file label
OUTPUTPATH="./redis_test_result_by_memtier_benchmark_${CONFIG}_3nd/" # output path
CURR_CONFIG=m # pagetable talbe replication cache set sign
NR_PTCACHE_PAGES=51200 # ---512Mb per socket
SERVERADDR="localhost" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	memtier_benchmark -p 6379 \
		-t 20 \
		-c 5 \
		-n 1800000 \
		-R \
		--randomize \
		--distinct-client-seed \
		-d 24 \
		--key-maximum=180000000 \
		--key-minimum=1 \
		--ratio=1:0 \
		--key-pattern=P:P \
		--pipeline=2500 \
		--hide-histogram \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===success prepare data for test==="
}

function testOne(){
	echo "===begin test for testOne==="
	memtier_benchmark -p 6379 -t 20 -c 5 \
		--test-time=1800 \
		-R \
		--randomize \
		--distinct-client-seed \
		-d 24 \
		--key-maximum=180000000 \
		--key-minimum=1 \
		--ratio=0:1 \
		--key-pattern=R:R \
		-o ${OUTPUTPATH}redis_result_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log \
		--hide-histogram \
		--pipeline=2500
	wait
	sleep 1m
	echo "===Gauss82 is test end==="
}

function clearData(){
	#clean up databases
	echo "===Begin to clean databases==="
	redis-cli -h $SERVERADDR -p 6379 flushall
	wait
	sleep 5s
	echo "===Databases are cleaned==="
}

function startRedis(){
	# start redis
	#sudo /etc/init.d/redis-server start
	sudo redis-server /etc/redis/redis.conf
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success start redis"
}
function startRedisWithPageReplication(){
	#sudo numactl -r 0-3 /etc/init.d/redis-server start
        sudo numactl -r 0-3 redis-server /etc/redis/redis.conf
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success start redis server with pgreplication"
}
function stopRedis(){
	# stop redis
	sudo sudo /etc/init.d/redis-server stop
	wait 
	ps auxf | grep redis-server
	sleep 1s
	echo "SIGN: success stop redis"
}
function stopMySQL(){
        sudo service mysql stop
        sleep 1s
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
#prepareData
#mainTest
#clearData
stopRedis
