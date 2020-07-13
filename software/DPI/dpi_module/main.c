//============================================================================
// Name        : main.c
// Author      : TS
// Version     :
// Copyright   : Your copyright notice
// Description : Main for library of MPA functions for MPA-FPGA testing
//============================================================================

#include "dpi_module.h"

/** Types of unit tests:
 * 1 - test of function tbGenTestDataMultiplicationInteger (random data)
 * 2 - test of function tbGenTestDataMultiplicationInteger (pseudo-random data)
 * 3 - test of function tbGenTestDataAdditionIntegerSeedSrup (pseudo-random data)
 * 4 - test of function tbGenTestDataSubtractionIntegerSeedSrup (pseudo-random data)
 * 5 - test of function tbGenTestDataMultiplicationIntegerSeedSrup (pseudo-random data)
 */

//#define UTEST1
//#define UTEST2
#define UTEST3
//#define UTEST4
//#define UTEST5

#define MULSIZE 64  //MUX size
#define PRECANB 3	//1 //precision of multiplied numbers
#define PRECBNB 5	//1

#define MAX(a,b) (((a)>(b))?(a):(b))

/** This function provides tests of the library in gcc environment.
 */
int main() {

//unit test 1
#ifdef UTEST1
	char *a, *b, *c;
	int  *a_int, *b_int, *c_int;

	a=NULL; b=NULL; c=NULL;
	a_int=NULL; b_int=NULL; c_int=NULL;

	tbDisplay ();

	tbGenTestDataMultiplicationInteger (MULSIZE, &a, PRECANB, &b, PRECBNB, &c);

	tbConvStringNumToHalfIntArray(MULSIZE, a, PRECANB, &a_int);
	tbConvStringNumToHalfIntArray(MULSIZE, b, PRECBNB, &b_int);
	tbConvStringNumToHalfIntArray(MULSIZE, c, PRECANB+PRECBNB, &c_int);

	tbPrintHalfIntArray (MULSIZE, c_int, PRECANB+PRECBNB);

	if(a)
		free (a);
	if(b)
		free (b);
	if(c)
		free (c);
	if(a_int)
		free (a_int);
	if(b_int)
		free (b_int);
	if(c_int)
		free (c_int);
#endif
//unit test 2
#ifdef UTEST2
	int		k;
	int		byte_count;
	int		seed=6;
	int		*a_int, *b_int, *c_int;

	byte_count = (MULSIZE * PRECANB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	a_int = (int *)calloc (k/2, sizeof(int));

	byte_count = (MULSIZE * PRECBNB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	b_int = (int *)calloc (k/2, sizeof(int));

	byte_count = (MULSIZE * (PRECANB+PRECBNB)) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	c_int = (int *)calloc (k/2, sizeof(int));

	tbGenTestDataMultiplicationIntegerSeedHalfIntExtArrayOutput (MULSIZE, a_int, PRECANB, b_int, PRECBNB, c_int, seed);
	tbPrintHalfIntArray (MULSIZE, a_int, PRECANB);
	tbPrintHalfIntArray (MULSIZE, b_int, PRECBNB);
	tbPrintHalfIntArray (MULSIZE, c_int, PRECANB+PRECBNB);

	free (a_int);
	free (b_int);
	free (c_int);
#endif
//unit test 3
#ifdef UTEST3
	int		k;
	int		c_prec;
	int		byte_count;
	int		seed=6;
	int		*a_int, *b_int, *c_int;
	int		*a_last, *b_last, *c_last;

	byte_count = (MULSIZE * PRECANB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	a_int = (int *)calloc (k/2, sizeof(int));
	a_last = (int *)calloc (PRECANB, sizeof(int));

	byte_count = (MULSIZE * PRECBNB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	b_int = (int *)calloc (k/2, sizeof(int));
	b_last = (int *)calloc (PRECBNB, sizeof(int));

	byte_count = (MULSIZE * (MAX(PRECANB+1,PRECBNB+1))) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	c_int = (int *)calloc (k/2, sizeof(int));
	c_last = (int *)calloc (MAX(PRECANB,PRECBNB)+1, sizeof(int));

	tbGenTestDataAdditionIntegerSeedSrup (	a_int, PRECANB, a_last, b_int, PRECBNB, b_last, c_int, &c_prec, c_last, seed);

#ifdef PRINTVAL
	printf("Values sent to Vivado:\n");

	tbPrintHalfIntArray (MULSIZE, a_int, PRECANB);
	tbPrintHalfIntArray (MULSIZE, b_int, PRECBNB);
	tbPrintHalfIntArray (MULSIZE, c_int, c_prec);

	printf("Output precision: %d\n", c_prec);
	printf("\n\nLast signals:\n");
	for (k=0; k<PRECANB; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<PRECBNB; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<c_prec; k++)
		printf("%d", c_last[k]);
	printf("\n\n");

	printf("SUCCESS ANYWAY!!!\n");
#endif

	free (a_int);
	free (b_int);
	free (c_int);
#endif
//unit test 4
#ifdef UTEST4
	int		k;
	int		c_amb_prec, c_bma_prec;
	int		byte_count;
	int		seed=6;
	int		*a_int, *b_int, *c_amb_int, *c_bma_int;
	int		*a_last, *b_last, *c_amb_last, *c_bma_last;

	byte_count = (MULSIZE * PRECANB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	a_int = (int *)calloc (k/2, sizeof(int));
	a_last = (int *)calloc (PRECANB, sizeof(int));

	byte_count = (MULSIZE * PRECBNB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	b_int = (int *)calloc (k/2, sizeof(int));
	b_last = (int *)calloc (PRECBNB, sizeof(int));

	byte_count = (MULSIZE * MAX(PRECANB+1,PRECBNB+1)) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	c_amb_int = (int *)calloc (k/2, sizeof(int));
	c_amb_last = (int *)calloc (MAX(PRECANB,PRECBNB)+1, sizeof(int));
	c_bma_int = (int *)calloc (k/2, sizeof(int));
	c_bma_last = (int *)calloc (MAX(PRECANB,PRECBNB)+1, sizeof(int));

	tbGenTestDataSubtractionIntegerSeedSrup (	a_int, PRECANB, a_last, b_int, PRECBNB, b_last, c_amb_int, &c_amb_prec, c_amb_last, c_bma_int, &c_bma_prec, c_bma_last, seed);

#ifdef PRINTVAL
	printf("Values sent to Vivado:\n");

	tbPrintHalfIntArray (MULSIZE, a_int, PRECANB);
	tbPrintHalfIntArray (MULSIZE, b_int, PRECBNB);
	tbPrintHalfIntArray (MULSIZE, c_amb_int, c_amb_prec);
	tbPrintHalfIntArray (MULSIZE, c_bma_int, c_bma_prec);

	printf("Output precision a-b: %d\n", c_amb_prec);
	printf("Output precision b-a: %d\n", c_bma_prec);

	printf("\n\nLast signals:\n");
	for (k=0; k<PRECANB; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<PRECBNB; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<c_amb_prec; k++)
		printf("%d", c_amb_last[k]);
	printf("\n\n");
	for (k=0; k<c_bma_prec; k++)
		printf("%d", c_bma_last[k]);
	printf("\n\n");

	printf("SUCCESS ANYWAY!!!\n");
#endif

	free (a_int);
	free (b_int);
	free (c_amb_int);
	free (c_bma_int);
#endif
//unit test 5
#ifdef UTEST5
	int		k;
	int		c_prec;
	int		byte_count;
	int		seed=6;
	int		*a_int, *b_int, *c_int;
	int		*a_last, *b_last, *c_last;
	int		*cycle;

#ifdef KAMORD
	a_int = (int *)calloc (PRECANB*PRECBNB*(MULSIZE/4), sizeof(int));
	a_last = (int *)calloc (PRECANB*PRECBNB, sizeof(int));

	b_int = (int *)calloc (PRECANB*PRECBNB*(MULSIZE/4), sizeof(int));
	b_last = (int *)calloc (PRECANB*PRECBNB, sizeof(int));
#else
	byte_count = (MULSIZE * PRECANB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	a_int = (int *)calloc (k/2, sizeof(int));
	a_last = (int *)calloc (PRECANB, sizeof(int));

	byte_count = (MULSIZE * PRECBNB) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	b_int = (int *)calloc (k/2, sizeof(int));
	b_last = (int *)calloc (PRECBNB, sizeof(int));
#endif

	byte_count = (MULSIZE * (PRECANB+PRECBNB)) / 8;
	k = byte_count%2 ? byte_count+1 : byte_count;
	c_int = (int *)calloc (k/2, sizeof(int));
	c_last = (int *)calloc (PRECANB+PRECBNB, sizeof(int));
	cycle = (int *)calloc (PRECANB*PRECBNB, sizeof(int));

	tbGenTestDataMultiplicationIntegerSeedSrup (	a_int, PRECANB, a_last, b_int, PRECBNB, b_last, c_int, &c_prec, c_last, cycle, seed);
#ifdef PRINTVAL

	printf("Values sent to Vivado:\n");
#ifdef KAMORD
	tbPrintHalfIntArray (MULSIZE, a_int, PRECANB*PRECBNB);
	tbPrintHalfIntArray (MULSIZE, b_int, PRECANB*PRECBNB);
	tbPrintHalfIntArray (MULSIZE, c_int, c_prec);

	printf("Output precision: %d\n", c_prec);
	printf("\n\nLast signals:\n");
	for (k=0; k<PRECANB*PRECBNB; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<PRECANB*PRECBNB; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<(PRECANB+PRECBNB); k++)
		printf("%d", c_last[k]);
	printf("\n\n");
	printf("Cycle signal:\n");
	for (k=0; k<PRECANB*PRECBNB; k++)
		printf("%d", cycle[k]);
	printf("\n\n");
#else
	tbPrintHalfIntArray (MULSIZE, a_int, PRECANB);
	tbPrintHalfIntArray (MULSIZE, b_int, PRECBNB);
	tbPrintHalfIntArray (MULSIZE, c_int, c_prec);

	printf("Output precision: %d\n", c_prec);
	printf("\n\nLast signals:\n");
	for (k=0; k<PRECANB; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<PRECBNB; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<c_prec; k++)
		printf("%d", c_last[k]);
	printf("\n\n");
#endif

	printf("SUCCESS ANYWAY!!!\n");
#endif

	free (a_int); free (b_int); free (c_int);
	free (a_last); free (b_last); free (c_last);
	free(cycle);
#endif
	return 0;
}
//====================================EOF=====================================
