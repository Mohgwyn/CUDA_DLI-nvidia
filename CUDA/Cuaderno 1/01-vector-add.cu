#include <stdio.h>

void initWith(float num, float *a, int N)
{
  for(int i = 0; i < N; ++i)
  {
    a[i] = num;
  }
}

__global__ void addVectorsInto(float *result, float *a, float *b, int N)
{

  int idx = blockDim.x*blockIdx.x + threadIdx.x;
  if (idx < N) {
    result[idx] = a[idx] + b[idx];
  }
      
}

void checkElementsAre(float target, float *array, int N)
{
  for(int i = 0; i < N; i++)
  {
    if(array[i] != target)
    {
      printf("FAIL: array[%d] - %0.0f does not equal %0.0f\n", i, array[i], target);
      exit(1);
    }
  }
  printf("SUCCESS! All values added correctly.\n");
}

int main()
{
  const int N = 2<<20;
  size_t size = N * sizeof(float);

  float *a;
  float *b;
  float *c;

  cudaMallocManaged(&a,size);
  cudaMallocManaged(&b,size);
  cudaMallocManaged(&c,size);
    
  initWith(3, a, N);
  initWith(4, b, N);
  initWith(0, c, N);

  int N_threads = 256;
  int N_blocks = ((N/N_threads) + 1);
    
  addVectorsInto<<<N_blocks,N_threads>>>(c, a, b, N);
  cudaDeviceSynchronize();

  checkElementsAre(7, c, N);

  cudaFree(a);
  cudaFree(b);
  cudaFree(c);
}
