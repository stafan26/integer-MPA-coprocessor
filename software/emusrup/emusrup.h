/*
 ============================================================================
 Name        : emusrup.h
 Author      : Tomasz Stefanski
 Version     :
 Copyright   : Your copyright notice
 Description : This code emulates SRUP on PC
 ============================================================================
 */

#ifndef EMUSRUP_H_INCLUDED
#define EMUSRUP_H_INCLUDED

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <gmp.h>
#include <sys/wait.h>
#include <semaphore.h>
#include "time_maker.h"

//#define DPITEST
#define DPIEXEC
#ifdef  DPIEXEC
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#endif

#define BINFNAME "prog.bin"
#define BINFBUSA "busA.bin"
#define BINFBUSB "busB.bin"
#define BINFBUSZ "busZ.bin"
#define EMUOUT	 "emuout.txt"

#define NUMSHD			1
#define NUMREG			16
#define NUMALLREG		(NUMSHD+NUMREG)

#define CMDSIZE  4

#define LOAACOM		"loaa"
#define LOABCOM		"loab"
#define LOAABCOM	"loaab"
#define UNLCOM		"unl"
#define ZEROCOM		"zer"
#define SET1COM		"set1"
#define CPRSCOM		"cpy"
#define MULTCOM		"mult"
#define ADDCOM		"add"
#define SUBCOM		"sub"

#define LOAABINCOM	0x01
#define LOABBINCOM	0x02
#define LOAABBINCOM	0x03
#define UNLBINCOM	0x04
#define ZEROBINCOM	0x05
#define SET1BINCOM	0x06
#define CPRSBINCOM	0x07
#define MULTBINCOM	0x08
#define ADDBINCOM	0x09
#define SUBBINCOM	0x0A

#define LASTBYTE	0x01
#define BREAKBYTE	0x00

#define HMASK		0xF0
#define LMASK		0x0F

#define FALSE	0
#define TRUE	1
#define bool	int

#define MAXFILENAMELENGTH		1024
#define RANDOMFILENAMELENGTH	16

//#define REGZERO
//#define TSPRINTSYS
//#define EMUOPT
#define LONGOUTDATA
#define MAXBYTES	4096

#define max(x,y) (((x) >= (y)) ? (x) : (y))

//===========================================================================
void print_reg_stat (FILE *fp, mpz_t *reg, int *phys, int reg_num);
//===========================================================================
void read_bin_file (char *file, char **data, int *data_size);
//===========================================================================
int mpz_limbs(mpz_t number);
//===========================================================================
char conv_char2hexchar (char a);
//===========================================================================
void read_int_number (char *data,  int data_size, mpz_t number, unsigned int *number_size);
//===========================================================================
void execute_instruction (	mpz_t	*reg,
									int	*phys,
									char	*prog,
									char	*busA,
									char	*busB,
									int	*prog_counter_pt,
									int	*busA_counter_pt,
									int	*busB_counter_pt,
									int	busA_size,
									int	busB_size,
									int	*execution_time_pt,
									char	*instruction,
									bool	verbose_scr,
									bool	verbose_emuout,
									bool	verbose_busZ,
									FILE	*emuout_pt,
									FILE	*busZ_pt
								);
//===========================================================================
void end_emulation (		mpz_t	*reg,
								int	*phys,
								char	*prog,
								char	*busA,
								char	*busB,
								int	execution_time,
								bool	verbose_scr,
								bool	verbose_emuout,
								bool	verbose_busZ,
								FILE	*emuout_pt,
								FILE	*busZ_pt
							);
//===========================================================================
void emulate(	mpz_t	*reg,
					int	*phys,
					char	*fname_prog,
					char	*fname_busA,
					char	*fname_busB,
					char	*fname_emuout,
					char	*fname_busZ,
					bool	verbose_scr
					);
//===========================================================================
#ifdef DPIEXEC
//===========================================================================
char *rand_string(char *str, size_t size);
//===========================================================================
char* rand_string_alloc(size_t size);
//===========================================================================
void read_shm (	char		*handle,
						char		*semaphore,
						mpz_t		*reg,
						int		*phys,
						int		*lfsr,
						int		*num_of_addr_bits,
						int		*instruction,
						int		*chpid,
						int		*control);
//===========================================================================
void write_shm (	char		*handle,
						char		*semaphore,
						mpz_t		*reg,
						int		*phys,
						int		lfsr,
						int		num_of_addr_bits,
						int		instruction,
						int		chpid,
						int		control);
//===========================================================================
void read_shm_for_check (	char		*handle,
									char		*semaphore,
									char		*reg,
									int		*reg_prec,
									int		*reg_sign,
									int		reg_num,
									int		*phys,
									int		*lfsr,
									int		*num_of_addr_bits,
									int		*instruction,
									int		*chpid,
									int		*control);
//===========================================================================
void read_shm_reg (	char		*handle,
							char		*semaphore,
							mpz_t		reg,
							int		*reg_limbs,
							int		reg_num );
//===========================================================================
void write_shm_reg (	char		*handle,
							char		*semaphore,
							mpz_t		reg,
							int		reg_save_limbs,
							int		reg_num );
//===========================================================================
void write_shm_reg_rev (	char		*handle,
									char		*semaphore,
									mpz_t		reg,
									int		reg_save_limbs,
									int		reg_num );
//===========================================================================
void write_shm_reg2c (	char		*handle,
								char		*semaphore,
								mpz_t		reg,
								int		reg_save_limbs,
								int		reg_num );
//===========================================================================
void write_shm_reg2c_rev (	char		*handle,
									char		*semaphore,
									mpz_t		reg,
									int		reg_save_limbs,
									int		reg_num );
//===========================================================================
void read_shm_phys (	char		*handle,
							char		*semaphore,
							int		*phys,
							int		reg_num );
//===========================================================================
void write_shm_phys (	char		*handle,
								char		*semaphore,
								int		phys,
								int		reg_num );
//===========================================================================
void swap_shm_reg (	char		*handle,
							char		*semaphore,
							int		regX_num,
							int		regY_num );
//===========================================================================
void read_shm_instruction (	char		*handle,
										char		*semaphore,
										int		*instruction);
//===========================================================================
void write_shm_instruction (	char		*handle,
										char		*semaphore,
										int		instruction);
//===========================================================================
void read_shm_chpid (	char		*handle,
								char		*semaphore,
								int		*chpid);
//===========================================================================
void write_shm_chpid (	char		*handle,
								char		*semaphore,
								int		chpid);
//===========================================================================
void read_shm_control (	char		*handle,
								char		*semaphore,
								int		*control);
//===========================================================================
void write_shm_control (	char		*handle,
									char		*semaphore,
									int		control);
//===========================================================================
void end_debug (		mpz_t	*reg,
								int	*phys,
								char	*prog,
								char	*busA,
								char	*busB,
								int	execution_time,
								bool	verbose_scr,
								bool	verbose_emuout,
								bool	verbose_busZ,
								FILE	*emuout_pt,
								FILE	*busZ_pt
							);
//===========================================================================
void emulate_in_background (
	char	*dir,
	int	lfsr,
	int	num_of_addr_bits,
	char	*handle,
	char	*semaphore         );
//===========================================================================
void debug_instruction (	char	*handle,
									char	*semaphore,
									mpz_t	*reg,
									int	*phys,
									char	*prog,
									char	*busA,
									char	*busB,
									int	*prog_counter_pt,
									int	*busA_counter_pt,
									int	*busB_counter_pt,
									int	busA_size,
									int	busB_size,
									int	*execution_time_pt,
									char	*instruction,
									bool	verbose_scr,
									bool	verbose_emuout,
									bool	verbose_busZ,
									FILE	*emuout_pt,
									FILE	*busZ_pt
								);
//===========================================================================
void debug_in_background (
	char	*dir,
	int	lfsr,
	int	num_of_addr_bits,
	char	*handle,
	char	*semaphore         );
//===========================================================================
void tbEmusrupStart (
	char	*dir,
	int	lfsr,
	int	num_of_addr_bits,
	char	*handle,
	char	*semaphore  );
//===========================================================================
void tbEmusrupProceed (
	char	*handle,
	char	*semaphore,
	int	*opcode_instr );
//===========================================================================
void tbEmusrupCheck		(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
								);
//===========================================================================
void tbEmusrupCheckLogic	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
									);
//===========================================================================
void tbEmusrupCheckShadow	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
									);
//===========================================================================
void tbEmusrupStop (
	char	*handle,
	char	*semaphore
							);
//===========================================================================
// Debugger for DPI debugger
//===========================================================================
/** Function prints status of registers of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_logic_addr logical number of checked register
 */
void tbEmusrupPrintReg	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr
								);
//===========================================================================
/** Function prints status of registers of emusrup in DPI debug mode for assumed instruction number.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_logic_addr logical number of checked register
 * \param counter_print_val value of counter, when info about register should be printed out
 * \param counter current value of counter
 */
void tbEmusrupPrintRegStep	(
	char								*handle,
	char								*semaphore,
	int								data_logic_addr,
	int								counter_print_val,
	int								counter
									);
//===========================================================================
/** Function prints status of registers of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_logic_addr logical number of checked register
 * \param data MPA number in half-integer long form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 * \param data_phys_addr physical number of checked register
 */
void tbEmusrupCheckRegPC	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
									);
//===========================================================================
/** Function prints status of registers of emusrup in DPI debug mode for assumed instruction number.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_logic_addr logical number of checked register
 * \param data MPA number in half-integer long form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 * \param data_phys_addr physical number of checked register
 * \param counter_print_val value of counter, when info about register should be printed out
 * \param counter current value of counter
 */
void tbEmusrupCheckRegStepPC	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr,
	int							counter_print_val,
	int							counter
									);
#endif
//===========================================================================
#endif
//===========================================================================
