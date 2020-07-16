/*
 ============================================================================
Name        : lfsr.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : LFSR implementation
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include "lfsr.h"

#define BYTESINLIMB	8

//============================================================================
//LFSR magic table:
char mtab[65][5]	=
	{	{0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0},
		{2, 2, 1, 0, 0},
		{2, 3, 2, 0, 0},
		{2, 4, 3, 0, 0},
		{2, 5, 3, 0, 0},
		{2, 6, 5, 0, 0},
		{2, 7, 6, 0, 0},
		{4, 8, 6, 5, 4},
		{2, 9, 5, 0, 0},
		{2, 10, 7, 0, 0},
		{2, 11, 9, 0, 0},
		{4, 12, 11, 8, 6},
		{4, 13, 12, 10, 9},
		{4, 14, 13, 11, 9},
		{2, 15, 14, 0, 0},
		{4, 16, 14, 13, 11},
		{2, 17, 14, 0, 0},
		{2, 18, 11, 0, 0},
		{4, 19, 18, 17, 14},
		{2, 20, 17, 0, 0},
		{2, 21, 19, 0, 0},
		{2, 22, 21, 0, 0},
		{2, 23, 18, 0, 0},
		{4, 24, 23, 21, 20},
		{2, 25, 22, 0, 0},
		{4, 26, 25, 24, 20},
		{4, 27, 26, 25, 22},
		{2, 28, 25, 0, 0},
		{2, 29, 27, 0, 0},
		{4, 30, 29, 26, 24},
		{2, 31, 28, 0, 0},
		{4, 32, 30, 26, 25},
		{2, 33, 20, 0, 0},
		{4, 34, 31, 30, 26},
		{2, 35, 33, 0, 0},
		{2, 36, 25, 0, 0},
		{4, 37, 36, 33, 31},
		{4, 38, 37, 33, 32},
		{2, 39, 35, 0, 0},
		{4, 40, 37, 36, 35},
		{2, 41, 38, 0, 0},
		{4, 42, 40, 37, 35},
		{4, 43, 42, 38, 37},
		{4, 44, 42, 39, 38},
		{4, 45, 44, 42, 41},
		{4, 46, 40, 39, 38},
		{2, 47, 42, 0, 0},
		{4, 48, 44, 41, 39},
		{2, 49, 40, 0, 0},
		{4, 50, 48, 47, 46},
		{4, 51, 50, 48, 45},
		{2, 52, 49, 0, 0},
		{4, 53, 52, 51, 47},
		{4, 54, 51, 48, 46},
		{2, 55, 31, 0, 0},
		{4, 56, 54, 52, 49},
		{2, 57, 50, 0, 0},
		{2, 58, 39, 0, 0},
		{4, 59, 57, 55, 52},
		{2, 60, 59, 0, 0},
		{4, 61, 60, 59, 56},
		{4, 62, 59, 57, 56},
		{2, 63, 62, 0, 0},
		{4, 64, 63, 61, 60}	};
//============================================================================
// Convert number size to LFSR form
void num2lfsr(unsigned int *lfsr_limbs, unsigned int limbs, unsigned int lfsr_length) {

	unsigned int i, j;
	unsigned int num_taps;
	unsigned int tmp_lfsr_limbs;
	char *reg;
	char tmpxor;

	if (limbs == 0)
		limbs = 1;
	limbs = limbs-1;

	reg = (char*) calloc (lfsr_length,sizeof(char));

	reg[0]=1;
	num_taps = mtab[lfsr_length][0];
	for (i = 0; i<limbs; i++) {

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]);
		else//num_taps == 4
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]) ^ (reg[ mtab[lfsr_length][3]-1 ]) ^ (reg[ mtab[lfsr_length][4]-1 ]);

		//shift LFSR
		for (j = lfsr_length-1; j>0; j--)
			reg[j] = reg[j-1];

		//put XOR
		reg[0] = tmpxor;
	}

	tmp_lfsr_limbs = 0;
	for (i = 0; i<lfsr_length; i++)
		if(reg[i])
			tmp_lfsr_limbs |= (1 << i);

	*lfsr_limbs = tmp_lfsr_limbs;
	free(reg);
}
//============================================================================
// Convert LFSR form to number size
void lfsr2num(unsigned int *limbs, unsigned int lfsr_limbs, unsigned int lfsr_length) {

	unsigned int i, j;
	unsigned int num_taps;
	char *reg;
	char tmpxor;

	if (lfsr_limbs == 0) {
		fprintf (stderr, "Wrong value in LFSR\n");
		exit (8);
	}
	reg = (char*) calloc (lfsr_length,sizeof(char));
	for (i = 0; i<lfsr_length; i++)
		if( (lfsr_limbs >> i) & 1 )
			reg[i] = 1;

	num_taps = mtab[lfsr_length][0];
	for (i = 0; i<((1<<9)-1); i++) {

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ 0 ]) ^ (reg[ (unsigned int)(mtab[lfsr_length][2]) ]);
		else//num_taps == 4
			tmpxor = (reg[ 0 ]) ^ (reg[ (unsigned int)(mtab[lfsr_length][2]) ]) ^ (reg[ (unsigned int)(mtab[lfsr_length][3]) ]) ^ (reg[ (unsigned int)(mtab[lfsr_length][4]) ]);

		//shift LFSR
		for (j = 0; j<(lfsr_length-1); j++)
			reg[j] = reg[j+1];

		//put XOR
		reg[lfsr_length-1] = tmpxor;

		//stop computations if possible
		j = 0;
		if (reg[0] == 1)
			for(j = 1; j<lfsr_length; j++)
				if (reg[j] != 0)
					break;
		if (j == lfsr_length) {
			*limbs = i+1;
			free(reg);

			if (*limbs == 511)
				*limbs = 0;
			*limbs = *limbs + 1;
			return;
		}
	}

	fprintf (stderr, "LFSR computations not convergent\n");
	exit (9);
}
//============================================================================
#ifdef LONGOUTDATA
//============================================================================
// Convert standard array to LFSR form
void arr2lfsrf(unsigned long long int *lfsrf_array, unsigned long long int *array, unsigned int num_array_elements, unsigned int lfsr_length) {
//lfsr_limbs->lfsrf_array
//limbs->array

	unsigned int i, j;
	unsigned int num_taps;
	unsigned int tmp_lfsr_val;
	char *reg;
	char tmpxor;

	//reg = (char*) calloc (lfsr_length,sizeof(char));
	reg = (char*) calloc (lfsr_length,sizeof(char));

	reg[0]=1;
	num_taps = mtab[lfsr_length][0];
	//for (i = 0; i<limbs; i++) {
	for (i = 0; i<num_array_elements; i++) {

		tmp_lfsr_val = 0;
		//for (i = 0; i<lfsr_length; i++)
		for (j = 0; j<lfsr_length; j++)
			if(reg[j])
				tmp_lfsr_val |= (1 << j);
		//*lfsr_limbs = tmp_lfsr_limbs;
		lfsrf_array[tmp_lfsr_val]=array[i];

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]);
		else//num_taps == 4
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]) ^ (reg[ mtab[lfsr_length][3]-1 ]) ^ (reg[ mtab[lfsr_length][4]-1 ]);

		//shift LFSR
		for (j = lfsr_length-1; j>0; j--)
			reg[j] = reg[j-1];

		//put XOR
		reg[0] = tmpxor;
	}

	free(reg);
}
//============================================================================
// Convert LFSR-form array to standard array
void lfsrf2arr(unsigned long long int *array, unsigned long long int *lfsrf_array, unsigned int num_array_elements, unsigned int lfsr_length) {
//lfsr_limbs->lfsrf_array
//limbs->array

	unsigned int i, j;
	unsigned int num_taps;
	unsigned int tmp_lfsr_val;
	char *reg;
	char tmpxor;

	//reg = (char*) calloc (lfsr_length,sizeof(char));
	reg = (char*) calloc (lfsr_length,sizeof(char));

	reg[0]=1;
	num_taps = mtab[lfsr_length][0];
	//for (i = 0; i<limbs; i++) {
	for (i = 0; i<num_array_elements; i++) {

		tmp_lfsr_val = 0;
		//for (i = 0; i<lfsr_length; i++)
		for (j = 0; j<lfsr_length; j++)
			if(reg[j])
				tmp_lfsr_val |= (1 << j);
		//*lfsr_limbs = tmp_lfsr_limbs;
		array[i]=lfsrf_array[tmp_lfsr_val];

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]);
		else//num_taps == 4
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]) ^ (reg[ mtab[lfsr_length][3]-1 ]) ^ (reg[ mtab[lfsr_length][4]-1 ]);

		//shift LFSR
		for (j = lfsr_length-1; j>0; j--)
			reg[j] = reg[j-1];

		//put XOR
		reg[0] = tmpxor;
	}

	free(reg);
}
//============================================================================
#else
//============================================================================
// Convert standard array to LFSR form
void arr2lfsrf(unsigned int *lfsrf_array, unsigned int *array, unsigned int num_array_elements, unsigned int lfsr_length) {
//lfsr_limbs->lfsrf_array
//limbs->array

	unsigned int i, j;
	unsigned int num_taps;
	unsigned int tmp_lfsr_val;
	char *reg;
	char tmpxor;

	//reg = (char*) calloc (lfsr_length,sizeof(char));
	reg = (char*) calloc (lfsr_length,sizeof(char));

	reg[0]=1;
	num_taps = mtab[lfsr_length][0];
	//for (i = 0; i<limbs; i++) {
	for (i = 0; i<num_array_elements; i++) {

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]);
		else//num_taps == 4
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]) ^ (reg[ mtab[lfsr_length][3]-1 ]) ^ (reg[ mtab[lfsr_length][4]-1 ]);

		//shift LFSR
		for (j = lfsr_length-1; j>0; j--)
			reg[j] = reg[j-1];

		//put XOR
		reg[0] = tmpxor;

		tmp_lfsr_val = 0;
		//for (i = 0; i<lfsr_length; i++)
		for (j = 0; j<lfsr_length; j++)
			if(reg[j])
				tmp_lfsr_val |= (1 << j);
		//*lfsr_limbs = tmp_lfsr_limbs;
		for (j = 0; j<4; j++)
			lfsrf_array[tmp_lfsr_val*4+j-4]=array[i*4+j];
	}

	free(reg);
}
//============================================================================
// Convert LFSR-form array to standard array
void lfsrf2arr(unsigned int *array, unsigned int *lfsrf_array, unsigned int num_array_elements, unsigned int lfsr_length) {
//lfsr_limbs->lfsrf_array
//limbs->array

	unsigned int i, j;
	unsigned int num_taps;
	unsigned int tmp_lfsr_val;
	char *reg;
	char tmpxor;

	//reg = (char*) calloc (lfsr_length,sizeof(char));
	reg = (char*) calloc (lfsr_length,sizeof(char));

	reg[0]=1;
	num_taps = mtab[lfsr_length][0];
	//for (i = 0; i<limbs; i++) {
	for (i = 0; i<num_array_elements; i++) {

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]);
		else//num_taps == 4
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]) ^ (reg[ mtab[lfsr_length][3]-1 ]) ^ (reg[ mtab[lfsr_length][4]-1 ]);

		//shift LFSR
		for (j = lfsr_length-1; j>0; j--)
			reg[j] = reg[j-1];

		//put XOR
		reg[0] = tmpxor;

		tmp_lfsr_val = 0;
		//for (i = 0; i<lfsr_length; i++)
		for (j = 0; j<lfsr_length; j++)
			if(reg[j])
				tmp_lfsr_val |= (1 << j);
		//*lfsr_limbs = tmp_lfsr_limbs;
		for (j = 0; j<4; j++)
			array[i*4+j]=lfsrf_array[tmp_lfsr_val*4+j-4];
	}

	free(reg);
}
//============================================================================
#endif
//============================================================================

//============================================================================
// Convert limbs to LFSR form
int limbs2lfsr(unsigned int lfsr_length, unsigned int limbs) {

	unsigned int i, j;
	unsigned int num_taps;
	unsigned int lfsr;
	char *reg;
	char tmpxor;

	if (limbs == 0)
		limbs = 1;
	limbs = limbs-1;

	reg = (char*) calloc (lfsr_length,sizeof(char));

	reg[0]=1;
	num_taps = mtab[lfsr_length][0];
	for (i = 0; i<limbs; i++) {

		//compute XOR
		if (num_taps == 2)
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]);
		else//num_taps == 4
			tmpxor = (reg[ mtab[lfsr_length][1]-1 ]) ^ (reg[ mtab[lfsr_length][2]-1 ]) ^ (reg[ mtab[lfsr_length][3]-1 ]) ^ (reg[ mtab[lfsr_length][4]-1 ]);

		//shift LFSR
		for (j = lfsr_length-1; j>0; j--)
			reg[j] = reg[j-1];

		//put XOR
		reg[0] = tmpxor;
	}

	lfsr = 0;
	for (i = 0; i<lfsr_length; i++)
		if(reg[i])
			lfsr |= (1 << i);

	free(reg);
	return lfsr;
}
//============================================================================
