GPUARCH=-m64 -gencode arch=compute_70,code=sm_70
#MAIN=Benchmark_REAL
#MAIN=Benchmark_su3_mapper
#MAIN=Benchmark_su3
MAIN=Benchmark_su3_debug

##xlC
#CXX=xlC_r
#CXXFLAGS=-qsmp=omp -qoffload -Ofast  -std=c++11 -lcudart
#CXXFLAGS+=-DOMPTARGET -DOMPTARGET_MANAGED

##icpx
#CXX=icpx
#CXXFLAGS=-std=c++14 -O2 -fiopenmp -fopenmp-targets=spir64 
#CXXFLAGS+=-DOMPTARGET -DOMPTARGET_UVM #-DDEBUG

##PGI
#CXX=pgc++
#CXXFLAGS=-fast --c++14 -acc -Mnollvm -Minfo=accel -ta=tesla:cc70,managed -Mlarge_arrays --no_exceptions

##Main LLVM/Clang
#CXX=clang++
#CXXFLAGS=-std=c++14 -g -fopenmp -fopenmp-cuda-mode  -O3 -fopenmp-targets=nvptx64-nvidia-cuda -lcudart
#CXXFLAGS += -DOMPTARGET -Wno-unknown-cuda-version
##CXXFLAGS += -Xclang -fdump-record-layouts
##CXXFLAGS += -DOMPTARGET_UVM
##CXXFLAGS +=-DOMPTARGET_MANAGED
##CXXFLAGS += -DVECTOR_LOOPS
##LLVMFLAGS = -S -emit-llvm
##CXXFLAGS += -DVECTOR_LOOPS -Xclang -fdump-record-layouts-simple
##CXXFLAGS += -DDEBUG

##AOMP Clang - NVIDIA V100 GPU
#CXX=clang++
#CXXFLAGS = -std=c++14 -O3 -target x86_64-pc-linux-gnu -fopenmp -fopenmp-version=50
#CXXFLAGS += -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target=nvptx64-nvidia-cuda -march=sm_70
#CXXFLAGS += -DOMPTARGET


##AOMP Clang - AMD GPU
CXX=clang++ -fopenmp-version=50 -fopenmp-cuda-mode
CXXFLAGS=-std=c++14 -O3 -target x86_64-pc-linux-gnu -fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=gfx908
CXXFLAGS += -DOMPTARGET
##CXXFLAGS += -DDEBUG

##NVCC
#CXX=nvcc
#CXXFLAGS=--x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14

##NVC++ for OpenMP offloading
#CXX=nvc++
#CXXFLAGS=-std=c++14 -mp=gpu -gpu=cc70 -cuda -DOMPTARGET_MANAGED -DOMPTARGET -Minfo

##GCC
#CXX=g++
#CXXFLAGS=-std=c++14 -O3 -fopenmp -foffload=nvptx-none -DOMPTARGET #-DOMPTARGET_MANAGED -DDEBUG -lcudart

##CRAY CCE
#CXX=CC
#CXXFLAGS=-std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70
#CXXFLAGS += -DOMPTARGET 
#CXXFLAGS += -DOMPTARGET_MANAGED
#CXXFLAGS += -DDEBUG

INCLUDES=-I./ -I${CUDA_ROOT}/include
LDFLAGS=-L${CUDA_ROOT}/lib64
all:
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(LDFLAGS) \
		benchmarks/${MAIN}.cc \
                Grid/util/Init.cc \
                Grid/communicator/SharedMemory.cc \
                Grid/communicator/SharedMemoryNone.cc \
                Grid/allocator/AlignedAllocator.cc \
                Grid/communicator/Communicator_base.cc \
                Grid/communicator/Communicator_none.cc  \
                Grid/log/Log.cc \
                -o ${MAIN}.x \
                -DGEN \
                -DGEN_SIMD_WIDTH=16 \
                -DHAVE_MALLOC_H \
                -DGRID_COMMS_NONE \
                -DGRID_DEFAULT_PRECISION_DOUBLE \
		-DRNG_RANLUX


llvm:
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(LDFLAGS) \
		benchmarks/${MAIN}.cc \
                Grid/util/Init.cc \
                Grid/communicator/SharedMemory.cc \
                Grid/communicator/SharedMemoryNone.cc \
                Grid/allocator/AlignedAllocator.cc \
                Grid/communicator/Communicator_base.cc \
                Grid/communicator/Communicator_none.cc  \
                Grid/log/Log.cc \
                $(LLVMFLAGS) \
                -DGEN \
                -DGEN_SIMD_WIDTH=32 \
                -DHAVE_MALLOC_H \
                -DGRID_COMMS_NONE \
                -DGRID_DEFAULT_PRECISION_DOUBLE \
		-DRNG_RANLUX


clean:
	rm -v *.x 
