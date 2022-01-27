GPUARCH=-m64 -gencode arch=compute_70,code=sm_70
NVIDIA_ARCH=sm_70 #change to the target NVIDIA GPU arch
AMD_ARCH=gfx908   #change to the target AMD GPU arch


MAIN=Benchmark_su3
MAIN1=Benchmark_su3_debug
MAIN2=Benchmark_su3_mapper


SRCS=benchmarks/${MAIN}.cc \
                Grid/util/Init.cc \
                Grid/communicator/SharedMemory.cc \
                Grid/communicator/SharedMemoryNone.cc \
                Grid/allocator/AlignedAllocator.cc \
                Grid/communicator/Communicator_base.cc \
                Grid/communicator/Communicator_none.cc  \
                Grid/log/Log.cc \

# include path
INCLUDES=-I./ -I${CUDA_ROOT}/include

# linking path
LDFLAGS=-L${CUDA_ROOT}/lib64

# Macros in Grid 
DEFS=-DGEN \
     -DGEN_SIMD_WIDTH=16 \
     -DHAVE_MALLOC_H \
     -DGRID_COMMS_NONE \
     -DGRID_DEFAULT_PRECISION_DOUBLE \
     -DRNG_RANLUX \
#     -DSPOT_CHECK=4 #Uncomment to spot check for correctness. If SPOT_CHECK is specified with a number, that site index will be checked. Otherwise, site 1 will be checked.  

#OMPTARGET_MANAGED uses cudaMallocManaged or hipMallocManaged as the memory allocator
#OMPTARGET_MAP uses manual data copying using the "map" clauses 
#OMPTARGET_UVM uses the built-in unified shared memory support -- NOT WORKING 

OMPFLAGS=-DOMPTARGET -DOMPTARGET_UVM # -DOMPTARGET_MAP -DOMPTARGET_MANAGED #


##xlC
XLCXXFLAGS=-qsmp=omp -qoffload -Ofast  -std=c++11 -lcudart

xl: $(SRCS) 
	xlC_r $(INCLUDES) $(LDFLAGS) $(XLCXXFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o xl-$(MAIN).x 


##icpx
ICPXFLAGS=-std=c++14 -O2 -fiopenmp -fopenmp-targets=spir64 

intel: $(SRCS)
	icpx $(INCLUDES) $(LDFLAGS) $(ICPXFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o intel-$(MAIN).x


##PGI/NVHPC for OpenACC
NVACCFLAGS=-fast --c++14 -acc -Mnollvm -Minfo=accel -ta=tesla:cc70,managed -Mlarge_arrays --no_exceptions

nv-acc: $(SRCS)
	nvc++ $(INCLUDES) $(LDFLAGS) $(NVACCFLAGS) $(DEFS) $(SRCS) -o nvacc-$(MAIN).x

##Main LLVM/Clang

CXXFLAGS=-std=c++14 -g -fopenmp -fopenmp-cuda-mode  -O3 -fopenmp-targets=nvptx64-nvidia-cuda -lcudart
clang-nvidia: $(SRCS)
	clang++ $(INCLUDES) $(LDFLAGS) $(CXXFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o llvm-$(MAIN).x

##CXXFLAGS += -Xclang -fdump-record-layouts
#CXXFLAGS += -DOMPTARGET_UVM
#CXXFLAGS +=-DOMPTARGET_MANAGED
##CXXFLAGS += -DVECTOR_LOOPS
##LLVMFLAGS = -S -emit-llvm
##CXXFLAGS += -DVECTOR_LOOPS -Xclang -fdump-record-layouts-simple
##CXXFLAGS += -DDEBUG

##AOMP Clang - NVIDIA V100 GPU
#CXX=clang++
#CXXFLAGS = -std=c++14 -O3 -target x86_64-pc-linux-gnu -fopenmp -fopenmp-version=50
#CXXFLAGS += -fopenmp-targets=nvptx64-nvidia-cuda -Xopenmp-target=nvptx64-nvidia-cuda -march=$(NVIDIA_ARCH)
#CXXFLAGS += -DOMPTARGET


##AOMP Clang - AMD GPU
AMDFLAGS = -std=c++14 -O3 -target x86_64-pc-linux-gnu -fopenmp \
	   -fopenmp-targets=amdgcn-amd-amdhsa \
	   -Xopenmp-target=amdgcn-amd-amdhsa \
	   -march=$(AMD_ARCH) \
	   -fopenmp-cuda-mode 
clang-amd: $(SRCS)
	clang++ $(INCLUDES) $(LDFLAGS) $(AMDFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o amd-$(MAIN).x

#CXX=clang++ -fopenmp-version=50 -fopenmp-cuda-mode
#CXXFLAGS=-std=c++14 -O3 -target x86_64-pc-linux-gnu -fopenmp -fopenmp-targets=amdgcn-amd-amdhsa -Xopenmp-target=amdgcn-amd-amdhsa -march=$(AMD_ARCH)
#CXXFLAGS += -DOMPTARGET
##CXXFLAGS += -DDEBUG

##NVCC
#CXX=nvcc
NVCCFLAGS=--x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14
nvcc: $(SRCS)
	nvcc $(NVCCFLAGS) $(INCLUDES) $(LDFLAGS) $(DEFS) $(SRCS) -o cuda-$(MAIN).x

##NVC++ for OpenMP offloading
NVOMPFLAGS = -std=c++14 -mp=gpu -gpu=cc70 -cuda  -Minfo=accel
nv-omp: $(SRCS)
	nvc++ $(INCLUDES) $(LDFLAGS) $(NVOMPFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o nvhpc-$(MAIN).x

#CXX=nvc++
#CXXFLAGS=-std=c++14 -mp=gpu -gpu=cc70 -cuda -DOMPTARGET_MANAGED -DOMPTARGET -Minfo

##GCC
GCCFLAGS=-std=c++14 -O3 -fopenmp -foffload=nvptx-none -lcudart
gcc-omp: $(SRCS)
	g++ $(INCLUDES) $(LDFLAGS) $(GCCFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o gcc-$(MAIN).x

#CXX=g++
#CXXFLAGS=-std=c++14 -O3 -fopenmp -foffload=nvptx-none -DOMPTARGET #-DOMPTARGET_MANAGED -DDEBUG -lcudart

##CRAY CCE
CRAYFLAGS = -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=$(NVIDIA_ARCH)

cray-omp: $(SRCS)
	CC $(INCLUDES) $(LDFLAGS) $(CRAYFLAGS) $(OMPFLAGS) $(DEFS) $(SRCS) -o cray-$(MAIN).x
#CXX=CC
#CXXFLAGS=-std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=$(NVIDIA_ARCH)
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
