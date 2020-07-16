/*
 ============================================================================
Name        : addition_data.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Addition computations in MPA on SRUP
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
#include "lfsr.h"
#include "../../common/write_fun.h"

#define MAXFILENAMELENGTH 1024
#define MAXBYTES	4096

/** Speed test parameters **/
#define REPF	9

/** General assembler generation parameters **/
#define XREG		"reg0"
#define YREG		"reg1"
#define ZREG		"reg2"

#define XBINREG	0x00
#define YBINREG	0x01
#define ZBINREG	0x02

#define LOAACOM	"loaa"
#define LOABCOM	"loab"
#define LOAABCOM	"loaab"
#define UNLCOM		"unl"
#define MULTCOM	"mult"
#define ADDCOM		"add"
#define SUBCOM		"sub"

#define LOAABINCOM	0x01
#define LOABBINCOM	0x02
#define LOAABBINCOM	0x03
#define UNLBINCOM		0x04
#define MULTBINCOM	0x08
#define ADDBINCOM		0x09
#define SUBBINCOM		0x0A

#define LASTBYTE		0x01
#define BREAKBYTE		0x00

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
void addition_code_gen(char *dir) {

int i;
int prec [] = {128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32640};

int_t  tmp;
uint_t n, k;
uint_t num_command;
uint_t size_commands;
char   *bin_commands;

FILE   *fp_asm, *fpbus_asm, *fpbusB_asm;
FILE   *fp_sim, *fpbus_sim, *fpbusB_sim;
FILE   *fp_bin, *fpbus_bin, *fpbusB_bin;
FILE   *fp_md5sums;

char	fname_fp_asm[MAXFILENAMELENGTH];
char	fname_fpbus_asm[MAXFILENAMELENGTH];
char	fname_fpbusB_asm[MAXFILENAMELENGTH];

char	fname_fp_sim[MAXFILENAMELENGTH];
char	fname_fpbus_sim[MAXFILENAMELENGTH];
char	fname_fpbusB_sim[MAXFILENAMELENGTH];

char	fname_fp_bin[MAXFILENAMELENGTH];
char	fname_fpbus_bin[MAXFILENAMELENGTH];
char	fname_fpbusB_bin[MAXFILENAMELENGTH];

char	fname_fp_md5sums[MAXFILENAMELENGTH];

gmp_randstate_t state;
mpz_t my_random1, my_random2;

	if (dir == NULL) {
		fp_asm = fopen (ASMFNAME, "w");
		fpbus_asm = fopen (ASMFBUSA, "w");
		fpbusB_asm = fopen (ASMFBUSB, "w");

		fp_sim = fopen (SIMFNAME, "w");
		fpbus_sim = fopen (SIMFBUSA, "w");
		fpbusB_sim = fopen (SIMFBUSB, "w");

		fp_bin = fopen (BINFNAME, "w");
		fpbus_bin = fopen (BINFBUSA, "w");
		fpbusB_bin = fopen (BINFBUSB, "w");

		fp_md5sums = fopen (MD5SUMSF, "w");
	} else {
		strcpy ( fname_fp_asm, dir ); strcat ( fname_fp_asm, "/" ); strcat ( fname_fp_asm, ASMFNAME ); fp_asm = fopen (fname_fp_asm, "w");
		strcpy ( fname_fpbus_asm, dir ); strcat ( fname_fpbus_asm, "/" ); strcat ( fname_fpbus_asm, ASMFBUSA ); fpbus_asm = fopen (fname_fpbus_asm, "w");
		strcpy ( fname_fpbusB_asm, dir ); strcat ( fname_fpbusB_asm, "/" ); strcat ( fname_fpbusB_asm, ASMFBUSB ); fpbusB_asm = fopen (fname_fpbusB_asm, "w");

		strcpy ( fname_fp_sim, dir ); strcat ( fname_fp_sim, "/" ); strcat ( fname_fp_sim, SIMFNAME ); fp_sim = fopen (fname_fp_sim, "w");
		strcpy ( fname_fpbus_sim, dir ); strcat ( fname_fpbus_sim, "/" ); strcat ( fname_fpbus_sim, SIMFBUSA ); fpbus_sim = fopen (fname_fpbus_sim, "w");
		strcpy ( fname_fpbusB_sim, dir ); strcat ( fname_fpbusB_sim, "/" ); strcat ( fname_fpbusB_sim, SIMFBUSB ); fpbusB_sim = fopen (fname_fpbusB_sim, "w");

		strcpy ( fname_fp_bin, dir ); strcat ( fname_fp_bin, "/" ); strcat ( fname_fp_bin, BINFNAME ); fp_bin = fopen (fname_fp_bin, "w");
		strcpy ( fname_fpbus_bin, dir ); strcat ( fname_fpbus_bin, "/" ); strcat ( fname_fpbus_bin, BINFBUSA ); fpbus_bin = fopen (fname_fpbus_bin, "w");
		strcpy ( fname_fpbusB_bin, dir ); strcat ( fname_fpbusB_bin, "/" ); strcat ( fname_fpbusB_bin, BINFBUSB ); fpbusB_bin = fopen (fname_fpbusB_bin, "w");

		strcpy ( fname_fp_md5sums, dir ); strcat ( fname_fp_md5sums, "/" ); strcat ( fname_fp_md5sums, MD5SUMSF ); fp_md5sums = fopen (fname_fp_md5sums, "w");
	}

	if (	fp_asm==NULL || fpbus_asm==NULL || fpbusB_asm==NULL ||
			fp_sim==NULL || fpbus_sim==NULL || fpbusB_sim==NULL ||
			fp_bin==NULL || fpbus_bin==NULL || fpbusB_bin==NULL ||
			fp_md5sums==NULL
	) {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}

	fprintf(fp_asm, ";============================================================================\n");
	fprintf(fp_asm, ";Name        : addition_data.c\n");
	fprintf(fp_asm, ";Author      : Tomasz Stefanski\n");
	fprintf(fp_asm, ";Version     : 0.1\n");
	fprintf(fp_asm, ";Copyright   : Your copyright notice\n");
	fprintf(fp_asm, ";Description : Addition computations in MPA on SRUP\n");
	fprintf(fp_asm, ";============================================================================\n\n\n");

	k = 0;
	num_command=0;
	size_commands=REPF*10;
 	bin_commands = (char*)calloc (size_commands, sizeof(char));

	mpz_inits(my_random1, my_random2, NULL);
	gmp_randinit_default (state);

	for (i=0; i<REPF; i++) {
		n = prec[i];

		//load numbers
		mpz_urandomb (my_random1, state, n);
		write_sim_number (fpbus_sim, my_random1);
		write_asm_number (fpbus_asm, my_random1);
		write_bin_number (fpbus_bin, my_random1);

		mpz_urandomb (my_random2, state, n);
		write_sim_number (fpbusB_sim, my_random2);
		write_asm_number (fpbusB_asm, my_random2);
		write_bin_number (fpbusB_bin, my_random2);

 		bin_commands[num_command++]=YBINREG;
 		bin_commands[num_command++]=BREAKBYTE;
 		bin_commands[num_command++]=LOAABBINCOM | (XBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;

		fprintf(fp_asm, "%.4d\t\t\t%s %s, %s;\t\t\t%.2X%.2X\n", k++, LOAABCOM, XREG, YREG, bin_commands[num_command-4], bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

		//add numbers
	 	bin_commands[num_command++]=YBINREG | (ZBINREG<<4);
	 	bin_commands[num_command++]=BREAKBYTE;
	 	bin_commands[num_command++]=ADDBINCOM | (XBINREG<<4);
	 	bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", k++, ADDCOM, XREG, YREG, ZREG, bin_commands[num_command-4], bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4], bin_commands[num_command-3], bin_commands[num_command-2], bin_commands[num_command-1]);

		//unload result
		bin_commands[num_command++]=UNLBINCOM | (ZBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", k++, UNLCOM, ZREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);
	}

	fclose (fp_asm);
	fclose (fpbus_asm);
	fclose (fpbusB_asm);

	fclose (fp_sim);
	fclose (fpbus_sim);
	fclose (fpbusB_sim);

	fwrite (bin_commands, sizeof(char), size_commands, fp_bin);
	fclose (fp_bin);
	fclose (fpbus_bin);
	fclose (fpbusB_bin);

	free(bin_commands);

	//MD5 sums
	tmp=0;
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

		tmp+=md5sum_print(fp_md5sums, ASMFBUSB);
		fprintf(fp_md5sums, "  %s\n", ASMFBUSB);

		tmp+=md5sum_print(fp_md5sums, SIMFBUSB);
		fprintf(fp_md5sums, "  %s\n", SIMFBUSB);

		tmp+=md5sum_print(fp_md5sums, BINFBUSB);
		fprintf(fp_md5sums, "  %s\n", BINFBUSB);

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

		tmp+=md5sum_print(fp_md5sums, fname_fpbusB_asm);
		fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_asm));

		tmp+=md5sum_print(fp_md5sums, fname_fpbusB_sim);
		fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_sim));

		tmp+=md5sum_print(fp_md5sums, fname_fpbusB_bin);
		fprintf(fp_md5sums, "  %s\n", basename(fname_fpbusB_bin));

	}
	fclose (fp_md5sums);
	if(tmp<0) {
		printf("//===========================MD5SUMS FILE ERROR===============================\n");
		exit(1);
	}

	printf("//==================================DONE======================================\n");
}
//============================================================================
int main(int argc, char **argv) {

	char *pos = NULL;
	struct stat st = {0};

//#define LFSRTEST

#ifdef LFSRTEST
	unsigned int		lfsr_num;
	unsigned int		number_size;
	for(unsigned int i=1; i<10; i++) {
		num2lfsr(&lfsr_num, i, 9);
		lfsr2num(&number_size, lfsr_num, 9);
		printf("%u %u %u\n", i, lfsr_num, number_size);
	}
	exit(0);
#endif

	if (argc == 1) {//print help
		fprintf (stderr, "	usage: ./addition_data <optional directory>\n");
		exit (1);
	} else if (argc == 2) {//directory of execution

		//create directory if does not exist
		pos = argv[1];
		if (stat(pos, &st) == -1) {
		    mkdir(pos, 0775);
		}

		pos = realpath(argv[1], NULL);
	} else {//print help
		fprintf (stderr, "	usage: ./addition_data <optional directory>\n");
		exit (2);
	}

	addition_code_gen(pos);

	if(pos)
		free(pos);

	return 0;
}
//============================================================================
