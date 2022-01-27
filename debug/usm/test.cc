#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#define SIZE 1024
#pragma omp requires unified_shared_memory
int main() {
int deviceId = (omp_get_num_devices() > 0) ? omp_get_default_device() : omp_get_initial_device();
//int *a = (int *)omp_target_alloc(SIZE, deviceId);
//int *b = (int *)omp_target_alloc(SIZE, deviceId);

int *a = (int *)malloc(SIZE*sizeof(int));
int *b = (int *)malloc(SIZE*sizeof(int));
for (int i = 0; i < SIZE; i++) {
a[i] = i; b[i] = SIZE - i;
}
#pragma omp target teams distribute parallel for //map(tofrom:a[:SIZE]) map(to:b[:SIZE])  //is_device_ptr(a,b)
for (int i = 0; i < SIZE; i++) {
a[i] += b[i];
}
for (int i = 0; i < SIZE; i++) {
if (a[i] != SIZE) {
printf("%s failed\na[%d]=%d\n", __func__,i,a[i]); return EXIT_FAILURE;
}
}
//omp_target_free(a, deviceId);
//omp_target_free(b, deviceId);
printf("%s passed\n", __func__);
return EXIT_SUCCESS;
}
