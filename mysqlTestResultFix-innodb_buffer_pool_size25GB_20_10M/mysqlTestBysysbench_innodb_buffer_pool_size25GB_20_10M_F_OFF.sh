#!/bin/bash
NUMBER=1nd
CONFIG=20_10M_F_OFF
INNODB_BUFFER_SIZE=25GB
OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
MYSQLADDR="127.0.0.1"
function preparedata(){
	echo "SIGN: prepare data=="
	sysbench /usr/share/sysbench/oltp_write_only.lua \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-db=testdb_20_10M \
		--db-driver=mysql \
		--tables=20 \
		--table_size=10000000 \
		--report-interval=10 \
		--threads=32 \
		--time=120 prepare >> "${OUTPUTPATH}mysysbench_prepare_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
        wait
        sleep 1m
	echo "SIGN:data ready"
}

function cleardata(){
	echo "==SIGN: can't cleardata=="
}
function testOne(){
	echo "SIGN: stat one test."
	sysbench /usr/share/sysbench/oltp_read_only.lua \
		--mysql-host=${MYSQLADDR} \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-db=testdb_20_10M \
		--db-driver=mysql \
		--tables=20 \
		--table_size=10000000 \
		--report-interval=3 \
		--threads=100 \
		--time=3600 run >> "${OUTPUTPATH}mysysbench_test_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	wait
	sleep 1m
	echo "SIGN: test one end."

}
function disableSWAP(){
	sudo swapoff -a
	wait
	echo "SIGN: success disable swap."
}
function stopMYSQLandRedis(){
	sudo service mysql stop
	sudo service redis stop
	sudo service mysql status
	sudo service redis status
}
function disableAutoNUMA(){
	# disable auto numa
	echo 0 | sudo tee /proc/sys/kernel/numa_balancing > /dev/null
	if [ $? -ne 0 ]; then
		echo "ERROR setting AutoNUMA to: 0"
                exit
        fi
	echo "SIGN:success disable Auto NUMA"
}

#three times test
function alltest(){
	start_time=$(date +%s)  # script start run time
	
	#rw test
	for ((i=1; i<=3; i++))
        do
                NUMBER=${i}nd
		OUTPUTPATH=./mysqlTestBysysbench_innodb_buffer_pool_size${INNODB_BUFFER_SIZE}_${CONFIG}_${NUMBER}/
		testOne
        done

	end_time=$(date +%s)  # scrip stop run time,(s).
	# calculate script run time,(s).
	duration=$((end_time - start_time))
	echo "Script run time is: $duration (s)"
}
#stopMYSQLandRedis
#disableSWAP
#disableAutoNUMA
#preparedata
alltest
