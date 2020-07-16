//============================================================================
// Name        : dpi_module.h
// Author      : TS
// Version     :
// Copyright   : Your copyright notice
// Description : Library of MPA functions for MPA-FPGA testing
//============================================================================

#ifndef DPI_MODULE_H_INCLUDED
#define DPI_MODULE_H_INCLUDED

#include <gmp.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

//Error codes
#define ERR_STR 1

//Print on screen computed numbers for e.g. debugging
//#define PRINTVAL
#define PRINTDEBUGVAL

//Employ Kamil's operand order of data in multiplication
#define KAMORD

/** Functions prints error message and exits program.
 * \param msg error message
 * \param err_code error code
 */
void tbError (char *msg, int err_code);

/** Display function for testing connection of C and SV.
 */
void tbDisplay ();

/** Function prints on the screen ascii codes of the characters in string.
 * \param string pointer to the string with NULL end
 */
void tbPrintAsciiCodesStr (const char *string);

/** Function prints hex string on the screen.
 * \param string pointer to the string with NULL end
 */
void tbPrintHexStr (const char *string);

/** Function prints half-fulfilled integer array on the screen.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a the half-fulfilled array
 * \param a_prec precision of the number in a array (in multiples of the number of bits of the multiplier unit)
 */
void tbPrintHalfIntArray (	int		mult_prec,
							int		*a,
							int		a_prec);

/** Function generates random number in hex string.
 * \param a the table for storing the generated number (memory for this table must be allocated before calling this function)
 * \param a_size size of the table without NULL character in the end
 */
void tbGenRandomString (char	*a,
						int		a_size);

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
									char	*c);

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
									char	*c);

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
									int		*c_bma_sign);

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
											char	**c);

/** Function converts a hex character '0'-'f'/'F' into an 8-bit number.
 * \param a the character for conversion
 * \return 8-bit number
 */
char tbConvHexCharToChar (char a);

/** Convert string number to array of chars.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_char array with returned chars
 */
void tbConvStringNumToCharArray (	int		mult_prec,
									char	*a,
									int		a_prec,
									char	**a_char);

/** Convert string number to array of half-fulfilled integers.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_int array with returned integers
 */
void tbConvStringNumToHalfIntArray (	int		mult_prec,
										char	*a,
										int		a_prec,
										int		**a_int);

/** Convert string number to an external array of chars.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_char array with returned chars
 */
void tbConvStringNumToCharExtArray (	int		mult_prec,
										char	*a,
										int		a_prec,
										char	*a_char);

/** Add zeros to string number.
 * \param a_data string with MPA number
 * \param a_hex_length number of digits expected
 */
void tbAddZerosToStringNum (	char	*a_data,
								int		a_hex_length);

/** Convert string number to an external array of half-fulfilled integers.
 * \param mult_prec precision of the multiplier unit (in bits)
 * \param a string with MPA number
 * \param a_prec precision of the operand (in multiples of the number of bits of the multiplier unit)
 * \param a_int array with returned integers
 */
void tbConvStringNumToHalfIntExtArray (	int		mult_prec,
										char	*a,
										int		a_prec,
										int		*a_int);

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
																	int		seed);

#endif
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
											int		seed);

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
											int		seed);

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
											int		seed);

//============================================================================
//==MULTIPLICATION RELATED FUNCTIONS IMPORTED FROM mult_regs_address PROJECT==
//============================================================================

void mult_regs_address(int *Aind,
											int Alimbs,
											int *Bind,
											int Blimbs,
											int *cycle,
											int *addr_init_up, int *last, int *valid);

//====================================EOF=====================================

