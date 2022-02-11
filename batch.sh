#!/bin/bash

#SBATCH -A lgt104_crusher 
#SBATCH -p batch
#SBATCH -N 1
#SBATCH -t 2:00:00
#SBATCH -J llvm-map-su3 
#SBATCH -o %x-%j.out

echo "==============================="
echo "Running OpenMP offloading benchmark"
echo "==============================="
cat Makefile
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 8
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 16
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 32
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 64
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 128
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 256
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 512
srun -n1 ./amd-Benchmark_su3.x --gpu-threads 1024

#srun -n1 nvprof --print-gpu-trace ./amd-Benchmark_su3.x

#echo "==============================="
#echo "Running reference CUDA benchmark"
#echo "==============================="
#cat Makefile.nvcc

#srun -n1 nvprof ./amd-Benchmark_su3.nvcc.x -o nvcc-8threads.nvp --gpu-threads 8
#srun -n1 nvprof ./amd-Benchmark_su3.nvcc.x -o nvcc-32threads.nvp --gpu-threads 32
#srun -n1 nvprof ./amd-Benchmark_su3.nvcc.x -o nvcc-128threads.nvp --gpu-threads 128

#srun -n1 ./amd-Benchmark_su3.nvcc.x --gpu-threads 64
#srun -n1 ./amd-Benchmark_su3.nvcc.x --gpu-threads 128
#srun -n1 nvprof --print-gpu-trace ./amd-Benchmark_su3.nvcc.x
#srun -n 1 nv-nsight-cu-cli -o omp-cuda-mode ./amd-Benchmark_su3.x
