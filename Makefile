GPUARCH=-m64 -gencode arch=compute_70,code=sm_70
MAIN=Benchmark_STREAM

##xlC
#CXX=xlC_r
#CXXFLAGS=-qsmp=omp -qoffload -Ofast  -std=c++11 -g -DOMPTARGET -DOMPMANAGED # -DDEBUG

##PGI
#CXX=pgc++
#CXXFLAGS=-fast --c++14 -mp -Mllvm -Minfo=accel

##Clang
#CXX=clang++
#CXXFLAGS=-std=c++11 -v -fopenmp -O3 -fopenmp-targets=nvptx64 -lcudart -DOMPTARGET -DOMPMANAGED
#CXXFLAGS=-std=c++11 -v -fopenmp -O3 -Xopenmp-target -march=sm_70 -fopenmp-targets=nvptx64-nvidia-cuda -lcudart -DOMPTARGET -DOMPMANAGED
	#-Xcuda-ptxas -maxregcount=64

##NVCC
#CXX=nvcc
#CXXFLAGS=--x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14

##GCC
CXX=g++
CXXFLAGS=-std=c++14 -O3 -fopenmp -foffload=nvptx-none


INCLUDES=-I./ -I${OLCF_CUDA_ROOT}/include
LDFLAGS=-L${OLCF_CUDA_ROOT}/lib64
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
                -DGPU_VEC \
                -DGEN_SIMD_WIDTH=16 \
                -DHAVE_MALLOC_H \
                -DGRID_COMMS_NONE \
                -DGRID_DEFAULT_PRECISION_DOUBLE \
                -DRNG_RANLUX  

clean:
	rm -v *.x *.o
