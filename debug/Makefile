CLANG_CXXFLAGS=-std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda
SRCS=$(wildcard *.cc)

%.x: $(SRCS)
clang: 
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-template.cc -o test-template.x
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-template-2.cc -o test-template-2.x
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float.cc -o test-float.x
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float-2.cc -o test-float-2.x
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float-class.cc -o test-float-class.x
	clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float-pointer.cc -o test-float-pointer.x


cray:
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-template.cc -o cray-test-template.x
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-template-2.cc -o cray-test-template-2.x
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float.cc -o cray-test-float.x
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float-2.cc -o cray-test-float-2.x
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float-class.cc -o cray-test-float-class.x
	CC -std=c++14 -fopenmp -fopenmp-targets=nvptx64 -Xopenmp-target -march=sm_70 test-float-pointer.cc -o cray-test-float-pointer.x


clean:
	rm -v *.x 
