// gcc -fopenmp omp_master-slave.c -o omp_master-slave

#include <stdio.h>
#include <omp.h>

int main(int argc, char* argv[])
{
 int i;

 omp_set_nested(1);

 #pragma omp parallel private(i) num_threads(2)
 {
  #pragma omp sections
    {
       #pragma omp section   // MASTER
         {
          printf("Master %d/%d \n",omp_get_thread_num(),omp_get_num_threads() );
         }
       #pragma omp section  // SLAVES
         {
         #pragma omp parallel for num_threads(8)  // nested parallel region
         for(i = 0; i < 8; i++)
           printf("Thr %d/%d : %d \n",omp_get_thread_num(),omp_get_num_threads(),i);
         }

    } // end sections 
  } // end parallel 
}


