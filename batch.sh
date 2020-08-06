#!/bin/bash

## salloc -A m2845 -C gpu -N 1 --gres=gpu:1 -t 2:00:00
#SBATCH -A m2845
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -t 2:00:00
#SBATCH --gres=gpu:1

echo "==============================="
echo "Running OpenMP offloading benchmark"
echo "==============================="
cat Makefile
srun -n1 ./Benchmark_su3.x --gpu-threads 8
srun -n1 ./Benchmark_su3.x --gpu-threads 32 
srun -n1 ./Benchmark_su3.x --gpu-threads 128
#srun -n1 nvprof --print-gpu-trace ./Benchmark_su3.x

echo "==============================="
echo "Running reference CUDA benchmark"
echo "==============================="
cat Makefile.nvcc

srun -n1 ./Benchmark_su3.nvcc.x --gpu-threads 8
srun -n1 ./Benchmark_su3.nvcc.x --gpu-threads 32
srun -n1 ./Benchmark_su3.nvcc.x --gpu-threads 128

#srun -n1 ./Benchmark_su3.nvcc.x --gpu-threads 64
#srun -n1 ./Benchmark_su3.nvcc.x --gpu-threads 128
#srun -n1 nvprof --print-gpu-trace ./Benchmark_su3.nvcc.x
#srun -n 1 nv-nsight-cu-cli -o omp-cuda-mode ./Benchmark_su3.x
