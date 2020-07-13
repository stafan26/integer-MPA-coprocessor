/*
 ============================================================================
 Name        : main.c
 Author      : Tomasz Stefanski
 Version     :
 Copyright   : Your copyright notice
 Description : This code emulates SRUP on PC
 ============================================================================
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <gmp.h>
#include "emusrup.h"
#include "lfsr.h"
#include "time_maker.h"

#define FIXED_FILES
//#define MAIN_ARG_FILES

#if defined DPITEST
//===========================================================================
int main(int argc, char **argv) {

	int	i, j;
	int	opcode_instr;
	char *pos;
	char	handle[RANDOMFILENAMELENGTH+1];
	char	semaphore[RANDOMFILENAMELENGTH+1];

	int	Ninstr = 835;
	int	Ninstr_print = 830;
	int	lfsr = 1;
	int	num_of_addr_bits = 9;

	int	data_logic_reg = 16;
/*
//U2 test
mpz_t	number;
int	data_size=3*(8)+8;
char	char_number[MAXBYTES];
FILE *file_pt;

	mpz_init (number);
	mpz_set_si (number, -2);

	write_int2c_number_with_reset (number, char_number,  data_size);

	file_pt = fopen ( "test.bin" , "wb" );
	fwrite (char_number , sizeof(char), data_size, file_pt);
	fclose (file_pt);

	printf("%s\n", "done");
	mpz_clear (number);
	exit(0);
*/
	if (argc == 2) {
		pos = realpath(argv[1], NULL);
	} else {
		fprintf (stderr, "Wrong number of function arguments. It should be: ./emusrup <directory>\n");
		exit (18);
	}

	rand_string(handle, RANDOMFILENAMELENGTH);
	handle[0]='/';
	handle[RANDOMFILENAMELENGTH-4]='_';
	handle[RANDOMFILENAMELENGTH-3]='s';
	handle[RANDOMFILENAMELENGTH-2]='h';
	handle[RANDOMFILENAMELENGTH-1]='m';
	handle[RANDOMFILENAMELENGTH-0]='\0';

	rand_string(semaphore, RANDOMFILENAMELENGTH);
	semaphore[0]='/';
	semaphore[RANDOMFILENAMELENGTH-4]='_';
	semaphore[RANDOMFILENAMELENGTH-3]='s';
	semaphore[RANDOMFILENAMELENGTH-2]='e';
	semaphore[RANDOMFILENAMELENGTH-1]='m';
	semaphore[RANDOMFILENAMELENGTH-0]='\0';

	tbEmusrupStart (
		pos,
		lfsr,
		num_of_addr_bits,
		handle,
		semaphore    );

	printf(           "===========================================================================\n");
	printf(           "============================ Start of DPI emulation =======================\n");
	printf(           "===========================================================================\n\n");

	//int phys[17];
	//int phys_test[17];

	for (i=0; i<Ninstr; i++) {
		usleep(1000);

		printf(            "===========================================================================\n");
		printf(            "=============================== Step: %.4d ================================\n", i);
/*
		for(int j = 0; j<17; j++)
			read_shm_phys (	handle,
									semaphore,
									&phys[j],
									j);
		printf("before instruction\n");
		for(int j = 0; j<17; j++)
			printf("%d\t", phys[j]);
		printf("\n");
*/
		tbEmusrupProceed (
									handle,
									semaphore,
									&opcode_instr );
		printf("Instruction executed %d\n", opcode_instr);
/*
		for(int j = 0; j<17; j++)
			read_shm_phys (	handle,
									semaphore,
									&phys[j],
									j);
		printf("after instruction\n");
		for(int j = 0; j<17; j++)
			printf("%d\t", phys[j]);
		printf("\n");
*/
		if (i>Ninstr_print) {
			for(j=0; j<17; j++) {
				printf("xxxxxxxxxxxxxxx instr=%d, reg=%d xxxxxxxxxxxxxxxx\n", i, j);
				tbEmusrupPrintReg	(
					handle,
					semaphore,
					j
										);
			}
		}
/*
		for(int j = 0; j<17; j++)
			phys_test[j] = 0;

		for(int j = 0; j<17; j++)
			read_shm_phys (	handle,
									semaphore,
									&phys[j],
									j);

		for(int j = 0; j<17; j++)
			phys_test[ phys[j] ]++;

		for(int j = 0; j<17; j++)
			if (phys_test[j] != 1) {
				printf("Error in phys!\n");
				for(int k = 0; k<17; k++)
					printf("%d\t", phys_test[k]);
					printf("\n");
				for(int k = 0; k<17; k++)
					printf("%d\t", phys[k]);
				printf("\n");
				exit(0);
			}
*/
	}

	tbEmusrupStop (
							handle,
							semaphore   );
}
//===========================================================================
#else
//===========================================================================
int main(int argc, char **argv) {
#ifdef EMUOPT
	mpz_t	reg[NUMREG];
	int	phys[NUMREG+NUMSHD];
#else
	mpz_t	reg[NUMALLREG];
	int	phys[NUMALLREG];
#endif
	char	fname_prog[MAXFILENAMELENGTH], fname_busA[MAXFILENAMELENGTH], fname_busB[MAXFILENAMELENGTH], fname_emuout[MAXFILENAMELENGTH], fname_busZ[MAXFILENAMELENGTH];

#if defined FIXED_FILES
	char *pos;

	if (argc == 1) {
		strcpy ( fname_prog, BINFNAME );
		strcpy ( fname_busA, BINFBUSA );
		strcpy ( fname_busB, BINFBUSB );
		strcpy ( fname_busZ, BINFBUSZ );
		strcpy ( fname_emuout, EMUOUT );
	} else if (argc == 2) {
		pos = realpath(argv[1], NULL);

		strcpy ( fname_prog, pos );
		strcpy ( fname_busA, pos );
		strcpy ( fname_busB, pos );
		strcpy ( fname_busZ, pos );
		strcpy ( fname_emuout, pos );

		strcat ( fname_prog, "/" );
		strcat ( fname_busA, "/" );
		strcat ( fname_busB, "/" );
		strcat ( fname_busZ, "/" );
		strcat ( fname_emuout, "/" );

		strcat ( fname_prog, BINFNAME );
		strcat ( fname_busA, BINFBUSA );
		strcat ( fname_busB, BINFBUSB );
		strcat ( fname_busZ, BINFBUSZ );
		strcat ( fname_emuout, EMUOUT );
	} else {
		fprintf (stderr, "Wrong number of function arguments. It should be: ./emusrup <directory>\n");
		exit (18);
	}
#elif defined MAIN_ARG_FILES
	if (argc != 6) {
		fprintf (stderr, "Wrong number of function arguments. It should be: ./emusrup <prog.bin> <busA.bin> <busB.bin> <busZ.bin> <emuout.txt>\n");
		exit (17);
	}

	strcpy ( fname_prog, realpath(argv[1], NULL) );
	strcpy ( fname_busA, realpath(argv[2], NULL) );
	strcpy ( fname_busB, realpath(argv[3], NULL) );
	strcpy ( fname_busZ, realpath(argv[4], NULL) );
	strcpy ( fname_emuout, realpath(argv[5], NULL) );
#else
	char *pos;

	printf ("Enter a prog file name: ");
	fgets(fname_prog, MAXFILENAMELENGTH, stdin);
	if ((pos=strchr(fname_prog, '\n')) != NULL)
	    *pos = '\0';

	printf ("Enter a busA file name: ");
	fgets (fname_busA, MAXFILENAMELENGTH, stdin);
	if ((pos=strchr(fname_busA, '\n')) != NULL)
	    *pos = '\0';

	printf ("Enter a busB file name: ");
	fgets (fname_busB, MAXFILENAMELENGTH, stdin);
	if ((pos=strchr(fname_busB, '\n')) != NULL)
	    *pos = '\0';

	printf ("Enter a busZ file name: ");
	fgets (fname_busZ, MAXFILENAMELENGTH, stdin);
	if ((pos=strchr(fname_busZ, '\n')) != NULL)
	    *pos = '\0';

	printf ("Enter an emulator output file name: ");
	fgets (fname_emuout, MAXFILENAMELENGTH, stdin);
	if ((pos=strchr(fname_emuout, '\n')) != NULL)
	    *pos = '\0';
#endif

	emulate(	reg,
				phys,
				fname_prog,
				fname_busA,
				fname_busB,
				fname_emuout,
				fname_busZ,
				TRUE);

	return EXIT_SUCCESS;
}
//===========================================================================
#endif
