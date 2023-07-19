#!/bin/bash
NUMBER=1nd # test times label
OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
CONFIG=F_OFF # output file label
CURR_CONFIG=m # pagetable talbe replication cache set sign
NR_PTCACHE_PAGES=262144 # ---1GB per socket
SERVERADDR="localhost" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	# default size is: --key-maximum=5243086 \
	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6379 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P1_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 6380 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P2_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--requests 100000 \
#		-p 6381 \
#		--key-pattern P:P \
#		--ratio=1:0 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--out-file=${OUTPUTPATH}redis_prepare_${CONFIG}_P3_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===success prepare data for test==="
}

function Gauss82(){
	echo "===begin test for Gauss82==="
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern G:G \
		--ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--key-stddev=873847 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P1_${NUMBER}$(date +"%Y%m%d%H%M%S").log
	
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern G:G \
		--ratio=2:8 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--key-stddev=873847 \
		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=40 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6381 \
#		--key-pattern G:G \
#		--ratio=2:8 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--key-stddev=873847 \
#		--out-file=${OUTPUTPATH}redis_result_Gauss82_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Gauss82 is test end==="
}

function Gauss110(){
	echo "===begin test for Gauss110==="
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--key-stddev=873847 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern G:G \
		--ratio=10:1 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--key-stddev=873847 \
		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=40 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6381 \
#		--key-pattern G:G \
#		--ratio=10:1 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--key-stddev=873847 \
#		--out-file=${OUTPUTPATH}redis_result_Gauss110_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Gauss110 is test end==="
}

function Random82(){
	echo "===begin test for Random82==="
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern R:R \
		--ratio=2:8 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=40 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6381 \
#		--key-pattern R:R \
#		--ratio=2:8 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--out-file=${OUTPUTPATH}redis_result_Random82_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Random82 is test end==="
}
function Random110(){
	echo "===Begin test for Random110==="
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern R:R \
		--ratio=10:1 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=40 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6381 \
#		--key-pattern R:R \
#		--ratio=10:1 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--out-file=${OUTPUTPATH}redis_result_Random110_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Random110 is test end==="
}
function Sequential82(){
	echo "===Begin test for Sequential82==="
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern S:S \
		--ratio=2:8 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log

#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=40 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6381 \
#		--key-pattern S:S \
#		--ratio=2:8 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--out-file=${OUTPUTPATH}redis_result_Sequential82_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Sequential82 is test end==="
}
function Sequential110(){
	echo "===Bengin test for Sequential110==="
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6379 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=1 \
		--key-maximum=5243086 \
		--key-prefix=memtier-benchmark-prefix-redistests \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P1_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	
	memtier_benchmark -s ${SERVERADDR} \
		--test-time=40 \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 6380 \
		--key-pattern S:S \
		--ratio=10:1 \
		--key-minimum=5243086 \
		--key-maximum=10000000 \
		--key-prefix=memtier-benchmark-prefix-redistests-keysize70-xxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P2_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	
#	memtier_benchmark -s ${SERVERADDR} \
#		--test-time=40 \
#		--threads=20 \
#		--clients=5 \
#		--pipeline 1 \
#		--data-size=1024 \
#		--distinct-client-seed \
#		-p 6381 \
#		--key-pattern S:S \
#		--ratio=10:1 \
#		--key-minimum=10000000 \
#		--key-maximum=16043086 \
#		--key-prefix=memtier-benchmark-prefix-redistests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
#		--out-file=${OUTPUTPATH}redis_result_Sequential110_${CONFIG}_P3_${NUMBER}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===Sequential110 is test end==="
}
function clearData(){
	#clean up databases
	echo "===Begin to clean databases==="
	redis-cli -h $SERVERADDR -p 6379 flushall
	redis-cli -h $SERVERADDR -p 6380 flushall
#	redis-cli -h $SERVERADDR -p 6381 flushall
	wait
	sleep 5s
	echo "===Databases are cleaned==="
}
function startRedis(){
	# start redis
	#sudo /etc/init.d/redis-server start
	sudo redis-server /etc/redis/redis.conf
	sudo redis-server /etc/redis/redis6380.conf
#	sudo redis-server /etc/redis/redis6381.conf
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success start redis"
}
function startRedisWithPageReplication(){
	#sudo numactl -r 0-3 /etc/init.d/redis-server start
        sudo numactl -r 0-3 redis-server /etc/redis/redis.conf
        sudo numactl -r 0-3 redis-server /etc/redis/redis6380.conf
#        sudo numactl -r 0-3 redis-server /etc/redis/redis6381.conf
	wait 
	ps auxf | grep redis-server
	sleep 5s
	echo "SIGN: success start redis server with pgreplication"
}
function stopRedis(){
	# stop redis
#	sudo redis-cli -p 6381 shutdown
	sudo redis-cli -p 6380 shutdown
	sudo sudo /etc/init.d/redis-server stop
	wait 
	ps auxf | grep redis-server
	sleep 5s
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
	sleep 5s
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
		sleep 5s
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
		sleep 5s
		echo "SIGN: success set pgtable replication strategy default, and set pgtable cache size zero"
        fi

}
function mainTest(){
	# Test three times
	for ((i=1; i<=3; i++))
	do
		NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
		Gauss82
	done

	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
		Gauss110
        done

	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
		Random82
        done

	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
                Random110
        done

	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
		Sequential82
        done

	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./redis_test_result_by_memtier_benchmark_F_OFF_${NUMBER}/ # output path
		Sequential110
        done
}
#stopMySQL
#disableAutoNUMA
#disableSWAP
#setPagetableReplication
#startRedisWithPageReplication
#startRedis
prepareData
mainTest
#clearData
#stopRedis
