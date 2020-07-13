/*
 ============================================================================
Name        : read_fun.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Functions for reading data from files
 ============================================================================
 */

#ifndef READ_FUN_H_INCLUDED
#define READ_FUN_H_INCLUDED

#include <gmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//===========================================================================
void read_bin_file (char *file, char **data, int *data_size);
//===========================================================================
char conv_char2hexchar (char a);
//===========================================================================
void read_int_number (char *data,  int data_size, mpz_t number, unsigned int *number_size);

//============================================================================
#endif
