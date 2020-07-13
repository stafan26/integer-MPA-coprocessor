/*
 ============================================================================
 Name        : emusrup.c
 Author      : Tomasz Stefanski
 Version     :
 Copyright   : Your copyright notice
 Description : This code emulates SRUP on PC
 ============================================================================
 */

#include "emusrup.h"
#include "../common/write_fun.h"
#include "../common/read_fun.h"
#include "../common/lfsr.h"

//===========================================================================
void print_reg_stat (FILE *fp, mpz_t *reg, int *phys, int reg_num) {

	int i;

	fprintf(fp, "===========================================================================\n");
	fprintf(fp, "=========================== Values of registers ===========================\n");
	for (i=0; i<reg_num; i++) {
#ifdef TSPRINTSYS
		gmp_fprintf (fp, "reg%d (P%d) = %Zx\n", i, phys[i], reg[i]);
#else
		fprintf (fp, "reg%d (P%d) = ", i, phys[i]);
		kam_fprintf (fp, reg[i]);
#endif
	}
}
//===========================================================================
int mpz_limbs(mpz_t number) {

	int	bytes_num, limbs_num;
	int	str_num_abs_size;
	char	*str_num, *str_num_abs;

	str_num = mpz_get_str (NULL, 16, number);

	if(str_num[0] == '-') {
		str_num_abs = &str_num[1];
	} else {// + sign
		str_num_abs = &str_num[0];
	}
	str_num_abs_size = strlen(str_num_abs);
	bytes_num = str_num_abs_size/2 + str_num_abs_size%2;
	limbs_num = bytes_num/8 + (bytes_num%8?((unsigned int)1):((unsigned int)0));
	return limbs_num;
}
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
								)
{
#ifdef EMUOPT //====================================EMULATOR VERSION=========
	int				swap;
	unsigned int	tmp;
	int				prog_counter, busA_counter, busB_counter;

	mpz_t				abs_a, abs_b;
	char				cmd[CMDSIZE];
	char				ex_cmd, op_cmd, opa_cmd, rop_cmd;

	int				execution_time, delta_time;

	prog_counter = *prog_counter_pt;
	busA_counter = *busA_counter_pt;
	busB_counter = *busB_counter_pt;

	execution_time = *execution_time_pt;
	delta_time = 0;

	mpz_inits(abs_a, abs_b, NULL);

	//execute instruction
	cmd[0] = prog[prog_counter++];
	cmd[1] = prog[prog_counter++];
	if (cmd[1] == LASTBYTE) { //short instruction
		ex_cmd = (cmd[0] & LMASK);
		op_cmd = (cmd[0] & HMASK)>>4;
		switch(ex_cmd) {
			case LOAABINCOM: //loaa regX
				//send data from busA to regX
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", LOAACOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", LOAACOM, op_cmd);

				read_int_number (&busA[busA_counter], busA_size-busA_counter, reg[(int)(op_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);
				busA_counter+=8*tmp+8;

				delta_time = exec_cmd(LOAABINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case LOABBINCOM: //loab regX
				//send data from busB to regX
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", LOABCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", LOABCOM, op_cmd);

				read_int_number (&busB[busB_counter], busB_size-busB_counter, reg[(int)(op_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);
				busB_counter+=8*tmp+8;

				delta_time = exec_cmd(LOABBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case UNLBINCOM: //unl data
				//unload data from register
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", UNLCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", UNLCOM, op_cmd);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("UNLOADED VALUE from reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("UNLOADED VALUE from reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_busZ)
					write_bin_number (busZ_pt, reg[(int)(op_cmd)]);
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(UNLBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case ZEROBINCOM: //zero reg
				//set register value to 0
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", ZEROCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", ZEROCOM, op_cmd);

				mpz_set_ui (reg[(int)(op_cmd)], 0);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(ZEROBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case SET1BINCOM: //set reg to 1
				//set register value to 1
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", SET1COM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", SET1COM, op_cmd);

				mpz_set_ui (reg[(int)(op_cmd)], 1);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(SET1BINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			default:
				fprintf (stderr, "Unknown short command\n");
				exit (5);
		}
	} else if (cmd[1] == BREAKBYTE) { //long instruction
		cmd[2] = prog[prog_counter++];
		cmd[3] = prog[prog_counter++];

		ex_cmd  = (cmd[2] & LMASK);
		op_cmd = (cmd[2] & HMASK)>>4;
		opa_cmd  = (cmd[0] & LMASK);
		rop_cmd = (cmd[0] & HMASK)>>4;
		if (cmd[3] != LASTBYTE) {
			fprintf (stderr, "Wrong last byte\n");
			exit (6);
		}
		switch(ex_cmd) {
			case LOAABBINCOM: //loaab regX, regY
				if (verbose_scr)
					printf(           "%s reg%d, reg%d;\n\n", LOAABCOM, op_cmd, opa_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d;\n\n", LOAABCOM, op_cmd, opa_cmd);

				//send data from busA to regX
				read_int_number (&busA[busA_counter], busA_size-busA_counter, reg[(int)(op_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				busA_counter+=8*tmp+8;
				//send data from busB to regY
				read_int_number (&busB[busB_counter], busB_size-busB_counter, reg[(int)(opa_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
				}
#endif
				busB_counter+=8*tmp+8;

				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(LOAABBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), 0);
				execution_time += delta_time;

				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case CPRSBINCOM: //cpy regX, regY (regY = regX)------------------------DONE
				//copy data from regX to regY
				if (verbose_scr)
					printf(           "%s reg%d, reg%d;\n\n", CPRSCOM, op_cmd, opa_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d;\n\n", CPRSCOM, op_cmd, opa_cmd);

				mpz_set (reg[(int)(opa_cmd)], reg[(int)(op_cmd)]);
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(CPRSBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), 0);
				execution_time += delta_time;

				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case MULTBINCOM: //mutl regX, regY, regZ (regZ = regX * regY)----------DONE
				//multiply data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				//fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, rop_cmd, op_cmd, opa_cmd, phys[(int)(opa_cmd)]);

				mpz_mul (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(MULTBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case ADDBINCOM: //add regX, regY, regZ (regZ = regX + regY)------------DONE
				//add data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", ADDCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", ADDCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);

				mpz_add (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);

				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);
				if ( ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])<0 && mpz_sgn(reg[(int)(opa_cmd)])>0 ) ||
					  ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])>0 && mpz_sgn(reg[(int)(opa_cmd)])<0 )    ) {
					swap=phys[(int)(rop_cmd)];
					phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
					phys[(int)(NUMREG)] = swap;
				}
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(ADDBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case SUBBINCOM: //sub regX, regY, regZ (regZ = regX - regY)------------DONE
				//subtract data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", SUBCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", SUBCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);

				mpz_sub (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);

				if ( ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])>0 && mpz_sgn(reg[(int)(opa_cmd)])>0 ) ||
					  ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])<0 && mpz_sgn(reg[(int)(opa_cmd)])<0 )    ) {
					swap=phys[(int)(rop_cmd)];
					phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
					phys[(int)(NUMREG)] = swap;
				}
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMREG);

				delta_time = exec_cmd(SUBBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			default:
				fprintf (stderr, "Unknown long command\n");
				exit (7);
		}
	} else { //error in program
		fprintf (stderr, "Error in program\n");
		exit (4);
	}

	mpz_clears(abs_a, abs_b, NULL);

	*prog_counter_pt = prog_counter;
	*busA_counter_pt = busA_counter;
	*busB_counter_pt = busB_counter;

	*execution_time_pt = execution_time;
	*instruction = ex_cmd;
#else //====================================DEBUG VERSION====================
	int				swap;
	unsigned int	tmp;
	int				prog_counter, busA_counter, busB_counter;

	mpz_t				abs_a, abs_b;
	char				cmd[CMDSIZE];
	char				ex_cmd, op_cmd, opa_cmd, rop_cmd;

	int				execution_time, delta_time;

	prog_counter = *prog_counter_pt;
	busA_counter = *busA_counter_pt;
	busB_counter = *busB_counter_pt;

	execution_time = *execution_time_pt;
	delta_time = 0;

	mpz_inits(abs_a, abs_b, NULL);

	//execute instruction
	cmd[0] = prog[prog_counter++];
	cmd[1] = prog[prog_counter++];
	if (cmd[1] == LASTBYTE) { //short instruction
		ex_cmd = (cmd[0] & LMASK);
		op_cmd = (cmd[0] & HMASK)>>4;
		switch(ex_cmd) {
			case LOAABINCOM: //loaa regX
				//send data from busA to regX
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", LOAACOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", LOAACOM, op_cmd);

				read_int_number (&busA[busA_counter], busA_size-busA_counter, reg[(int)(op_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);
				busA_counter+=8*tmp+8;

				delta_time = exec_cmd(LOAABINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case LOABBINCOM: //loab regX
				//send data from busB to regX
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", LOABCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", LOABCOM, op_cmd);

				read_int_number (&busB[busB_counter], busB_size-busB_counter, reg[(int)(op_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);
				busB_counter+=8*tmp+8;

				delta_time = exec_cmd(LOABBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case UNLBINCOM: //unl data
				//unload data from register
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", UNLCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", UNLCOM, op_cmd);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("UNLOADED VALUE from reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("UNLOADED VALUE from reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_busZ)
					write_bin_number (busZ_pt, reg[(int)(op_cmd)]);
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(UNLBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case ZEROBINCOM: //zero reg
				//set register value to 0
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", ZEROCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", ZEROCOM, op_cmd);

				mpz_set_ui (reg[(int)(op_cmd)], 0);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(ZEROBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case SET1BINCOM: //set reg to 1
				//set register value to 1
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", SET1COM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", SET1COM, op_cmd);

				mpz_set_ui (reg[(int)(op_cmd)], 1);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(SET1BINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			default:
				fprintf (stderr, "Unknown short command\n");
				exit (5);
		}
	} else if (cmd[1] == BREAKBYTE) { //long instruction
		cmd[2] = prog[prog_counter++];
		cmd[3] = prog[prog_counter++];

		ex_cmd  = (cmd[2] & LMASK);
		op_cmd = (cmd[2] & HMASK)>>4;
		opa_cmd  = (cmd[0] & LMASK);
		rop_cmd = (cmd[0] & HMASK)>>4;
		if (cmd[3] != LASTBYTE) {
			fprintf (stderr, "Wrong last byte\n");
			exit (6);
		}
		switch(ex_cmd) {
			case LOAABBINCOM: //loaab regX, regY
				if (verbose_scr)
					printf(           "%s reg%d, reg%d;\n\n", LOAABCOM, op_cmd, opa_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d;\n\n", LOAABCOM, op_cmd, opa_cmd);

				//send data from busA to regX
				read_int_number (&busA[busA_counter], busA_size-busA_counter, reg[(int)(op_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				busA_counter+=8*tmp+8;
				//send data from busB to regY
				read_int_number (&busB[busB_counter], busB_size-busB_counter, reg[(int)(opa_cmd)], &tmp);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
				}
#endif
				busB_counter+=8*tmp+8;

				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(LOAABBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), 0);
				execution_time += delta_time;

				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case CPRSBINCOM: //cpy regX, regY (regY = regX)------------------------DONE
				//copy data from regX to regY
				if (verbose_scr)
					printf(           "%s reg%d, reg%d;\n\n", CPRSCOM, op_cmd, opa_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d;\n\n", CPRSCOM, op_cmd, opa_cmd);

				mpz_set (reg[(int)(opa_cmd)], reg[(int)(op_cmd)]);
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(CPRSBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), 0);
				execution_time += delta_time;

				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case MULTBINCOM: //mutl regX, regY, regZ (regZ = regX * regY)----------DONE
				//multiply data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				//fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, rop_cmd, op_cmd, opa_cmd, phys[(int)(opa_cmd)]);

				mpz_mul (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(MULTBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case ADDBINCOM: //add regX, regY, regZ (regZ = regX + regY)------------DONE
				//add data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", ADDCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", ADDCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
/*
				mpz_add (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);

				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);
				if ( ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])<0 && mpz_sgn(reg[(int)(opa_cmd)])>0 ) ||
					  ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])>0 && mpz_sgn(reg[(int)(opa_cmd)])<0 )    ) {
					swap=phys[(int)(rop_cmd)];
					phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
					phys[(int)(NUMREG)] = swap;
				}
*/
				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);

				if (mpz_cmp (abs_a, abs_b) > 0) {//|A| > |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) == 0) {//|A| = |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) < 0) {//|A| < |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									mpz_neg (reg[NUMREG], reg[NUMREG]);//sign change
									//////////////////SWAP////////////////////////
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									//////////////////SWAP////////////////////////
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else {
					fprintf (stderr, "debug_instruction: Error in kam table 0\n");
					exit (60);
				}
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(ADDBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case SUBBINCOM: //sub regX, regY, regZ (regZ = regX - regY)------------DONE
				//subtract data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", SUBCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", SUBCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
/*
				mpz_sub (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);

				if ( ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])>0 && mpz_sgn(reg[(int)(opa_cmd)])>0 ) ||
					  ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])<0 && mpz_sgn(reg[(int)(opa_cmd)])<0 )    ) {
					swap=phys[(int)(rop_cmd)];
					phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
					phys[(int)(NUMREG)] = swap;
				}
*/
				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);

				if (mpz_cmp (abs_a, abs_b) > 0) {//|A| > |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) == 0) {//|A| = |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) < 0) {//|A| < |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									mpz_neg (reg[NUMREG], reg[NUMREG]);//sign change
									//////////////////SWAP////////////////////////
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									//////////////////SWAP////////////////////////
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else {
					fprintf (stderr, "debug_instruction: Error in kam table 0\n");
					exit (60);
				}
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(SUBBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			default:
				fprintf (stderr, "Unknown long command\n");
				exit (7);
		}
	} else { //error in program
		fprintf (stderr, "Error in program\n");
		exit (4);
	}

	mpz_clears(abs_a, abs_b, NULL);

	*prog_counter_pt = prog_counter;
	*busA_counter_pt = busA_counter;
	*busB_counter_pt = busB_counter;

	*execution_time_pt = execution_time;
	*instruction = ex_cmd;
#endif
}
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
							)
{
	int				i;

	//print final status of registers
#ifdef EMUOPT
	if (verbose_scr)
		print_reg_stat (stdout, reg, phys, NUMREG);
#else
	if (verbose_scr)
		print_reg_stat (stdout, reg, phys, NUMALLREG);
#endif
	//print total time information
	execution_time += time_to_termination();
	if (verbose_scr) {
		printf(            "===========================================================================\n");
		printf(            "Total clk = %d\n", execution_time);
	}
	if (verbose_emuout) {
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "Total clk = %d\n", execution_time);
	}

	//free data and registers
#ifdef EMUOPT
	for(i=0; i<NUMREG; i++)
		mpz_clear (reg[i]);
#else
	for(i=0; i<NUMALLREG; i++)
		mpz_clear (reg[i]);
#endif
	free(prog);
	free(busA);
	free(busB);

	if (verbose_scr) {
		printf(            "===========================================================================\n");
		printf(            "============================= End of emulation ============================\n");
		printf(            "===========================================================================\n");
	}

	if (verbose_emuout) {
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "============================= End of emulation ============================\n");
		fprintf(emuout_pt, "===========================================================================\n");
	}

	if (verbose_busZ)
		fclose (busZ_pt);
	if (verbose_emuout)
		fclose (emuout_pt);
}
//===========================================================================
void emulate(	mpz_t	*reg,
					int	*phys,
					char	*fname_prog,
					char	*fname_busA,
					char	*fname_busB,
					char	*fname_emuout,
					char	*fname_busZ,
					bool	verbose_scr
					)
{

	FILE				*emuout_pt, *busZ_pt;
	int				i;
	unsigned int	instr;
	char				*prog, *busA, *busB;
	int				prog_size, busA_size, busB_size;
	int				prog_counter, busA_counter, busB_counter;

	bool				verbose_emuout, verbose_busZ;

	char instruction;
	int  execution_time=0;

	if (fname_emuout == NULL) {
		verbose_emuout = FALSE;
	} else {
		verbose_emuout = TRUE;
		emuout_pt = fopen (fname_emuout, "w");
	}
	if (fname_busZ == NULL) {
		verbose_busZ = FALSE;
	} else {
		verbose_busZ = TRUE;
		busZ_pt = fopen (fname_busZ, "wb");
	}

	if (verbose_scr) {
		printf(           "===========================================================================\n");
		printf(           "============================ Start of emulation ===========================\n");
		printf(           "===========================================================================\n");
		printf(           "Emulation based on files:\n%s\n%s\n%s\n%s\n%s\n\n", fname_prog, fname_busA, fname_busB, fname_busZ, fname_emuout);
	}
	if (verbose_emuout) {
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "============================ Start of emulation ===========================\n");
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "Emulation based on files:\n%s\n%s\n%s\n%s\n%s\n\n", fname_prog, fname_busA, fname_busB, fname_busZ, fname_emuout);
	}

	//init time measurement
	time_maker();

	//init registers
#ifdef EMUOPT
	for(i=0; i<NUMREG; i++)
		mpz_init (reg[i]);
	for(i=0; i<(NUMREG+NUMSHD); i++)
		phys[i]=i;
#else
	for(i=0; i<NUMALLREG; i++)
		mpz_init (reg[i]);
	for(i=0; i<NUMALLREG; i++)
		phys[i]=i;
#endif
	//read program and data
	read_bin_file (fname_prog, &(prog), &prog_size);
	read_bin_file (fname_busA, &(busA), &busA_size);
	read_bin_file (fname_busB, &(busB), &busB_size);

	//execute code
	instr = 0;
	prog_counter = 0;
	busA_counter = 0;
	busB_counter = 0;
	while (prog_counter < prog_size) {

		if (verbose_scr) {
			printf(            "===========================================================================\n");
			printf(            "=============================== Step: %.4d ================================\n", instr);
		}
		if (verbose_emuout) {
			fprintf(emuout_pt, "===========================================================================\n");
			fprintf(emuout_pt, "=============================== Step: %.4d ================================\n", instr++);
		}

		execute_instruction (	reg,
										phys,
										prog,
										busA,
										busB,
										&prog_counter,
										&busA_counter,
										&busB_counter,
										busA_size,
										busB_size,
										&execution_time,
										&instruction,
										verbose_scr,
										verbose_emuout,
										verbose_busZ,
										emuout_pt,
										busZ_pt);
	}

	end_emulation (	reg,
							phys,
							prog,
							busA,
							busB,
							execution_time,
							verbose_scr,
							verbose_emuout,
							verbose_busZ,
							emuout_pt,
							busZ_pt
							);
}
//===========================================================================
#ifdef DPIEXEC

#include <time.h>
//===========================================================================
char *rand_string(char *str, size_t size)
{
	const char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJK...";

	srand( time(NULL) );
	if (size) {
		--size;
      size_t n = 0;
		for (n = 0; n < size; n++) {
			int key = rand() % (int) (sizeof charset - 1);
			str[n] = charset[key];
		}
		str[0] = '/';
		str[size] = '\0';
	}
	return str;
}
//===========================================================================
char* rand_string_alloc(size_t size)
{
	char *s = malloc(size + 1);
	if (s) {
		rand_string(s, size);
	}
	return s;
}
//===========================================================================
void read_shm (	char		*handle,
						char		*semaphore,
						mpz_t		*reg,
						int		*phys,
						int		*lfsr,
						int		*num_of_addr_bits,
						int		*instruction,
						int		*chpid,
						int		*control)
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	unsigned int	data_size[NUMALLREG];
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm: Error in shared memory opening\n");
		exit (6);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "read_shm: Error in shared memory truncation\n");
		exit (6);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "read_shm: Error in shared memory mapping\n");
		exit (6);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm: Error in semaphore opening\n");
		exit (6);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	for (i=0; i<NUMALLREG; i++) {
		read_int_number (&data_char[i*MAXBYTES],  MAXBYTES, reg[i], &data_size[i]);
	}

	data_int = (int *)shm_pt;
	for (i=0; i<NUMALLREG; i++)
		if (data_int[NUMALLREG*MAXBYTES/4+i]!=data_size[i]) {
			fprintf (stderr, "read_shm: Error in shared memory - reg data size\n");
			exit (6);
		}
	for (i=0; i<NUMALLREG; i++)
		if (mpz_cmp_si (reg[i], (signed long int) 0) >= 0) {
			if(data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]!=0) {
				fprintf (stderr, "read_shm: Error in shared memory - reg data sign\n");
				exit (6);
			}
		} else {
			if (data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]!=1) {
				fprintf (stderr, "read_shm: Error in shared memory - reg data sign\n");
				exit (6);
			}
		}
	for (i=0; i<NUMALLREG; i++)
		phys[i] = data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+i];
	*lfsr = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG];
	*num_of_addr_bits = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+1];
	*instruction = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+2];
	*chpid = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+3];
	*control = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+4];

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void write_shm (	char		*handle,
						char		*semaphore,
						mpz_t		*reg,
						int		*phys,
						int		lfsr,
						int		num_of_addr_bits,
						int		instruction,
						int		chpid,
						int		control)
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	data_size[NUMALLREG];
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm: Error in shared memory opening\n");
		exit (6);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm: Error in shared memory truncation\n");
		exit (6);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "write_shm: Error in shared memory mapping\n");
		exit (6);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm: Error in semaphore opening\n");
		exit (6);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	for (i=0; i<NUMALLREG; i++) {
#ifdef REGZERO
		for (int j=0; j<MAXBYTES; j++) data_char[i*MAXBYTES+j]=0;
#endif
		write_int_number (reg[i], &data_char[i*MAXBYTES],  &data_size[i]);
	}

	data_int = (int *)shm_pt;
	for (i=0; i<NUMALLREG; i++)
		data_int[NUMALLREG*MAXBYTES/4+i]=(data_size[i]/8-1);
	for (i=0; i<NUMALLREG; i++)
		if (mpz_cmp_si (reg[i], (signed long int) 0) >= 0)
			data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=0;
		else
			data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=1;
	for (i=0; i<NUMALLREG; i++)
		data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+i]=phys[i];
	data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG]=lfsr;
	data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+1]=num_of_addr_bits;
	data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+2]=instruction;
	data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+3]=chpid;
	data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+4]=control;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
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
									int		*control)
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm: Error in shared memory opening\n");
		exit (6);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "read_shm: Error in shared memory truncation\n");
		exit (6);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "read_shm: Error in shared memory mapping\n");
		exit (6);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm: Error in semaphore opening\n");
		exit (6);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	for (i=0; i<MAXBYTES; i++) {
		reg[i] = data_char[reg_num*MAXBYTES+i];
	}

	data_int = (int *)shm_pt;
	*reg_prec = data_int[NUMALLREG*MAXBYTES/4+reg_num];
	*reg_sign = data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+reg_num];

	for (i=0; i<NUMALLREG; i++)
		phys[i] = data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+i];
	*lfsr = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG];
	*num_of_addr_bits = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+1];
	*instruction = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+2];
	*chpid = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+3];
	*control = data_int[NUMALLREG*MAXBYTES/4+3*NUMALLREG+4];

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void read_shm_reg (	char		*handle,
							char		*semaphore,
							mpz_t		reg,
							int		*reg_limbs,
							int		reg_num )
{
	int	i = reg_num;
	int	j;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	unsigned int	data_size;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm_reg: Error in shared memory opening\n");
		exit (7);
	}
	j=ftruncate(fd, length);
	if (j<0) {
		fprintf (stderr, "read_shm_reg: Error in shared memory truncation\n");
		exit (7);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "read_shm_reg: Error in shared memory mapping\n");
		exit (7);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm_reg: Error in semaphore opening\n");
		exit (7);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	read_int_number (&data_char[i*MAXBYTES],  MAXBYTES, reg, &data_size);

	data_int = (int *)shm_pt;
	if (data_int[NUMALLREG*MAXBYTES/4+i]!=data_size) {
		fprintf (stderr, "read_shm_reg: Error in shared memory - reg data size\n");
		exit (7);
	}
	if (mpz_cmp_si (reg, (signed long int) 0) >= 0) {
		if(data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]!=0) {
			fprintf (stderr, "read_shm_reg: Error in shared memory - reg data sign\n");
			exit (7);
		}
	} else {
		if (data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]!=1) {
			fprintf (stderr, "read_shm_reg: Error in shared memory - reg data sign\n");
			exit (7);
		}
	}
	*reg_limbs = data_size;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void write_shm_reg (	char		*handle,
							char		*semaphore,
							mpz_t		reg,
							int		reg_save_limbs,
							int		reg_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory opening\n");
		exit (7);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory truncation\n");
		exit (7);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory mapping\n");
		exit (7);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_reg: Error in semaphore opening\n");
		exit (7);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	i = reg_num;
#ifdef REGZERO
	for (int j=0; j<MAXBYTES; j++) data_char[i*MAXBYTES+j]=0;
#endif
	write_int_number_with_reset (reg, &data_char[i*MAXBYTES],  8*reg_save_limbs+8);

	data_int = (int *)shm_pt;
	data_int[NUMALLREG*MAXBYTES/4+i]=mpz_limbs(reg);
	if (mpz_cmp_si (reg, (signed long int) 0) >= 0)
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=0;
	else
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=1;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void write_shm_reg_rev (	char		*handle,
									char		*semaphore,
									mpz_t		reg,
									int		reg_save_limbs,
									int		reg_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory opening\n");
		exit (7);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory truncation\n");
		exit (7);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory mapping\n");
		exit (7);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_reg: Error in semaphore opening\n");
		exit (7);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	i = reg_num;
#ifdef REGZERO
	for (int j=0; j<MAXBYTES; j++) data_char[i*MAXBYTES+j]=0;
#endif
	write_int_number_with_reset_rev (reg, &data_char[i*MAXBYTES],  8*reg_save_limbs+8);

	data_int = (int *)shm_pt;
	data_int[NUMALLREG*MAXBYTES/4+i]=mpz_limbs(reg);
	if (mpz_cmp_si (reg, (signed long int) 0) >= 0)
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=0;
	else
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=1;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void write_shm_reg2c (	char		*handle,
								char		*semaphore,
								mpz_t		reg,
								int		reg_save_limbs,
								int		reg_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory opening\n");
		exit (7);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory truncation\n");
		exit (7);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory mapping\n");
		exit (7);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_reg: Error in semaphore opening\n");
		exit (7);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	i = reg_num;
#ifdef REGZERO
	for (int j=0; j<MAXBYTES; j++) data_char[i*MAXBYTES+j]=0;
#endif
	//write_int_number_with_reset (reg, &data_char[i*MAXBYTES],  8*reg_save_limbs+8);
	write_int2c_number_with_reset (reg, &data_char[i*MAXBYTES],  8*reg_save_limbs+8);

	data_int = (int *)shm_pt;
	//data_int[NUMALLREG*MAXBYTES/4+i]=mpz_limbs(reg);
	data_int[NUMALLREG*MAXBYTES/4+i]=reg_save_limbs;
	if (mpz_cmp_si (reg, (signed long int) 0) >= 0)
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=0;
	else
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=1;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void write_shm_reg2c_rev (	char		*handle,
									char		*semaphore,
									mpz_t		reg,
									int		reg_save_limbs,
									int		reg_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory opening\n");
		exit (7);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory truncation\n");
		exit (7);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "write_shm_reg: Error in shared memory mapping\n");
		exit (7);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_reg: Error in semaphore opening\n");
		exit (7);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	i = reg_num;
#ifdef REGZERO
	for (int j=0; j<MAXBYTES; j++) data_char[i*MAXBYTES+j]=0;
#endif
	//write_int_number_with_reset (reg, &data_char[i*MAXBYTES],  8*reg_save_limbs+8);
	write_int2c_number_with_reset_rev (reg, &data_char[i*MAXBYTES],  8*reg_save_limbs+8);

	data_int = (int *)shm_pt;
	//data_int[NUMALLREG*MAXBYTES/4+i]=mpz_limbs(reg);
	data_int[NUMALLREG*MAXBYTES/4+i]=reg_save_limbs;
	if (mpz_cmp_si (reg, (signed long int) 0) >= 0)
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=0;
	else
		data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+i]=1;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void read_shm_phys (	char		*handle,
							char		*semaphore,
							int		*phys,
							int		reg_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm_phys: Error in shared memory opening\n");
		exit (8);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "read_shm_phys: Error in shared memory truncation\n");
		exit (8);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "read_shm_phys: Error in shared memory mapping\n");
		exit (8);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm_phys: Error in semaphore opening\n");
		exit (8);
	}
	sem_wait(sem_id);

	data_int = (int *)shm_pt;
	*phys = data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+reg_num];

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void write_shm_phys (	char		*handle,
								char		*semaphore,
								int		phys,
								int		reg_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm: Error in shared memory opening\n");
		exit (8);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm: Error in shared memory truncation\n");
		exit (8);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "write_shm: Error in shared memory mapping\n");
		exit (8);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm: Error in semaphore opening\n");
		exit (8);
	}
	sem_wait(sem_id);

	data_int = (int *)shm_pt;
	data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+reg_num]=phys;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void swap_shm_reg (	char		*handle,
							char		*semaphore,
							int		regX_num,
							int		regY_num )
{
	int	i;
	int	fd;
	void	*shm_pt;
	sem_t	*sem_id;
	int	*data_int;
	char	*data_char;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);

	char	regX, regY;
	int	regX_prec, regY_prec;
	int	regX_sign, regY_sign;
	int	physX, physY;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "swap_shm_reg: Error in shared memory opening\n");
		exit (6);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "swap_shm_reg: Error in shared memory truncation\n");
		exit (6);
	}
	shm_pt = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (shm_pt<0) {
		fprintf (stderr, "swap_shm_reg: Error in shared memory mapping\n");
		exit (6);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "swap_shm_reg: Error in semaphore opening\n");
		exit (6);
	}
	sem_wait(sem_id);

	data_char = (char *)shm_pt;
	//data swap
	for (i=0; i<MAXBYTES; i++) {
		regX = data_char[regX_num*MAXBYTES+i];
		regY = data_char[regY_num*MAXBYTES+i];
		data_char[regX_num*MAXBYTES+i] = regY;
		data_char[regY_num*MAXBYTES+i] = regX;
	}

	data_int = (int *)shm_pt;
	//prec swap
	regX_prec = data_int[NUMALLREG*MAXBYTES/4+regX_num];
	regY_prec = data_int[NUMALLREG*MAXBYTES/4+regY_num];
	data_int[NUMALLREG*MAXBYTES/4+regX_num] = regY_prec;
	data_int[NUMALLREG*MAXBYTES/4+regY_num] = regX_prec;

	//sign swap
	regX_sign = data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+regX_num];
	regY_sign = data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+regY_num];
	data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+regX_num] = regY_sign;
	data_int[NUMALLREG*MAXBYTES/4+NUMALLREG+regY_num] = regX_sign;
/*
	printf("before swap_shm_reg\n");
	for (i=0; i<NUMALLREG; i++)
		printf("phys%d=%d\n", i, data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+i]);
*/
	//phys table swap
	physX = data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+regX_num];
	physY = data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+regY_num];
	data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+regX_num] = physY;
	data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+regY_num] = physX;
/*
	printf("after swap_shm_reg\n");
	for (i=0; i<NUMALLREG; i++)
		printf("phys%d=%d\n", i, data_int[NUMALLREG*MAXBYTES/4+2*NUMALLREG+i]);
*/
	sem_post(sem_id);
	sem_close(sem_id);
	munmap(shm_pt, length);
	close(fd);
}
//===========================================================================
void read_shm_instruction (	char		*handle,
										char		*semaphore,
										int		*instruction)
{
	int	i;
	int	fd;
	int	*data_int;
	sem_t	*sem_id;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm_instruction: Error in shared memory opening\n");
		exit (9);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "read_shm_instruction: Error in shared memory truncation\n");
		exit (9);
	}
	data_int = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (data_int<0) {
		fprintf (stderr, "read_shm_instruction: Error in shared memory mapping\n");
		exit (9);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm_instruction: Error in semaphore opening\n");
		exit (9);
	}
	sem_wait(sem_id);

	*instruction = data_int[length_int-3];

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(data_int, length);
	close(fd);
}
//===========================================================================
void write_shm_instruction (	char		*handle,
										char		*semaphore,
										int		instruction)
{
	int	i;
	int	fd;
	int	*data_int;
	sem_t	*sem_id;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_instruction: Error in shared memory opening\n");
		exit (9);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_instruction: Error in shared memory truncation\n");
		exit (9);
	}
	data_int = (int *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (data_int<0) {
		fprintf (stderr, "write_shm_instruction: Error in shared memory mapping\n");
		exit (9);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_instruction: Error in semaphore opening\n");
		exit (9);
	}
	sem_wait(sem_id);

	data_int[length_int-3]=instruction;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(data_int, length);
	close(fd);
}
//===========================================================================
void read_shm_chpid (	char		*handle,
								char		*semaphore,
								int		*chpid)
{
	int	i;
	int	fd;
	int	*data_int;
	sem_t	*sem_id;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm_chpid: Error in shared memory opening\n");
		exit (10);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "read_shm_chpid: Error in shared memory truncation\n");
		exit (10);
	}
	data_int = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (data_int<0) {
		fprintf (stderr, "read_shm_chpid: Error in shared memory mapping\n");
		exit (10);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm_chpid: Error in semaphore opening\n");
		exit (10);
	}
	sem_wait(sem_id);

	*chpid = data_int[length_int-2];

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(data_int, length);
	close(fd);
}
//===========================================================================
void write_shm_chpid (	char		*handle,
								char		*semaphore,
								int		chpid)
{
	int	i;
	int	fd;
	int	*data_int;
	sem_t	*sem_id;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_chpid: Error in shared memory opening\n");
		exit (10);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_chpid: Error in shared memory truncation\n");
		exit (10);
	}
	data_int = (int *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (data_int<0) {
		fprintf (stderr, "write_shm_chpid: Error in shared memory mapping\n");
		exit (10);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_chpid: Error in semaphore opening\n");
		exit (10);
	}
	sem_wait(sem_id);

	data_int[length_int-2]=chpid;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(data_int, length);
	close(fd);
}
//===========================================================================
void read_shm_control (	char		*handle,
								char		*semaphore,
								int		*control)
{
	int	i;
	int	fd;
	int	*data_int;
	sem_t	*sem_id;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "read_shm_control: Error in shared memory opening\n");
		exit (11);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "read_shm_control: Error in shared memory truncation\n");
		exit (11);
	}
	data_int = (void *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (data_int<0) {
		fprintf (stderr, "read_shm_control: Error in shared memory mapping\n");
		exit (11);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "read_shm_control: Error in semaphore opening\n");
		exit (11);
	}
	sem_wait(sem_id);

	*control = data_int[length_int-1];

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(data_int, length);
	close(fd);
}
//===========================================================================
void write_shm_control (	char		*handle,
									char		*semaphore,
									int		control)
{
	int	i;
	int	fd;
	int	*data_int;
	sem_t	*sem_id;
	int	length = sizeof(char) * MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;

	fd = shm_open(handle, O_RDWR, 0644 );
	if (fd<0) {
		fprintf (stderr, "write_shm_control: Error in shared memory opening\n");
		exit (11);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "write_shm_control: Error in shared memory truncation\n");
		exit (11);
	}
	data_int = (int *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (data_int<0) {
		fprintf (stderr, "write_shm_control: Error in shared memory mapping\n");
		exit (11);
	}

	sem_id = sem_open(semaphore, 0);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "write_shm_control: Error in semaphore opening\n");
		exit (11);
	}
	sem_wait(sem_id);

	data_int[length_int-1]=control;

	sem_post(sem_id);
	sem_close(sem_id);
	munmap(data_int, length);
	close(fd);
}
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
							)
{
//int	i;

	end_emulation (	reg,
							phys,
							prog,
							busA,
							busB,
							execution_time,
							verbose_scr,
							verbose_emuout,
							verbose_busZ,
							emuout_pt,
							busZ_pt
						);
/*
	//clear shadow registers
	for (i=NUMREG; i<NUMALLREG; i++)
		mpz_clear(reg[i]);
*/
}
//===========================================================================
void emulate_in_background (
	char	*dir,
	int	lfsr,
	int	num_of_addr_bits,
	char	*handle,
	char	*semaphore         )
{
	mpz_t	reg[NUMALLREG];
	int	phys[NUMALLREG];

	char	fname_prog[MAXFILENAMELENGTH], fname_busA[MAXFILENAMELENGTH], fname_busB[MAXFILENAMELENGTH], fname_emuout[MAXFILENAMELENGTH], fname_busZ[MAXFILENAMELENGTH];

	bool	verbose_emuout, verbose_busZ;
	bool	verbose_scr		= FALSE;

	char				*pos;
	FILE				*emuout_pt, *busZ_pt;
	int				i;
	unsigned int	instr;
	int				mychpid;
	int				control = 0;
	char				*prog, *busA, *busB;
	int				prog_size, busA_size, busB_size;
	int				prog_counter, busA_counter, busB_counter;

	char				instruction;
	int				execution_time=0;

	//create input files in the directory "dir"
	pos = realpath(dir, NULL);

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

	if (fname_emuout == NULL) {
		verbose_emuout = FALSE;
	} else {
		verbose_emuout = TRUE;
		emuout_pt = fopen (fname_emuout, "w");
	}
	if (fname_busZ == NULL) {
		verbose_busZ = FALSE;
	} else {
		verbose_busZ = TRUE;
		busZ_pt = fopen (fname_busZ, "wb");
	}

	if (verbose_scr) {
		printf(           "===========================================================================\n");
		printf(           "============================ Start of emulation ===========================\n");
		printf(           "===========================================================================\n");
		printf(           "Emulation based on files:\n%s\n%s\n%s\n%s\n%s\n\n", fname_prog, fname_busA, fname_busB, fname_busZ, fname_emuout);
	}
	if (verbose_emuout) {
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "============================ Start of emulation ===========================\n");
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "Emulation based on files:\n%s\n%s\n%s\n%s\n%s\n\n", fname_prog, fname_busA, fname_busB, fname_busZ, fname_emuout);
	}

	//init time measurement
	time_maker();

	//init registers
	for(i=0; i<NUMALLREG; i++)
		mpz_init (reg[i]);
	for(i=0; i<NUMALLREG; i++)
		phys[i]=i;

	//read program and data
	read_bin_file (fname_prog, &(prog), &prog_size);
	read_bin_file (fname_busA, &(busA), &busA_size);
	read_bin_file (fname_busB, &(busB), &busB_size);

	//execute code
	instr = 0;
	prog_counter = 0;
	busA_counter = 0;
	busB_counter = 0;
	while (prog_counter < prog_size) {

		for ( ; ; ) {
			read_shm_control ( handle, semaphore, &control);
			if (control == 1) {//execute a single step
				break;
			} else if (control == 2) {//end simulation
				end_debug		 (	reg,
										phys,
										prog,
										busA,
										busB,
										execution_time,
										verbose_scr,
										verbose_emuout,
										verbose_busZ,
										emuout_pt,
										busZ_pt
									);
				//shm_unlink(handle);
				return;
			} else { //control=0 //wait
				usleep(100);
			}
		}

		if (verbose_scr) {
			printf(            "===========================================================================\n");
			printf(            "=============================== Step: %.4d ================================\n", instr);
		}
		if (verbose_emuout) {
			fprintf(emuout_pt, "===========================================================================\n");
			fprintf(emuout_pt, "=============================== Step: %.4d ================================\n", instr++);
		}

		execute_instruction (	reg,
										phys,
										prog,
										busA,
										busB,
										&prog_counter,
										&busA_counter,
										&busB_counter,
										busA_size,
										busB_size,
										&execution_time,
										&instruction,
										verbose_scr,
										verbose_emuout,
										verbose_busZ,
										emuout_pt,
										busZ_pt);

		read_shm_chpid (	handle, semaphore, &mychpid);
		write_shm (	handle,
						semaphore,
						reg,
						phys,
						lfsr,
						num_of_addr_bits,
						instruction,
						mychpid,
						0);
	}

	end_debug		 (	reg,
							phys,
							prog,
							busA,
							busB,
							execution_time,
							verbose_scr,
							verbose_emuout,
							verbose_busZ,
							emuout_pt,
							busZ_pt
							);
}
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
								)
{
	int				swap;
	unsigned int	tmp;
	int				prog_counter, busA_counter, busB_counter;

	mpz_t				abs_a, abs_b;
	char				cmd[CMDSIZE];
	char				ex_cmd, op_cmd, opa_cmd, rop_cmd;

	int				execution_time, delta_time;

	prog_counter = *prog_counter_pt;
	busA_counter = *busA_counter_pt;
	busB_counter = *busB_counter_pt;

	execution_time = *execution_time_pt;
	delta_time = 0;

	mpz_inits(abs_a, abs_b, NULL);

	//execute instruction
	cmd[0] = prog[prog_counter++];
	cmd[1] = prog[prog_counter++];
	if (cmd[1] == LASTBYTE) { //short instruction
		ex_cmd = (cmd[0] & LMASK);
		op_cmd = (cmd[0] & HMASK)>>4;
		switch(ex_cmd) {
			case LOAABINCOM: //loaa regX
				//send data from busA to regX
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", LOAACOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", LOAACOM, op_cmd);

				read_int_number (&busA[busA_counter], busA_size-busA_counter, reg[(int)(op_cmd)], &tmp);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(op_cmd)],
										mpz_limbs(reg[(int)(op_cmd)]),
										op_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);
				busA_counter+=8*tmp+8;

				delta_time = exec_cmd(LOAABINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case LOABBINCOM: //loab regX
				//send data from busB to regX
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", LOABCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", LOABCOM, op_cmd);

				read_int_number (&busB[busB_counter], busB_size-busB_counter, reg[(int)(op_cmd)], &tmp);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(op_cmd)],
										mpz_limbs(reg[(int)(op_cmd)]),
										op_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);
				busB_counter+=8*tmp+8;

				delta_time = exec_cmd(LOABBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case UNLBINCOM: //unl data
				//unload data from register
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", UNLCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", UNLCOM, op_cmd);
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("UNLOADED VALUE from reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("UNLOADED VALUE from reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_busZ)
					write_bin_number (busZ_pt, reg[(int)(op_cmd)]);
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(UNLBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case ZEROBINCOM: //zero reg
				//set register value to 0
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", ZEROCOM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", ZEROCOM, op_cmd);

				mpz_set_ui (reg[(int)(op_cmd)], 0);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(op_cmd)],
										mpz_limbs(reg[(int)(op_cmd)]),
										op_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(ZEROBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case SET1BINCOM: //set reg to 1
				//set register value to 1
				if (verbose_scr)
					printf(           "%s reg%d;\n\n", SET1COM, op_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d;\n\n", SET1COM, op_cmd);

				mpz_set_ui (reg[(int)(op_cmd)], 1);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(op_cmd)],
										mpz_limbs(reg[(int)(op_cmd)]),
										op_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(SET1BINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), 0, 0, 0);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			default:
				fprintf (stderr, "Unknown short command\n");
				exit (5);
		}
	} else if (cmd[1] == BREAKBYTE) { //long instruction
		cmd[2] = prog[prog_counter++];
		cmd[3] = prog[prog_counter++];

		ex_cmd  = (cmd[2] & LMASK);
		op_cmd = (cmd[2] & HMASK)>>4;
		opa_cmd  = (cmd[0] & LMASK);
		rop_cmd = (cmd[0] & HMASK)>>4;
		if (cmd[3] != LASTBYTE) {
			fprintf (stderr, "Wrong last byte\n");
			exit (6);
		}
		switch(ex_cmd) {
			case LOAABBINCOM: //loaab regX, regY
				if (verbose_scr)
					printf(           "%s reg%d, reg%d;\n\n", LOAABCOM, op_cmd, opa_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d;\n\n", LOAABCOM, op_cmd, opa_cmd);

				//send data from busA to regX
				read_int_number (&busA[busA_counter], busA_size-busA_counter, reg[(int)(op_cmd)], &tmp);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(op_cmd)],
										mpz_limbs(reg[(int)(op_cmd)]),
										op_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
				}
#endif
				busA_counter+=8*tmp+8;
				//send data from busB to regY
				read_int_number (&busB[busB_counter], busB_size-busB_counter, reg[(int)(opa_cmd)], &tmp);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(opa_cmd)],
										mpz_limbs(reg[(int)(opa_cmd)]),
										opa_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr)
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
				}
#endif
				busB_counter+=8*tmp+8;

				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(LOAABBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), 0);
				execution_time += delta_time;

				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case CPRSBINCOM: //cpy regX, regY (regY = regX)------------------------DONE
				//copy data from regX to regY
				if (verbose_scr)
					printf(           "%s reg%d, reg%d;\n\n", CPRSCOM, op_cmd, opa_cmd);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d;\n\n", CPRSCOM, op_cmd, opa_cmd);

				mpz_set (reg[(int)(opa_cmd)], reg[(int)(op_cmd)]);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(opa_cmd)],
										mpz_limbs(reg[(int)(opa_cmd)]),
										opa_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(CPRSBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), 0);
				execution_time += delta_time;

				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case MULTBINCOM: //mutl regX, regY, regZ (regZ = regX * regY)----------DONE
				//multiply data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				//fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", MULTCOM, rop_cmd, op_cmd, opa_cmd, phys[(int)(opa_cmd)]);

				mpz_mul (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(rop_cmd)],
										mpz_limbs(reg[(int)(op_cmd)])+mpz_limbs(reg[(int)(opa_cmd)]),
										rop_cmd );
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(MULTBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case ADDBINCOM: //add regX, regY, regZ (regZ = regX + regY)------------DONE
				//add data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", ADDCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", ADDCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
/*
				mpz_add (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(rop_cmd)],
										max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
										rop_cmd );

				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);
				if ( ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])<0 && mpz_sgn(reg[(int)(opa_cmd)])>0 ) ||
					  ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])>0 && mpz_sgn(reg[(int)(opa_cmd)])<0 )    ) {
					swap=phys[(int)(rop_cmd)];
					phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
					write_shm_phys (	handle,
											semaphore,
											phys[(int)(rop_cmd)],
											rop_cmd );
					phys[(int)(NUMREG)] = swap;
					write_shm_phys (	handle,
											semaphore,
											phys[(int)(NUMREG)],
											NUMREG );
				}
*/
				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);

				if (mpz_cmp (abs_a, abs_b) > 0) {//|A| > |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) == 0) {//|A| = |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) < 0) {//|A| < |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									mpz_neg (reg[NUMREG], reg[NUMREG]);//sign change
									//////////////////SWAP////////////////////////
									//new approach
									/*
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									write_shm_phys (	handle,
															semaphore,
															phys[(int)(rop_cmd)],
															rop_cmd );
									phys[(int)(NUMREG)] = swap;
									write_shm_phys (	handle,
															semaphore,
															phys[(int)(NUMREG)],
															NUMREG );
									*/
									write_shm_reg2c (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap_shm_reg (		handle,
															semaphore,
															(int)(rop_cmd),
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									//////////////////SWAP////////////////////////
									//new approach
									/*
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									write_shm_phys (	handle,
															semaphore,
															phys[(int)(rop_cmd)],
															rop_cmd );
									phys[(int)(NUMREG)] = swap;
									write_shm_phys (	handle,
															semaphore,
															phys[(int)(NUMREG)],
															NUMREG );
									*/
									write_shm_reg2c (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap_shm_reg (		handle,
															semaphore,
															(int)(rop_cmd),
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else {
					fprintf (stderr, "debug_instruction: Error in kam table 0\n");
					exit (60);
				}
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(ADDBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			case SUBBINCOM: //sub regX, regY, regZ (regZ = regX - regY)------------DONE
				//subtract data in registers
				if (verbose_scr)
					printf(           "%s reg%d, reg%d, reg%d (P%d);\n\n", SUBCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
				if (verbose_emuout)
					fprintf(emuout_pt, "%s reg%d, reg%d, reg%d (P%d);\n\n", SUBCOM, op_cmd, opa_cmd, rop_cmd, phys[(int)(rop_cmd)]);
/*
				mpz_sub (reg[(int)(rop_cmd)], reg[(int)(op_cmd)], reg[(int)(opa_cmd)]);
				write_shm_reg (	handle,
										semaphore,
										reg[(int)(rop_cmd)],
										max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
										rop_cmd );

				if ( ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])>0 && mpz_sgn(reg[(int)(opa_cmd)])>0 ) ||
					  ( mpz_cmp (abs_a, abs_b)<0 && mpz_sgn(reg[(int)(op_cmd)])<0 && mpz_sgn(reg[(int)(opa_cmd)])<0 )    ) {
					swap=phys[(int)(rop_cmd)];
					phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
					write_shm_phys (	handle,
											semaphore,
											phys[(int)(phys[(int)(rop_cmd)])],
											rop_cmd );
					phys[(int)(NUMREG)] = swap;
					write_shm_phys (	handle,
											semaphore,
											phys[(int)(NUMREG)],
											NUMREG );
				}
*/
				mpz_abs (abs_a, reg[(int)(op_cmd)]);
				mpz_abs (abs_b, reg[(int)(opa_cmd)]);

				if (mpz_cmp (abs_a, abs_b) > 0) {//|A| > |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) == 0) {//|A| = |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A| = 0
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else if (mpz_cmp (abs_a, abs_b) < 0) {//|A| < |B|
								if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A >= 0	B >= 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									mpz_neg (reg[NUMREG], reg[NUMREG]);//sign change
									//////////////////SWAP////////////////////////
									//new approach
									write_shm_reg2c (	handle,
																	semaphore,
																	reg[(int)(rop_cmd)],
																	max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
																	rop_cmd );
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap_shm_reg (		handle,
															semaphore,
															(int)(rop_cmd),
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
								} else if (mpz_sgn (reg[(int)(op_cmd)]) >= 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A >= 0	B < 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) >= 0) {//A < 0	B >= 0
									mpz_add (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| + |B|
									mpz_neg (reg[(int)(rop_cmd)], reg[(int)(rop_cmd)]);//sign change
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
								} else if (mpz_sgn (reg[(int)(op_cmd)]) < 0 && mpz_sgn (reg[(int)(opa_cmd)]) < 0) {//A < 0	B < 0
									mpz_sub (reg[(int)(rop_cmd)], abs_a, abs_b);//m:|A| - |B|
									mpz_sub (reg[NUMREG], abs_b, abs_a);//s: |B| - |A|
									//////////////////SWAP////////////////////////
									//new approach
									/*
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
									write_shm_reg (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									write_shm_reg2c (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									write_shm_phys (	handle,
															semaphore,
															phys[(int)(rop_cmd)],
															rop_cmd );
									phys[(int)(NUMREG)] = swap;
									write_shm_phys (	handle,
															semaphore,
															phys[(int)(NUMREG)],
															NUMREG );
									*/
									write_shm_reg2c (	handle,
															semaphore,
															reg[(int)(rop_cmd)],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															rop_cmd );
									write_shm_reg (	handle,
															semaphore,
															reg[NUMREG],
															max(mpz_limbs(reg[(int)(op_cmd)]), mpz_limbs(reg[(int)(opa_cmd)]))+1,
															NUMREG );
									swap_shm_reg (		handle,
															semaphore,
															(int)(rop_cmd),
															NUMREG );
									swap=phys[(int)(rop_cmd)];
									phys[(int)(rop_cmd)] = phys[(int)(NUMREG)];
									phys[(int)(NUMREG)] = swap;
									mpz_swap (reg[(int)(rop_cmd)], reg[NUMREG]);
								} else {
									fprintf (stderr, "debug_instruction: Error in kam table 1\n");
									exit (60);
								}
				} else {
					fprintf (stderr, "debug_instruction: Error in kam table 0\n");
					exit (60);
				}
#ifdef TSPRINTSYS
				if (verbose_scr) {
					gmp_printf ("reg%d (P%d) = %Zx\n", op_cmd, phys[(int)(op_cmd)], reg[(int)(op_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", opa_cmd, phys[(int)(opa_cmd)], reg[(int)(opa_cmd)]);
					gmp_printf ("reg%d (P%d) = %Zx\n", rop_cmd, phys[(int)(rop_cmd)], reg[(int)(rop_cmd)]);
				}
#else
				if (verbose_scr) {
					printf ("reg%d (P%d) = ", op_cmd, phys[(int)(op_cmd)]);
					kam_printf (reg[(int)(op_cmd)]);
					printf ("reg%d (P%d) = ", opa_cmd, phys[(int)(opa_cmd)]);
					kam_printf (reg[(int)(opa_cmd)]);
					printf ("reg%d (P%d) = ", rop_cmd, phys[(int)(rop_cmd)]);
					kam_printf (reg[(int)(rop_cmd)]);
				}
#endif
				if (verbose_emuout)
					print_reg_stat (emuout_pt, reg, phys, NUMALLREG);

				delta_time = exec_cmd(SUBBINCOM, op_cmd, mpz_size ( reg[(int)(op_cmd)] ), opa_cmd, mpz_size ( reg[(int)(opa_cmd)] ), rop_cmd);
				execution_time += delta_time;
				if (verbose_scr) {
					printf(           "Delta clk = %d\n", delta_time);
					printf(           "Execution @ clk = %d\n", execution_time);
				}
				if (verbose_emuout) {
					fprintf(emuout_pt, "Delta clk = %d\n", delta_time);
					fprintf(emuout_pt, "Execution @ clk = %d\n", execution_time);
				}
				break;
			default:
				fprintf (stderr, "Unknown long command\n");
				exit (7);
		}
	} else { //error in program
		fprintf (stderr, "Error in program\n");
		exit (4);
	}

	mpz_clears(abs_a, abs_b, NULL);

	*prog_counter_pt = prog_counter;
	*busA_counter_pt = busA_counter;
	*busB_counter_pt = busB_counter;

	*execution_time_pt = execution_time;
	*instruction = ex_cmd;
}
//===========================================================================
void debug_in_background (
	char	*dir,
	int	lfsr,
	int	num_of_addr_bits,
	char	*handle,
	char	*semaphore         )
{
	mpz_t	reg[NUMALLREG];
	int	phys[NUMALLREG];

	char	fname_prog[MAXFILENAMELENGTH], fname_busA[MAXFILENAMELENGTH], fname_busB[MAXFILENAMELENGTH], fname_emuout[MAXFILENAMELENGTH], fname_busZ[MAXFILENAMELENGTH];

	bool	verbose_emuout, verbose_busZ;
	bool	verbose_scr		= FALSE;

	char				*pos;
	FILE				*emuout_pt, *busZ_pt;
	int				i;
	unsigned int	instr;
	int				control = 0;
	char				*prog, *busA, *busB;
	int				prog_size, busA_size, busB_size;
	int				prog_counter, busA_counter, busB_counter;

	char				instruction;
	int				execution_time=0;

	//create input files in the directory "dir"
	pos = realpath(dir, NULL);

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

	if (fname_emuout == NULL) {
		verbose_emuout = FALSE;
	} else {
		verbose_emuout = TRUE;
		emuout_pt = fopen (fname_emuout, "w");
	}
	if (fname_busZ == NULL) {
		verbose_busZ = FALSE;
	} else {
		verbose_busZ = TRUE;
		busZ_pt = fopen (fname_busZ, "wb");
	}

	if (verbose_scr) {
		printf(           "===========================================================================\n");
		printf(           "============================ Start of emulation ===========================\n");
		printf(           "===========================================================================\n");
		printf(           "Emulation based on files:\n%s\n%s\n%s\n%s\n%s\n\n", fname_prog, fname_busA, fname_busB, fname_busZ, fname_emuout);
	}
	if (verbose_emuout) {
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "============================ Start of emulation ===========================\n");
		fprintf(emuout_pt, "===========================================================================\n");
		fprintf(emuout_pt, "Emulation based on files:\n%s\n%s\n%s\n%s\n%s\n\n", fname_prog, fname_busA, fname_busB, fname_busZ, fname_emuout);
	}

	//init time measurement
	time_maker();

	//init registers
	for(i=0; i<NUMALLREG; i++)
		mpz_init (reg[i]);
	for(i=0; i<NUMALLREG; i++)
		phys[i]=i;

	//read program and data
	read_bin_file (fname_prog, &(prog), &prog_size);
	read_bin_file (fname_busA, &(busA), &busA_size);
	read_bin_file (fname_busB, &(busB), &busB_size);

	//execute code
	instr = 0;
	prog_counter = 0;
	busA_counter = 0;
	busB_counter = 0;
	while (prog_counter < prog_size) {

		for ( ; ; ) {
			read_shm_control ( handle, semaphore, &control);
			if (control == 1) {//execute a single step
				break;
			} else if (control == 2) {//end simulation
				end_debug		 (	reg,
										phys,
										prog,
										busA,
										busB,
										execution_time,
										verbose_scr,
										verbose_emuout,
										verbose_busZ,
										emuout_pt,
										busZ_pt
									);
				//shm_unlink(handle);
				return;
			} else { //control=0 //wait
				usleep(100);
			}
		}

		if (verbose_scr) {
			printf(            "===========================================================================\n");
			printf(            "=============================== Step: %.4d ================================\n", instr);
		}
		if (verbose_emuout) {
			fprintf(emuout_pt, "===========================================================================\n");
			fprintf(emuout_pt, "=============================== Step: %.4d ================================\n", instr++);
		}

		debug_instruction (		handle,
										semaphore,
										reg,
										phys,
										prog,
										busA,
										busB,
										&prog_counter,
										&busA_counter,
										&busB_counter,
										busA_size,
										busB_size,
										&execution_time,
										&instruction,
										verbose_scr,
										verbose_emuout,
										verbose_busZ,
										emuout_pt,
										busZ_pt);
		write_shm_instruction (	handle,
										semaphore,
										instruction);
		write_shm_control (	handle,
									semaphore,
									0);
	}

	end_debug		 (	reg,
							phys,
							prog,
							busA,
							busB,
							execution_time,
							verbose_scr,
							verbose_emuout,
							verbose_busZ,
							emuout_pt,
							busZ_pt
							);
}
//===========================================================================
/** Function starts execution of emusrup in DPI debug mode.
 * \param dir directory with simulation files
 * \param lfsr switch for lfsr order useage
 * \param num_of_addr_bits size of lfsr shift register
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 */
void tbEmusrupStart (
	char	*dir,
	int	lfsr,
	int	num_of_addr_bits,
	char	*handle,
	char	*semaphore  )
{
	int	i;
	int	fd;
	int	*ptr;
	pid_t  pid;
	sem_t *sem_id;
	int	length = MAXBYTES * NUMALLREG + sizeof(int)*(NUMALLREG + NUMALLREG + NUMALLREG + 5);
	int	length_int = length/4;
	mpz_t	reg[NUMALLREG];
	int	phys[NUMALLREG];

	//data sheared in memory
	//char[MAXBYTES] * NUMALLREG		- *data
	//int[NUMALLREG]						- *data_prec
	//int[NUMALLREG]						- *data_sign
	//int[NUMALLREG]						- *data_phys_reg
	//int										- lfsr;
	//int										- num_of_addr_bits;
	//int										- instruction;
	//int										- chpid;
	//int										- control;//: 0-wait, 1-proceed, 2-end

	fd = shm_open(handle, O_RDWR | O_CREAT, 0644 );
	if (fd == -1) {
		fprintf (stderr, "tbEmusrupStart: Error in shared memory opening\n");
		exit (5);
	}
	i=ftruncate(fd, length);
	if (i<0) {
		fprintf (stderr, "tbEmusrupStart: Error in shared memory truncation\n");
		exit (5);
	}
	ptr = (int *) mmap(NULL, length, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (ptr<0) {
		fprintf (stderr, "tbEmusrupStart: Error in shared memory mapping\n");
		exit (5);
	}
	for(i=0; i<length_int; i++) ptr[i] = 0;
	munmap(ptr, length);
	close(fd);

	//init semaphore
	sem_id = sem_open(semaphore, O_CREAT, S_IRUSR | S_IWUSR, 1);
	if (sem_id == SEM_FAILED) {
		fprintf (stderr, "tbEmusrupStart: Error in semaphore opening\n");
		exit (5);
	}
//	sem_wait(sem_id);
//	sem_post(sem_id);
	sem_close(sem_id);

	//init registers
	for(i=0; i<NUMALLREG; i++)
		mpz_init (reg[i]);
	for(i=0; i<NUMALLREG; i++)
		phys[i]=i;

	write_shm (	handle,
					semaphore,
					reg,
					phys,
					lfsr,
					num_of_addr_bits,
					0,
					0,
					0);

	for(i=0; i<NUMALLREG; i++)
		mpz_clear (reg[i]);

	//Start Emusrup in background
	pid = fork();
	if (pid == 0) { //here executes child process
		usleep(10000);
#ifdef EMUOPT
		emulate_in_background(dir, lfsr, num_of_addr_bits, handle, semaphore);
#else
		debug_in_background(dir, lfsr, num_of_addr_bits, handle, semaphore);
#endif
		exit(0);
	} else {        //here executes parent process
		write_shm_chpid (	handle, semaphore, pid);
	}
}
//===========================================================================
/** Function executes a single step of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param opcode_instr code of executed instruction
 */
void tbEmusrupProceed (
	char	*handle,
	char	*semaphore,
	int	*opcode_instr )
{
int	control=1;

	write_shm_control ( handle, semaphore, 1);

	for ( ; ; ) {
		read_shm_control ( handle, semaphore, &control);
		if (control == 0)//finished execution of a single step
			break;
	}

	read_shm_instruction ( handle, semaphore, opcode_instr );
}
//===========================================================================
/** Function returns status of registers of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_logic_addr logical number of checked register
 * \param data MPA number in half-integer form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 * \param data_phys_addr physical number of checked register
 */
void tbEmusrupCheck		(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
								)
{
#ifdef REGZERO //version with reg cleaning
	int	i, j;
	int	lfsr;
	int	num_of_addr_bits;
	int	instruction;
	int	mychpid;
	int	control;
	mpz_t	reg[NUMALLREG];
	int	phys[NUMALLREG];

	int	data_char_size;
	char	data_char[MAXBYTES];

	unsigned char	tmp[8];

	int							data_long_size;
	unsigned long long int	data_long[MAXBYTES/8];
	unsigned long long int	data_lfsr_long[MAXBYTES/8];

	for(i=0; i<NUMALLREG; i++)
		mpz_init (reg[i]);

	read_shm (	handle,
					semaphore,
					reg,
					phys,
					&lfsr,
					&num_of_addr_bits,
					&instruction,
					&mychpid,
					&control);

	write_int_number (reg[data_logic_addr], data_char,  &data_char_size);

	data_long_size = data_char_size/8 + ((data_char_size%8)?1:0) - 1;

	for (i=0; i<data_long_size; i++) {
		data_long[i] = 0;
		for (j=0; j<8; j++) {
			tmp[j] = ((8*i+8+j)  < data_char_size) ? data_char[8*i+8+j]  : 0 ;
			data_long[i] += ((unsigned long long int)tmp[j])<<(8*j);
		}
	}

	//lfsr transformation
	if (lfsr == 1) {
		arr2lfsrf(data_lfsr_long, data_long, data_long_size, num_of_addr_bits);
		for (i=0; i<MAXBYTES/8; i++)
			data[i] = data_lfsr_long[i];
		num2lfsr((unsigned int *) data_prec, (unsigned int) data_long_size, (unsigned int) num_of_addr_bits);
	} else {
		for (i=0; i<data_long_size; i++)
			data[i] = data_long[i];
		*data_prec = data_long_size;
	}

	if (mpz_cmp_si (reg[data_logic_addr], (signed long int) 0) >= 0)
		*data_sign=0;
	else
		*data_sign=1;

	*data_phys_addr = phys[data_logic_addr];

	for(i=0; i<NUMALLREG; i++)
		mpz_clear (reg[i]);
#else //version without reg cleaning
	int	i, j;
	int	lfsr;
	int	num_of_addr_bits;
	int	instruction;
	int	mychpid;
	int	control;
	int	phys[NUMALLREG];

	char	data_char[MAXBYTES];

	unsigned char	tmp[8];

	int							data_long_size;
	unsigned long long int	data_long[MAXBYTES/8];
	unsigned long long int	data_lfsr_long[MAXBYTES/8];

	read_shm_for_check (	handle,
								semaphore,
								data_char,
								&data_long_size,
								data_sign,
								data_logic_addr,
								phys,
								&lfsr,
								&num_of_addr_bits,
								&instruction,
								&mychpid,
								&control);

	for (i=0; i<(MAXBYTES/8-1); i++) {
		data_long[i] = 0;
		for (j=0; j<8; j++) {
			//tmp[j] = (unsigned char) data_char[8*i+8+j];
			tmp[j] = *(unsigned char*) &data_char[8*i+8+j];
			data_long[i] += ((unsigned long long int)tmp[j])<<(8*j);
		}
	}
	//data_long[MAXBYTES/8-2] = 0;

//////////////////help from : https://stackoverflow.com/questions/5040920/converting-from-signed-char-to-unsigned-char-and-back-again
/*
signed char x = -100;
unsigned char y;

y = (unsigned char)x;                    // C static
y = *(unsigned char*)(&x);               // C reinterpret
*/
///////////////////

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

	*data_phys_addr = phys[data_logic_addr];
#endif
}
//===========================================================================
/** Function returns status of logical registers of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_logic_addr logical number of checked register
 * \param data MPA number in half-integer form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 * \param data_phys_addr physical number of checked register
 */
void tbEmusrupCheckLogic	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
									)
{

	if (data_logic_addr >= NUMREG) {
		fprintf (stderr, "tbEmusrupCheckLogic: Too large value of data_logic_addr\n");
		exit (31);
	}

	tbEmusrupCheck		(
						handle,
						semaphore,
						data_logic_addr,
						data,
						data_prec,
						data_sign,
						data_phys_addr
							);
}
//===========================================================================
/** Function returns status of shadow registers of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 * \param data_shadow_addr logical number of checked register
 * \param data MPA number in half-integer form
 * \param data_prec precision of the number in register (in number of limbs)
 * \param data_sign sign of the number
 * \param data_phys_addr physical number of checked register
 */
void tbEmusrupCheckShadow	(
	char							*handle,
	char							*semaphore,
	int							data_logic_addr,
	unsigned long long int	*data,
	int							*data_prec,
	int							*data_sign,
	int							*data_phys_addr
									)
{

	if (data_logic_addr >= NUMALLREG) {
		fprintf (stderr, "tbEmusrupCheckShadow: Too large value of data_logic_addr\n");
		exit (41);
	}

	tbEmusrupCheck		(
						handle,
						semaphore,
						data_logic_addr+NUMREG,
						data,
						data_prec,
						data_sign,
						data_phys_addr
							);
}
//===========================================================================
/** Function stops execution of emusrup in DPI debug mode.
 * \param handle name of shared memory file
 * \param semaphore name of semaphore file
 */
void tbEmusrupStop (
	char	*handle,
	char	*semaphore
							)
{
	int	mychpid;
	int	status;

	read_shm_chpid (	handle, semaphore, &mychpid);
	write_shm_control ( handle, semaphore, 2);

	waitpid(mychpid, &status, 0);
	printf("Emusrup library exited, status=%d\n", WIFEXITED(status));
	shm_unlink(handle);
	sem_unlink(semaphore);
}
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
								)
{
	int	j;

	unsigned long long int	data[MAXBYTES/8];

	int	data_prec;
	int	data_sign;
	int	data_phys_addr;

	tbEmusrupCheck (
							handle,
							semaphore,
							data_logic_addr,
							data,
							&data_prec,
							&data_sign,
							&data_phys_addr );

	printf("\nLog reg = %d\n", data_logic_addr);
	printf("Precision = %d\n", data_prec);
	printf("Sign = %d\n", data_sign);
	printf("Phys reg = %d\n", data_phys_addr);
	printf("Number = \n");

	for (j=0; j<(MAXBYTES/8); j++)
		printf("%d:\t%llx\n", j, data[j]);
}
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
									)
{
	if (counter_print_val == counter)
		tbEmusrupPrintReg	(
			handle,
			semaphore,
			data_logic_addr
								);
}
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
									)
{
	int	j;

	unsigned long long int	data_emu[MAXBYTES/8];

	int	data_prec_emu;
	int	data_sign_emu;
	int	data_phys_addr_emu;

	tbEmusrupCheck (
							handle,
							semaphore,
							data_logic_addr,
							data_emu,
							&data_prec_emu,
							&data_sign_emu,
							&data_phys_addr_emu );

	if (*data_prec != data_prec_emu)
		printf("\nWrong precision %d in reg%d, it should be %d\n", data_logic_addr, *data_prec, data_prec_emu);

	if (*data_sign != data_sign_emu)
		printf("\nWrong sign %d in reg%d, it should be %d\n", data_logic_addr, *data_sign, data_sign_emu);

	if (*data_phys_addr != data_phys_addr_emu)
		printf("\nWrong phys reg %d in reg%d, it should be %d\n", data_logic_addr, *data_phys_addr, data_phys_addr_emu);

	for (j=0; j<(MAXBYTES/8); j++)
		if (data[j] != data_emu[j]) {
			printf("\nWrong value in reg%d\n", data_logic_addr);
			printf("%d:\t%llx\n", j, data[j]);
			printf("Should be:\n");
			printf("%d:\t%llx\n", j, data_emu[j]);
		}
}
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
									)
{
	if (counter_print_val == counter)
		tbEmusrupCheckRegPC	(
									handle,
									semaphore,
									data_logic_addr,
									data,
									data_prec,
									data_sign,
									data_phys_addr
									);
}
//===========================================================================
#endif
//===========================================================================
