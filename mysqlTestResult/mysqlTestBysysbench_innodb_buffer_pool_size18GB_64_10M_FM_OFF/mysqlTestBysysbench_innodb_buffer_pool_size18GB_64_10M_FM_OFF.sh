#!/bin/bash
OUTPUTPATH=./
NUMBER=1nd
CONFIG=FM_OFF_64_10M
function preparedata(){
	echo "==Prepare data=="
	sysbench --threads=200 \
		--max-requests=0 \
		--test=/home/jianguoliu/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--oltp-table-size=10000000 \
		--oltp-tables-count=64 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--mysql-table-engine=innodb \
		--mysql-host=localhost \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--report-interval=3 prepare
        wait
        sleep 1m
}

function cleardata(){
	echo "==cleanup databases=="
	sysbench --threads=200 \
                --max-requests=0 \
                --test=/home/jianguoliu/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--oltp-table-size=10000000 \
		--oltp-tables-count=64 \
		--mysql-db=testdb \
		--db-driver=mysql \
		--mysql-table-engine=innodb \
                --mysql-host=localhost \
                --mysql-port=3306 \
                --mysql-user=root \
                --mysql-password=123456 \
                --report-interval=3 cleanup
       wait
       sleep 1m
}

function rwtest(){
	echo "==run sysbench for RW=="
	echo "Start time is: $(date '+%c')"
	sysbench --threads=200 \
		--max-time=360 \
		--max-requests=0 \
		--test=/home/jianguoliu/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-db=testdb \
		--oltp-table-size=10000000 \
		--oltp-tables-count=64 \
		--db-driver=mysql \
		--mysql-host=localhost \
		--mysql-port=3306 \
		--mysql-user=root \
		--mysql-password=123456 \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_rw_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
	wait
	sleep 1m
}

function rotest(){
	echo "==run sysbench test for RO=="
	echo "Start time is: $(date '+%c')"
	sysbench --test=/home/jianguoliu/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-host=localhost \
		--oltp-tables-count=64 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-port=3306 \
		--db-driver=mysql \
		--oltp-table-size=10000000 \
		--mysql-db=testdb \
		--max-requests=0 \
		--oltp-simple-ranges=0 \
		--oltp-distinct-ranges=0 \
		--oltp-sum-ranges=0 \
		--oltp-order-ranges=0 \
		--max-time=360 \
		--oltp-read-only=on \
		--threads=200 \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_ro_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
	wait
	sleep 1m
}

function wotest(){
	echo "== run sysbench for WO=="
	echo "Start time is: $(date '+%c')"
	sysbench --test=/home/jianguoliu/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-host=localhost \
		--oltp-tables-count=64 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-port=3306 \
		--db-driver=mysql \
		--oltp-table-size=10000000 \
		--mysql-db=testdb \
		--max-requests=0 \
		--max-time=360 \
		--oltp-simple-ranges=0 \
		--oltp-distinct-ranges=0 \
		--oltp-sum-ranges=0 \
		--oltp-order-ranges=0 \
		--oltp-point-selects=0 \
		--threads=200 \
		--randtype=uniform \
		--report-interval=3 \
		--thread-init-timeout=300 \
		--forced-shutdown=1 run >> "${OUTPUTPATH}mysysbench_wo_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
	wait
	sleep 1m
}
function gauss(){
	echo "== run sysbench for gauss=="
        echo "Start time is: $(date '+%c')"
	sysbench --test=/home/jianguoliu/Download/sysbench-1.0.11/tests/include/oltp_legacy/oltp.lua \
		--mysql-host=localhost \
		--oltp-tables-count=64 \
		--mysql-user=root \
		--mysql-password=123456 \
		--mysql-port=3306 \
		--db-driver=mysql \
		--oltp-table-size=10000000 \
		--mysql-db=testdb \
		--max-requests=0 \
		--max-time=360 \
		--threads=200 \
		--report-interval=3 \
		--oltp-test-mode=complex run >> "${OUTPUTPATH}mysysbench_gauss_${CONFIG}_${NUMBER}_$(date +"%Y%m%d%H%M%S").log"
	echo "End time is: $(date '+%c')"
        wait
        sleep 1m
}

function startMysql(){
	#sudo /etc/init.d/mysql restart
	service mysql start
	sleep 30s
}

#three times test
function alltest(){
	start_time=$(date +%s)  # script start run time
	
	#startMysql
	preparedata
	
	#rw test
	OUTPUTPATH=./
	NUMBER=1nd
	rwtest
	OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_2nd/
	NUMBER=2nd
	rwtest
	OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_3nd/
        NUMBER=3nd
	rwtest

	#ro test
	OUTPUTPATH=./
        NUMBER=1nd
	rotest
	OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_2nd/
	NUMBER=2nd
	rotest
	OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_3nd/
        NUMBER=3nd
	rotest
	
	#wo test
	OUTPUTPATH=./
        NUMBER=1nd
	wotest
	OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_2nd/
	NUMBER=2nd
	wotest
	OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_3nd/
        NUMBER=3nd
	wotest

	#gauss test
	OUTPUTPATH=./
        NUMBER=1nd
        gauss
        OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_2nd/
        NUMBER=2nd
        gauss
        OUTPUTPATH=../mysqlTestBysysbench_innodb_buffer_pool_size18GB_64_10M_FM_OFF_3nd/
        NUMBER=3nd
        gauss

	#cleardata

	end_time=$(date +%s)  # scrip stop run time,(s).
	# calculate script run time,(s).
	duration=$((end_time - start_time))
	echo "Script run time is: $duration (s)"
}
alltest
