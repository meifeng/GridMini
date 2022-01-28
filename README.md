# GridMini

## General description 
GridMini is a mini-application for Lattice Quantum Chromodynamics (QCD). Lattice QCD is a numerical framework to simulate the strong interactions of quarks and gluons on a discrete four-dimensional space-time lattice, and provides crucial input to theoretical nuclear and particle physics. GridMini is a substantially reduced version of Grid, a C++ lattice QCD library  developed for highly parallel computer architectures. It supports data layouts that are amenable to SIMD vectorizations and uses extensive templating to hide low-level architecture-dependent implementations to allow for physics DSL-like high-level interfaces. 

While Grid contains many additional codes to support high-level numerical algorithms and physics analysis essential for Lattice QCD, GridMini only retains Grid's lower-level data structures and data layouts necessary for the performance benchmarks of interest to lattice QCD. 

The current version of GridMini is mainly developed to assess the ability to use OpenMP, with its target offloading support, as a common portable solution across different GPU accelerator architectures. But it can also be extended to evaluate other programming models. 

The main benchmark for this version is Benchmark_su3, which measures the sustained device memory bandwidth in the 3x3 matrix multiplication that is common in lattice QCD simulations. 

## Compiling the code 
First clone the code to your local directory
> git clone https://github.com/meifeng/GridMini

Go into the source directory
> cd GridMini

The Makefile supports different targets with different compilers and device architectures. 

For NVIDIA GPUs, current supported OpenMP offloading compilers include LLVM/Clang (clang++), GCC (g++), IBM XL/C (xlc_r) and NVIDIA HPC SDK (nvc++). A baseline implementation with CUDA is also available, and can be compiled with the NVIDIA CUDA compiler (nvcc). Specific GPU architecture is specified in the NVIDIA_ARCH variable in Makefile. 

For AMD GPUs, the only OpenMP offloading compiler supported is rocm clang. You can specific the AMD GPU architecture version by changing the AMD_ARCH variable in Makefile. 

Make sure NVIDIA_ARCH or AMD_ARCH has the correct value in the makefile. If you have the correct compiler loaded, you can then compile the code with 
> make target

where *target* is one of the following:

#### On NVIDIA GPUs
* *nvcc*: This will compile the CUDA implementation in GridMini for NVIDIA GPUs. This version uses CUDA *managed memory*. 
* *nv-omp*: This will try to compile the OpenMP offloading version with nvc++ for NVIDIA GPUs. 
* *nv-acc*: This will try to compile the OpenACC implementation in GridMini with nvc++ for NVIDIA GPUs.
* *clang-nvidia*: It compiles the OpenMP offloading implementation using the mainline LLVM clang++ for NVIDIA GPUs.  
* *xl*: This will compile the code using IBM's XL C compiler for NVIDIA GPUs. 
* *gcc-omp*: This uses the g++ compiler for OpenMP offloading to NVIDIA GPUs. 
* *cray-omp*: This uses the Cray C++ compiler for OpenMP offloading to NVIDIA GPUs. 

#### On AMD GPUs 
* *clang-amd*: It will compile the code with AMD's clang++ for AMD GPUs. 

The executable produced will be named prefix-Benchmark_su3.x, where *prefix* depends on the target you choose. 

## Running the code

Benchmark_su3 will print out the measured device memory bandwith as a function of the lattice volume (or bytes), as well as the corresponding FLOPs. 

You can specify the number of GPU threads in a thread block through the *--gpu-threads* command line argument. For example, 
> prefix-Benchmark_su3.x --gpu-threads 128 

If you don't provide --gpu-threads argument, it will use the default value, which is 8. 

If your system uses Slurm as the workload manager, you may need to launch the executable with *srun*, such as the following
> srun prefix-Benchmark_su3.x 
