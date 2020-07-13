/*
 ============================================================================
Name        : lfsr.h
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : LFSR implementation
 ============================================================================
 */

#ifndef LFSR_H_INCLUDED
#define LFSR_H_INCLUDED

#include "../emusrup/emusrup.h"

//============================================================================
// Convert number size to LFSR form
void num2lfsr(unsigned int *lfsr_limbs, unsigned int limbs, unsigned int lfsr_length);
//============================================================================
// Convert LFSR form to number size
void lfsr2num(unsigned int *limbs, unsigned int lfsr_limbs, unsigned int lfsr_length);
//============================================================================
#ifdef LONGOUTDATA
//============================================================================
// Convert standard array to LFSR form
void arr2lfsrf(unsigned long long int *lfsrf_array, unsigned long long int *array, unsigned int num_array_elements, unsigned int lfsr_length);
//============================================================================
// Convert LFSR-form array to standard array
void lfsrf2arr(unsigned long long int *array, unsigned long long int *lfsrf_array, unsigned int num_array_elements, unsigned int lfsr_length);
//============================================================================
#else
//============================================================================
// Convert standard array to LFSR form
void arr2lfsrf(unsigned int *lfsrf_array, unsigned int *array, unsigned int num_array_elements, unsigned int lfsr_length);
//============================================================================
// Convert LFSR-form array to standard array
void lfsrf2arr(unsigned int *array, unsigned int *lfsrf_array, unsigned int num_array_elements, unsigned int lfsr_length);
//============================================================================
#endif
//============================================================================
// Convert limbs to LFSR form
int limbs2lfsr(unsigned int lfsr_length, unsigned int limbs);
//============================================================================
#endif
