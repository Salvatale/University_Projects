#include "mpi.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <math.h> 

#define BLOCK_SIZE_X 16
#define BLOCK_SIZE_Y 16


__host__ __device__ int iDivUp(int a, int b){ return ((a % b) != 0) ? (a / b + 1) : (a / b); }

/***********************************/
/* JACOBI ITERATION FUNCTION - GPU */
/***********************************/
__global__ void Jacobi_Iterator_GPU(const float * __restrict__ T_old, float * __restrict__ T_new, const int NX, const int NY, float* recv, int rank)
{
    const int i = blockIdx.x * blockDim.x + threadIdx.x ;
    const int j = blockIdx.y * blockDim.y + threadIdx.y ;

    int left=i-1;
    int right=i+1;
    int up=j+1;
    int down=j-1;
    if (left<0) left=0;
    if (right>=gridDim.x*blockDim.x) right--;
    if (down<0) down=0;
    if (up>=gridDim.y*blockDim.y) up--; 
                              //                         N 
    int P = i + j*NX;         // node (i,j)              |
    int N = i + up*NX;        // node (i,j+1)            |
    int S = i + down*NX;      // node (i,j-1)     W ---- P ---- E
    int E = right + j*NX;     // node (i+1,j)            |
    int W = left + j*NX;      // node (i-1,j)            |
                              //                         S 
    float upv;
    if (rank==0 && j==NY-1) /// bordo alto -> N viene letto da recv
      upv=recv[i];
    else
      upv=T_old[N];
    float downv;
    if (rank==1 && j==0) /// bordo basso -> S viene letto da recv
      downv=recv[i];
    else
      downv=T_old[S];

    /// Update
    T_new[P] = 0.25 * (T_old[E] + T_old[W] + upv + downv);
}
/*************
***** copy constant
************/

__global__ void copy_constant(float * __restrict__ T, const float * __restrict__ T_const, const int NX, const int NY)
{
    const int i = blockIdx.x * blockDim.x + threadIdx.x ;
    const int j = blockIdx.y * blockDim.y + threadIdx.y ;

    int P = i + j*NX;

    /// Update
    float temp=T_const[P];
    if (temp>0)
       T[P] = temp;
}


//// questo kernel funziona con 1 blocco <=1024 thread
//// adattarlo per funzionare con piu' blocchi (es. NX=2048)
__global__ void copy_send(int base,float* d_t,float* d_send){

  /// P e' l'indice lineare sulla riga della matrice
  /// per ricavare la posizione, in caso di piu' blocchi,
  /// e' necessario costruire la linearizzazione come nei kernel sopra
  /// P = blockIdx.x*blockDim.x + threadIdx.x


  int P= threadIdx.x + base;

  d_send[threadIdx.x]=d_t[P];
}


/******************************/
/* TEMPERATURE INITIALIZATION */
/******************************/
void Initialize(float * __restrict h_T, const int NX, const int NY, int rank)
{
   int startx,starty,endx,endy;
	if (rank==0){
    startx=NX/2-NX/10;
    endx=NX/2+NX/10; 
    starty=NY/4;
    endy=NY-2; 
    }
    else{
    startx=NX/4-NX/10;
    endx=NX/4+NX/10; 
    starty=2;
    endy=NY-NY/4;     
    }
    for(int i=startx; i<endx; i++) 
        for(int j=starty; j<endy; j++) 
              h_T[i+j * NX] = 1.0;

}


void go(int rank, int rank_node){


    /// assuming two ranks
    /// y doubled, bottom part (y=0..NY-1) -> rank 0, top part (y=NY..2*NY-1) -> rank 1
 
    const int NX = 1024;         // --- Number of discretization points along the x axis
    const int NY = 1024;         // --- Number of discretization points along the y axis

    const int MAX_ITER = 100000;     // --- Number of Jacobi iterations

    // --- CPU temperature distributions
    float *h_T              = (float *)calloc(NX * NY, sizeof(float));
    Initialize(h_T,     NX, NY, rank);
    float *h_T_GPU_result   = (float *)malloc(NX * NY * sizeof(float));

    /// exchange buffer
    float *h_send   = (float *)malloc(NX * sizeof(float));
    float *h_recv   = (float *)malloc(NX * sizeof(float));

    // --- GPU temperature distribution
    float *d_T;     
    cudaMalloc((void**)&d_T,      NX * NY * sizeof(float));
    float *d_T_old; 
    cudaMalloc((void**)&d_T_old,  NX * NY * sizeof(float));
    float *d_T_const;     
    cudaMalloc((void**)&d_T_const,  NX * NY * sizeof(float));

    /// exchange buffer on gpu
    float *d_send;     
    cudaMalloc((void**)&d_send,  NX * sizeof(float));
    float *d_recv;     
    cudaMalloc((void**)&d_recv,  NX * sizeof(float));

    cudaMemcpy(d_T,     h_T, NX * NY * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_T_old, d_T, NX * NY * sizeof(float), cudaMemcpyDeviceToDevice);
    cudaMemcpy(d_T_const, d_T, NX * NY * sizeof(float), cudaMemcpyDeviceToDevice);

    // --- Grid size
    dim3 dimBlock(BLOCK_SIZE_X, BLOCK_SIZE_Y);
    dim3 dimGrid (iDivUp(NX, BLOCK_SIZE_X), iDivUp(NY, BLOCK_SIZE_Y));

    double average_mpi=0;

    // --- Jacobi iterations on the device
    for (int k=0; k<MAX_ITER; k++) {
        copy_constant<<<dimGrid, dimBlock>>>(d_T,     d_T_const, NX, NY);   // --- Update d_T with constant data >0 stored in d_T_const

	// copy from matrix to send buffer (NX<=1024)
	int base; /// prepara la posizione iniziale 
	    	  /// nella matrice della riga da copiare su ram per la spedizione
	if (rank==0) base=(NY-1)*NX;
	else base=NY;

	/// se NX>1024 non ci sono abbastanza thread nel blocco!
        /// sostituire 1 con il calcolo simile a dimGrid per gestire NX thread a gruppi di 1024 thread
        /// l'equivalente di dimBlock diventa 1024 se NX>=1024 oppure NX se NX<1024
	copy_send<<<1,NX>>>(base,d_T,d_send);
	 
	// gpu -> cpu
	cudaMemcpy(h_send,d_send,NX*sizeof(float),cudaMemcpyDeviceToHost);

        double a=MPI_Wtime();
	MPI_Sendrecv(h_send,NX,MPI_FLOAT,1-rank,0,
		     h_recv,NX,MPI_FLOAT,1-rank,0,
		     MPI_COMM_WORLD,MPI_STATUS_IGNORE);
	double b=MPI_Wtime();
        average_mpi+=b-a;
	
	/// cpu -> gpu
	cudaMemcpy(d_recv,h_recv,NX*sizeof(float),cudaMemcpyHostToDevice);

        Jacobi_Iterator_GPU<<<dimGrid, dimBlock>>>(d_T,     d_T_old, NX, NY,d_recv,rank);   // --- Update d_T_old     starting from data stored in d_T
	float* temp;
	temp=d_T;
	d_T=d_T_old;
	d_T_old=temp;
    }

    // --- Copy result from device to host
    cudaMemcpy(h_T_GPU_result, d_T, NX * NY * sizeof(float), cudaMemcpyDeviceToHost);


  char name[256];
  sprintf(name,"test-%d.txt",rank);
  FILE* f=fopen(name,"w+");
    for (int j=0; j<NY; j++){
        for (int i=0; i<NX; i++) {
	    fprintf(f,"%2.2f ",h_T_GPU_result[j * NX + i]);
        }
	fprintf(f,"\n");
	}
  fclose(f);

    printf("Rank %d: average MPI communication time: %f mS\n",rank,1000*average_mpi/MAX_ITER);

    // --- Release host memory 
    free(h_T);
    free(h_T_GPU_result);

    // --- Release device memory
    cudaFree(d_T);
    cudaFree(d_T_old);









}

int stringCmp( const void *a, const void *b)
{
  return strcmp((char*)a,(char*)b);
}

 int main(int argc, char *argv[])
 {
 
 MPI_Init(&argc,&argv);

 char     host_name[MPI_MAX_PROCESSOR_NAME];
 char (*host_names)[MPI_MAX_PROCESSOR_NAME];
 MPI_Comm nodeComm;
 int  n, namelen, color, rank, nprocs;
 int rank_node, gpu_per_node; /// sul singolo nodo
 size_t bytes;
 int dev;
 struct cudaDeviceProp deviceProp;

 MPI_Comm_rank(MPI_COMM_WORLD, &rank);
 MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
 MPI_Get_processor_name(host_name,&namelen);

 bytes = nprocs * sizeof(char[MPI_MAX_PROCESSOR_NAME]);
 host_names = (char (*)[MPI_MAX_PROCESSOR_NAME]) malloc(bytes);

 strcpy(host_names[rank], host_name);
 for (n=0; n<nprocs; n++){
   MPI_Bcast(&(host_names[n]),MPI_MAX_PROCESSOR_NAME, MPI_CHAR, n, MPI_COMM_WORLD);
 }

 qsort(host_names, nprocs,  sizeof(char[MPI_MAX_PROCESSOR_NAME]), stringCmp);

 color = 0; /// linearizzazione dei processi su nodo uguale

 for (n=0; n<nprocs; n++){
   if(n>0&&strcmp(host_names[n-1], host_names[n])) color++;
   if(strcmp(host_name, host_names[n]) == 0) break;
 }

 if (rank==0){
   printf("Elenco ordinato rank -> host\n");
   
   for (n=0; n<nprocs; n++){
     printf("visione rank %d -> host %d %s\n",rank, n,host_names[n]);
   }
 }

 printf("rank %d -> colore %d\n",rank,color);

 MPI_Comm_split(MPI_COMM_WORLD, color, 0, &nodeComm);

 /// calcola rank sul singolo nodo (nodeComm)
 MPI_Comm_rank(nodeComm, &rank_node);
 MPI_Comm_size(nodeComm, &gpu_per_node);

 /* Find out how many DP capable GPUs are in the system and their device number */
 int deviceCount,slot=0;
 int *devloc;
 cudaGetDeviceCount(&deviceCount);
 devloc=(int *)malloc(deviceCount*sizeof(int));
 devloc[0]=999;

 printf("Sono host %s, rank %d: vedo %d GPU, rank nel nodo %d\n",host_name,rank,deviceCount,rank_node);
 if (deviceCount<rank_node){
   printf("Warning: sul nodo sono previste meno GPU di rank!\n");
 }

 for (dev = 0; dev < deviceCount; ++dev)
   {
     cudaGetDeviceProperties(&deviceProp, dev);
     if(deviceProp.major>1){
	 //printf("    --> rank %d (rank %d sul nodo): ct %d gpu %d\n",rank,rank_node,slot, dev);
	 devloc[slot]=dev;
	 slot++;
       };
   }
 // printf (" host %s rank nodo %d: Assigning device %d\n",	 host_name,rank_node, devloc[rank_node] );
 /* Assign device to MPI process and probe device properties */
 cudaSetDevice(devloc[rank_node]);
 cudaGetDevice(&dev);
 cudaGetDeviceProperties(&deviceProp, dev);
 size_t free_bytes, total_bytes;
 cudaMemGetInfo(&free_bytes, &total_bytes);
 printf("Host: %s Rank=%d RankNode=%d Device= %d (%s)  ECC=%s  Free = %lu, Total = %lu\n",host_name,rank, rank_node, devloc[rank_node],deviceProp.name, deviceProp.ECCEnabled ? "Enabled " : "Disabled", (unsigned long)free_bytes, (unsigned long)total_bytes);


 go(rank,rank_node);

 MPI_Finalize();
 }
