
/* gcc omp_factorize_master_slave.c -o omp_factorize_master_slave   -lcrypto -lm */

/*
openssl genrsa -out rsa_key.pem 68
openssl rsa -in rsa_key.pem -modulus -noout

time ./factorize2 -m B81915BC0A2222F4B  -a 4    # modulus 68 bit - prime 34 bit (4 addr + 30 block) 
*/



#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <openssl/bn.h>
#include <math.h>
#include <omp.h>

void status() {}
void options(int argc, char * argv[]) ;
void usage(char * argv[]);
int block_factorize (unsigned long int);

BIGNUM *P, *Q, *M, *F, *ZERO,  *ONE, *TWO, *BLOCK_DIM_SIZE, *BLOCK_DIM_BIT ;
BN_CTX *ctx;
int block_idx=0, found=0, skip=0;
unsigned long int  modulus_bit, prime_bit, block_addr_bit,  block_addr_size ,  block_dim_bit , block_dim_size; 
char m[256]="";

int response, request, master_stop=0;
int thr = 4;

omp_lock_t master;
omp_lock_t slave;

int request_new_work(int t)
{
   request=t;               // slave set the request
   omp_unset_lock(&master); // request is ready: unlock master
   if(!master_stop) omp_set_lock(&slave);    // waiting fo answer from master: lock the slave
   omp_test_lock(&master);  // lock master and return 
   return (response);
}


int main(int argc, char *argv[])
{

	omp_init_lock(&master);
 	omp_init_lock(&slave);

	 omp_set_lock(&master);
 	omp_set_lock(&slave);

 	omp_set_nested(1);

        double t1, t2; // timer

        P = BN_new();     // prime number
        Q = BN_new();     // prime number
        M = BN_new();     // modulw = p x q
        F = BN_new();     // found number

        ZERO           = BN_new();  //  0
        ONE            = BN_new();  //  1
        TWO            = BN_new();  //  2
        BLOCK_DIM_BIT  = BN_new();  // quanti bit per blocco
        BLOCK_DIM_SIZE = BN_new();  // dimensione blocco
        ctx = BN_CTX_new();

        BN_set_word(ZERO,0);
        BN_set_word(ONE,1);
        BN_set_word(TWO,2);

        modulus_bit=64; // init modulus bits
        block_addr_bit  = 4;

        options(argc, argv); 

        block_addr_size = pow(2,block_addr_bit);

        if (strcmp(m,""))
        {
        BN_hex2bn(&M, m);
        modulus_bit     = strlen(m)*4;
        prime_bit       = modulus_bit/2;
        block_dim_bit   = prime_bit - block_addr_bit;
        block_dim_size  = pow(2,block_dim_bit);
        }
        else
        {
        prime_bit=modulus_bit/2;
        block_dim_bit   = prime_bit - block_addr_bit;
        block_dim_size  = pow(2,block_dim_bit);
        BN_generate_prime(P,prime_bit,1,NULL,NULL,status,NULL);
        BN_generate_prime(Q,prime_bit,1,NULL,NULL,status,NULL);
        BN_mul(M,P,Q, ctx);
        strcpy(m,BN_bn2hex(M));
        }
        BN_set_word(BLOCK_DIM_BIT,block_dim_bit);                 // bits per block
        BN_print_fp(stdout,BLOCK_DIM_BIT);
        BN_exp(BLOCK_DIM_SIZE, TWO , BLOCK_DIM_BIT,ctx);


        printf("\n# Modulus: ");
        BN_print_fp(stdout,M);
        printf(" %d bits - prime: address %d bit, block %d bit \n\n", modulus_bit, block_addr_bit, block_dim_bit );
	
	response = block_addr_size;
	
	t1 = omp_get_wtime();
	
	#pragma omp parallel num_threads(2)
	{
		#pragma omp sections
		{
			#pragma omp section //master
			{
				while(response)
				{
					omp_set_lock(&master);
					printf("#MASTER: received request from %d  resp: %d \n", request, --response);
					omp_unset_lock(&slave);
					omp_test_lock(&master);
				}
				master_stop = 1;
				printf("response is %d the Master is stopped",response);
			}
			#pragma omp section //slaves
			{	
				#pragma omp parallel num_threads(thr)
				{ 
					int block_num = 0;
					float x;
					int t = omp_get_thread_num();

					while(!master_stop)
					{	
						printf ("#SLAVE %d: calling request of work.. \n",t);
						#pragma omp critical
						block_num = request_new_work(t);
						block_factorize(block_num);
					}

					printf("Slave %d has terminated the work\n",t);

				}

				printf("Slave sections is closed\n");
			}
					
		}
	}
	        

        t2 = omp_get_wtime();     
	
	omp_destroy_lock(&master);
	omp_destroy_lock(&slave);
		
        BN_print_fp(stdout,F);
	printf("Number of bit: %d\n",modulus_bit );
	printf("Number of threads: %d\n",thr);
	printf("Total time: %.1f", t2-t1);
        printf("\n");
        return (0);
}


int block_factorize (unsigned long int block_addr)
{

              BIGNUM *R, *X, *Y, *BLOCK_IDX, *BLOCK_ADDR;
              BN_CTX *ctx2;
              ctx2 = BN_CTX_new();
              R       = BN_new();  // resto della divisione
              X       = BN_new();  // indice del  blocco
              Y       = BN_new();  // ultimo numero del  blocco
              BLOCK_IDX       = BN_new();  // ultimo numero del  blocco
              BLOCK_ADDR      = BN_new();  // Block Address

              BN_set_word(R,0);
              BN_set_word(X,1);
              BN_set_word(Y,1);
              BN_set_word(BLOCK_ADDR, block_addr);
              BN_mul(X, BLOCK_ADDR, BLOCK_DIM_SIZE,ctx2);   // x = i  block_size
              BN_add(X,X,ONE);                             // x = x+1 
              BN_add(Y,X,BLOCK_DIM_SIZE);                      // y = x + block_size
              BN_sub(Y,Y,TWO);                             // y = y - 2
              BLOCK_IDX=BN_dup(X);

              while ( ! skip  && BN_cmp(BLOCK_IDX,Y))
                {
                BN_add(BLOCK_IDX,BLOCK_IDX,TWO);
                BN_mod(R,M,BLOCK_IDX, ctx2);
                if ( BN_is_zero(R) ) 
                  { 
                    F=BN_dup(BLOCK_IDX);
                    found=1;
                    skip=1;
                  }  
               }
		
	    #pragma omp critical (print)
            {	
              printf(" Blk:");
              BN_print_fp(stdout,BLOCK_ADDR);
              printf(" ");
              BN_print_fp(stdout, X);
              printf("-");
              BN_print_fp(stdout, Y);
              if (found) {  printf (" FOUND \n");  found=0;}
              else if (skip)  printf (" skip \n"); 
              else printf (" not found \n");
	    }

              return (0);
             
}

/************************************************/
  
void options(int argc, char * argv[])
{
  int i;
   while ( (i = getopt(argc, argv, "a:t:b:m:h")) != -1) {
        switch (i)
        {
	case 't':  thr = strtol(optarg,NULL,10); break;
        case 'a':  block_addr_bit = strtol(optarg, NULL, 10);  break;
        case 'b':  modulus_bit  = strtol(optarg, NULL, 10);  break;
        case 'm':  strcpy(m,optarg);  break;
        case 'h':  usage(argv); exit(1);
        case '?':  usage(argv); exit(1);
        default:   usage(argv); exit(1);
        }
    }
}

/***************************************/

void usage(char * argv[])
{
  printf ("\n%s [-b modulus_bit] [-m modulus] [-a block_addr_bit] [-h]",argv[0]);
  printf ("\n");
}

