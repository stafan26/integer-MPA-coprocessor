/*
 ============================================================================
 Name        : 1ddgf.h
 Author      :
 Version     :
 Copyright   :
 Description : 1d dgf formula header file
 ============================================================================
 */
#ifndef ONEDDGF_H_INCLUDED
#define ONEDDGF_H_INCLUDED

#include <gmp.h>
#include "settings.h"

//============================================================================
uint_t binomial_std(uint_t n, uint_t k);
//============================================================================
int_t scalar_dgf_cflf1_std(uint_t n, uint_t k);
//============================================================================
void binomial_mpa(mpz_t rop, uint_t n, uint_t k);
//============================================================================
int_t scalar_dgf_cflf1_mpa(uint_t n, uint_t k);
//============================================================================
void table_gen_cflf1_mpamem(uint_t n, uint_t k, mpz_t *tab1, mpz_t *tab2);
//============================================================================
void scalar_dgf_cflf1_mpamem(uint_t n, uint_t k, mpz_t *tab1, mpz_t *tab2, mpz_t result);
//============================================================================
int_t scalar_dgf_cflf1(uint_t n, uint_t k);
//============================================================================
float_t dgf_ee_cflf1(uint_t n, uint_t k, float_t dt, float_t dz);
//============================================================================
float_t dgf_eh_cflf1(uint_t n, uint_t k, float_t dt, float_t dz);
//============================================================================
float_t dgf_he_cflf1(uint_t n, uint_t k, float_t dt, float_t dz);
//============================================================================
float_t dgf_hh_cflf1(uint_t n, uint_t k, float_t dt, float_t dz);
//============================================================================
void dgfjg_ee(uint_t nmax, uint_t kk, float_t gamma, float_t dt, float_t *g);
//============================================================================
float_t dgf_ee_z(uint_t n, uint_t k, float_t dt, float_t dz);
//============================================================================
float_t dgf_he_z(uint_t n, uint_t k, float_t dt, float_t dz);
//============================================================================
void DgfCpuConvolutionOffline(			float_t *y, const int_t y_size,
													const	float_t *h, const int_t h_size,
													const	float_t *x, const int_t x_size,
													const	int_t	sum_offset,
													const	int_t	x_offset,
													const	int_t	y_begin);
//============================================================================
#endif
//============================================================================
