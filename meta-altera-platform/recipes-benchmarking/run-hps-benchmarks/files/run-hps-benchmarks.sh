#!/bin/bash

# get a list of unique processors
procs="$(lscpu -p=cpu,modelname | tail +5 | tr "," " " | sort -k 2 | uniq -f 1 | awk '{print $1}' | xargs)"

# run dhrystone
run_dhrystone() {
    cmd="taskset -c $1 dhry"
    echo $cmd
    echo 1000000000 | $cmd > "dhrystone-$1.log" 2>&1
}

# run dhrystone
run_coremark() {
    cmd="taskset -c $1 coremark 0x0 0x0 0x66 440000"
    echo $cmd
    $cmd > "coremark-$1.log" 2>&1
}

# bw_mem microbenchmark of lmbench
run_bw_mem() {
    for sz in 512 1K 2K 4K 8K 16K 32K 64K 128K 256K 512K 1024K 2048K 4096K 8192K 16384K 32768K 65536K 131072K 262144K; do
        bw_mem -N 1000 -P 1 "$sz" "$1"
    done
}

# run lmbench microbenchmarks: bw_mem fcp, bw_mem fwr, and bw_mem frd
run_lmbench() {
    for mode in fcp fwr frd; do
        log_file="lmbench_${mode}-$1.log"
        for size in 512 1K 2K 4K 8K 16K 32K 64K 128K 256K 512K 1024K 2048K 4096K 8192K 16384K 32768K 65536K 131072K 262144K; do
            cmd="taskset -c $1 bw_mem -N 1000 -P 1 $size $mode"
            echo $cmd
            $cmd >> $log_file 2>&1
        done
    done
}

# run STREAM
run_stream() {
    cmd="taskset -c $1 stream.mccalpin"
    echo $cmd
    $cmd > "stream.mccalpin-$1.log" 2>&1
}

# run benchmarks with the command:
# run-hps-benchmarks coremark dhrystone stream lmbench
for i in $procs; do
    for j in $*; do run_$j $i; done
done
