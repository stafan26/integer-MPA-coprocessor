/*
 ============================================================================
Name        : random_data.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Random data generation for SRUP
 ============================================================================
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libgen.h>
#include <gmp.h>
#include "lfsr.h"
#include "md5sum.h"
#include "../../common/write_fun.h"

#define MAXFILENAMELENGTH 1024

/** General assembler generation parameters **/
#define NUMINSTR	7
#define NUMPREC		32640
#define NUMBITPREC	15
#define NUMREG		16
#define DEFAULTL	10

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

#define LOAATYPECOM		1
#define LOABTYPECOM		1
#define LOAABTYPECOM	2
#define UNLTYPECOM		1
#define MULTTYPECOM		3
#define ADDTYPECOM		3
#define SUBTYPECOM		3

#define LASTBYTE	0x01
#define BREAKBYTE	0x00

#define MAXBYTES	4096

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
typedef char char_t;

/** Instruction tables **/
char codes_instr[]={
		LOAABINCOM,
		LOABBINCOM,
		LOAABBINCOM,
		UNLBINCOM,
		MULTBINCOM,
		ADDBINCOM,
		SUBBINCOM
};
char* asm_instr[]={
		LOAACOM,
		LOABCOM,
		LOAABCOM,
		UNLCOM,
		MULTCOM,
		ADDCOM,
		SUBCOM
};
char types_instr[]={
		LOAATYPECOM,
		LOABTYPECOM,
		LOAABTYPECOM,
		UNLTYPECOM,
		MULTTYPECOM,
		ADDTYPECOM,
		SUBTYPECOM
};

//============================================================================
void random_code_gen(uint_t num_instr, char *dir) {

int_t	tmp;
uint_t	k;
uint_t	remainder;
uint_t	num_command;
uint_t	regX, regY, regZ;
char	bin_commands[4];

FILE   *fp_asm, *fpbus_asm, *fpbusB_asm;
FILE   *fp_sim, *fpbus_sim, *fpbusB_sim;
FILE   *fp_bin, *fpbus_bin, *fpbusB_bin;
FILE   *fp_md5sums;

gmp_randstate_t state;
mpz_t my_random, tmp_mpz;

char	fname_fp_asm[MAXFILENAMELENGTH];
char	fname_fpbus_asm[MAXFILENAMELENGTH];
char	fname_fp_sim[MAXFILENAMELENGTH];
char	fname_fpbus_sim[MAXFILENAMELENGTH];
char	fname_fp_bin[MAXFILENAMELENGTH];
char	fname_fpbus_bin[MAXFILENAMELENGTH];
char	fname_fp_md5sums[MAXFILENAMELENGTH];
char	fname_fpbusB_asm[MAXFILENAMELENGTH];
char	fname_fpbusB_sim[MAXFILENAMELENGTH];
char	fname_fpbusB_bin[MAXFILENAMELENGTH];

	mpz_inits(my_random, tmp_mpz, NULL);
	gmp_randinit_default (state);
	//gmp_printf ("Seed: %Zd\n", state->_mp_seed);

	if (dir == NULL) {
		fp_asm = fopen (ASMFNAME, "w");
		fpbus_asm = fopen (ASMFBUSA, "w");

		fp_sim = fopen (SIMFNAME, "w");
		fpbus_sim = fopen (SIMFBUSA, "w");

		fp_bin = fopen (BINFNAME, "w");
		fpbus_bin = fopen (BINFBUSA, "w");

		fp_md5sums = fopen (MD5SUMSF, "w");

		fpbusB_asm = fopen (ASMFBUSB, "w");
		fpbusB_sim = fopen (SIMFBUSB, "w");
		fpbusB_bin = fopen (BINFBUSB, "w");
	} else {
		strcpy ( fname_fp_asm, dir ); strcat ( fname_fp_asm, "/" ); strcat ( fname_fp_asm, ASMFNAME ); fp_asm = fopen (fname_fp_asm, "w");
		strcpy ( fname_fpbus_asm, dir ); strcat ( fname_fpbus_asm, "/" ); strcat ( fname_fpbus_asm, ASMFBUSA ); fpbus_asm = fopen (fname_fpbus_asm, "w");

		strcpy ( fname_fp_sim, dir ); strcat ( fname_fp_sim, "/" ); strcat ( fname_fp_sim, SIMFNAME ); fp_sim = fopen (fname_fp_sim, "w");
		strcpy ( fname_fpbus_sim, dir ); strcat ( fname_fpbus_sim, "/" ); strcat ( fname_fpbus_sim, SIMFBUSA ); fpbus_sim = fopen (fname_fpbus_sim, "w");

		strcpy ( fname_fp_bin, dir ); strcat ( fname_fp_bin, "/" ); strcat ( fname_fp_bin, BINFNAME ); fp_bin = fopen (fname_fp_bin, "w");
		strcpy ( fname_fpbus_bin, dir ); strcat ( fname_fpbus_bin, "/" ); strcat ( fname_fpbus_bin, BINFBUSA ); fpbus_bin = fopen (fname_fpbus_bin, "w");

		strcpy ( fname_fp_md5sums, dir ); strcat ( fname_fp_md5sums, "/" ); strcat ( fname_fp_md5sums, MD5SUMSF ); fp_md5sums = fopen (fname_fp_md5sums, "w");

		strcpy ( fname_fpbusB_asm, dir ); strcat ( fname_fpbusB_asm, "/" ); strcat ( fname_fpbusB_asm, ASMFBUSB ); fpbusB_asm = fopen (fname_fpbusB_asm, "w");
		strcpy ( fname_fpbusB_sim, dir ); strcat ( fname_fpbusB_sim, "/" ); strcat ( fname_fpbusB_sim, SIMFBUSB ); fpbusB_sim = fopen (fname_fpbusB_sim, "w");
		strcpy ( fname_fpbusB_bin, dir ); strcat ( fname_fpbusB_bin, "/" ); strcat ( fname_fpbusB_bin, BINFBUSB ); fpbusB_bin = fopen (fname_fpbusB_bin, "w");
	}

	if (fp_asm!=NULL && fpbus_asm!=NULL && fpbusB_asm!=NULL && fp_sim!=NULL && fpbus_sim!=NULL && fpbusB_sim!=NULL && fp_bin!=NULL && fpbus_bin!=NULL && fpbusB_bin!=NULL) {

 		fprintf(fp_asm, ";============================================================================\n");
 		fprintf(fp_asm, ";Name        : random_data.c\n");
 		fprintf(fp_asm, ";Author      : Tomasz Stefanski\n");
 		fprintf(fp_asm, ";Version     : 0.1\n");
 		fprintf(fp_asm, ";Copyright   : Your copyright notice\n");
 		fprintf(fp_asm, ";Description : Random data generation for SRUP\n");
 		fprintf(fp_asm, ";Input       : number_of_instructions_to_generate=%d\n", num_instr);
 		fprintf(fp_asm, ";============================================================================\n\n\n");
#if 1
 		//initialization of registers
 		for (k=0; k<NUMREG; k++) {
 			num_command = 0;
			regX = k;

			//send data to files
	 		bin_commands[num_command++]=LOAABINCOM | (regX<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s reg%d;\t\t\t\t  %.2X\n", k, LOAACOM, regX, bin_commands[num_command-2] & 0xff);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
			fwrite (bin_commands, sizeof(char), num_command, fp_bin);

			//send data to bus file
			mpz_urandomb (my_random, state, NUMPREC);
			write_sim_number (fpbus_sim, my_random);
			write_asm_number (fpbus_asm, my_random);
			write_bin_number (fpbus_bin, my_random);
 		}
#endif
 		//main loop of the random code generation
 		for (k=0; k<num_instr; k++) {
 			num_command = 0;

 			//generate the instruction
 			mpz_urandomb (my_random, state, NUMPREC);
 			remainder = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMINSTR);
 			switch (types_instr[remainder]) {
				case 1:
		 			mpz_urandomb (my_random, state, NUMPREC);
		 			regX = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMREG);

		 			//send data to files
		 	 		bin_commands[num_command++]=codes_instr[remainder] | (regX<<4);
		 	 		bin_commands[num_command++]=LASTBYTE;
		 			fprintf(fp_asm, "%.4d\t\t\t%s reg%d;\t\t\t\t  %.2X\n", k, asm_instr[remainder], regX, bin_commands[num_command-2] & 0xff);
		 			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);

		 			//send data to bus file
		 			if (codes_instr[remainder] == LOAABINCOM) {
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				write_sim_number (fpbus_sim, my_random);
		 				write_asm_number (fpbus_asm, my_random);
		 				write_bin_number (fpbus_bin, my_random);
		 			}
		 			if (codes_instr[remainder] == LOABBINCOM) {
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				write_sim_number (fpbusB_sim, my_random);
		 				write_asm_number (fpbusB_asm, my_random);
		 				write_bin_number (fpbusB_bin, my_random);
		 			}
					break;
				case 2:
		 			mpz_urandomb (my_random, state, NUMPREC);
		 			regX = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMREG);
		 			do {
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				regY = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMREG);
		 			} while (regY == regX);

		 			//send data to files
		 	 		bin_commands[num_command++]=regY;
		 	 		bin_commands[num_command++]=BREAKBYTE;
		 	 		bin_commands[num_command++]=codes_instr[remainder] | (regX<<4);
		 	 		bin_commands[num_command++]=LASTBYTE;
		 			fprintf(fp_asm, "%.4d\t\t\t%s reg%d, reg%d;\t\t\t%.2X%.2X\n", k, asm_instr[remainder], regX, regY, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
		 			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);

		 			//send data to bus file
		 			if (codes_instr[remainder] == LOAABBINCOM) {
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				write_sim_number (fpbus_sim, my_random);
		 				write_asm_number (fpbus_asm, my_random);
		 				write_bin_number (fpbus_bin, my_random);
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				write_sim_number (fpbusB_sim, my_random);
		 				write_asm_number (fpbusB_asm, my_random);
		 				write_bin_number (fpbusB_bin, my_random);
		 			}
					break;
				case 3:
		 			mpz_urandomb (my_random, state, NUMPREC);
		 			regX = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMREG);
		 			do {
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				regY = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMREG);
		 			} while (regY == regX);
		 			do {
		 				mpz_urandomb (my_random, state, NUMPREC);
		 				regZ = mpz_cdiv_r_ui (tmp_mpz, my_random, NUMREG);
		 			} while (regZ == regX || regZ == regY);

		 			//send data to files
			 		bin_commands[num_command++]=regY | (regZ<<4);
			 		bin_commands[num_command++]=BREAKBYTE;
			 		bin_commands[num_command++]=codes_instr[remainder] | (regX<<4);
			 		bin_commands[num_command++]=LASTBYTE;
					fprintf(fp_asm, "%.4d\t\t\t%s reg%d, reg%d, reg%d;\t\t\t%.2X%.2X\n", k, asm_instr[remainder], regX, regY, regZ, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
					fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
					break;
				default:
					fprintf (stderr, "Unknown instruction type\n");
					exit (1);
 			}
 			fwrite (bin_commands, sizeof(char), num_command, fp_bin);
 		}

		mpz_clears(my_random, tmp_mpz, NULL);

		fclose (fp_asm);
		fclose (fpbus_asm);
		fclose (fpbusB_asm);

		fclose (fp_sim);
		fclose (fpbus_sim);
		fclose (fpbusB_sim);

		fclose (fp_bin);
		fclose (fpbus_bin);
		fclose (fpbusB_bin);

		//MD5 sums
		tmp=0;
		fprintf(fp_md5sums, "#Input       : number_of_instructions_to_generate=%d\n", num_instr);
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
	else {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}
}
//============================================================================
int main(int argc, char *argv[]) {

char *pos = NULL;
uint_t num_instr = DEFAULTL;
struct stat st = {0};

	//check correctness of function call
	if (argc == 1) {//print help
		fprintf (stderr, "	usage: ./random_data <number_of_instructions_to_generate> <optional directory>\n");
		exit (1);
	} else if (argc == 2) {//default directory of execution
		num_instr = (uint_t) atoi (argv[1]);
	} else if (argc == 3) {//directory specified by a user
		num_instr = (uint_t) atoi (argv[1]);

		//create directory if does not exist
		pos = argv[2];
		if (stat(pos, &st) == -1) {
		    mkdir(pos, 0775);
		}

		pos = realpath(argv[2], NULL);
	} else {//print help
		fprintf (stderr, "	usage: ./random_data <number_of_instructions_to_generate> <optional directory>\n");
		exit (2);
	}

	random_code_gen(num_instr, pos);

	if(pos)
		free(pos);
	return 0;
}
//============================================================================
