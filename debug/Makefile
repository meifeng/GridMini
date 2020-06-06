CLANG_CXXFLAGS=-std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda
%.x: %.cc
clang: 
	clang++ ${CLANG_CXXFLAGS} $^ -o $@
	#clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-template.cc -o test-template.x
	#clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-template-2.cc -o test-template-2.x
	#clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float.cc -o test-float.x
	#clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float-2.cc -o test-float-2.x
	#clang++ -std=c++14 -g -fopenmp -O3 -fopenmp-targets=nvptx64-nvidia-cuda test-float-class.cc -o test-float-class.x


cray:

clean:
	rm -v *.x 
