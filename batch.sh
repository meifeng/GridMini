#!/bin/bash

## salloc -A m2845 -C gpu -N 1 --gres=gpu:1 -t 2:00:00
#SBATCH -A m2845
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -t 00:10:00
#SBATCH --gres=gpu:1

echo "==============================="
echo "Running OpenMP offloading benchmark"
echo "==============================="
cat Makefile 
srun -n 1 ./Benchmark_su3.x

echo "==============================="
echo "Running reference CUDA benchmark"
echo "==============================="
cat Makefile.nvcc
srun -n 1 ./Benchmark_su3.nvcc.x
