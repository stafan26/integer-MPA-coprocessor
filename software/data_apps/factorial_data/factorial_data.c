/*
 ============================================================================
Name        : factorial_data.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Factorial computations in MPA on SRUP
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <gmp.h>
#include <time.h>
#include <libgen.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "md5sum.h"

#define FILESNEWGEN

#define MAXFILENAMELENGTH 1024

/** Speed test parameters **/
#define REPF	10
#define N_MIN	1000
#define N_MAX	1000
#define N_STEP	1000

#define FULLMPAIMPL

/** General assembler generation parameters **/
#define SINGLELOAD

#define OUTREG		"reg0"
#define TMPREG		"reg1"
#define MULREG		"reg2"
#define INCREG		"reg3"
#define RESREG		"reg4"
#define N1REG		"reg2"
#define N2REG		"reg4"
#define P1REG		"reg5"
#define P2REG		"reg6"

#define OUTBINREG	0x00
#define TMPBINREG	0x01
#define MULBINREG	0x02
#define INCBINREG	0x03
#define RESBINREG	0x04
#define N1BINREG	0x02
#define N2BINREG	0x04
#define P1BINREG	0x05
#define P2BINREG	0x06

#define LOAACOM		"loaa"
#define LOABCOM		"loab"
#define LOAABCOM	"loaab"
#define UNLCOM		"unl"
#define MULTCOM		"mult"
#define ADDCOM		"add"
#define SUBCOM		"sub"

#define LOAABINCOM	0x01
#define LOABBINCOM	0x02
#define LOAABBINCOM	0x03
#define UNLBINCOM	0x04
#define MULTBINCOM	0x08
#define ADDBINCOM	0x09
#define SUBBINCOM	0x0A

#define LASTBYTE	0x01
#define BREAKBYTE	0x00

/** Code generation parameters **/
#define ASMFNAME "prog.asm"
#define ASMFBUSA "busA.asm"
#define ASMFBUSB "busB.asm"
#define BINFNAME "prog.bin"
#define BINFBUSA "busA.bin"
#define BINFBUSB "busB.bin"
#define SIMFNAME "prog.sim"
#define SIMFBUSA "busA.sim"
#define SIMFBUSB "busB.sim"
#define MD5SUMSF "md5sums.txt"

/** Indexing and unsigned integer variables. */
#define float_t double
typedef unsigned int uint_t;
typedef unsigned long ulong_t;
typedef unsigned long long ulonglong_t;
typedef int int_t;
typedef long long_t;
typedef long long longlong_t;

//============================================================================
void factorial_mpa(mpz_t rop, uint_t n) {

uint_t i;

#ifdef FULLMPAIMPL
mpz_t inc, mult;

	mpz_init_set_ui (inc, (unsigned long int) 1);
	mpz_init_set_ui (mult, (unsigned long int) 1);
	mpz_set_ui (rop, (unsigned long int) 1);
	for (i = 2; i <= n; i++) {
		mpz_add (mult, mult, inc);
		mpz_mul (rop, rop, mult);
	}
	mpz_clears (inc, mult, NULL);
#else
	mpz_set_ui (rop, (unsigned long int) 1);
	for (i = 2; i <= n; i++) {
		mpz_mul_ui (rop, rop, (unsigned long int) i);
	}
#endif
}
//============================================================================
void factorial_code_gen(int Narg, char *dir) {
int_t  tmp;
uint_t n, k;
uint_t num_command;
uint_t size_commands;
uint_t size_data;
char   *bin_commands;
char   *bin_data;

#ifdef SINGLELOAD
uint_t size_dataB;
char   *bin_dataB;
FILE   *fpbusB_asm, *fpbusB_sim, *fpbusB_bin;
#endif

FILE   *fp_asm, *fpbus_asm;
FILE   *fp_sim, *fpbus_sim;
FILE   *fp_bin, *fpbus_bin;
FILE   *fp_md5sums;

char	fname_fp_asm[MAXFILENAMELENGTH];
char	fname_fpbus_asm[MAXFILENAMELENGTH];
char	fname_fp_sim[MAXFILENAMELENGTH];
char	fname_fpbus_sim[MAXFILENAMELENGTH];
char	fname_fp_bin[MAXFILENAMELENGTH];
char	fname_fpbus_bin[MAXFILENAMELENGTH];
char	fname_fp_md5sums[MAXFILENAMELENGTH];
#ifdef SINGLELOAD
char	fname_fpbusB_asm[MAXFILENAMELENGTH];
char	fname_fpbusB_sim[MAXFILENAMELENGTH];
char	fname_fpbusB_bin[MAXFILENAMELENGTH];
#endif

	if (dir == NULL) {
		fp_asm = fopen (ASMFNAME, "w");
		fpbus_asm = fopen (ASMFBUSA, "w");

		fp_sim = fopen (SIMFNAME, "w");
		fpbus_sim = fopen (SIMFBUSA, "w");

		fp_bin = fopen (BINFNAME, "w");
		fpbus_bin = fopen (BINFBUSA, "w");

		fp_md5sums = fopen (MD5SUMSF, "w");
	} else {
		strcpy ( fname_fp_asm, dir ); strcat ( fname_fp_asm, "/" ); strcat ( fname_fp_asm, ASMFNAME ); fp_asm = fopen (fname_fp_asm, "w");
		strcpy ( fname_fpbus_asm, dir ); strcat ( fname_fpbus_asm, "/" ); strcat ( fname_fpbus_asm, ASMFBUSA ); fpbus_asm = fopen (fname_fpbus_asm, "w");

		strcpy ( fname_fp_sim, dir ); strcat ( fname_fp_sim, "/" ); strcat ( fname_fp_sim, SIMFNAME ); fp_sim = fopen (fname_fp_sim, "w");
		strcpy ( fname_fpbus_sim, dir ); strcat ( fname_fpbus_sim, "/" ); strcat ( fname_fpbus_sim, SIMFBUSA ); fpbus_sim = fopen (fname_fpbus_sim, "w");

		strcpy ( fname_fp_bin, dir ); strcat ( fname_fp_bin, "/" ); strcat ( fname_fp_bin, BINFNAME ); fp_bin = fopen (fname_fp_bin, "w");
		strcpy ( fname_fpbus_bin, dir ); strcat ( fname_fpbus_bin, "/" ); strcat ( fname_fpbus_bin, BINFBUSA ); fpbus_bin = fopen (fname_fpbus_bin, "w");

		strcpy ( fname_fp_md5sums, dir ); strcat ( fname_fp_md5sums, "/" ); strcat ( fname_fp_md5sums, MD5SUMSF ); fp_md5sums = fopen (fname_fp_md5sums, "w");
	}

#ifdef SINGLELOAD
	if (dir == NULL) {
		fpbusB_asm = fopen (ASMFBUSB, "w");
		fpbusB_sim = fopen (SIMFBUSB, "w");
		fpbusB_bin = fopen (BINFBUSB, "w");
	} else {
		strcpy ( fname_fpbusB_asm, dir ); strcat ( fname_fpbusB_asm, "/" ); strcat ( fname_fpbusB_asm, ASMFBUSB ); fpbusB_asm = fopen (fname_fpbusB_asm, "w");
		strcpy ( fname_fpbusB_sim, dir ); strcat ( fname_fpbusB_sim, "/" ); strcat ( fname_fpbusB_sim, SIMFBUSB ); fpbusB_sim = fopen (fname_fpbusB_sim, "w");
		strcpy ( fname_fpbusB_bin, dir ); strcat ( fname_fpbusB_bin, "/" ); strcat ( fname_fpbusB_bin, BINFBUSB ); fpbusB_bin = fopen (fname_fpbusB_bin, "w");
	}

	if (fpbusB_asm==NULL || fpbusB_sim==NULL || fpbusB_bin==NULL) {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}
#endif

	if (fp_asm!=NULL && fpbus_asm!=NULL && fp_sim!=NULL && fpbus_sim!=NULL && fp_bin!=NULL && fpbus_bin!=NULL) {

 		fprintf(fp_asm, ";============================================================================\n");
 		fprintf(fp_asm, ";Name        : factorial_test.c\n");
 		fprintf(fp_asm, ";Author      : Tomasz Stefanski\n");
 		fprintf(fp_asm, ";Version     : 0.1\n");
 		fprintf(fp_asm, ";Copyright   : Your copyright notice\n");
 		fprintf(fp_asm, ";Description : Factorial computations in MPA on SRUP\n");
 		fprintf(fp_asm, ";Input       : N=%d\n", Narg);
 		fprintf(fp_asm, ";============================================================================\n\n\n");

 		k=1;
 		num_command=0;
#ifdef SINGLELOAD
		//set 1 at output, multiplication and increment registers
		fprintf(fpbus_sim,  "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim,  "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbusB_sim, "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");

 		size_data=2*16;
 		bin_data = (char*)calloc (size_data, sizeof(char));
 		bin_data[0] =0x01;	bin_data[2] =0x01;	bin_data[8]=0x01;
 		bin_data[16]=0x01;	bin_data[18]=0x01;	bin_data[24]=0x01;

 		size_dataB=16;
 		bin_dataB = (char*)calloc (size_dataB, sizeof(char));
 		bin_dataB[0]=0x01;	bin_dataB[2]=0x01;	bin_dataB[8]=0x01;

		fprintf(fpbus_asm,  "1) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbus_asm,  "2) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbusB_asm, "1) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");

 		size_commands=6+(Narg-1)*8+2;
 		bin_commands = (char*)calloc (size_commands, sizeof(char));

 		bin_commands[num_command++]=MULBINREG;
 		bin_commands[num_command++]=BREAKBYTE;
 		bin_commands[num_command++]=LOAABBINCOM | (OUTBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;

		fprintf(fp_asm, "%.4d\t\t\t%s %s, %s;\t\t\t%.2X%.2X\n", k++, LOAABCOM, OUTREG, MULREG, bin_commands[num_command-4], bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);
#else
		//set 1 at output, multiplication and increment registers
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");

 		size_data=3*16;
 		bin_data = (char*)calloc (size_data, sizeof(char));
 		bin_data[0] =0x01;	bin_data[2] =0x01;	bin_data[8] =0x01;
 		bin_data[16]=0x01;	bin_data[18]=0x01;	bin_data[24]=0x01;
 		bin_data[32]=0x01;	bin_data[34]=0x01;	bin_data[40]=0x01;

		fprintf(fpbus_asm, "1) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbus_asm, "2) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbus_asm, "3) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");

 		size_commands=6+(Narg-1)*8+2;
 		bin_commands = (char*)calloc (size_commands, sizeof(char));

 		bin_commands[num_command++]=LOAABINCOM | (OUTBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, OUTREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);

		bin_commands[num_command++]=LOAABINCOM | (MULBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, MULREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
#endif
		bin_commands[num_command++]=LOAABINCOM | (INCBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, INCREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);

		//multiply integers
		for(n=2; n<=(Narg/2); n++) {
			//increase multiplication factor 1
	 		bin_commands[num_command++]=INCBINREG | (RESBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (MULBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, MULREG, INCREG, RESREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply previous result
	 		bin_commands[num_command++]=OUTBINREG  | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (RESBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, RESREG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//increase multiplication factor 2
	 		bin_commands[num_command++]=INCBINREG | (MULBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (RESBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, RESREG, INCREG, MULREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply previous result
	 		bin_commands[num_command++]=TMPBINREG  | (OUTBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (MULBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, MULREG, TMPREG, OUTREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);
		}

		if(!(Narg%2)) {//FACTORIAL - even number
			//increase multiplication factor 3
	 		bin_commands[num_command++]=INCBINREG | (RESBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (MULBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, MULREG, INCREG, RESREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply previous result
	 		bin_commands[num_command++]=OUTBINREG  | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (RESBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, RESREG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//unload temporary register
			bin_commands[num_command++]=UNLBINCOM | (TMPBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, TMPREG, bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
		} else {//FACTORIAL - odd number
			//increase multiplication factor 1
	 		bin_commands[num_command++]=INCBINREG | (RESBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (MULBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, MULREG, INCREG, RESREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply previous result
	 		bin_commands[num_command++]=OUTBINREG  | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (RESBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, RESREG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//increase multiplication factor 2
	 		bin_commands[num_command++]=INCBINREG | (MULBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (RESBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, RESREG, INCREG, MULREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply previous result
	 		bin_commands[num_command++]=TMPBINREG  | (OUTBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (MULBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, MULREG, TMPREG, OUTREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//unload output register
			bin_commands[num_command++]=UNLBINCOM | (OUTBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, OUTREG, bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
		}

		fclose (fp_asm);
		fclose (fpbus_asm);

		fclose (fp_sim);
		fclose (fpbus_sim);

		fwrite (bin_commands, sizeof(char), size_commands, fp_bin);
		fclose (fp_bin);
		fwrite (bin_data, sizeof(char), size_data, fpbus_bin);
		fclose (fpbus_bin);

#ifdef SINGLELOAD
		fclose (fpbusB_asm);
		fclose (fpbusB_sim);
		fwrite (bin_dataB, sizeof(char), size_dataB, fpbusB_bin);
		fclose (fpbusB_bin);
#endif
		free(bin_commands);
		free(bin_data);

		//MD5 sums
		tmp=0;
		fprintf(fp_md5sums, "#Input       : N=%d\n", Narg);
		if (dir == NULL) {
			tmp+=md5sum_print(fp_md5sums, ASMFNAME);
			fprintf(fp_md5sums, "  %s\n", ASMFNAME);

			tmp+=md5sum_print(fp_md5sums, ASMFBUSA);
			fprintf(fp_md5sums, "  %s\n", ASMFBUSA);

			tmp+=md5sum_print(fp_md5sums, SIMFNAME);
			fprintf(fp_md5sums, "  %s\n", SIMFNAME);

			tmp+=md5sum_print(fp_md5sums, SIMFBUSA);
			fprintf(fp_md5sums, "  %s\n", SIMFBUSA);

			tmp+=md5sum_print(fp_md5sums, BINFNAME);
			fprintf(fp_md5sums, "  %s\n", BINFNAME);

			tmp+=md5sum_print(fp_md5sums, BINFBUSA);
			fprintf(fp_md5sums, "  %s\n", BINFBUSA);
#ifdef SINGLELOAD
			tmp+=md5sum_print(fp_md5sums, ASMFBUSB);
			fprintf(fp_md5sums, "  %s\n", ASMFBUSB);

			tmp+=md5sum_print(fp_md5sums, SIMFBUSB);
			fprintf(fp_md5sums, "  %s\n", SIMFBUSB);

			tmp+=md5sum_print(fp_md5sums, BINFBUSB);
			fprintf(fp_md5sums, "  %s\n", BINFBUSB);
#endif
		} else {
			tmp+=md5sum_print(fp_md5sums, fname_fp_asm);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fp_asm));

			tmp+=md5sum_print(fp_md5sums, fname_fpbus_asm);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbus_asm));

			tmp+=md5sum_print(fp_md5sums, fname_fp_sim);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fp_sim));

			tmp+=md5sum_print(fp_md5sums, fname_fpbus_sim);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbus_sim));

			tmp+=md5sum_print(fp_md5sums, fname_fp_bin);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fp_bin));

			tmp+=md5sum_print(fp_md5sums, fname_fpbus_bin);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbus_bin));
#ifdef SINGLELOAD
			tmp+=md5sum_print(fp_md5sums, fname_fpbusB_asm);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_asm));

			tmp+=md5sum_print(fp_md5sums, fname_fpbusB_sim);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_sim));

			tmp+=md5sum_print(fp_md5sums, fname_fpbusB_bin);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_bin));
#endif
		}
		fclose (fp_md5sums);
		if(tmp<0) {
			printf("//===========================MD5SUMS FILE ERROR===============================\n");
			exit(1);
		}

		printf("//==================================DONE======================================\n");
	}
	else {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}
}
//============================================================================
void new_factorial_code_gen(int Narg, char *dir) {
int_t  tmp;
uint_t n, k;
uint_t num_command;
uint_t size_commands;
uint_t size_data;
uint_t loop_iter;
uint_t remainder;
char   *bin_commands;
char   *bin_data;

#ifdef SINGLELOAD
uint_t size_dataB;
char   *bin_dataB;
FILE   *fpbusB_asm, *fpbusB_sim, *fpbusB_bin;
#endif

FILE   *fp_asm, *fpbus_asm;
FILE   *fp_sim, *fpbus_sim;
FILE   *fp_bin, *fpbus_bin;
FILE   *fp_md5sums;

char	fname_fp_asm[MAXFILENAMELENGTH];
char	fname_fpbus_asm[MAXFILENAMELENGTH];
char	fname_fp_sim[MAXFILENAMELENGTH];
char	fname_fpbus_sim[MAXFILENAMELENGTH];
char	fname_fp_bin[MAXFILENAMELENGTH];
char	fname_fpbus_bin[MAXFILENAMELENGTH];
char	fname_fp_md5sums[MAXFILENAMELENGTH];
#ifdef SINGLELOAD
char	fname_fpbusB_asm[MAXFILENAMELENGTH];
char	fname_fpbusB_sim[MAXFILENAMELENGTH];
char	fname_fpbusB_bin[MAXFILENAMELENGTH];
#endif

	if (dir == NULL) {
		fp_asm = fopen (ASMFNAME, "w");
		fpbus_asm = fopen (ASMFBUSA, "w");

		fp_sim = fopen (SIMFNAME, "w");
		fpbus_sim = fopen (SIMFBUSA, "w");

		fp_bin = fopen (BINFNAME, "w");
		fpbus_bin = fopen (BINFBUSA, "w");

		fp_md5sums = fopen (MD5SUMSF, "w");
	} else {
		strcpy ( fname_fp_asm, dir ); strcat ( fname_fp_asm, "/" ); strcat ( fname_fp_asm, ASMFNAME ); fp_asm = fopen (fname_fp_asm, "w");
		strcpy ( fname_fpbus_asm, dir ); strcat ( fname_fpbus_asm, "/" ); strcat ( fname_fpbus_asm, ASMFBUSA ); fpbus_asm = fopen (fname_fpbus_asm, "w");

		strcpy ( fname_fp_sim, dir ); strcat ( fname_fp_sim, "/" ); strcat ( fname_fp_sim, SIMFNAME ); fp_sim = fopen (fname_fp_sim, "w");
		strcpy ( fname_fpbus_sim, dir ); strcat ( fname_fpbus_sim, "/" ); strcat ( fname_fpbus_sim, SIMFBUSA ); fpbus_sim = fopen (fname_fpbus_sim, "w");

		strcpy ( fname_fp_bin, dir ); strcat ( fname_fp_bin, "/" ); strcat ( fname_fp_bin, BINFNAME ); fp_bin = fopen (fname_fp_bin, "w");
		strcpy ( fname_fpbus_bin, dir ); strcat ( fname_fpbus_bin, "/" ); strcat ( fname_fpbus_bin, BINFBUSA ); fpbus_bin = fopen (fname_fpbus_bin, "w");

		strcpy ( fname_fp_md5sums, dir ); strcat ( fname_fp_md5sums, "/" ); strcat ( fname_fp_md5sums, MD5SUMSF ); fp_md5sums = fopen (fname_fp_md5sums, "w");
	}

#ifdef SINGLELOAD
	if (dir == NULL) {
		fpbusB_asm = fopen (ASMFBUSB, "w");
		fpbusB_sim = fopen (SIMFBUSB, "w");
		fpbusB_bin = fopen (BINFBUSB, "w");
	} else {
		strcpy ( fname_fpbusB_asm, dir ); strcat ( fname_fpbusB_asm, "/" ); strcat ( fname_fpbusB_asm, ASMFBUSB ); fpbusB_asm = fopen (fname_fpbusB_asm, "w");
		strcpy ( fname_fpbusB_sim, dir ); strcat ( fname_fpbusB_sim, "/" ); strcat ( fname_fpbusB_sim, SIMFBUSB ); fpbusB_sim = fopen (fname_fpbusB_sim, "w");
		strcpy ( fname_fpbusB_bin, dir ); strcat ( fname_fpbusB_bin, "/" ); strcat ( fname_fpbusB_bin, BINFBUSB ); fpbusB_bin = fopen (fname_fpbusB_bin, "w");
	}

	if (fpbusB_asm==NULL || fpbusB_sim==NULL || fpbusB_bin==NULL) {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}
#endif

	if (fp_asm!=NULL && fpbus_asm!=NULL && fp_sim!=NULL && fpbus_sim!=NULL && fp_bin!=NULL && fpbus_bin!=NULL) {

 		fprintf(fp_asm, ";============================================================================\n");
 		fprintf(fp_asm, ";Name        : factorial_test.c\n");
 		fprintf(fp_asm, ";Author      : Tomasz Stefanski\n");
 		fprintf(fp_asm, ";Version     : 0.1\n");
 		fprintf(fp_asm, ";Copyright   : Your copyright notice\n");
 		fprintf(fp_asm, ";Description : Factorial computations in MPA on SRUP\n");
 		fprintf(fp_asm, ";Input       : N=%d\n", Narg);
 		fprintf(fp_asm, ";============================================================================\n\n\n");

 		k=1;
 		num_command=0;
#ifdef SINGLELOAD
		//set 1 at output, multiplication and increment registers
		fprintf(fpbus_sim,  "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim,  "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbusB_sim, "01 00 01 00 00 00 00 00 02 00 00 00 00 00 00 00\n");
		fprintf(fpbusB_sim, "01 00 01 00 00 00 00 00 02 00 00 00 00 00 00 00\n");

 		size_data=2*16;
 		bin_data = (char*)calloc (size_data, sizeof(char));
 		bin_data[0] =0x01;	bin_data[2] =0x01;	bin_data[8]=0x01;
 		bin_data[16]=0x01;	bin_data[18]=0x01;	bin_data[24]=0x01;

 		size_dataB=2*16;
 		bin_dataB = (char*)calloc (size_dataB, sizeof(char));
 		//bin_dataB[0]=0x02;	bin_dataB[2]=0x01;	bin_dataB[8]=0x01;
 		bin_dataB[0] =0x01;	bin_dataB[2] =0x01;	bin_dataB[8]=0x02;
 		bin_dataB[16]=0x01;	bin_dataB[18]=0x01;	bin_dataB[24]=0x02;

		fprintf(fpbus_asm,  "1) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbus_asm,  "2) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbusB_asm, "1) num_of_limbs=1 sign=0\n0000 0000 0000 0002\n\n");
		fprintf(fpbusB_asm, "2) num_of_limbs=1 sign=0\n0000 0000 0000 0002\n\n");

 		size_commands=8+(Narg-1)*8+2;
 		bin_commands = (char*)calloc (size_commands, sizeof(char));

 		bin_commands[num_command++]=INCBINREG;
 		bin_commands[num_command++]=BREAKBYTE;
 		bin_commands[num_command++]=LOAABBINCOM | (OUTBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;

		fprintf(fp_asm, "%.4d\t\t\t%s %s, %s;\t\t\t%.2X%.2X\n", k++, LOAABCOM, OUTREG, INCREG, bin_commands[num_command-4], bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

 		bin_commands[num_command++]=P1BINREG;
 		bin_commands[num_command++]=BREAKBYTE;
 		bin_commands[num_command++]=LOAABBINCOM | (N1BINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;

		fprintf(fp_asm, "%.4d\t\t\t%s %s, %s;\t\t\t%.2X%.2X\n", k++, LOAABCOM, N1REG, P1REG, bin_commands[num_command-4], bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);
#else
		//set 1 at output, multiplication and increment registers
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 01 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 02 00 00 00 00 00 00 00\n");
		fprintf(fpbus_sim, "01 00 01 00 00 00 00 00 02 00 00 00 00 00 00 00\n");

 		size_data=4*16;
 		bin_data = (char*)calloc (size_data, sizeof(char));
 		bin_data[0] =0x01;	bin_data[2] =0x01;	bin_data[8] =0x01;
 		bin_data[16]=0x01;	bin_data[18]=0x01;	bin_data[24]=0x01;
 		bin_data[32]=0x01;	bin_data[34]=0x01;	bin_data[40]=0x02;
 		bin_data[48]=0x01;	bin_data[40]=0x01;	bin_data[56]=0x02;

		fprintf(fpbus_asm, "1) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbus_asm, "2) num_of_limbs=1 sign=0\n0000 0000 0000 0001\n\n");
		fprintf(fpbus_asm, "3) num_of_limbs=1 sign=0\n0000 0000 0000 0002\n\n");
		fprintf(fpbus_asm, "4) num_of_limbs=1 sign=0\n0000 0000 0000 0002\n\n");

 		size_commands=8+(Narg-1)*8+2;
 		bin_commands = (char*)calloc (size_commands, sizeof(char));

 		bin_commands[num_command++]=LOAABINCOM | (OUTBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, OUTREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);

		bin_commands[num_command++]=LOAABINCOM | (N1BINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, N1REG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);

 		bin_commands[num_command++]=LOAABINCOM | (INCBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, INCREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);

 		bin_commands[num_command++]=LOAABINCOM | (P1BINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, LOAACOM, P1REG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
#endif

		//multiply integers
		loop_iter = (Narg-1)/4;
		remainder = (Narg-1)%4;
		for(n=1; n<=loop_iter; n++) {
			//multiply
	 		bin_commands[num_command++]=OUTBINREG | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (P1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, P1REG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//add
	 		bin_commands[num_command++]=INCBINREG  | (N2BINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (N1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, N1REG, INCREG, N2REG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply
	 		bin_commands[num_command++]=TMPBINREG | (OUTBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (N2BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, N2REG, TMPREG, OUTREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//add
	 		bin_commands[num_command++]=INCBINREG  | (P2BINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (P1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, P1REG, INCREG, P2REG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply
	 		bin_commands[num_command++]=OUTBINREG | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (P2BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, P2REG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//add
	 		bin_commands[num_command++]=INCBINREG  | (N1BINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (N2BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, N2REG, INCREG, N1REG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply
	 		bin_commands[num_command++]=TMPBINREG | (OUTBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (N1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, N1REG, TMPREG, OUTREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			if ( (n==loop_iter) && (remainder == 0) ) {
				//unload register
				bin_commands[num_command++]=UNLBINCOM | (OUTBINREG<<4);
		 		bin_commands[num_command++]=LASTBYTE;
				fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, OUTREG, bin_commands[num_command-2]);
				fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
			} else {
				//add
				bin_commands[num_command++]=INCBINREG  | (P1BINREG<<4);
				bin_commands[num_command++]=BREAKBYTE;
				bin_commands[num_command++]=ADDBINCOM | (P2BINREG<<4);
				bin_commands[num_command++]=LASTBYTE;
				fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, P2REG, INCREG, P1REG, bin_commands[num_command-4], bin_commands[num_command-2]);
				fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);
			}
		}

		if(remainder == 0 && Narg==4) {//FACTORIAL==4 - remainer=0
//TU CONT
		}
		if(remainder == 1) {//FACTORIAL - remainer=1
			//multiply
	 		bin_commands[num_command++]=OUTBINREG | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (P1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, P1REG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//unload register
			bin_commands[num_command++]=UNLBINCOM | (TMPBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, TMPREG, bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
		}
		if(remainder == 2) {//FACTORIAL - remainer=2
			//multiply
	 		bin_commands[num_command++]=OUTBINREG | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (P1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, P1REG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//add
	 		bin_commands[num_command++]=INCBINREG  | (N2BINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (N1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, N1REG, INCREG, N2REG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply
	 		bin_commands[num_command++]=TMPBINREG | (OUTBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (N2BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, N2REG, TMPREG, OUTREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//unload register
			bin_commands[num_command++]=UNLBINCOM | (OUTBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, OUTREG, bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
		}
		if(remainder == 3) {//FACTORIAL - remainer=3
			//multiply
	 		bin_commands[num_command++]=OUTBINREG | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (P1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, P1REG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//add
	 		bin_commands[num_command++]=INCBINREG  | (N2BINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (N1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, N1REG, INCREG, N2REG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply
	 		bin_commands[num_command++]=TMPBINREG | (OUTBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (N2BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, N2REG, TMPREG, OUTREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//add
	 		bin_commands[num_command++]=INCBINREG  | (P2BINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=ADDBINCOM | (P1BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, P1REG, INCREG, P2REG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//multiply
	 		bin_commands[num_command++]=OUTBINREG | (TMPBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (P2BINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, MULTCOM, P2REG, OUTREG, TMPREG, bin_commands[num_command-4], bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

			//unload register
			bin_commands[num_command++]=UNLBINCOM | (TMPBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, TMPREG, bin_commands[num_command-2]);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
		}

		fclose (fp_asm);
		fclose (fpbus_asm);

		fclose (fp_sim);
		fclose (fpbus_sim);

		//fwrite (bin_commands, sizeof(char), size_commands, fp_bin);
		fwrite (bin_commands, sizeof(char), num_command, fp_bin);
		fclose (fp_bin);
		fwrite (bin_data, sizeof(char), size_data, fpbus_bin);
		fclose (fpbus_bin);

#ifdef SINGLELOAD
		fclose (fpbusB_asm);
		fclose (fpbusB_sim);
		fwrite (bin_dataB, sizeof(char), size_dataB, fpbusB_bin);
		fclose (fpbusB_bin);

		free(bin_dataB);
#endif
		free(bin_commands);
		free(bin_data);

		//MD5 sums
		tmp=0;
		fprintf(fp_md5sums, "#Input       : N=%d\n", Narg);
		if (dir == NULL) {
			tmp+=md5sum_print(fp_md5sums, ASMFNAME);
			fprintf(fp_md5sums, "  %s\n", ASMFNAME);

			tmp+=md5sum_print(fp_md5sums, ASMFBUSA);
			fprintf(fp_md5sums, "  %s\n", ASMFBUSA);

			tmp+=md5sum_print(fp_md5sums, SIMFNAME);
			fprintf(fp_md5sums, "  %s\n", SIMFNAME);

			tmp+=md5sum_print(fp_md5sums, SIMFBUSA);
			fprintf(fp_md5sums, "  %s\n", SIMFBUSA);

			tmp+=md5sum_print(fp_md5sums, BINFNAME);
			fprintf(fp_md5sums, "  %s\n", BINFNAME);

			tmp+=md5sum_print(fp_md5sums, BINFBUSA);
			fprintf(fp_md5sums, "  %s\n", BINFBUSA);
#ifdef SINGLELOAD
			tmp+=md5sum_print(fp_md5sums, ASMFBUSB);
			fprintf(fp_md5sums, "  %s\n", ASMFBUSB);

			tmp+=md5sum_print(fp_md5sums, SIMFBUSB);
			fprintf(fp_md5sums, "  %s\n", SIMFBUSB);

			tmp+=md5sum_print(fp_md5sums, BINFBUSB);
			fprintf(fp_md5sums, "  %s\n", BINFBUSB);
#endif
		} else {
			tmp+=md5sum_print(fp_md5sums, fname_fp_asm);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fp_asm));

			tmp+=md5sum_print(fp_md5sums, fname_fpbus_asm);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbus_asm));

			tmp+=md5sum_print(fp_md5sums, fname_fp_sim);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fp_sim));

			tmp+=md5sum_print(fp_md5sums, fname_fpbus_sim);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbus_sim));

			tmp+=md5sum_print(fp_md5sums, fname_fp_bin);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fp_bin));

			tmp+=md5sum_print(fp_md5sums, fname_fpbus_bin);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbus_bin));
#ifdef SINGLELOAD
			tmp+=md5sum_print(fp_md5sums, fname_fpbusB_asm);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_asm));

			tmp+=md5sum_print(fp_md5sums, fname_fpbusB_sim);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_sim));

			tmp+=md5sum_print(fp_md5sums, fname_fpbusB_bin);
			fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_bin));
#endif
		}
		fclose (fp_md5sums);
		if(tmp<0) {
			printf("//===========================MD5SUMS FILE ERROR===============================\n");
			exit(1);
		}

		printf("//==================================DONE======================================\n");
	}
	else {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}
}
//============================================================================
int main(int argc, char **argv) {

	char *pos = NULL;
	int  Nf = 1;
	struct stat st = {0};

	if (argc == 1) {//print help
		fprintf (stderr, "	usage: ./factorial_data <N> <optional directory>\n");
		exit (1);
	} else if (argc == 2) {//directory of execution
		Nf = atoi (argv[1]);
	} else if (argc == 3) {//directory specified by a user
		Nf = atoi (argv[1]);

		//create directory if does not exist
		pos = argv[2];
		if (stat(pos, &st) == -1) {
		    mkdir(pos, 0775);
		}

		pos = realpath(argv[2], NULL);
	} else {//print help
		fprintf (stderr, "	usage: ./factorial_data <N> <optional directory>\n");
		exit (2);
	}

#ifdef FILESNEWGEN
	new_factorial_code_gen(Nf, pos);
#else
	factorial_code_gen(Nf, pos);
#endif

	if(pos)
		free(pos);

	return 0;
}
//============================================================================
