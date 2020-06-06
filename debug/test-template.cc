#include <cstdlib>
#include <stdio.h>
#include <iostream>

using namespace std;
template <typename T>
struct vec {
  T v[2];
};

inline template <typename T> vec<T> mult(vec<T> x, vec<T> y){
  vec<T> out;
  out.v[0]=x.v[0]*y.v[0];
  out.v[1]=x.v[1]*y.v[1];
  printf("x.v[0]=%f, y.v[0]=%f\n",x.v[0],y.v[0]); 
  return out;
}
int main(int argc, char* argv[]){

	int N=10;
        float x=1.0;
	float y=2.0;
	vec<float> in1,in2;
	in1.v[0]=x;
	in1.v[1]=x;
	in2.v[0]=y;
	in2.v[1]=y;
	vec<float> out[N];
printf("CPU calculation...\n");
	vec<float> expected=mult(in1,in2);

printf("GPU offloading...\n");

#pragma omp target teams distribute parallel for //map(to:in1,in2) map(from:out[0:N])
	for(int n=0;n<N;n++) {
		out[n]=mult(in1,in2);
		printf("Got: %f %f\n",out[n].v[0],out[n].v[1]);
	}
	printf("Expected: %f %f\n",expected.v[0],expected.v[1]);

return 0;

}

