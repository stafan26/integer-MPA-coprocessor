/*
 ============================================================================
Name        : read_fun.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Functions for reading data from files
 ============================================================================
 */

#include "lfsr.h"

//===========================================================================
void read_bin_file (char *file, char **data, int *data_size) {

	FILE *file_pt;
	int	  file_size;
	char *buffer;
	size_t result;

	//open file
	file_pt = fopen ( file , "rb" );
	if (file_pt == NULL) {
		fprintf (stderr, "Error of reading file: %s\n", file);
		exit (1);
	}

	// obtain file size:
	fseek (file_pt , 0 , SEEK_END);
	file_size = ftell (file_pt);
	rewind (file_pt);

	// allocate memory to contain the whole file:
	buffer = (char*) malloc (sizeof(char)*file_size);
	if (buffer == NULL) {
		fprintf (stderr, "Error of memory allocation for copying of file: %s\n", file);
		exit (2);
	}

	// copy the file into the buffer:
	result = fread (buffer, 1, file_size, file_pt);
	if (result != file_size) {
		fprintf (stderr, "Error of reading data in file: %s\n", file);
		exit (3);
	}

	// terminate
	fclose (file_pt);
	*data_size = file_size;
	*data = buffer;
}
//===========================================================================
char conv_char2hexchar (char a) {

	char out;

	if(a>=0 && a<=9)
		out = a + '0';
	else if (a>=10 && a<=15)
		out = (a-10) + 'a';
	else {
		fprintf (stderr, "Wrong number in conv_char2hexchar\n");
		exit (12);
	}
	return out;
}
//===========================================================================
void read_int_number (char *data,  int data_size, mpz_t number, unsigned int *number_size) {

	unsigned int i;
	char sign, max_bit;
	int   str_num_size;
	char *str_num;

	//check if enough data in input (min 1 limb)
	if (data_size < 16 ) {
		fprintf (stderr, "Wrong data in a bus\n");
		for (i = 0; i<data_size; i++)
			fprintf (stderr, "%.2X ", data[i]);
		fprintf (stderr, "\n");
		exit (10);
	}

	//obtain number size, check header
	if ( data[7] != 0 || data[6] !=0 || data[5] != 0 || data[4] !=0 || (data[2] & 0xF8) != 0 || (data[1] & 0x7E) != 0) {
		fprintf (stderr, "Wrong header of a number in a bus\n");
		for (i = 0; i<8; i++)
			fprintf (stderr, "%.2X ", (unsigned char) data[i]);
		fprintf (stderr, "\n");
		exit (11);
	}
	else {
		sign = (data[1] >> 7) & 1;
		max_bit = data[1] & 1;
		i = max_bit*(256) + ((unsigned char)(data[0]));
		lfsr2num(number_size, i, 9);
		switch (*number_size) {
			case 1:
				if (data[2] != 1) {
					fprintf (stderr, "Wrong last flag not set to 1\n");
					exit(13);
				}
				break;
			case 2:
				if (data[2] != 2) {
					fprintf (stderr, "Wrong last flag not set to 2\n");
					exit(14);
				}
				break;
			case 3:
				if (data[2] != 4) {
					fprintf (stderr, "Wrong last flag not set to 4\n");
					exit(15);
				}
				break;
			default:
				if (data[2] != 0) {
					fprintf (stderr, "Wrong last flag not set to 0\n");
					exit(16);
				}
		}
	}

	//generate MPA number
	str_num_size = 16*(*number_size);
	if (sign == 1) str_num_size++;
	str_num = (char*)calloc (str_num_size+1, sizeof(char));
	str_num[str_num_size] = '\0';
	if (sign == 1) str_num[0] = '-';
	for (i = 0; i<(*number_size)*8; i++) {
		//lower bits
		str_num[str_num_size-2*i-1] = conv_char2hexchar (data[8+i] & 0x0F);
		//upper bits
		str_num[str_num_size-2*i-2] = conv_char2hexchar ((data[8+i] & 0xF0)>>4);
	}
	if (mpz_set_str (number, str_num, 16) != 0) {
		fprintf (stderr, "Wrong a number in a bus\n");
		exit (12);
	}
	//gmp_printf ("LOADED VALUE = %Zx\n", number);
	free(str_num);
}
//===========================================================================
