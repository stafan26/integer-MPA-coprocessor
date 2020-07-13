/*
 ============================================================================
 Name        : srup_code_gen.h
 Author      :
 Version     :
 Copyright   :
 Description : Generation of 1d dgf for SRUP (header file)
 ============================================================================
 */
#ifndef SRUP_CODE_GEN_H_INCLUDED
#define SRUP_CODE_GEN_H_INCLUDED

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <gmp.h>
#include <libgen.h>
#include "lfsr.h"
#include "md5sum.h"
#include "settings.h"

//===========================================================================
void kam_fprintf (FILE *fp, mpz_t num);
//============================================================================
char conv_hexchar2char (char a);
//============================================================================
void write_int_number (mpz_t number, char *data,  int *data_size);
//============================================================================
void write_sim_number (FILE *fp, mpz_t number);
//============================================================================
void write_asm_number (FILE *fp, mpz_t number);
//============================================================================
void write_bin_number (FILE *fp, mpz_t number);
//============================================================================
void srup_code_gen(int_t n, int_t k, char *dir);
//============================================================================

#endif
//============================================================================
