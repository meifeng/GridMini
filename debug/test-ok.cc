#include <stdlib.h>
#include <stdio.h>

struct mydata{
 float a;
 float b;
};

inline mydata mult(mydata x, mydata y){
  mydata out;
  out.a=x.a*y.a;
  out.b=x.b*y.b;
  
  return out;
}
int main(int argc, char* argv[]){

	int N=10;
        float x=1.0;
	float y=2.0;
	mydata in1,in2;
	in1.a=x;
	in1.b=x;
	in2.a=y;
	in2.b=y;
	mydata out[N];

#pragma omp target teams distribute parallel for map(to:in1,in2) map(from:out[0:N])
	for(int n=0;n<N;n++) {
		out[n]=mult(in1,in2);
		printf("%f %f\n",out[n].a,out[n].b);
	}

return 0;

}

