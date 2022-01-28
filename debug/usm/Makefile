CLANG_CXXFLAGS=-std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda
SRCS=$(wildcard *.cc)

%.x: $(SRCS)
icpx:

	icpx -std=c++14 -O3 -fiopenmp -fopenmp-targets=spir64 test-float.cc -o test-float.x
	icpx -std=c++14 -O3 -fiopenmp -fopenmp-targets=spir64 test.cc -o test.x
clang: 
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test.cc -o test.x

nvhpc:
	nvc++ -std=c++14 -mp=gpu -gpu=cc70 -Minfo test.cc -o test.x 

cray:
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test.cc -o cray-test.x
#	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-2.cc -o cray-test-2.x
#	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float.cc -o cray-test-float.x
#	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float-2.cc -o cray-test-float-2.x
#	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float-class.cc -o cray-test-float-class.x
#	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float-pointer.cc -o cray-test-float-pointer.x


clean:
	rm -v *.x 
