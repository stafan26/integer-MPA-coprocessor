/*
 ============================================================================
 Name        : add.cpp
 Author      : TS
 Version     :
 Copyright   : Your copyright notice
 Description : Written for KR to measure runtime of addition
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <chrono>
#include <gmp.h>

#define NPRECS 9 	//precision of numbers in files (in bits)

int main(int argc, char *argv[]){

	using namespace std::chrono;

	int i, k;
	mpz_t *a, *b, *g;                 		/* working numbers */
	gmp_randstate_t state;
	int prec[NPRECS]={128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32704};
	int tabs[NPRECS]={1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000, 1000};

	gmp_randinit_default (state);
	printf ("Start of computations \n");
	printf("no. \t prec \t tsize \t time_add_tab \t time_add_num \n");

	for(i=0; i<NPRECS; i++){
		std::cout << i+1 << " \t " << prec[i] << " \t " << tabs[i] << " \t ";

		a = new mpz_t[ tabs[i] ];
		b = new mpz_t[ tabs[i] ];
		g = new mpz_t[ tabs[i] ];

		for(k=0; k<tabs[i]; k++){
			mpz_init (a[k]);
			mpz_init (b[k]);
			mpz_init (g[k]);

			mpz_urandomb (a[k], state, prec[i]);
			mpz_urandomb (b[k], state, prec[i]);
		}

		//addition
		high_resolution_clock::time_point t1 = high_resolution_clock::now();
		for(k=0; k<tabs[i]; k++){
			mpz_add (g[k] , a[k] , b[k] );             /* g=a+b */
		}
		high_resolution_clock::time_point t2 = high_resolution_clock::now();
		duration<double> time_span = duration_cast<duration<double>>(t2 - t1);
		std::cout << time_span.count() << " \t " << time_span.count()/tabs[i] << std::endl;

		for(k=0; k<tabs[i]; k++){
			mpz_clear (a[k]);
			mpz_clear (b[k]);
			mpz_clear (g[k]);
		}

		delete[] a;
		delete[] b;
		delete[] g;
	}

	printf ("Stop of computations \n");
	return EXIT_SUCCESS;
}
