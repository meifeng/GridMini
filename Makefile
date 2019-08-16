GPUARCH=-m64 -gencode arch=compute_60,code=sm_60
MAIN=benchmarks/Benchmark_su3

nvcc:
	nvcc --x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14 ${MAIN}.cc Grid/util/Init.cc Grid/communicator/SharedMemory.cc Grid/communicator/SharedMemoryNone.cc Grid/allocator/AlignedAllocator.cc Grid/communicator/Communicator_base.cc Grid/communicator/Communicator_none.cc  Grid/log/Log.cc -o ${MAIN}.x -DGPU -DGEN_SIMD_WIDTH=512 -DHAVE_MALLOC_H -DGRID_COMMS_NONE -DGRID_DEFAULT_PRECISION_SINGL -DRNG_RANLUX

cpu:
	g++ -I. -std=c++14 -O3 \
		-fopenmp \
		${MAIN}.cc \
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
		-DGRID_DEFAULT_PRECISION_SINGLE \
		-DRNG_RANLUX

pgi-cpu:
	pgc++ -fast -I. --c++14 -mp -Mllvm -Minfo=accel \
		${MAIN}.cc \
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
                -DGRID_DEFAULT_PRECISION_SINGLE \
                -DRNG_RANLUX

nvcc:
	nvcc --x cu ${GPUARCH} -I. -ccbin g++ -rdc=true --expt-extended-lambda --expt-relaxed-constexpr -std=c++14 \
		${MAIN}.cc \
                Grid/util/Init.cc \
                Grid/communicator/SharedMemory.cc \
                Grid/communicator/SharedMemoryNone.cc \
                Grid/allocator/AlignedAllocator.cc \
                Grid/communicator/Communicator_base.cc \
                Grid/communicator/Communicator_none.cc  \
                Grid/log/Log.cc \
                -o ${MAIN}.x \
                -DGPU \
                -DGEN_SIMD_WIDTH=512 \
                -DHAVE_MALLOC_H \
                -DGRID_COMMS_NONE \
                -DGRID_DEFAULT_PRECISION_SINGLE \
                -DRNG_RANLUX

