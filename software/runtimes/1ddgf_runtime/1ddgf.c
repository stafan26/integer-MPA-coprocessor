/*
 ============================================================================
 Name        : 1ddgf.c
 Author      :
 Version     :
 Copyright   :
 Description : 1d dgf formula
 ============================================================================
 */
#include "1ddgf.h"
//#include "settings.h"
#include <limits.h>
#include <gmp.h>
#include <math.h>

//#define TRIV_SOL
#define MPAPREC

//============================================================================
//function code from wikipedia
//============================================================================
uint_t binomial_std(uint_t n, uint_t k) {

uint_t c = 1, i;

	if (k > n-k) k = n-k;  /* take advantage of symmetry */

	for (i = 1; i <= k; i++, n--) {
	    if (c/i > UINT_MAX/n) return 0;  /* return 0 on overflow */
	    c = c/i * n + c%i * n / i;  /* split c*n/i into (c/i*i + c%i)*n/i */
	}
	return c;
}
//============================================================================
int_t scalar_dgf_cflf1_std(uint_t n, uint_t k) {

uint_t m;
int_t out;
int_t sign;

	if(n<=k) {
		out=0;
	} else {
		out=0;
		for(m=k; m<n; m++) {
			sign= (m+k)%2 ? -1 : 1;
			out+=binomial_std(m+n,2*m+1)*binomial_std(2*m, m+k)*sign;
		}
	}
	return out;
}
//============================================================================
void binomial_mpa(mpz_t rop, uint_t n, uint_t k) {

uint_t i;
mpz_t q, r;
mpz_t part1, part2;

	mpz_init_set_ui (rop, 1);
	mpz_inits (q, r, part1, part2, NULL);

	if (k > n-k) k = n-k;  /* take advantage of symmetry */

	for (i = 1; i <= k; i++, n--) {
	    //like in C above: c = c/i * n + c%i * n / i;  /* split c*n/i into (c/i*i + c%i)*n/i */
		mpz_cdiv_qr_ui (q, r, rop, (unsigned long int) i);
		mpz_mul_ui (part1, q, (unsigned long int) n);
		mpz_mul_ui (q, r, (unsigned long int) n);
		mpz_cdiv_q_ui (part2, q, (unsigned long int) i);
		mpz_add (rop, part1, part2);
	}

	mpz_clears (q, r, part1, part2, NULL);
}
//============================================================================
int_t scalar_dgf_cflf1_mpa(uint_t n, uint_t k) {

uint_t m;
int_t out;
mpz_t b1, b2;
mpz_t tmp, result;

	if(n<=k) {
		out=0;
	} else {
		mpz_inits (b1, b2, tmp, result, NULL);
		for(m=k; m<n; m++) {
			binomial_mpa(b1, m+n,2*m+1);
			binomial_mpa(b2, 2*m, m+k);
			mpz_mul (tmp, b1, b2);
			if ((m+k)%2)//odd
				mpz_sub (result, result, tmp);
			else//even
				mpz_add (result, result, tmp);
		}
		out=mpz_get_ui (result);
		mpz_clears (b1, b2, tmp, result, NULL);
	}
	return out;
}
//============================================================================
void table_gen_cflf1_mpamem(uint_t n, uint_t k, mpz_t *tab1, mpz_t *tab2) {

uint_t tab1_idx, tab2_idx;
uint_t m;

	tab1_idx = 0;
	tab2_idx = 0;

	if(n<=k) {
		fprintf(stderr, "Wrong input settings in table_gen_cflf1_mpamem\n");
		exit(1);
	} else {
		for(m=k; m<n; m++) {
			binomial_mpa(tab1[tab1_idx++], m+n,2*m+1);
			binomial_mpa(tab2[tab2_idx++], 2*m, m+k);
		}
	}
}
//============================================================================
void scalar_dgf_cflf1_mpamem(uint_t n, uint_t k, mpz_t *tab1, mpz_t *tab2, mpz_t result) {

uint_t tab1_idx, tab2_idx;
uint_t m;
//mpz_t b1, b2;
mpz_t tmp;

	tab1_idx = 0;
	tab2_idx = 0;

	mpz_set_ui (result, (unsigned long int) 0);
	if(n>k) {
		//mpz_inits (b1, b2, tmp, result, NULL);
		mpz_inits (tmp, NULL);
		for(m=k; m<n; m++) {
			//now in tab1[tab1_idx++];//binomial_mpa(b1, m+n,2*m+1);
			//now in tab2[tab2_idx++];//binomial_mpa(b2, 2*m, m+k);
			mpz_mul (tmp, tab1[tab1_idx++], tab2[tab2_idx++]);
			if ((m+k)%2)//odd
				mpz_sub (result, result, tmp);
			else//even
				mpz_add (result, result, tmp);
		}
//		out=mpz_get_ui (result);
		//mpz_clears (b1, b2, tmp, result, NULL);
		mpz_clears (tmp, NULL);
	}
	//return out;
}
//============================================================================
int_t scalar_dgf_cflf1(uint_t n, uint_t k) {

int_t out;

#ifdef TRIV_SOL
	if(n<=k) {
		out=0;
	} else {
		out=(n+k)%2;
	}
#else

#ifdef MPAPREC
//-------------MPA-------------
	out=scalar_dgf_cflf1_mpa(n, k);
#else
//-------------STD-------------
	out=scalar_dgf_cflf1_std(n, k);
#endif

#endif
	return out;
}
//============================================================================
float_t dgf_ee_cflf1(uint_t n, uint_t k, float_t dt, float_t dz) {

float_t out;
float_t gl, gr;

	gl=scalar_dgf_cflf1(n, k);
	gr= n>=1 ? scalar_dgf_cflf1(n-1, k) : 0;
	out=-dt/eps0_const*( gl-gr );

	return out;
}
//============================================================================
float_t dgf_eh_cflf1(uint_t n, uint_t k, float_t dt, float_t dz) {

float_t out;
float_t gl, gr;

	gl=scalar_dgf_cflf1(n, k);
	gr= k>=1 ? scalar_dgf_cflf1(n, k-1) : 0;
	out=dz*( gl-gr );

	return out;
}
//============================================================================
float_t dgf_he_cflf1(uint_t n, uint_t k, float_t dt, float_t dz) {

float_t out;
float_t gl, gr;

	gl=scalar_dgf_cflf1(n, k+1);
	gr=scalar_dgf_cflf1(n, k);
	out=dz*( gl-gr );

	return out;
}
//============================================================================
float_t dgf_hh_cflf1(uint_t n, uint_t k, float_t dt, float_t dz) {

float_t out;
float_t gl, gr;

	gl=scalar_dgf_cflf1(n+1, k);
	gr=scalar_dgf_cflf1(n, k);
	out=-dt/mu0_const*( gl-gr );

	return out;
}
//============================================================================
void dgfjg_ee(uint_t nmax, uint_t kk, float_t gamma, float_t dt, float_t *g) {

uint_t t;//time index
int_t n, k;//integer variables
float_t lcoeff, rcoeff;

	k=kk;

	//sizeof(g)=nmax+1
	for(t=0; t<=nmax; t++) {

		if (t<k+1) {
			g[t]=0;
		} else if (t==(k+1)) {
			g[t]=-dt/eps0_const*pow(gamma, (float_t)(2*k));
		} else if (t==(k+2)) {
			g[t]=-dt/eps0_const*pow(gamma, (float_t)(2*k))*(2*k+1-(2*k+2)*gamma*gamma);
		} else {//recurrence scheme
			n=t;
			/*
			//v1
			lcoeff= ((float_t)( (k-n+2)*(n-1)*(n+k-2) ))/(n-2)/(n+k-1)/(n-k-1);
			rcoeff= ((float_t)(3-2*n))/(n+k-2) + (2*n-3)*gamma*gamma/(n+k-2) + ((float_t)( (n+k-1)*(n-k-1) ))/2/(n-1)/(n+k-2) + ((float_t)(n-k-2))/2/(n-2);
			rcoeff*=2*(n-1)*(n+k-2);
			rcoeff/=(n+k-1)*(n-k-1);
			//recurrence
			g[t]=lcoeff*g[t-2] - rcoeff*g[t-1];
			*/
			lcoeff = -((float_t)( (n-k-2)*(n-1)*(n+k-2) ))/(n-2)/(n+k-1)/(n-k-1);
			rcoeff =  ((float_t)( 2*(n-1)*(3-2*n) ))/(n+k-1)/(n-k-1);
			rcoeff+=  ((float_t)( 2*(n-1)*(2*n-3) ))/(n+k-1)/(n-k-1)*gamma*gamma + 1;
			rcoeff+=  ((float_t)( (n-1)*(n+k-2)*(n-k-2) ))/(n-2)/(n+k-1)/(n-k-1);
			rcoeff*= -1;
			//recurrence
			g[n]=lcoeff*g[n-2]+rcoeff*g[n-1];
		}
		fprintf(stdout,"Iteration (scalar DGF): %d\r",t);
	}
}
//============================================================================
float_t scalar_zdgf(uint_t n, uint_t k, float_t cfl) {

uint_t m;
float_t out;
mpz_t b1, b2, tmp;
mpf_t tmpfl, gamma, convfl, result;

	if(n<=k) {
		out=0;
	} else {
		mpz_inits (b1, b2, tmp, NULL);
		mpf_inits (tmpfl, gamma, convfl, result, NULL);
		mpf_set_d (gamma, (double) cfl);
		for(m=k; m<n; m++) {
			binomial_mpa(b1, m+n,2*m+1);
			binomial_mpa(b2, 2*m, m+k);
			mpz_mul (tmp, b1, b2);

			mpf_set_z (convfl, tmp);
			mpf_pow_ui (tmpfl, gamma, (unsigned long int) (2*m));
			mpf_mul (tmpfl, tmpfl, convfl);
			if ((m+k)%2)//odd
				mpf_sub (result, result, tmpfl);
			else//even
				mpf_add (result, result, tmpfl);
		}
		out=mpf_get_d (result);
		mpz_clears (b1, b2, tmp, NULL);
		mpf_clears (tmpfl, gamma, convfl, result, NULL);
	}
	return out;
}
//============================================================================
float_t dgf_ee_z(uint_t n, uint_t k, float_t dt, float_t dz) {

float_t cfl;
float_t out;
float_t gl, gr;

	cfl=c_const*dt/dz;
	gl=scalar_zdgf (n, k, cfl);
	gr= n>=1 ? scalar_zdgf (n-1, k, cfl) : 0;
	out=-dt/eps0_const*( gl-gr );

	return out;
}
//============================================================================
float_t dgf_he_z(uint_t n, uint_t k, float_t dt, float_t dz) {

float_t cfl;
float_t out;
float_t gl, gr;

	cfl=c_const*dt/dz;
	gl=scalar_zdgf (n, k+1, cfl);
	gr=scalar_zdgf (n, k, cfl);
	out=dz*cfl*cfl*( gl-gr );

	return out;
}
//============================================================================
int max(int a, int b)
{
	if (a>b) return a;
	return b;
}


int min(int a, int b)
{
	if (a<b) return a;
	return b;
}
//============================================================================

/** Compute convolution of two h and x waveforms.
 * \param y returned array of the convolution
 * \param y_size size of the y array
 * \param h input array of the convolution operation
 * \param h_size size of the h array
 * \param x input array of the convolution operation
 * \param x_size size of the x array
 * \param sum_offset offset in the summation
 * \param x_offset offset in the x array
 * \param y_begin first index when system answer appears
 */
void DgfCpuConvolutionOffline(			float_t *y, const int_t y_size,
													const	float_t *h, const int_t h_size,
													const	float_t *x, const int_t x_size,
													const	int_t	sum_offset,
													const	int_t	x_offset,
													const	int_t	y_begin)
{
int_t i, j;
int_t j_min, j_max;

	for(i=y_begin; i<y_size; i++)
	{
		y[i]=0;
		//
		//y[i]=Sum(0<=j<=i-sum_offset):x[j+x_offset]*h[i-j]
		//
		//sum limits:		0<=j<=i-sum_offset		<=>		0<=j			^		j<=i-sum_offset
		//x[j+x_offset]:	0<=j+x_offset<=x_size-1	<=>		-x_offset<=j	^		j<=x_size-x_offset-1
		//h[i-j]:			0<=i-j<=h_size-1		<=>		i-h_size+1<=j	^		j<=i
		j_min=max(0, i-h_size+1);
		j_max=max( min(i-sum_offset, x_size-x_offset-1), 0 );
		for(j=j_min; j<=j_max; j++)
			y[i]+=x[j+x_offset]*h[i-j];
	}
}
//============================================================================
