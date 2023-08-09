#!/bin/bash
NUMBER=1nd # test times label
CONFIG=F_OFF # output file label
OUTPUTPATH="./F-1st/" # output path

#SERVERADDR="localhost" # redis server address
SERVERADDR="192.168.1.180" # redis server address
function prepareData(){
	echo "===begin prepare data for test==="
	numactl -C 2-23 memtier_benchmark -s $SERVERADDR \
		-P memcache_text \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 7000 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=1 \
		--key-maximum=5500000 \
		--key-prefix=memtier-benchmark-prefix-memcachedtests \
		--out-file=${OUTPUTPATH}memcached_test_prepare_P1_${CONFIG}_$(date +"%Y%m%d%H%M%S").log

	numactl -C 26-47 memtier_benchmark -s $SERVERADDR \
		-P memcache_text \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 7001 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=5500000 \
		--key-maximum=11000000 \
		--key-prefix=memtier-benchmark-prefix-memcachedtests-keysize70-xxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}memcached_test_prepare_P2_${CONFIG}_$(date +"%Y%m%d%H%M%S").log

	numactl -C 50-71 memtier_benchmark -s $SERVERADDR \
		-P memcache_text \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--requests 100000 \
		-p 7002 \
		--key-pattern P:P \
		--ratio=1:0 \
		--key-minimum=11000000 \
		--key-maximum=16500000 \
		--key-prefix=memtier-benchmark-prefix-memcachedtests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
		--out-file=${OUTPUTPATH}memcached_test_prepare_P3_${CONFIG}_$(date +"%Y%m%d%H%M%S").log
	wait
	sleep 1m
	echo "===success prepare data for test==="
}

function testOne(){
	echo "===begin test for testOne==="
	numactl -C 2-23 memtier_benchmark -s $SERVERADDR \
		--test-time=900 \
		-P memcache_text \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed -p 7000 \
		--key-pattern G:G \
		--ratio=2:8 \
		--key-minimum=1 \
		--key-maximum=5500000 \
		--key-prefix=memtier-benchmark-prefix-memcachedtests \
		--key-stddev=916666 \
		--out-file=${OUTPUTPATH}memcached_test_result_Gauss82-P1_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	numactl -C 26-47 memtier_benchmark -s $SERVERADDR \
		--test-time=900 \
		-P memcache_text \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 7001 \
		--key-pattern G:G \
		--ratio=2:8 \
		--key-minimum=5500000 \
		--key-maximum=11000000 \
		--key-prefix=memtier-benchmark-prefix-memcachedtests-keysize70-xxxxxxxxxxxxx- \
		--key-stddev=916666 \
		--out-file=${OUTPUTPATH}memcached_test_result_Gauss82-P2_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &

	numactl -C 50-71 memtier_benchmark -s $SERVERADDR \
		--test-time=900 \
		-P memcache_text \
		--threads=20 \
		--clients=5 \
		--pipeline 1 \
		--data-size=1024 \
		--distinct-client-seed \
		-p 7002 \
		--key-pattern G:G \
		--ratio=2:8 \
		--key-minimum=11000000 \
		--key-maximum=16500000 \
		--key-prefix=memtier-benchmark-prefix-memcachedtests-keysize100-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx- \
		--key-stddev=916666 \
		--out-file=${OUTPUTPATH}memcached_test_result_Gauss82-P3_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log &
	wait
	sleep 1m
	echo "===Gauss82 is test end==="
}

function clearData(){
	#clean up databases
	echo "===Begin to clean databases==="
	echo "flush_all" | nc -q 2 $SERVERADDR 7000
	echo "flush_all" | nc -q 2 $SERVERADDR 7001
	echo "flush_all" | nc -q 2 $SERVERADDR 7002
	wait
	sleep 1s
	echo "===Databases are cleaned==="
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

function mainTest(){
	# Test three times
	for ((i=1; i<=3; i++))
	do
		NUMBER=${i}nd
		testOne
	done
}
#disableAutoNUMA
#disableSWAP
prepareData
mainTest
#testOne
#clearData
