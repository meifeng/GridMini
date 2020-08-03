#!/bin/bash

## salloc -A m2845 -C gpu -N 1 --gres=gpu:1 -t 2:00:00
#SBATCH -A m2845
#SBATCH -C gpu
#SBATCH -N 1
#SBATCH -t 00:10:00
#SBATCH --gres=gpu:4
#SBATCH --exclusive

srun ./Benchmark_su3.x
