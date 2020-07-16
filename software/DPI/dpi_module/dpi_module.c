//============================================================================
// Name        : dpi_module.c
// Author      : TS
// Version     :
// Copyright   : Your copyright notice
// Description : Library of MPA functions for MPA-FPGA testing
//============================================================================

#include "dpi_module.h"

/** Functions prints error message and exits program.
 * \param msg error message
 * \param err_code error code
 */
void tbError (char *msg, int err_code) {
	puts(msg);
	exit(err_code);
}

/** Display function for testing connection of C and SV.
 */
void tbDisplay () {

	printf("Connection works!!!\n");
}

/** Function prints on the screen ascii codes of the characters in string.
 * \param string pointer to the string with NULL end
 */
void tbPrintAsciiCodesStr (const char *string) {
	while(*string)
		printf("%02x", (unsigned int) *string++);
	printf("\n");
}

/** Function prints hex string on the screen.
 * \param string pointer to the string with NULL end
 */
void tbPrintHexStr (const char *string) {
	puts (string);
}

/** Function prints half-fulfilled integer array on the screen.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a the half-fulfilled array
 * \param a_prec precision of the number in a array (in multiples of the number of bits of the multiplier unit)
 */
void tbPrintHalfIntArray (	int		mult_prec,
							int		*a,
							int		a_prec) {
	int i;

	for (i=0; i<(mult_prec*a_prec)/16; i++)
		printf("%x\n", a[i]);
	printf("\n");
}
/** Function generates random number in hex string.
 * \param a the table for storing the generated number (memory for this table must be allocated before calling this function)
 * \param a_size size of the table without NULL character in the end
 */
void tbGenRandomString (char	*a,
						int		a_size) {
	int		i;
	FILE	*fp;

	fp = fopen ("/dev/urandom", "r");
	fread (a, 1, a_size, fp);
	fclose (fp);

	for (i=0; i<a_size; i++) {
		a[i] &= 0x0F;

		if (a[i]<10)
			a[i]+='0';
		else
			a[i]+=('a'-10);
	}

	if (a[0]=='0')
		a[0]='1';
	a[a_size]='\0';
}

/** Compute multiplication of two numbers in MPA.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit)
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit)
 * \param c result of multiplication (its precision is well defined by c_prec=a_prec + b_prec)
 */
void tbCompMultiplicationInteger (	int		mult_prec,
									char	*a,
									int		a_prec,
									char	*b,
									int		b_prec,
									char	*c) {
	mpz_t a_mpa, b_mpa, c_mpa;

	mpz_init (a_mpa);
	mpz_init (b_mpa);
	mpz_init (c_mpa);

	mpz_set_str (a_mpa, a, 16);
	mpz_set_str (b_mpa, b, 16);

	mpz_mul (c_mpa, a_mpa, b_mpa);				/* c=a*b */
	mpz_get_str (c, 16, c_mpa);

#ifdef PRINTDEBUGVAL
	printf ("*************************Start of GMP computations**************************\n");
	gmp_printf ("a = %Zx\n", a_mpa);
	gmp_printf ("b = %Zx\n", b_mpa);
	gmp_printf ("c = %Zx\n", c_mpa);
	printf ("**************************End of GMP computations***************************\n\n");
#endif

	mpz_clear (a_mpa);
	mpz_clear (b_mpa);
	mpz_clear (c_mpa);
}

/** Compute addition of two numbers in MPA.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit)
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit)
 * \param c result of addition
 */
void tbCompAdditionInteger (		int		mult_prec,
									char	*a,
									int		a_prec,
									char	*b,
									int		b_prec,
									char	*c) {
	mpz_t a_mpa, b_mpa, c_mpa;

	mpz_init (a_mpa);
	mpz_init (b_mpa);
	mpz_init (c_mpa);

	mpz_set_str (a_mpa, a, 16);
	mpz_set_str (b_mpa, b, 16);

	mpz_add (c_mpa, a_mpa, b_mpa);				/* c=a+b */
	mpz_get_str (c, 16, c_mpa);

#ifdef PRINTDEBUGVAL
	printf ("*************************Start of GMP computations**************************\n");
	gmp_printf ("a = %Zx\n", a_mpa);
	gmp_printf ("b = %Zx\n", b_mpa);
	gmp_printf ("c = %Zx\n", c_mpa);
	printf ("**************************End of GMP computations***************************\n\n");
#endif

	mpz_clear (a_mpa);
	mpz_clear (b_mpa);
	mpz_clear (c_mpa);
}

/** Compute subtraction of two numbers in MPA.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit)
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit)
 * \param c_amb result of subtraction a-b
 * \param c_amb_sign sign of result of subtraction a-b
 * \param c_bma result of subtraction b-a
 * \param c_bma_sign sign of result of subtraction b-a
 */
void tbCompSubtractionInteger (		int		mult_prec,
									char	*a,
									int		a_prec,
									char	*b,
									int		b_prec,
									char	*c_amb,
									int		*c_amb_sign,
									char	*c_bma,
									int		*c_bma_sign) {

	unsigned int prec;
	mpz_t a_mpa, b_mpa, c_amb_mpa, c_bma_mpa, c_ambu2_mpa, c_bmau2_mpa, tmp, abs;

	prec = mult_prec*(a_prec>b_prec?a_prec:b_prec);

	mpz_init (a_mpa);
	mpz_init (b_mpa);
	mpz_init (c_amb_mpa);
	mpz_init (c_bma_mpa);
	mpz_init (c_ambu2_mpa);
	mpz_init (c_bmau2_mpa);
	mpz_init (tmp);
	mpz_init (abs);

	mpz_set_str (a_mpa, a, 16);
	mpz_set_str (b_mpa, b, 16);

	mpz_ui_pow_ui (tmp, (unsigned long int) 2, (unsigned long int) prec);

	mpz_sub (c_amb_mpa, a_mpa, b_mpa);				/* c=a-b */
	if (mpz_sgn (c_amb_mpa) >= 0) {
		mpz_set (c_ambu2_mpa, c_amb_mpa);
		mpz_get_str (c_amb, 16, c_amb_mpa);
		*c_amb_sign = 0;
	} else {
		mpz_abs (abs, c_amb_mpa);
		mpz_sub (c_ambu2_mpa, tmp, abs);
		mpz_get_str (c_amb, 16, c_ambu2_mpa);
		*c_amb_sign = 1;
	}

	mpz_sub (c_bma_mpa, b_mpa, a_mpa);				/* c=b-a */
	if (mpz_sgn (c_bma_mpa) >= 0) {
		mpz_set (c_bmau2_mpa, c_bma_mpa);
		mpz_get_str (c_bma, 16, c_bma_mpa);
		*c_bma_sign = 0;
	} else {
		mpz_abs (abs, c_bma_mpa);
		mpz_sub (c_bmau2_mpa, tmp, abs);
		mpz_get_str (c_bma, 16, c_bmau2_mpa);
		*c_bma_sign = 1;
	}

#ifdef PRINTDEBUGVAL
	printf ("*************************Start of GMP computations**************************\n");
	gmp_printf ("a = %Zx\n", a_mpa);
	gmp_printf ("b = %Zx\n", b_mpa);
	gmp_printf ("c_amb = %Zx\n", c_amb_mpa);
	gmp_printf ("c_bma = %Zx\n", c_bma_mpa);
	gmp_printf ("c_ambu2 = %Zx\n", c_ambu2_mpa);
	gmp_printf ("c_bmau2 = %Zx\n", c_bmau2_mpa);
	printf ("**************************End of GMP computations***************************\n\n");
#endif

	mpz_clear (a_mpa);
	mpz_clear (b_mpa);
	mpz_clear (c_amb_mpa);
	mpz_clear (c_bma_mpa);
	mpz_clear (c_ambu2_mpa);
	mpz_clear (c_bmau2_mpa);
	mpz_clear (tmp);
	mpz_clear (abs);
}

/** Generate data for test of multiplication of two numbers in MPA.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit)
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit)
 * \param c result of multiplication (its precision is well defined by c_prec=a_prec + b_prec)
 */
void tbGenTestDataMultiplicationInteger (	int		mult_prec,
											char	**a,
											int		a_prec,
											char	**b,
											int		b_prec,
											char	**c) {
	char *a_data;
	char *b_data;
	char *c_data;
	int  a_byte_count;
	int  b_byte_count;
	int  c_byte_count;
	int  a_hex_length;
	int  b_hex_length;
	int  c_hex_length;

	a_byte_count = (mult_prec * a_prec) / 8;
	b_byte_count = (mult_prec * b_prec) / 8;
	c_byte_count = a_byte_count + b_byte_count;

	a_hex_length = 2 * a_byte_count;
	b_hex_length = 2 * b_byte_count;
	c_hex_length = 2 * c_byte_count;

	a_data = (char*) calloc (a_hex_length+1, sizeof(char));
	b_data = (char*) calloc (b_hex_length+1, sizeof(char));
	c_data = (char*) calloc (c_hex_length+1, sizeof(char));

	tbGenRandomString (a_data, a_hex_length);
	tbGenRandomString (b_data, b_hex_length);

	//tbPrintHexStr (a_data);
	//tbPrintHexStr (b_data);

	tbCompMultiplicationInteger (mult_prec, a_data, a_prec, b_data, b_prec, c_data);

	*a=a_data;
	*b=b_data;
	*c=c_data;
}

/** Function converts a hex character '0'-'f'/'F' into an 8-bit number.
 * \param a the character for conversion
 * \return 8-bit number
 */
char tbConvHexCharToChar (char a) {

	if (a>='0' && a<='9')
		a = a - '0';
	else if (a>='a' && a<='f')
		a = a - 'a' + 10;
	else if (a>='A' && a<='F')
		a = a - 'A' + 10;
	//else if (a==32)//space
	//	a = 0;
	else
		tbError ((char *)"Error in MPA string\n", ERR_STR);
	return a;
}

/** Convert string number to array of chars.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_char array with returned chars
 */
void tbConvStringNumToCharArray (	int		mult_prec,
									char	*a,
									int		a_prec,
									char	**a_char) {
	int		i, j, k;
	char	lsbits, msbits;
	int		a_byte_count;
	char	*a_char_tmp;

	a_byte_count = (mult_prec * a_prec) / 8;
	a_char_tmp = (char *)calloc (a_byte_count, sizeof(char));
	j=0;
	for (i=strlen(a)-1; i>=0; i-=2) {
		k=i-1;
		lsbits = tbConvHexCharToChar (a[i]);
		msbits = k<0 ? 0 : tbConvHexCharToChar (a[k]);
		a_char_tmp[j] = (msbits<<4) + lsbits;
		j++;
	}
	*a_char = a_char_tmp;
}

/** Convert string number to array of half-fulfilled integers.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_int array with returned integers
 */
void tbConvStringNumToHalfIntArray (	int		mult_prec,
										char	*a,
										int		a_prec,
										int		**a_int) {
	int		i, j, k, l, m;
	char	bits, bitsm1, bitsm2, bitsm3;
	int		a_byte_count;
	int		*a_int_tmp;

	a_byte_count = (mult_prec * a_prec) / 8;
	k = a_byte_count%2 ? a_byte_count+1 : a_byte_count;
	a_int_tmp = (int *)calloc (k/2, sizeof(int));
	j=0;
	for (i=strlen(a)-1; i>=0; i-=4 ) {
		k=i-1;
		l=i-2;
		m=i-3;

		bits   = tbConvHexCharToChar (a[i]);
		bitsm1 = k<0 ? 0 : tbConvHexCharToChar (a[k]);
		bitsm2 = l<0 ? 0 : tbConvHexCharToChar (a[l]);
		bitsm3 = m<0 ? 0 : tbConvHexCharToChar (a[m]);

		a_int_tmp[j] = (bitsm3<<12) + (bitsm2<<8) + (bitsm1<<4) + bits;
		j++;
	}
	*a_int = a_int_tmp;
}

/** Convert string number to an external array of chars.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_char array with returned chars
 */
void tbConvStringNumToCharExtArray (	int		mult_prec,
										char	*a,
										int		a_prec,
										char	*a_char) {
	int		i, j, k;
	char	lsbits, msbits;
	int		a_byte_count;

	a_byte_count = (mult_prec * a_prec) / 8;
	for (i=0; i<a_byte_count; i++ )
		a_char[i] = 0;
	j=0;
	for (i=strlen(a)-1; i>=0; i-=2 ) {
		k=i-1;
		lsbits = tbConvHexCharToChar (a[i]);
		msbits = k<0 ? 0 : tbConvHexCharToChar (a[k]);
		a_char[j] = (msbits<<4) + lsbits;
		j++;
	}
}

/** Add zeros to string number.
 * \param a_data string with MPA number
 * \param a_hex_length number of digits expected
 */
void tbAddZerosToStringNum (	char	*a_data,
								int		a_hex_length) {
int k, p;

	if( strlen(a_data)!=a_hex_length) {
		k = a_hex_length - strlen(a_data);//add k zeros
		for (p=strlen(a_data); p>=0; p--)
			a_data[p+k]=a_data[p];
		for (p=0; p<k; p++)
			a_data[p]='0';
	}
}

/** Convert string number to an external array of half-fulfilled integers.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_int array with returned integers
 */
void tbConvStringNumToHalfIntExtArray (	int		mult_prec,
										char	*a,
										int		a_prec,
										int		*a_int) {
	int		i, j, k, l, m;
	char	bits, bitsm1, bitsm2, bitsm3;
	int		a_byte_count;

	a_byte_count = (mult_prec * a_prec) / 8;
	k = a_byte_count%2 ? a_byte_count+1 : a_byte_count;
	for (i=0; i<k/2; i++ )
		a_int[i] = 0;
	j=0;
	//for (i=2*a_byte_count-1; i>=0; i-=4 ) {
	for (i=strlen(a)-1; i>=0; i-=4 ) {
		k=i-1;
		l=i-2;
		m=i-3;

		bits   = tbConvHexCharToChar (a[i]);
		bitsm1 = k<0 ? 0 : tbConvHexCharToChar (a[k]);
		bitsm2 = l<0 ? 0 : tbConvHexCharToChar (a[l]);
		bitsm3 = m<0 ? 0 : tbConvHexCharToChar (a[m]);

		a_int[j] = (bitsm3<<12) + (bitsm2<<8) + (bitsm1<<4) + bits;
		j++;
	}
}

/** Generate data for test of multiplication of two numbers in MPA, output is in external arrays of half-fulfilled integers.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a_int the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit)
 * \param b_int the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit)
 * \param c_int result of multiplication (its precision is well defined by c_prec=a_prec + b_prec)
 */
void tbGenTestDataMultiplicationIntegerHalfIntExtArrayOutput (	int		mult_prec,
																int		*a_int,
																int		a_prec,
																int		*b_int,
																int		b_prec,
																int		*c_int) {
	char *a_data;
	char *b_data;
	char *c_data;
	int  a_byte_count;
	int  b_byte_count;
	int  c_byte_count;
	int  a_hex_length;
	int  b_hex_length;
	int  c_hex_length;

	a_byte_count = (mult_prec * a_prec) / 8;
	b_byte_count = (mult_prec * b_prec) / 8;
	c_byte_count = a_byte_count + b_byte_count;

	a_hex_length = 2 * a_byte_count;
	b_hex_length = 2 * b_byte_count;
	c_hex_length = 2 * c_byte_count;

	a_data = (char*) calloc (a_hex_length+1, sizeof(char));
	b_data = (char*) calloc (b_hex_length+1, sizeof(char));
	c_data = (char*) calloc (c_hex_length+1, sizeof(char));

	tbGenRandomString (a_data, a_hex_length);
	tbGenRandomString (b_data, b_hex_length);

	tbCompMultiplicationInteger (mult_prec, a_data, a_prec, b_data, b_prec, c_data);

	tbConvStringNumToHalfIntExtArray (mult_prec, a_data, a_prec, a_int);
	tbConvStringNumToHalfIntExtArray (mult_prec, b_data, b_prec, b_int);
	tbConvStringNumToHalfIntExtArray (mult_prec, c_data, a_prec+b_prec, c_int);

	free(a_data);
	free(b_data);
	free(c_data);
}

/** Generate data for test of multiplication of two numbers in MPA using seed, output is in external arrays of half-fulfilled integers.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a_int the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit)
 * \param b_int the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit)
 * \param c_int result of multiplication (its precision is well defined by c_prec=a_prec + b_prec)
 * \param seed parameter of the random number generation
 */
void tbGenTestDataMultiplicationIntegerSeedHalfIntExtArrayOutput (	int		mult_prec,
																	int		*a_int,
																	int		a_prec,
																	int		*b_int,
																	int		b_prec,
																	int		*c_int,
																	int		seed) {
	char *a_data;
	char *b_data;
	char *c_data;
	int  a_byte_count;
	int  b_byte_count;
	int  c_byte_count;
	int  a_hex_length;
	int  b_hex_length;
	int  c_hex_length;
	gmp_randstate_t state;
	mpz_t a_mpa, b_mpa;

	mpz_init (a_mpa);
	mpz_init (b_mpa);

	a_byte_count = (mult_prec * a_prec) / 8;
	b_byte_count = (mult_prec * b_prec) / 8;
	c_byte_count = a_byte_count + b_byte_count;

	a_hex_length = 2 * a_byte_count;
	b_hex_length = 2 * b_byte_count;
	c_hex_length = 2 * c_byte_count;

	a_data = (char*) calloc (a_hex_length+1, sizeof(char));
	b_data = (char*) calloc (b_hex_length+1, sizeof(char));
	c_data = (char*) calloc (c_hex_length+1, sizeof(char));

	gmp_randinit_default (state);
	gmp_randseed_ui (state, (unsigned long int) seed);
	mpz_urandomb (a_mpa, state, mult_prec*a_prec);
	mpz_urandomb (b_mpa, state, mult_prec*b_prec);
	mpz_get_str (a_data, 16, a_mpa);
	mpz_get_str (b_data, 16, b_mpa);

	tbCompMultiplicationInteger (mult_prec, a_data, a_prec, b_data, b_prec, c_data);

	tbConvStringNumToHalfIntExtArray (mult_prec, a_data, a_prec, a_int);
	tbConvStringNumToHalfIntExtArray (mult_prec, b_data, b_prec, b_int);
	tbConvStringNumToHalfIntExtArray (mult_prec, c_data, a_prec+b_prec, c_int);

	mpz_clear (a_mpa);
	mpz_clear (b_mpa);
	gmp_randclear (state);

	free(a_data);
	free(b_data);
	free(c_data);
}
//============================================================================
//============================SRUP RELATED FUNCTIONS==========================
//============================================================================

/** Generate data for test of addition of two numbers in MPA using seed, output is in external arrays.
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit=64)
 * \param a_last information if last limb of a array
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit=64)
 * \param b_last information if last limb of b array
 * \param c result of addition
 * \param c_prec precision of the result (in multiples of the number of bits of the multiplier unit=64)
 * \param c_last information if last limb of c array
 * \param seed parameter of the random number generation
 */
void tbGenTestDataAdditionIntegerSeedSrup (	int		*a,
											int		a_prec,
											int		*a_last,
											int		*b,
											int		b_prec,
											int		*b_last,
											int		*c,
											int		*c_prec,
											int		*c_last,
											int		seed) {
	int					k;
	unsigned int		tmp;
	const int			mult_prec = 64;
	char				*a_data;
	char				*b_data;
	char				*c_data;
	int					a_byte_count;
	int					b_byte_count;
	int					c_byte_count;
	int					c_limb_out;
	int					a_hex_length;
	int					b_hex_length;
	int					c_hex_length;
	gmp_randstate_t		state;
	mpz_t				a_mpa, b_mpa, c_mpa;

	mpz_inits (a_mpa, b_mpa, c_mpa, NULL);

	a_byte_count = (mult_prec * a_prec) / 8;
	b_byte_count = (mult_prec * b_prec) / 8;
	c_byte_count = a_byte_count > b_byte_count?a_byte_count:b_byte_count;
	c_byte_count += 8;
	c_limb_out   = c_byte_count * 8 / mult_prec;

	a_hex_length = 2 * a_byte_count;
	b_hex_length = 2 * b_byte_count;
	c_hex_length = 2 * c_byte_count;

	a_data = (char*) calloc (a_hex_length+1, sizeof(char));
	b_data = (char*) calloc (b_hex_length+1, sizeof(char));
	c_data = (char*) calloc (c_hex_length+1, sizeof(char));

	gmp_randinit_default (state);
	gmp_randseed_ui (state, (unsigned long int) seed);

	//generate a number
	do {
		mpz_urandomb (a_mpa, state, mult_prec*a_prec);
		mpz_abs (a_mpa, a_mpa);
		mpz_get_str (a_data, 16, a_mpa);
		k = strlen (a_data);
	} while (k < (2 * (a_byte_count - mult_prec/8)));

	//generate b number
	do {
		mpz_urandomb (b_mpa, state, mult_prec*b_prec);
		mpz_abs (b_mpa, b_mpa);
		mpz_get_str (b_data, 16, b_mpa);
		k = strlen (b_data);
	} while (k < (2 * (b_byte_count - mult_prec/8)));

	tbCompAdditionInteger (mult_prec, a_data, a_prec, b_data, b_prec, c_data);
	tmp = strlen(c_data);
	if(tmp%(mult_prec/4)!=0)
		tmp = tmp / (mult_prec/4) + 1;
	else
		tmp = tmp / (mult_prec/4);

	tbConvStringNumToHalfIntExtArray (mult_prec, a_data, a_prec, a);
	tbConvStringNumToHalfIntExtArray (mult_prec, b_data, b_prec, b);
	tbConvStringNumToHalfIntExtArray (mult_prec, c_data, tmp, c);
	*c_prec = tmp;

	for (k=0; k<(a_prec-1); k++)
		a_last[k] = 0;
	a_last[k] = 1;
	for (k=0; k<(b_prec-1); k++)
		b_last[k] = 0;
	b_last[k] = 1;
	for (k=0; k<(c_limb_out-1); k++)
		c_last[k] = 0;
	c_last[k] = 1;

	mpz_clears (a_mpa, b_mpa, c_mpa, NULL);
	gmp_randclear (state);
#ifdef PRINTDEBUGVAL
	printf ("*******************************Debug info***********************************\n");

	printf("Values obtained from Vivado (a_prec, b_prec, seed):\n\n %u\n %u\n %u\n\n", a_prec, b_prec, seed);

	printf("Values sent to Vivado (a, b, c operand):\n\n");

	tbPrintHalfIntArray (mult_prec, a, a_prec);
	tbPrintHalfIntArray (mult_prec, b, b_prec);
	tbPrintHalfIntArray (mult_prec, c, c_limb_out);

	printf("Output precision:\n%d\n", *c_prec);
	printf("\nLast signals (a, b, c operand):\n");
	for (k=0; k<a_prec; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<b_prec; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<c_limb_out; k++)
		printf("%d", c_last[k]);
	printf("\n\n");

	printf ("***************************End of Debug info********************************\n\n");
#endif
	free(a_data);
	free(b_data);
	free(c_data);
}

/** Generate data for test of subtraction of two numbers in MPA using seed, output is in external arrays.
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit=64)
 * \param a_last information if last limb of a array
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit=64)
 * \param b_last information if last limb of b array
 * \param c_amb result of subtraction (a-b)
 * \param c_amb_prec precision of the result (in multiples of the number of bits of the multiplier unit=64)
 * \param c_amb_last information if last limb of c_amb array
 * \param c_bma result of subtraction (b-a)
 * \param c_bma_prec precision of the result (in multiples of the number of bits of the multiplier unit=64)
 * \param c_bma_last information if last limb of c_bma array
 * \param seed parameter of the random number generation
 */
void tbGenTestDataSubtractionIntegerSeedSrup (	int		*a,
											int		a_prec,
											int		*a_last,
											int		*b,
											int		b_prec,
											int		*b_last,
											int		*c_amb,
											int		*c_amb_prec,
											int		*c_amb_last,
											int		*c_bma,
											int		*c_bma_prec,
											int		*c_bma_last,
											int		seed) {
	int					k;
	unsigned int		tmp;
	const int			mult_prec = 64;
	char				*a_data;
	char				*b_data;
	char				*c_amb_data;
	char				*c_bma_data;
	int					a_byte_count;
	int					b_byte_count;
	int					c_byte_count;
	int					c_byte_out;
	int					c_limb_out;
	int					a_hex_length;
	int					b_hex_length;
	int					c_hex_length;
	int					c_amb_sign;
	int					c_bma_sign;
	gmp_randstate_t		state;
	mpz_t				a_mpa, b_mpa, c_amb_mpa, c_bma_mpa;

	mpz_inits (a_mpa, b_mpa, c_bma_mpa, c_amb_mpa, NULL);

	a_byte_count = (mult_prec * a_prec) / 8;
	b_byte_count = (mult_prec * b_prec) / 8;
	c_byte_count = a_byte_count > b_byte_count?a_byte_count:b_byte_count;
	c_byte_out   = c_byte_count + 8;
	c_limb_out   = c_byte_out * 8 / mult_prec;

	a_hex_length = 2 * a_byte_count;
	b_hex_length = 2 * b_byte_count;
	c_hex_length = 2 * c_byte_count;

	a_data = (char*) calloc (a_hex_length+1, sizeof(char));
	b_data = (char*) calloc (b_hex_length+1, sizeof(char));
	c_amb_data = (char*) calloc (c_hex_length+1, sizeof(char));
	c_bma_data = (char*) calloc (c_hex_length+1, sizeof(char));

	gmp_randinit_default (state);
	gmp_randseed_ui (state, (unsigned long int) seed);

	//generate a number
	do {
		mpz_urandomb (a_mpa, state, mult_prec*a_prec);
		mpz_abs (a_mpa, a_mpa);
		mpz_get_str (a_data, 16, a_mpa);
		k = strlen (a_data);
	} while (k < (2 * (a_byte_count - mult_prec/8)));

	//generate b number
	do {
		mpz_urandomb (b_mpa, state, mult_prec*b_prec);
		mpz_abs (b_mpa, b_mpa);
		mpz_get_str (b_data, 16, b_mpa);
		k = strlen (b_data);
	} while (k < (2 * (b_byte_count - mult_prec/8)));

	tbCompSubtractionInteger (mult_prec, a_data, a_prec, b_data, b_prec, c_amb_data, &c_amb_sign, c_bma_data, &c_bma_sign);

	tbConvStringNumToHalfIntExtArray (mult_prec, a_data, a_prec, a);
	tbConvStringNumToHalfIntExtArray (mult_prec, b_data, b_prec, b);

	tmp = strlen(c_amb_data);
	if(tmp%(mult_prec/4)!=0)
		tmp = tmp / (mult_prec/4) + 1;
	else
		tmp = tmp / (mult_prec/4);
	tbConvStringNumToHalfIntExtArray (mult_prec, c_amb_data, tmp, c_amb);
	*c_amb_prec = tmp;
	if (c_amb_sign > 0)//-
		for (k=tmp; k<c_limb_out; k++) {
			c_amb[4*k+0] = 0xFFFF;
			c_amb[4*k+1] = 0xFFFF;
			c_amb[4*k+2] = 0xFFFF;
			c_amb[4*k+3] = 0xFFFF;
		}
	else//+
		for (k=tmp; k<c_limb_out; k++) {
			c_amb[4*k+0] = 0x0000;
			c_amb[4*k+1] = 0x0000;
			c_amb[4*k+2] = 0x0000;
			c_amb[4*k+3] = 0x0000;
		}

	tmp = strlen(c_bma_data);
	if(tmp%(mult_prec/4)!=0)
		tmp = tmp / (mult_prec/4) + 1;
	else
		tmp = tmp / (mult_prec/4);
	tbConvStringNumToHalfIntExtArray (mult_prec, c_bma_data, tmp, c_bma);
	*c_bma_prec = tmp;
	if (c_bma_sign > 0)//-
		for (k=tmp; k<c_limb_out; k++) {
			c_bma[4*k+0] = 0xFFFF;
			c_bma[4*k+1] = 0xFFFF;
			c_bma[4*k+2] = 0xFFFF;
			c_bma[4*k+3] = 0xFFFF;
		}
	else//+
		for (k=tmp; k<c_limb_out; k++) {
			c_bma[4*k+0] = 0x0000;
			c_bma[4*k+1] = 0x0000;
			c_bma[4*k+2] = 0x0000;
			c_bma[4*k+3] = 0x0000;
		}

	for (k=0; k<(a_prec-1); k++)
		a_last[k] = 0;
	a_last[k] = 1;
	for (k=0; k<(b_prec-1); k++)
		b_last[k] = 0;
	b_last[k] = 1;
	for (k=0; k<(c_limb_out-1); k++)
		c_amb_last[k] = 0;
	c_amb_last[k] = 1;
	for (k=0; k<(c_limb_out-1); k++)
		c_bma_last[k] = 0;
	c_bma_last[k] = 1;

	mpz_clears (a_mpa, b_mpa, c_amb_mpa, c_bma_mpa, NULL);
	gmp_randclear (state);
#ifdef PRINTDEBUGVAL
	printf ("*******************************Debug info***********************************\n");

	printf("Values obtained from Vivado (a_prec, b_prec, seed):\n\n %u\n %u\n %u\n\n", a_prec, b_prec, seed);

	printf("Values sent to Vivado (a, b, c_amb, c_bma operand):\n\n");

	tbPrintHalfIntArray (mult_prec, a, a_prec);
	tbPrintHalfIntArray (mult_prec, b, b_prec);
	tbPrintHalfIntArray (mult_prec, c_amb, c_limb_out);
	tbPrintHalfIntArray (mult_prec, c_bma, c_limb_out);

	printf("Output precision a-b:\n%d\n", *c_amb_prec);
	printf("Output precision b-a:\n%d\n", *c_bma_prec);
	printf("\nLast signals (a, b, c_amb, c_bma operand):\n");
	for (k=0; k<a_prec; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<b_prec; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<c_limb_out; k++)
		printf("%d", c_amb_last[k]);
	printf("\n\n");
	for (k=0; k<c_limb_out; k++)
		printf("%d", c_bma_last[k]);
	printf("\n\n");

	printf ("***************************End of Debug info********************************\n\n");
#endif
	free(a_data);
	free(b_data);
	free(c_amb_data);
	free(c_bma_data);
}

//============================================================================
//==MULTIPLICATION RELATED FUNCTIONS IMPORTED FROM mult_regs_address PROJECT==
//============================================================================

//static variables
int A_size;
int B_size;
int A_start_addr;
int B_start_addr;
int A_curr_addr;
int B_curr_addr;
int smaller;
int greater;

int up_cycle;
int flat_cycle;
int down_cycle;


void m_init(int a, int b) {

	A_size = a;
	B_size = b;
	A_start_addr = -1;
	B_start_addr = 0;
	A_curr_addr = 0;
	B_curr_addr = 0;
	smaller = a;
	greater = b;

	if(smaller > greater) {
		smaller = b;
		greater = a;
	}

	up_cycle = 0;
	flat_cycle = 0;
	down_cycle = 0;
}

int m_get_smaller() {return smaller;}
int m_get_greater() {return greater;}

int m_get_up_cycle() {return up_cycle;}
int m_get_flat_cycle() {return flat_cycle;}
int m_get_down_cycle() {return down_cycle;}

void m_incr_up_cycle() {up_cycle++;}
void m_decr_up_cycle() {up_cycle--;}
void m_incr_flat_cycle() {flat_cycle++;}
void m_incr_down_cycle() {down_cycle++;}

void m_get_indices(int *Aind, int *Bind) {*Aind = A_curr_addr; *Bind = B_curr_addr;}

void m_modify_addr() {
	A_curr_addr--;
	B_curr_addr++;
}

void m_do_up_cycle() {
	A_start_addr++;
	A_curr_addr = A_start_addr;
	B_curr_addr = B_start_addr;
}

void m_do_flat_cycle() {
	if(A_start_addr < A_size-1) {
		A_start_addr++;
	}
	//if(smaller < B_size-1) {
	if(B_start_addr < B_size-1 && B_size >= A_size) {
		B_start_addr++;
	}
	A_curr_addr = A_start_addr;
	B_curr_addr = B_start_addr;
}

void m_do_down_cycle() {
	B_start_addr++;
	A_curr_addr = A_start_addr;
	B_curr_addr = B_start_addr;
}

void mult_regs_address(int *Aind, int Alimbs, int *Bind, int Blimbs, int *cycle, int *addr_init_up, int *last, int *valid)
{
    int i, j;

    m_init(Alimbs, Blimbs);

    int counter = 0;


    for (i=0; i<Alimbs*Blimbs+1; i++) {
        cycle[i]=0;
        addr_init_up[i]=0;
        last[i]=0;
        valid[i]=0;
     }

    // Generation of index_A, index_B, valid and last

    //UP
    for(j=0; j < m_get_smaller(); j++) {
        m_do_up_cycle();
        for(i = 0; i <= m_get_up_cycle(); i++) {
            counter++;
            m_get_indices(&Aind[counter], &Bind[counter]);
            m_modify_addr();
            valid[counter]=1;
        }
        m_incr_up_cycle();
    }

    //FLAT
    for(j=m_get_smaller(); j < m_get_greater(); j++) {
        m_do_flat_cycle();
        for(i = 0; i < m_get_smaller(); i++) {
            counter++;
            m_get_indices(&Aind[counter], &Bind[counter]);
            valid[counter]=1;
            m_modify_addr();
        }
        m_incr_flat_cycle();
    }

    //DOWN
    m_decr_up_cycle();
    for(j=0; j < m_get_smaller()-1; j++) {
        m_do_down_cycle();
        for(i = 0; i < m_get_up_cycle(); i++) {
            counter++;
            m_get_indices(&Aind[counter], &Bind[counter]);
            valid[counter]=1;
            m_modify_addr();
        }
        m_incr_down_cycle();
        m_decr_up_cycle();
    }
    last[counter] = 1;


    // Generation of cycle
    for(i=0; i<counter; i++) {
        if(Aind[i+1] > Aind[i] || ((Alimbs == 1 || Blimbs == 1) && valid[counter] == 1)) {
            cycle[i] = 1;
        }
    }

    // Generation of addr_init_up
    int init_up_A_cnt = 1;
    int init_up_B_cnt = 1;
    for(i=1; i<counter; i++) {
        if(cycle[i] == 1) {
            if(init_up_A_cnt < Alimbs) {
                addr_init_up[i-1] = 1;
                init_up_A_cnt++;
            } else if(init_up_B_cnt < Blimbs) {
                addr_init_up[i-1] = 2;
                init_up_B_cnt++;
            }
        }
    }

    // restting main addressing counters
    cycle[0] = 1;

}

//============================================================================

/** Generate data for test of multiplication of two numbers in MPA using seed, output is in external arrays.
 * \param a the first operand
 * \param a_prec precision of the first operand (in multiples of the number of bits of the multiplier unit=64)
 * \param a_last information if last limb of a array
 * \param b the second operand
 * \param b_prec precision of the second operand (in multiples of the number of bits of the multiplier unit=64)
 * \param b_last information if last limb of b array
 * \param c result of multiplication
 * \param c_prec precision of the result (in multiples of the number of bits of the multiplier unit=64)
 * \param c_last information if last limb of c array
 * \param cycle cycle signal
 * \param seed parameter of the random number generation
 */
void tbGenTestDataMultiplicationIntegerSeedSrup (	int		*a,
											int		a_prec,
											int		*a_last,
											int		*b,
											int		b_prec,
											int		*b_last,
											int		*c,
											int		*c_prec,
											int		*c_last,
											int		*cycle,
											int		seed) {
	int					k;
	unsigned int		tmp;
	const int			mult_prec = 64;
	char				*a_data;
	char				*b_data;
	char				*c_data;
	int					a_byte_count;
	int					b_byte_count;
	int					c_byte_count;
	int					a_hex_length;
	int					b_hex_length;
	int					c_hex_length;
	gmp_randstate_t		state;
	mpz_t				a_mpa, b_mpa, c_mpa;

	mpz_inits (a_mpa, b_mpa, c_mpa, NULL);

	a_byte_count = (mult_prec * a_prec) / 8;
	b_byte_count = (mult_prec * b_prec) / 8;
	c_byte_count = a_byte_count + b_byte_count;

	a_hex_length = 2 * a_byte_count;
	b_hex_length = 2 * b_byte_count;
	c_hex_length = 2 * c_byte_count;

	a_data = (char*) calloc (a_hex_length+1, sizeof(char));
	b_data = (char*) calloc (b_hex_length+1, sizeof(char));
	c_data = (char*) calloc (c_hex_length+1, sizeof(char));

	gmp_randinit_default (state);
	gmp_randseed_ui (state, (unsigned long int) seed);

	//generate a number
	do {
		mpz_urandomb (a_mpa, state, mult_prec*a_prec);
		mpz_abs (a_mpa, a_mpa);
		mpz_get_str (a_data, 16, a_mpa);
		k = strlen (a_data);
	} while (k < (2 * (a_byte_count - mult_prec/8)));

	//generate b number
	do {
		mpz_urandomb (b_mpa, state, mult_prec*b_prec);
		mpz_abs (b_mpa, b_mpa);
		mpz_get_str (b_data, 16, b_mpa);
		k = strlen (b_data);
	} while (k < (2 * (b_byte_count - mult_prec/8)));

	tbCompMultiplicationInteger (mult_prec, a_data, a_prec, b_data, b_prec, c_data);
	tmp = strlen(c_data);
	if(tmp%(mult_prec/4)!=0)
		tmp = tmp / (mult_prec/4) + 1;
	else
		tmp = tmp / (mult_prec/4);
	*c_prec = tmp;

#ifdef KAMORD
	int		mult_size = mult_prec/4;
	int		*a_order;
	int		*b_order;
	char	*a_data_tmp;
	char	*b_data_tmp;

	a_order = (int*) calloc (a_prec*b_prec+1, sizeof(int));
	b_order = (int*) calloc (a_prec*b_prec+1, sizeof(int));
	a_data_tmp = (char*) calloc (a_prec*b_prec*mult_size+1, sizeof(char));
	b_data_tmp = (char*) calloc (a_prec*b_prec*mult_size+1, sizeof(char));

	// addr_init_up, last and valid are dummy registers added by KR to support dpi_module in mult_regs_address
	int *addr_init_up = malloc((a_prec*b_prec+1) * sizeof(int));
	int *last = malloc((a_prec*b_prec+1) * sizeof(int));
	int *valid = malloc((a_prec*b_prec+1) * sizeof(int));

	mult_regs_address(a_order, a_prec, b_order, b_prec, cycle, addr_init_up, last, valid);

	/*
	//test if it works
	for(k=0; k<a_prec*b_prec; k++)
		printf("a_order=%d, b_order=%d\n", a_order[k], b_order[k]);
	 */

	for (k=0; k<(a_prec*b_prec-1); k++)
		a_last[k] = 0;
	a_last[k] = 1;
	for (k=0; k<(a_prec*b_prec-1); k++)
		b_last[k] = 0;
	b_last[k] = 1;
	for (k=0; k<(*c_prec-1); k++)
		c_last[k] = 0;
	c_last[k] = 1;

	tbAddZerosToStringNum (	a_data, a_hex_length);
	tbAddZerosToStringNum (	b_data, b_hex_length);
	tbAddZerosToStringNum (	c_data, c_hex_length);

	//change the order of data
	for (k=0; k<a_prec*b_prec*mult_size; k++) {
		a_data_tmp[k] = a_data[ a_order[k/mult_size+1]*mult_size+k%mult_size ];
		b_data_tmp[k] = b_data[ b_order[k/mult_size+1]*mult_size+k%mult_size ];
	}

	tbConvStringNumToHalfIntExtArray (mult_prec, a_data_tmp, a_prec*b_prec, a);
	tbConvStringNumToHalfIntExtArray (mult_prec, b_data_tmp, a_prec*b_prec, b);

	free(a_order);
	free(b_order);
	free(a_data_tmp);
	free(b_data_tmp);
#else
	for (k=0; k<(a_prec-1); k++)
		a_last[k] = 0;
	a_last[k] = 1;
	for (k=0; k<(b_prec-1); k++)
		b_last[k] = 0;
	b_last[k] = 1;
	for (k=0; k<(*c_prec-1); k++)
		c_last[k] = 0;
	c_last[k] = 1;

	tbConvStringNumToHalfIntExtArray (mult_prec, a_data, a_prec, a);
	tbConvStringNumToHalfIntExtArray (mult_prec, b_data, b_prec, b);
#endif
	tbConvStringNumToHalfIntExtArray (mult_prec, c_data, *c_prec, c);

	mpz_clears (a_mpa, b_mpa, c_mpa, NULL);
	gmp_randclear (state);
#ifdef PRINTDEBUGVAL
	printf ("*******************************Debug info***********************************\n");

	printf("Values obtained from Vivado (a_prec, b_prec, seed):\n\n %u\n %u\n %u\n\n", a_prec, b_prec, seed);

	printf("Values sent to Vivado (a, b, c operand):\n\n");

	tbPrintHalfIntArray (mult_prec, a, a_prec*b_prec);
	tbPrintHalfIntArray (mult_prec, b, a_prec*b_prec);
	tbPrintHalfIntArray (mult_prec, c, *c_prec);

	printf("Output precision:\n%d\n", *c_prec);
	printf("\nLast signals (a, b, c operand):\n");
	for (k=0; k<a_prec*b_prec; k++)
		printf("%d", a_last[k]);
	printf("\n\n");
	for (k=0; k<a_prec*b_prec; k++)
		printf("%d", b_last[k]);
	printf("\n\n");
	for (k=0; k<(a_prec+b_prec); k++)
		printf("%d", c_last[k]);
	printf("\n\n");
	printf("Cycle signal:\n");
	for (k=0; k<a_prec*b_prec; k++)
		printf("%d", cycle[k]);
	printf("\n\n");

	printf ("***************************End of Debug info********************************\n\n");
#endif
	free(a_data);
	free(b_data);
	free(c_data);
}

//====================================EOF=====================================
