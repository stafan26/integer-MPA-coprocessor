/*
 ============================================================================
Name        : write_fun.c
Author      : Tomasz Stefanski
Version     : 0.1
Copyright   : Your copyright notice
Description : Functions for writing data to files
 ============================================================================
 */

#include "lfsr.h"

//============================================================================
void kam_fprintf (FILE *fp, mpz_t num) {

	int		i, j;
	int		characters, limbs, rest;
	unsigned int lfsr_num;
	char	*buffer, *str;
	mpz_t	tmp;

	mpz_init (tmp);
	buffer	= (char*)calloc (2*MAXBYTES, sizeof(char));
	str		= (char*)calloc (21, sizeof(char));

	mpz_abs (tmp, num);

	//print sign
	if (mpz_sgn (num)>=0)//positive number
		fprintf (fp, "%s", "+");
	else//negative number
		fprintf (fp, "%s", "-");

	//print number of limbs
	characters = gmp_sprintf (buffer, "%Zx", tmp);
	if ((rest=(characters % 16)>0))
		limbs = characters/16 + 1;
	else
		limbs = characters/16;
	//fprintf (fp, " %d\n", limbs);
	//new version example: reg0 (P0) = + 5 (NBC = 4, LFSR = 0x10)
	num2lfsr(&lfsr_num, limbs, 9);
	fprintf (fp, " %d (NBC = %d, LFSR = %x)\n", limbs, limbs-1, lfsr_num);


	//print number according to kam request
	j = characters-1;
	for (i=0; i<limbs; i++) {
		strcpy (str, "0000 0000 0000 0000 ");

		if (j>=0) str[18] = buffer[j--];
		if (j>=0) str[17] = buffer[j--];
		if (j>=0) str[16] = buffer[j--];
		if (j>=0) str[15] = buffer[j--];

		if (j>=0) str[13] = buffer[j--];
		if (j>=0) str[12] = buffer[j--];
		if (j>=0) str[11] = buffer[j--];
		if (j>=0) str[10] = buffer[j--];

		if (j>=0) str[8] = buffer[j--];
		if (j>=0) str[7] = buffer[j--];
		if (j>=0) str[6] = buffer[j--];
		if (j>=0) str[5] = buffer[j--];

		if (j>=0) str[3] = buffer[j--];
		if (j>=0) str[2] = buffer[j--];
		if (j>=0) str[1] = buffer[j--];
		if (j>=0) str[0] = buffer[j--];

		fprintf (fp, "%s\n", str);
	}
	fprintf (fp, "\n");

	free(buffer);
	free(str);
	mpz_clear (tmp);
}
//===========================================================================
void kam_printf (mpz_t num) {

	kam_fprintf (stdout, num);
}
//============================================================================
char conv_hexchar2char (char a) {

	char out;

	if(a>='a')
		out = a - 'a' + 10;
	else
		out = a - '0';
	return out;
}
//============================================================================
void write_int_number (mpz_t number, char *data,  int *data_size) {

	unsigned int		i;
	char				sign;
	unsigned int		lfsr_num, bytes_num, limbs_num;
	unsigned int		str_num_abs_size;
	char				*str_num, *str_num_abs;

	//str_num = NULL;
	//mpz_get_str (str_num, 16, number);
	str_num = mpz_get_str (NULL, 16, number);

	if(str_num[0] == '-') {
		sign = 1;
		str_num_abs = &str_num[1];
	} else {// + sign
		sign = 0;
		str_num_abs = &str_num[0];
	}
	str_num_abs_size = strlen(str_num_abs);
	bytes_num = str_num_abs_size/2 + str_num_abs_size%2;
	limbs_num = bytes_num/8 + (bytes_num%8?((unsigned int)1):((unsigned int)0));
	*data_size = limbs_num*8+8;

	//reset data array
	for(i=0; i<(*data_size); i++)
		data[i] = 0;

	//header generation
	num2lfsr(&lfsr_num, limbs_num, 9);
	if(lfsr_num > 255) {
		data[0] = lfsr_num - 256;
		data[1] = 1;
	} else {
		data[0] = lfsr_num;
		data[1] = 0;
	}
	if (sign == 1) {
		data[1] += 128;
	}
	switch (limbs_num) {
		case 1:
			data[2] = 1;
			break;
		case 2:
			data[2] = 2;
			break;
		case 3:
			data[2] = 4;
			break;
		default:
			data[2] = 0;
	}

	//array generation
	for (i = 0; i<bytes_num; i++) {
		//lower bits
		data[8+i] = conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-1] ) & 0xff;
		//upper bits
		if ((((int)str_num_abs_size)-2*((int)i)-2)>=0)//TS//
			data[8+i] |= ( conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-2] ) & 0xff )<<4;
	}

	free(str_num);
}
//============================================================================
void write_int_number_with_reset (mpz_t number, char *data,  int data_size) {

	unsigned int		i;
	char					sign;
	unsigned int		lfsr_num, bytes_num, limbs_num;
	unsigned int		str_num_abs_size;
	char					*str_num, *str_num_abs;

	//str_num = NULL;
	//mpz_get_str (str_num, 16, number);
	str_num = mpz_get_str (NULL, 16, number);

	if(str_num[0] == '-') {
		sign = 1;
		str_num_abs = &str_num[1];
	} else {// + sign
		sign = 0;
		str_num_abs = &str_num[0];
	}
	str_num_abs_size = strlen(str_num_abs);
	bytes_num = str_num_abs_size/2 + str_num_abs_size%2;
	limbs_num = bytes_num/8 + (bytes_num%8?((unsigned int)1):((unsigned int)0));

	//reset data array
	for(i=0; i<data_size; i++)
		data[i] = 0;

	//header generation
	num2lfsr(&lfsr_num, limbs_num, 9);
	if(lfsr_num > 255) {
		data[0] = lfsr_num - 256;
		data[1] = 1;
	} else {
		data[0] = lfsr_num;
		data[1] = 0;
	}
	if (sign == 1) {
		data[1] += 128;
	}
	switch (limbs_num) {
		case 1:
			data[2] = 1;
			break;
		case 2:
			data[2] = 2;
			break;
		case 3:
			data[2] = 4;
			break;
		default:
			data[2] = 0;
	}

	//array generation
	for (i = 0; i<bytes_num; i++) {
		//lower bits
		data[8+i] = conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-1] ) & 0xff;
		//upper bits
		if ((((int)str_num_abs_size)-2*((int)i)-2)>=0)//TS//
			data[8+i] |= ( conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-2] ) & 0xff )<<4;
	}

	free(str_num);
}
//============================================================================
void write_int_number_with_reset_rev (mpz_t number, char *data,  int data_size) {

	unsigned int		i;
	char					sign;
	unsigned int		lfsr_num, bytes_num, limbs_num;
	unsigned int		str_num_abs_size;
	char					*str_num, *str_num_abs;

	//str_num = NULL;
	//mpz_get_str (str_num, 16, number);
	str_num = mpz_get_str (NULL, 16, number);

	if(str_num[0] == '-') {
		sign = 1;
		str_num_abs = &str_num[1];
	} else {// + sign
		sign = 0;
		str_num_abs = &str_num[0];
	}
	str_num_abs_size = strlen(str_num_abs);
	bytes_num = str_num_abs_size/2 + str_num_abs_size%2;
	limbs_num = bytes_num/8 + (bytes_num%8?((unsigned int)1):((unsigned int)0));

	//reset data array
	for(i=0; i<data_size; i++)
		data[i] = 0xFF;

	//header generation
	num2lfsr(&lfsr_num, limbs_num, 9);
	if(lfsr_num > 255) {
		data[0] = lfsr_num - 256;
		data[1] = 1;
	} else {
		data[0] = lfsr_num;
		data[1] = 0;
	}
	if (sign == 1) {
		data[1] += 128;
	}
	switch (limbs_num) {
		case 1:
			data[2] = 1;
			break;
		case 2:
			data[2] = 2;
			break;
		case 3:
			data[2] = 4;
			break;
		default:
			data[2] = 0;
	}

	//array generation
	for (i = 0; i<bytes_num; i++) {
		//lower bits
		data[8+i] = conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-1] ) & 0xff;
		//upper bits
		if ((((int)str_num_abs_size)-2*((int)i)-2)>=0)//TS//
			data[8+i] |= ( conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-2] ) & 0xff )<<4;
	}

	free(str_num);
}
//============================================================================
void write_int2c_number_with_reset (mpz_t number, char *data,  int data_size) {

	unsigned int		i;
	char					sign;
	unsigned int		lfsr_num, bytes_num, limbs_num;
	unsigned int		str_num_abs_size;
	char					*str_num, *str_num_abs;

	//str_num = NULL;
	//mpz_get_str (str_num, 16, number);
	if(mpz_sgn (number)>=0) {
		str_num = mpz_get_str (NULL, 16, number);

		sign = 0;// + sign
		str_num_abs = &str_num[0];

		str_num_abs_size = strlen(str_num_abs);
		bytes_num = str_num_abs_size/2 + str_num_abs_size%2;
		limbs_num = bytes_num/8 + (bytes_num%8?((unsigned int)1):((unsigned int)0));

		//reset data array
		for(i=0; i<data_size; i++)
			data[i] = 0;
	} else {
		mpz_t		mpz_tmp, mpz_max;
		mpz_inits(mpz_tmp, mpz_max, NULL);

		sign = 1;// - sign

		limbs_num = data_size/8 + (data_size%8?((unsigned int)1):((unsigned int)0)) - 1;

		mpz_setbit (mpz_max, limbs_num*64);
		mpz_abs (mpz_tmp, number);
		mpz_sub (mpz_tmp, mpz_max, mpz_tmp);

		str_num = mpz_get_str (NULL, 16, mpz_tmp);
		str_num_abs = &str_num[0];
		str_num_abs_size = strlen(str_num_abs);
		bytes_num = str_num_abs_size/2 + str_num_abs_size%2;

		//reset data array
		for(i=0; i<8; i++)
			data[i] = 0x00;
		for(i=8; i<data_size; i++)
			data[i] = 0xFF;
		mpz_clears(mpz_tmp, mpz_max, NULL);
	}

	//header generation
	num2lfsr(&lfsr_num, limbs_num, 9);
	if(lfsr_num > 255) {
		data[0] = lfsr_num - 256;
		data[1] = 1;
	} else {
		data[0] = lfsr_num;
		data[1] = 0;
	}
	if (sign == 1) {
		data[1] += 128;
	}
	switch (limbs_num) {
		case 1:
			data[2] = 1;
			break;
		case 2:
			data[2] = 2;
			break;
		case 3:
			data[2] = 4;
			break;
		default:
			data[2] = 0;
	}

	//array generation
	for (i = 0; i<bytes_num; i++) {
		//lower bits
		data[8+i] = conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-1] ) & 0xff;
		//upper bits
		if ((((int)str_num_abs_size)-2*((int)i)-2)>=0)//TS//
			data[8+i] |= ( conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-2] ) & 0xff )<<4;
	}

	free(str_num);
}
//============================================================================
void write_int2c_number_with_reset_rev (mpz_t number, char *data,  int data_size) {

	unsigned int		i;
	char					sign;
	unsigned int		lfsr_num, bytes_num, limbs_num;
	unsigned int		str_num_abs_size;
	char					*str_num, *str_num_abs;

	//str_num = NULL;
	//mpz_get_str (str_num, 16, number);
	if(mpz_sgn (number)>=0) {
		str_num = mpz_get_str (NULL, 16, number);

		sign = 0;// + sign
		str_num_abs = &str_num[0];

		str_num_abs_size = strlen(str_num_abs);
		bytes_num = str_num_abs_size/2 + str_num_abs_size%2;
		limbs_num = bytes_num/8 + (bytes_num%8?((unsigned int)1):((unsigned int)0));

		//reset data array
		for(i=0; i<8; i++)
			data[i] = 0x00;
		for(i=8; i<data_size; i++)
			data[i] = 0xFF;
	} else {
		mpz_t		mpz_tmp, mpz_max;
		mpz_inits(mpz_tmp, mpz_max, NULL);

		sign = 1;// - sign

		limbs_num = data_size/8 + (data_size%8?((unsigned int)1):((unsigned int)0)) - 1;

		mpz_setbit (mpz_max, limbs_num*64);
		mpz_abs (mpz_tmp, number);
		mpz_sub (mpz_tmp, mpz_max, mpz_tmp);

		str_num = mpz_get_str (NULL, 16, mpz_tmp);
		str_num_abs = &str_num[0];
		str_num_abs_size = strlen(str_num_abs);
		bytes_num = str_num_abs_size/2 + str_num_abs_size%2;

		//reset data array
		for(i=0; i<data_size; i++)
			data[i] = 0;
		mpz_clears(mpz_tmp, mpz_max, NULL);
	}

	//header generation
	num2lfsr(&lfsr_num, limbs_num, 9);
	if(lfsr_num > 255) {
		data[0] = lfsr_num - 256;
		data[1] = 1;
	} else {
		data[0] = lfsr_num;
		data[1] = 0;
	}
	if (sign == 1) {
		data[1] += 128;
	}
	switch (limbs_num) {
		case 1:
			data[2] = 1;
			break;
		case 2:
			data[2] = 2;
			break;
		case 3:
			data[2] = 4;
			break;
		default:
			data[2] = 0;
	}

	//array generation
	for (i = 0; i<bytes_num; i++) {
		//lower bits
		data[8+i] = conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-1] ) & 0xff;
		//upper bits
		if ((((int)str_num_abs_size)-2*((int)i)-2)>=0)//TS//
			data[8+i] |= ( conv_hexchar2char( str_num_abs[str_num_abs_size-2*i-2] ) & 0xff )<<4;
	}

	free(str_num);
}
//============================================================================
void write_sim_number (FILE *fp, mpz_t number) {

	int		i;
	char	data[MAXBYTES];
	int		data_size;

	int k;
	for (k=0; k<MAXBYTES; k++) data[k]=0;

	write_int_number (number, data,  &data_size);
	for(i=0; i<data_size; i++) {
		fprintf(fp, "%.2x ", data[i] & 0xff);
	}
	fprintf(fp, "\n");
}
//============================================================================
void write_asm_number (FILE *fp, mpz_t number) {

	kam_fprintf (fp, number);
}
//============================================================================
void write_bin_number (FILE *fp, mpz_t number) {

	char data[MAXBYTES];
	int data_size;

	int k;
	for (k=0; k<MAXBYTES; k++) data[k]=0;

	write_int_number (number, data,  &data_size);
	fwrite (data, sizeof(char), data_size, fp);
}
//============================================================================
