#!/bin/bash

if [ ! -d "./test" ]
then
    echo "directory ./test not found"
    exit 1
fi

version=$1
if [ -z $version ] 
then
    echo "version needed"
    exit 1
fi

executable=dbdeployer-${version}.linux
if [ ! -x $executable  ]
then
    echo "executable '$executable' not found"
    exit 1
fi

if [ ! -f ./test/common.sh ]
then
    echo "script './test/common.sh' not found"
    exit 1
fi

source ./test/common.sh

start_timer
timestamp=$(date +%Y-%m-%d-%H.%M)
log_summary=./test/logs/all_tests${timestamp}-summary.log

if [ ! -d ./test/logs ]
then
    mkdir ./test/logs
fi

function summary {
    exit_code=$1
    cat $log_summary
    stop_timer
    #rm -f $log_summary
    echo "# Exit code: $exit_code"
    exit $exit_code
}

function run_test {
    test_name="$1"
    test_arg="$2"
    start_test=$(date +%s)
    timestamp=$(date +%Y-%m-%d-%H.%M)
    test_base_name=$(basename $test_name .sh)
    test_log=./test/logs/${test_base_name}-${timestamp}.log
    echo "# Running $test_name $test_arg"
    $test_name $test_arg > $test_log
    exit_code=$?
    end_test=$(date +%s)
    elapsed=$((end_test-start_test))
    test_arg="[$test_arg]"
    printf "%-30s %-9s - time: %4ds (%10s) - exit code: %d\n" $test_base_name $test_arg ${elapsed} $(minutes_seconds $elapsed) $exit_code >> $log_summary
    if [ "$test_base_name" == "port-clash" ]
    then
        sandboxes=$(grep catalog $test_log | wc -l)
        ports=$(grep "Total ports installed" $test_log | awk '{print $NF}')
        changed=$(grep changed $test_log | wc -l)
        echo "# Deployed: $sandboxes sandboxes ($ports total ports) - Changed: $changed" >> $log_summary
    fi
    if [ "$exit_code" != "0" ]
    then
        echo "# --------------------------------"
        echo "# Error detected: $test_base_name "
        echo "# --------------------------------"
        tail -n 20 $test_log
        echo "# --------------------------------"
        summary $exit_code
    fi
}

function all_tests {
    run_test ./test/test.sh  
    run_test ./test/docker-test.sh $version
    run_test ./test/mock/defaults-change.sh 
    run_test ./test/mock/port-clash.sh sparse 
    if [ -n "$COMPLETE_PORT_TEST" ]
    then
        run_test ./test/mock/port-clash.sh 
    fi
} 

all_tests 
summary 0
