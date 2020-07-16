/*
 ============================================================================
Name        : factorial_runtime.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Factorial computations in MPA on SRUP
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <gmp.h>
#include <time.h>

/** Speed test parameters **/
#define REPF	10
#define N_MIN	100
#define N_MAX	1000
#define N_STEP	100

#define FULLMPAIMPL

/** Indexing and unsigned integer variables. */
#define float_t double
typedef unsigned int uint_t;
typedef unsigned long ulong_t;
typedef unsigned long long ulonglong_t;
typedef int int_t;
typedef long long_t;
typedef long long longlong_t;

//============================================================================
void pownn_mpa(mpz_t rop, uint_t n) {

uint_t i;

mpz_t mult;

	mpz_init_set_ui (mult, (unsigned long int) n);
	mpz_set_ui (rop, (unsigned long int) n);
	for (i = 2; i <= n; i++) {
		mpz_mul (rop, rop, mult);
	}
	mpz_clears (mult, NULL);
}
//============================================================================
void pownn_speed_test() {

uint_t n, k;
mpz_t result;
clock_t	start, stop;//time measurement
float_t	runtime;

	printf("//============================================================================\n");
    printf("Argument\t\tAverage Runtime (sec)\n");
	for(n=N_MIN; n<=N_MAX; n+=N_STEP) {
		mpz_init (result);

		start=clock();//start timer
		for(k=0; k<REPF; k++) {
			pownn_mpa(result, n);
			//printf(".");
			//gmp_printf ("%Zd\n", result);
		}
		stop=clock();//stop timer
	    //printf("\n");
		runtime=((float_t)(stop-start))/((float_t)(CLOCKS_PER_SEC))/((float_t)(REPF));
		printf("%d\t\t\t%f\n", n, runtime);

		mpz_clear (result);
	}
	printf("//============================================================================\n");
}
//============================================================================
int main(void) {

	pownn_speed_test();
	return 0;
}
//============================================================================
