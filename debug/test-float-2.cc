#include <cstdlib>
#include <stdio.h>
#include <iostream>

using namespace std;
struct vec {
  float v1;
  float v2;
};

inline  vec mult(vec x, vec y){
  vec out;
  out.v1=x.v1*y.v1;
  out.v2=x.v2*y.v2;
  printf("x.v[0]=%f, y.v[0]=%f\n",x.v1,y.v1); 
  return out;
}
int main(int argc, char* argv[]){

	int N=10;
        float x=1.0;
	float y=2.0;
	vec in1,in2;
	in1.v1=x;
	in1.v2=x;
	in2.v1=y;
	in2.v2=y;
	vec out[N];
printf("CPU calculation...\n");
	vec expected=mult(in1,in2);

printf("GPU offloading...\n");

#pragma omp target teams distribute parallel for //map(to:in1,in2) map(from:out[0:N])
	for(int n=0;n<N;n++) {
		out[n]=mult(in1,in2);
		printf("Got: %f %f\n",out[n].v1,out[n].v2);
	}
	printf("Expected: %f %f\n",expected.v1,expected.v2);

return 0;

}

