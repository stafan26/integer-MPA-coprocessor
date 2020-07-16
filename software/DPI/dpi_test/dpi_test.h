//============================================================================
// Name        : dpi_test.h
// Author      : TS
// Version     :
// Copyright   : Your copyright notice
// Description : Test for DPI interface
//============================================================================

#ifndef DPI_TEST_H_INCLUDED
#define DPI_TEST_H_INCLUDED

#include <gmp.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/** Function tests DPI function interface.
 * \param data MPA number in long form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 */
void tbEmusrupTest		(
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign
								);

#endif
//====================================EOF=====================================

