//============================================================================
// Name        : dpi_test.c
// Author      : TS
// Version     :
// Copyright   : Your copyright notice
// Description : Test for DPI interface
//============================================================================

#include "dpi_test.h"
#include "../../common/lfsr.h"

//===========================================================================
/** Function tests DPI function interface.
 * \param data MPA number in long form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 */
void tbEmusrupTest		(
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign
								)
{
	int	i, j;
	int	lfsr = 1;
	int	num_of_addr_bits = 9;

	char	data_char[MAXBYTES];

	unsigned char	tmp[8];

	int							data_long_size;
	unsigned long long int	data_long[MAXBYTES/8];
	unsigned long long int	data_lfsr_long[MAXBYTES/8];

	//fulfill array with 0xFF chars and one
	for(i=0; i<MAXBYTES; i++)
		data_char[i] = 0xFF;
	for(i=0; i<16; i++)
		data_char[i] = 0x00;
	data_char[0] = 0x01;//a single limb
	data_char[1] = 0x80;//minus sign
	data_char[2] = 0x01;//last flag
	data_char[8] = 0x01;

	//set sign
	*data_sign = 1;

	//set data prec
	*data_prec = 1;

	for (i=0; i<(MAXBYTES/8-1); i++) {
		data_long[i] = 0;
		for (j=0; j<8; j++) {
			tmp[j] = (unsigned char) data_char[8*i+8+j];
			data_long[i] += ((unsigned long long int)tmp[j])<<(8*j);
		}
	}
	//data_long[MAXBYTES/8-2] = 0;

	//lfsr transformation
	if (lfsr == 1) {
		for (i=0; i<MAXBYTES/8; i++)
			data_lfsr_long[i]=0;
		arr2lfsrf(data_lfsr_long, data_long, (MAXBYTES/8-1), num_of_addr_bits);
		for (i=0; i<MAXBYTES/8; i++)
			data[i] = data_lfsr_long[i];
		num2lfsr((unsigned int *) data_prec, (unsigned int) data_long_size, (unsigned int) num_of_addr_bits);
	} else {
		for (i=0; i<MAXBYTES/8; i++)
			data[i] = data_long[i];
		*data_prec = data_long_size;
	}
}
//===========================================================================
