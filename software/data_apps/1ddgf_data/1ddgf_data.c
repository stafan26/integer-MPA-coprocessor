/*
 ============================================================================
 Name        : 1ddgf_test.c
 Author      :
 Version     :
 Copyright   :
 Description : Code generation for 1d dgf
 ============================================================================
 */
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include "srup_code_gen.h"

#define N_ARG	4
#define K_ARG	1

//============================================================================
int main(int argc, char **argv) {

char *pos = NULL;
int  Nf = N_ARG;
int  Kf = K_ARG;
struct stat st = {0};

	if (argc == 1 || argc == 2) {//print help
		fprintf (stderr, "	usage: ./1ddgf_data <N> <K> <optional directory>\n");
		exit (1);
	} else if (argc == 3) {//default directory of execution
		Nf = atoi (argv[1]);
		Kf = atoi (argv[2]);
	} else if (argc == 4) {//directory specified by a user
		Nf = atoi (argv[1]);
		Kf = atoi (argv[2]);

		//create directory if does not exist
		pos = argv[3];
		if (stat(pos, &st) == -1) {
		    mkdir(pos, 0775);
		}

		pos = realpath(argv[3], NULL);
	} else {//print help
		fprintf (stderr, "	usage: ./1ddgf_data <N> <K> <optional directory>\n");
		exit (2);
	}

	srup_code_gen(Nf, Kf, pos);

	if(pos)
		free(pos);

	return 0;
}
//============================================================================
