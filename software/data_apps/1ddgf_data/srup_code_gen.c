/*
 ============================================================================
 Name        : srup_code_gen.c
 Author      :
 Version     :
 Copyright   :
 Description : Generation of 1d dgf for SRUP
 ============================================================================
 */

#include "srup_code_gen.h"
#include "../../common/write_fun.h"

#define MAXFILENAMELENGTH 1024

#define XREG		"reg0"
#define YREG		"reg1"
#define ZREG		"reg2"
#define RESREG		"reg3"
#define ALTREG		"reg4"

#define XBINREG		0x00
#define YBINREG		0x01
#define ZBINREG		0x02
#define RESBINREG	0x03
#define ALTBINREG	0x04

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

//===========================================================================
//	Helpful math functions
//===========================================================================
uint_t binomial_std(uint_t n, uint_t k) {

uint_t c = 1, i;

	if (k > n-k) k = n-k;  /* take advantage of symmetry */

	for (i = 1; i <= k; i++, n--) {
	    if (c/i > UINT_MAX/n) return 0;  /* return 0 on overflow */
	    c = c/i * n + c%i * n / i;  /* split c*n/i into (c/i*i + c%i)*n/i */
	}
	return c;
}
//===========================================================================
int_t scalar_dgf_cflf1_std(uint_t n, uint_t k) {

int_t out;

    if(n<=k) {
            out=0;
    } else {
            out=(n+k)%2;
    }

	return out;
}
//===========================================================================
void binomial_mpa(mpz_t rop, uint_t n, uint_t k) {

uint_t i;
mpz_t q, r;
mpz_t part1, part2;

	mpz_set_ui (rop, 1);
	mpz_inits (q, r, part1, part2, NULL);

	if (k > n-k) k = n-k;  /* take advantage of symmetry */

	for (i = 1; i <= k; i++, n--) {
	    //like in C above: c = c/i * n + c%i * n / i;  /* split c*n/i into (c/i*i + c%i)*n/i */
		mpz_cdiv_qr_ui (q, r, rop, (unsigned long int) i);
		mpz_mul_ui (part1, q, (unsigned long int) n);
		mpz_mul_ui (q, r, (unsigned long int) n);
		mpz_cdiv_q_ui (part2, q, (unsigned long int) i);
		mpz_add (rop, part1, part2);
	}

	mpz_clears (q, r, part1, part2, NULL);
}
//===========================================================================
void srup_code_gen(int_t n, int_t k, char *dir) {

int_t	tmp;
uint_t	ui_res;
uint_t	counter;
uint_t	out2res;
uint_t	num_line;
uint_t	num_command;
uint_t	size_commands;
char	*bin_commands;

FILE	*fpbusB_asm, *fpbusB_sim, *fpbusB_bin;

FILE	*fp_asm, *fpbus_asm;
FILE	*fp_sim, *fpbus_sim;
FILE	*fp_bin, *fpbus_bin;
FILE	*fp_md5sums;

mpz_t	mpz_num1, mpz_num2, mpz_res, mpz_tmp;

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

	if (fpbusB_asm==NULL || fpbusB_sim==NULL || fpbusB_bin==NULL) {
		printf("//===============================FILE ERROR===================================\n");
		exit(1);
	}

	if (fp_asm!=NULL && fpbus_asm!=NULL && fp_sim!=NULL && fpbus_sim!=NULL && fp_bin!=NULL && fpbus_bin!=NULL) {

 		fprintf(fp_asm, ";============================================================================\n");
 		fprintf(fp_asm, ";Name        : srup_code_gen.c\n");
 		fprintf(fp_asm, ";Author      : Tomasz Stefanski\n");
 		fprintf(fp_asm, ";Version     : 0.1\n");
 		fprintf(fp_asm, ";Copyright   : Your copyright notice\n");
 		fprintf(fp_asm, ";Description : Generation of 1d dgf for SRUP\n");
 		fprintf(fp_asm, ";Input       : N=%d, K=%d\n", n, k);
 		fprintf(fp_asm, ";============================================================================\n\n\n");

 		size_commands=((n-1) - abs(k) + 1)*12+4;
 		bin_commands = (char*)calloc (size_commands, sizeof(char));

 		out2res=1;
 		num_command=0;
 		num_line=0;
		mpz_inits (mpz_num1, mpz_num2, mpz_tmp, mpz_res, NULL);

		//initialize registers
 		bin_commands[num_command++]=LOAABINCOM | (ALTBINREG<<4);
 		bin_commands[num_command++]=LASTBYTE;
		fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", num_line++, LOAACOM, ALTREG, bin_commands[num_command-2]);
		fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2], bin_commands[num_command-1]);

		write_sim_number (fpbus_sim, mpz_num1);
		write_asm_number (fpbus_asm, mpz_num1);
		write_bin_number (fpbus_bin, mpz_num1);

		for(counter = abs(k); counter<=(n-1); counter++) {

			//generate numbers, send to busses and load them
			binomial_mpa (mpz_num1, counter + n, 2*counter + 1);
			binomial_mpa (mpz_num2, 2*counter, counter + k);

 	 		bin_commands[num_command++]=YBINREG;
 	 		bin_commands[num_command++]=BREAKBYTE;
 	 		bin_commands[num_command++]=LOAABBINCOM | (XBINREG<<4);
 	 		bin_commands[num_command++]=LASTBYTE;
 			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s;\t\t\t%.2X%.2X\n", num_line++, LOAABCOM, XREG, YREG, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
 			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);

			write_sim_number (fpbus_sim, mpz_num1);
			write_asm_number (fpbus_asm, mpz_num1);
			write_bin_number (fpbus_bin, mpz_num1);

			write_sim_number (fpbusB_sim, mpz_num2);
			write_asm_number (fpbusB_asm, mpz_num2);
			write_bin_number (fpbusB_bin, mpz_num2);

			//multiply them
			mpz_mul (mpz_tmp, mpz_num1, mpz_num2);

	 		bin_commands[num_command++]=YBINREG  | (ZBINREG<<4);
	 		bin_commands[num_command++]=BREAKBYTE;
	 		bin_commands[num_command++]=MULTBINCOM | (XBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", num_line++, MULTCOM, XREG, YREG, ZREG, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
			fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);

			//add/subtract
			if ((counter + k)%2 == 1) {//subtract
				mpz_sub (mpz_res, mpz_res, mpz_tmp);

				if (out2res == 1) {
			 		bin_commands[num_command++]=ZBINREG  | (RESBINREG<<4);
			 		bin_commands[num_command++]=BREAKBYTE;
			 		bin_commands[num_command++]=SUBBINCOM | (ALTBINREG<<4);
			 		bin_commands[num_command++]=LASTBYTE;
					fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", num_line++, SUBCOM, ALTREG, ZREG, RESREG, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
					fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
					out2res=0;
				} else {//out2res == 0
			 		bin_commands[num_command++]=ZBINREG  | (ALTBINREG<<4);
			 		bin_commands[num_command++]=BREAKBYTE;
			 		bin_commands[num_command++]=SUBBINCOM | (RESBINREG<<4);
			 		bin_commands[num_command++]=LASTBYTE;
					fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", num_line++, SUBCOM, RESREG, ZREG, ALTREG, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
					fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
					out2res=1;
				}
			} else {//add
				mpz_add (mpz_res, mpz_res, mpz_tmp);

				if (out2res == 1) {
			 		bin_commands[num_command++]=ZBINREG  | (RESBINREG<<4);
			 		bin_commands[num_command++]=BREAKBYTE;
			 		bin_commands[num_command++]=ADDBINCOM | (ALTBINREG<<4);
			 		bin_commands[num_command++]=LASTBYTE;
					fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", num_line++, ADDCOM, ALTREG, ZREG, RESREG, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
					fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
					out2res=0;
				} else {//out2res == 0
			 		bin_commands[num_command++]=ZBINREG  | (ALTBINREG<<4);
			 		bin_commands[num_command++]=BREAKBYTE;
			 		bin_commands[num_command++]=ADDBINCOM | (RESBINREG<<4);
			 		bin_commands[num_command++]=LASTBYTE;
					fprintf(fp_asm, "%.4d\t\t\t%s %s, %s, %s;\t\t\t%.2X%.2X\n", num_line++, ADDCOM, RESREG, ZREG, ALTREG, bin_commands[num_command-4] & 0xff, bin_commands[num_command-2] & 0xff);
					fprintf(fp_sim, "%.2X %.2X %.2X %.2X\n", bin_commands[num_command-4] & 0xff, bin_commands[num_command-3] & 0xff, bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
					out2res=1;
				}
			}
		}
		//check if the result is correct
		ui_res = mpz_get_ui (mpz_res);

		if (ui_res != scalar_dgf_cflf1_std(n, k) ) {
			printf("//============================DGF RESULT ERROR================================\n");
			exit(1);
		} else {
			printf("//====================DGF RESULT IS EQUAL TO %u================================\n", ui_res);
		}

		//unload result
		if (out2res == 0) {//result in RESREG
			bin_commands[num_command++]=UNLBINCOM | (RESBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", num_line++, UNLCOM, RESREG, bin_commands[num_command-2] & 0xff);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
		} else {//result in ALTREG
			bin_commands[num_command++]=UNLBINCOM | (ALTBINREG<<4);
	 		bin_commands[num_command++]=LASTBYTE;
			fprintf(fp_asm, "%.4d\t\t\t%s %s;\t\t\t\t  %.2X\n", num_line++, UNLCOM, ALTREG, bin_commands[num_command-2] & 0xff);
			fprintf(fp_sim, "%.2X %.2X\n", bin_commands[num_command-2] & 0xff, bin_commands[num_command-1] & 0xff);
		}

		mpz_clears (mpz_num1, mpz_num2, mpz_tmp, mpz_res, NULL);

		fclose (fp_asm);
		fclose (fpbus_asm);

		fclose (fp_sim);
		fclose (fpbus_sim);

		fwrite (bin_commands, sizeof(char), size_commands, fp_bin);
		fclose (fp_bin);
		fclose (fpbus_bin);

		fclose (fpbusB_asm);
		fclose (fpbusB_sim);
		fclose (fpbusB_bin);

		free(bin_commands);

		//MD5 sums
		tmp=0;
		fprintf(fp_md5sums, "#Input       : N=%d, K=%d\n", n, k);
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
