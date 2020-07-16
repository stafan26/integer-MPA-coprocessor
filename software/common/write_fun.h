/*
 ============================================================================
Name        : write_fun.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Functions for writing data to files
 ============================================================================
 */

#ifndef WRITE_FUN_H_INCLUDED
#define WRITE_FUN_H_INCLUDED

#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//============================================================================
void kam_fprintf (FILE *fp, mpz_t num);
//===========================================================================
void kam_printf (mpz_t num);
//============================================================================
char conv_hexchar2char (char a);
//============================================================================
void write_int_number (mpz_t number, char *data,  int *data_size);
//============================================================================
void write_int_number_with_reset (mpz_t number, char *data,  int data_size);
//============================================================================
void write_int_number_with_reset_rev (mpz_t number, char *data,  int data_size);
//============================================================================
void write_int2c_number_with_reset (mpz_t number, char *data,  int data_size);
//============================================================================
void write_int2c_number_with_reset_rev (mpz_t number, char *data,  int data_size);
//============================================================================
void write_sim_number (FILE *fp, mpz_t number);
//============================================================================
void write_asm_number (FILE *fp, mpz_t number);
//============================================================================
void write_bin_number (FILE *fp, mpz_t number);

//============================================================================
#endif
