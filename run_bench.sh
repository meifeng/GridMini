
srun ./Benchmark_su3_debug.x --gpu-threads 8 >& su3_8gpu-threads.log
srun ./Benchmark_su3_debug.x --gpu-threads 16 >& su3_16gpu-threads.log
srun ./Benchmark_su3_debug.x --gpu-threads 64 >& su3_64gpu-threads.log
srun ./Benchmark_su3_debug.x --gpu-threads 128 >& su3_128gpu-threads.log
srun ./Benchmark_su3_debug.x --gpu-threads 256 >& su3_256gpu-threads.log
srun ./Benchmark_su3_debug.x --gpu-threads 512 >& su3_512gpu-threads.log
srun ./Benchmark_su3_debug.x --gpu-threads 1024 >& su3_1024gpu-threads.log
