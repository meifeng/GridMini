GPUARCH=-m64 -gencode arch=compute_70,code=sm_70
MAIN=Benchmark_REAL

##xlC
#CXX=xlC_r
#CXXFLAGS=-qsmp=omp -qoffload -Ofast  -std=c++11

##PGI
#CXX=pgc++
#CXXFLAGS=-fast --c++14 -mp -Mllvm -Minfo=accel

##Clang
#CXX=clang++
CXX=/raid/data/lli/software/llvm/bin/clang++
CXXFLAGS=-std=c++14 -g -fopenmp -fopenmp-targets=nvptx64-nvidia-cuda -lcudart -Xopenmp-target -march=sm_70
CXXFLAGS += -DOMPTARGET -DOMPTARGET_MANAGED
#CXXFLAGS += -c -S -emit-llvm -mllvm -disable-llvm-optzns
CXXFLAGS += -O0 -mllvm -disable-llvm-optzns
#CXXFLAGS += -O3
#CXXFLAGS += -DVECTOR_LOOPS
#CXXFLAGS += -DDEBUG

##NVCC
#CXX=nvcc
#CXXFLAGS=--x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14

##GCC
#CXX=g++
#CXXFLAGS=-std=c++14 -O3 -fopenmp -foffload=nvptx-none -DOMPTARGET -DOMPTARGET_MANAGED -DDEBUG -lcudart


CUDA_ROOT=/usr/local/cuda-10.0
INCLUDES=-I./ -I${CUDA_ROOT}/include -I/home/lld/software/openssl-1.1.1g/include
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
                -DGEN \
                -DGEN_SIMD_WIDTH=16 \
                -DHAVE_MALLOC_H \
                -DGRID_COMMS_NONE \
                -DGRID_DEFAULT_PRECISION_DOUBLE \
                -o ${MAIN}.x \
		-DRNG_RANLUX

clean:
	rm -v *.x 
