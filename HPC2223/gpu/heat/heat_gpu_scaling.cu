/*
heat_gpu.cu

nvcc -O2 heat_gpu.cu -o heat_gpu

./heat_gpu -h
./heat_gpu -r 4096 -c 4096
*/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/time.h>  //gettimeofday

#define BLOCK_SIZE_X 16
#define BLOCK_SIZE_Y 16

__host__ __device__ int iDivUp(int a, int b){ return ((a % b) != 0) ? (a / b + 1) : (a / b); }

__global__ void Jacobi_Iterator_GPU(const float * __restrict__ T_old, float * __restrict__ T_new, const int NX, const int NY);
__global__ void copy_constant(float * __restrict__ T, const float * __restrict__ T_const, const int NX,  const int NY);

void options(int argc, char * argv[]) ;
void usage(char * argv[]);
void Jacobi_Iterator_CPU(float * __restrict T, float * __restrict T_new, const int NX, const int NY); 
void Init_center(float * __restrict h_T, const int NX, const int NY); // center 
void Init_left(float * __restrict h_T, const int NX, const int NY);   // left border
void Init_top(float * __restrict h_T, const int NX, const int NY);    // top border
void copy_rows(float * __restrict h_T, const int NX, const int NY);   // periodic boundary conditions
void copy_cols(float * __restrict h_T, const int NX, const int NY);   // periodic boundary conditions
void print_colormap(float * __restrict h_T);                          // 

int NX = 256;         // --- Number of discretization points along the x axis
int NY = 256;         // --- Number of discretization points along the y axis
int MAX_ITER = 1000;  // --- Number of Jacobi iterations

/********/
/* MAIN */
/********/
int main(int argc, char **argv)
{

  int iter;

  double t1, t2;
  struct timeval tempo;

  options(argc, argv);         /* optarg management */
  //fprintf (stderr,"# NX=%d, NY=%d, MAX_ITER=%d \n", NX, NY, MAX_ITER);

    // --- CPU temperature distributions
   float *h_T              = (float *)calloc(NX * NY, sizeof(float));
   Init_center(h_T,  NX, NY);
//   Init_left(h_T,    NX, NY);
    Init_top(h_T,     NX, NY);
   float *h_T_GPU_result   = (float *)malloc(NX * NY * sizeof(float));
   float *temp;

// --- GPU temperature distribution
    float *d_T;
    cudaMalloc((void**)&d_T,      NX * NY * sizeof(float));
    float *d_T_old;
    cudaMalloc((void**)&d_T_old,  NX * NY * sizeof(float));
    float *d_T_const;
    cudaMalloc((void**)&d_T_const,  NX * NY * sizeof(float));

    cudaMemcpy(d_T,     h_T, NX * NY * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_T_old, d_T, NX * NY * sizeof(float), cudaMemcpyDeviceToDevice);
    cudaMemcpy(d_T_const, d_T, NX * NY * sizeof(float), cudaMemcpyDeviceToDevice);

    // --- Grid size
    dim3 dimBlock(BLOCK_SIZE_X, BLOCK_SIZE_Y);
    dim3 dimGrid (iDivUp(NX, BLOCK_SIZE_X), iDivUp(NY, BLOCK_SIZE_Y));

///////////////////////////////


   gettimeofday(&tempo,0);  t1=tempo.tv_sec+(tempo.tv_usec/1000000.0); // get timer1

   for(iter=0; iter<MAX_ITER; iter=iter+1)
    {

    copy_constant<<<dimGrid, dimBlock>>>(d_T, d_T_const, NX, NY);
    Jacobi_Iterator_GPU<<<dimGrid, dimBlock>>>(d_T, d_T_old, NX, NY); 

    temp=d_T;
    d_T=d_T_old;
    d_T_old=temp;
    }

    gettimeofday(&tempo,0);  t2=tempo.tv_sec+(tempo.tv_usec/1000000.0); // get timer2

    // --- Copy result from device to host
    cudaMemcpy(h_T_GPU_result, d_T, NX * NY * sizeof(float), cudaMemcpyDeviceToHost);

    fprintf (stderr,"%.3f\n", t2-t1);
    //print_colormap(h_T_GPU_result);

    free(h_T);
    cudaFree(d_T);
    cudaFree(d_T_old);

    return 0;
}


/***********************************/
/* JACOBI ITERATION FUNCTION - CPU */
/***********************************/
void Jacobi_Iterator_CPU(float * __restrict T, float * __restrict T_new, const int NX, const int NY)
{
int i,j;

        // --- Only update "interior" (not boundary) node points
        for(j=1; j<NY-1; j++)
            for(i=1; i<NX-1; i++) {
                float T_E = T[(i+1) + NX*j];
                float T_W = T[(i-1) + NX*j];
                float T_N = T[i + NX*(j+1)];
                float T_S = T[i + NX*(j-1)];
                T_new[NX*j + i] = 0.25*(T_E + T_W + T_N + T_S);
            }
}

/*************
***** copy constant
************/

__global__ void copy_constant(float * __restrict__ T, const float * __restrict__ T_const, const int NX, const int NY)
{
    const int i = blockIdx.x * blockDim.x + threadIdx.x ;
    const int j = blockIdx.y * blockDim.y + threadIdx.y ;

    int P = i + j*NX;
    if(T_const[P] > 0) T[P] = T_const[P];              // copia punti a temperatura costante

    if (j==0)           T[NX*0+i]=     T[NX*(NY-2)+i]; // copia penultima riga nella prima
    if (j==(NY-1))      T[NX*(NY-1)+i]=T[(NX*1)+i];    // copia seconda riga nell'ultima riga
    if (i==0)           T[NX*j+0]=     T[NX*j+NX-2];   // copia penultima colonna nella prima
    if (i==(NX-1))      T[NX*j+(NX-1)]=T[(NX*j)+1];    // copia seconda colonna nell'ultima

}


/***********************************/
/* JACOBI ITERATION FUNCTION - GPU */
/***********************************/
__global__ void Jacobi_Iterator_GPU(const float * __restrict__ T_old, float * __restrict__ T_new, const int NX, const int NY)
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
    /// Update
    T_new[P] = 0.25 * (T_old[E] + T_old[W] + T_old[N] + T_old[S]);
}


/********************************/
/* TEMPERATURE INITIALIZATION : */
/* parte centrale della griglia */
/********************************/
void Init_center(float * __restrict h_T, const int NX, const int NY)
{
    int i,j;
    int startx=NX/2-NX/10;
    int endx=NX/2+NX/10;
    int starty=NY/2-NY/10;
    int endy=NY/2+NY/10;
//    int starty=NY/4;
//    int endy=NY-NY/4;
    for(i=startx; i<endx; i++)
        for(j=starty; j<endy; j++)
              h_T[NX*j + i] = 1.0;
}


/********************************/
/* TEMPERATURE INITIALIZATION : */
/* bordo sinistro               */
/********************************/
void Init_left(float * __restrict h_T, const int NX, const int NY)
{

    int i,j;
    int startx=1;
    int endx=2;
    int starty=0;
    int endy=NY-1;
    for(i=startx; i<endx; i++)
        for(j=starty; j<endy; j++)
              h_T[NX*j + i] = 1.0;
}


/********************************/
/* TEMPERATURE INITIALIZATION : */
/* bordo alto                   */
/********************************/
void Init_top(float * __restrict h_T, const int NX, const int NY)
{

    int i;
    int startx=0;
    int endx=NX-1;
    for(i=startx; i<endx; i++)
              h_T[NX + i] = 1.0;
}


/********************************/
/* Periodic boundary conditions */
/* COPY BORDER: COLS            */
/********************************/
void copy_cols (float * __restrict h_T, const int NX, const int NY)
{

int i;

// copy cols
  for (i = 1; i < NY-1; ++i) {
    h_T[NX*i+0]    = h_T[NX*i+NX-2];
    h_T[NX*i+NX-1] = h_T[NX*i+1];
  }
}



/********************************/
/* Periodic boundary conditions */
/* COPY BOREDER: ROWS           */
/********************************/
void copy_rows (float * __restrict h_T, const int NX, const int NY)
{

   memcpy(&(h_T[NX*0])      ,&(h_T[NX*(NY-2)]), NX*sizeof(float) );
   memcpy(&(h_T[NX*(NY-1)]) ,&(h_T[NX*1]),      NX*sizeof(float) );
}




/******************************************/
/* print color map                        */
/******************************************/

void print_colormap(float * __restrict h_T)
{
   int i,j;

   for (j=1; j<NY-1; j++){
        for (i=1; i<NX-1; i++) {
            printf("%2.2f ",h_T[NX*j + i]);
        }
        printf("\n");
        }
}


/******************************************/
/* options management                     */
/******************************************/
void options(int argc, char * argv[]) {

  int i;
   while ( (i = getopt(argc, argv, "c:r:s:h")) != -1) {
        switch (i) {
        case 'c':  NX       = strtol(optarg, NULL, 10);  break;
        case 'r':  NY       = strtol(optarg, NULL, 10);  break;
        case 's':  MAX_ITER = strtol(optarg, NULL, 10);  break;
        case 'h':  usage(argv); exit(1);
        case '?':  usage(argv); exit(1);
        default:   usage(argv); exit(1);
        }
    }
}

/******************************************/
/* print help                             */
/******************************************/
void usage(char * argv[])  {

  printf ("\n%s [-c ncols] [-r nrows] [-s nsteps] [-h]",argv[0]);
  printf ("\n");

}

