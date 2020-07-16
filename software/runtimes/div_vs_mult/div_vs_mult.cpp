/*
 ============================================================================
 Name        : div_runtime.c
 Author      : TS
 Version     :
 Copyright   : Your copyright notice
 Description : Written for KR to measure runtime of division
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <chrono>
#include <gmp.h>

#define NPRECS 16 	//precision of numbers in files (in bits)

int main(int argc, char *argv[]){

	using namespace std::chrono;

	int i, k;
	mpz_t *a, *b, *f, *g;                 		/* working numbers */
	gmp_randstate_t state;
	int prec[NPRECS]={100, 128, 256, 512, 1000, 1024, 2048, 4096, 8192, 10000, 65536, 100000, 524288, 1000000, 4194304, 10000000};
	int tabs[NPRECS]={1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 1000000, 100000, 100000, 10000, 10000, 1000, 1000, 100, 100};

	gmp_randinit_default (state);
	printf ("Start of computations \n");
	printf("no. \t prec \t tsize \t time_div_tab \t time_div_num \t time_mul_tab \t time_mul_num \n");

	for(i=0; i<NPRECS; i++){
		std::cout << i+1 << " \t " << prec[i] << " \t " << tabs[i] << " \t ";

		a = new mpz_t[ tabs[i] ];
		b = new mpz_t[ tabs[i] ];
		f = new mpz_t[ tabs[i] ];
		g = new mpz_t[ tabs[i] ];

		for(k=0; k<tabs[i]; k++){
			mpz_init (a[k]);
			mpz_init (b[k]);
			mpz_init (f[k]);
			mpz_init (g[k]);

			mpz_urandomb (a[k], state, prec[i]);
			mpz_urandomb (b[k], state, prec[i]);
		}

		//division
		high_resolution_clock::time_point t1 = high_resolution_clock::now();
		for(k=0; k<tabs[i]; k++){
			mpz_cdiv_q (f[k] , a[k] , b[k] );             /* f=a/b */
		}
		high_resolution_clock::time_point t2 = high_resolution_clock::now();
		duration<double> time_span = duration_cast<duration<double>>(t2 - t1);
		std::cout << time_span.count() << " \t " << time_span.count()/tabs[i] << " \t ";

		//multiplication
		t1 = high_resolution_clock::now();
		for(k=0; k<tabs[i]; k++){
			mpz_mul (g[k] , a[k] , b[k] );             /* g=a*b */
		}
		t2 = high_resolution_clock::now();
		time_span = duration_cast<duration<double>>(t2 - t1);
		std::cout << time_span.count() << " \t " << time_span.count()/tabs[i] << std::endl;

		for(k=0; k<tabs[i]; k++){
			mpz_clear (a[k]);
			mpz_clear (b[k]);
			mpz_clear (f[k]);
			mpz_clear (g[k]);
		}

		delete[] a;
		delete[] b;
		delete[] f;
		delete[] g;
	}

	printf ("Stop of computations \n");
	return EXIT_SUCCESS;
}
