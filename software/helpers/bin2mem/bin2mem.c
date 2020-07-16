/*
 ============================================================================
 Name        : bin2mem.c
 Author      : Tomasz Stefanski
 Version     :
 Copyright   : SRS
 Description : Code for conversion of bin files into mem files.
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {

	int i=0;
	char *pos_in = NULL;
	char *pos_out = NULL;
	FILE *pf_in, *pf_out;
	char ch_in1, ch_in2;

	if (argc == 3) {
		pos_in  = realpath(argv[1], NULL);
		//pos_out = realpath(argv[2], NULL);
		pos_out = argv[2];

		pf_in  = fopen (pos_in,"rb");
		if (pf_in == NULL) {
			fprintf (stderr, "	Input file does not exist.\n");
			exit (2);
		}
		pf_out = fopen (pos_out,"wt");

		do {
			ch_in1 = getc(pf_in);
			if (ch_in1 == EOF)
				break;
			ch_in2 = getc(pf_in);
			if (ch_in2 == EOF)
				break;

			if (ch_in2 == 0x00) {
				putc('0', pf_out);
			} else if (ch_in2 == 0x01) {
				putc('1', pf_out);
			} else {
				fprintf (stderr, "	Wrong last/break byte in binary file.\n");
				exit (3);
			}

			fprintf(pf_out, "%02X\n", ch_in1);
			i++;
		} while (1);

		printf("\n");
		printf("Number of lines       : %d", i);
		printf("Number of 18kb blocks : %d", i/(18*1024) + (i%(18*1024)?1:0));

		fclose (pf_in);
		fclose (pf_out);
	} else {
		fprintf (stderr, "	usage: ./bin2mem <input file path> <output file path>\n");
		exit (1);
	}

	return EXIT_SUCCESS;
}
