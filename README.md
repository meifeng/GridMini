# GridMini
This is a miniapp for Lattice QCD derived from Grid (https://github.com/paboyle/Grid)

DISCLAIMER: This is an ongoing development code. Functionalities are not guaranteed to be working correctly. More instructions for compiling and running GridMini are forthcomping. Please be patient. 

Currently supported benchmarks include
- Benchmark_su3.cc

To compile, edit Makefile to choose the desired compiler and target and save. For example, to run the benchmark on NVIDIA V100 GPUs with the CUDA implementation, set 

  - GPUARCH=-m64 -gencode arch=compute_70,code=sm_70
  - CXX=nvcc
  - CXXFLAGS=--x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14

Then type "make", and an executable called "Benchmark_su3.x" will be generated in the top directory.  
