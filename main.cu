/******************************************************************************
 *cr
 *cr            (C) Copyright 2010 The Board of Trustees of the
 *cr                        University of Illinois
 *cr                         All Rights Reserved
 *cr
 ******************************************************************************/

#include <stdio.h>
#include "support.h"
// extern declaration needed because kernel function is defined in a different file
extern __global__ void vecAddKernel(float* A, float* B, float* C, int n);

int main(int argc, char**argv) {

    Timer timer;
    cudaError_t cuda_ret;

    // Initialize host variables ----------------------------------------------

    printf("\nSetting up the problem..."); fflush(stdout);
    startTime(&timer);

    unsigned int n;
    if(argc == 1) {
        n = 10000;
    } else if(argc == 2) {
        n = atoi(argv[1]);
    } else {
        printf("\n    Invalid input parameters!"
           "\n    Usage: ./vecadd               # Vector of size 10,000 is used"
           "\n    Usage: ./vecadd <m>           # Vector of size m is used"
           "\n");
        exit(0);
    }

    float* A_h = (float*) malloc( sizeof(float)*n );
    for (unsigned int i=0; i < n; i++) { A_h[i] = (rand()%100)/100.00; }

    float* B_h = (float*) malloc( sizeof(float)*n );
    for (unsigned int i=0; i < n; i++) { B_h[i] = (rand()%100)/100.00; }

    float* C_h = (float*) malloc( sizeof(float)*n );

    stopTime(&timer);
    printf("%f s\n", elapsedTime(timer));
    printf("    Vector size = %u\n", n);

    // Allocate device variables ----------------------------------------------

    printf("Allocating device variables..."); fflush(stdout);
    startTime(&timer);

    //INSERT CODE HERE
    float *d_A, *d_B, *d_C;
    // ---- end
    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("%f s\n", elapsedTime(timer));

    // Copy host variables to device ------------------------------------------

    printf("Copying data from host to device..."); fflush(stdout);
    startTime(&timer);

    //INSERT CODE HERE
    int size = sizeof(float)*n;
    cudaMalloc((void **) &d_A, size);
    cudaMemcpy(d_A, A_h, size, cudaMemcpyHostToDevice);
    cudaMalloc((void **) &d_B, size);
    cudaMemcpy(d_B, B_h, size, cudaMemcpyHostToDevice);    

    cudaMalloc((void **) &d_C, size);    
    // ---- end

    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("%f s\n", elapsedTime(timer));

    // Launch kernel ----------------------------------------------------------

    printf("Performing CUDA computation via kernel..."); fflush(stdout);
    startTime(&timer);

    //INSERT CODE HERE
    vecAddKernel<<<ceil(n/256.0), 256>>>(d_A, d_B, d_C, n);

    cuda_ret = cudaDeviceSynchronize();
	if(cuda_ret != cudaSuccess) FATAL("Unable to launch kernel");
    stopTime(&timer);
    printf("%f s\n", elapsedTime(timer));

    // Copy device variables from host ----------------------------------------

    printf("Copying data from device to host..."); fflush(stdout);
    startTime(&timer);

    //INSERT CODE HERE
    cudaMemcpy(C_h, d_C, size, cudaMemcpyDeviceToHost);
    // ---- end

    cudaDeviceSynchronize();
    stopTime(&timer);
    printf("%f s\n", elapsedTime(timer));

    // Verify correctness -----------------------------------------------------

    printf("Verifying results..."); fflush(stdout);

    verify(A_h, B_h, C_h, n);

    // Free memory ------------------------------------------------------------

    free(A_h);
    free(B_h);
    free(C_h);

    //INSERT CODE HERE to free device-side arrays

    cudaFree(d_A);
    cudaFree(d_B);
    cudaFree(d_C);

    return 0;

}
