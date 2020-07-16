#include "time_maker.h"

//global variables

	int reg[NUM_OF_REGS];
	int route0;
	int route1;
	int dma_add_sub;
	int dma_mult;
	int dma_unload;
	int adder;
	int multiplier;
	int load_A;
	int load_B;

	int extra_reg[NUM_OF_REGS];
	int extra_route;
	int extra_dma_add_sub;
	int extra_dma_mult;
	int extra_dma_unload;
	int extra_adder;
	int extra_multiplier;
	int extra_load_A;
	int extra_load_B;

//functions

	void sim_reset() {
		for(int i=0; i<NUM_OF_REGS; i++)
			reg[i] = 0;
		route0 = 0;
		route1 = 0;
		dma_add_sub = 0;
		dma_mult = 0;
		dma_unload = 0;
		adder = 0;
		multiplier = 0;
		load_A = 0;
		load_B = 0;
	}

	void time_maker() {
		sim_reset();
	}

	void extra_reset() {
		for(int i=0; i<NUM_OF_REGS; i++)
			extra_reg[i] = 0;
		extra_route = 0;
		extra_dma_add_sub = 0;
		extra_dma_mult = 0;
		extra_dma_unload = 0;
		extra_adder = 0;
		extra_multiplier = 0;
		extra_load_A = 0;
		extra_load_B = 0;
	}


	int use_resource(int x, int clk) {
		if(x > clk)
			x = x - clk;
		else
			x = 0;
		return x;
	}


	void spend_time(int clk) {
		for(int i=0; i<NUM_OF_REGS; i++)
			reg[i] = use_resource(reg[i], clk);
		route0 = use_resource(route0, clk);
		route1 = use_resource(route1, clk);
		dma_add_sub = use_resource(dma_add_sub, clk);
		dma_mult = use_resource(dma_mult, clk);
		dma_unload = use_resource(dma_unload, clk);
		adder = use_resource(adder, clk);
		multiplier = use_resource(multiplier, clk);
		load_A = use_resource(load_A, clk);
		load_B = use_resource(load_B, clk);
	}


	int greater(int a, int b) {
		if(a < b)
			a = b;
		return a;
	}


	int less_than(int a, int b) {
		if(a > b)
			a = b;
		return a;
	}


	int check_and_calculate_time_jump(int opcode, int regA_index, int regA_limb, int regB_index, int regB_limb, int regC_index) {

		int clk = 0;

		switch(opcode) {
			case 1:		// LOAD_A
				clk = greater(clk, reg[regA_index]);					extra_reg[regA_index] = LOAD_PRE + regA_limb;
				clk = greater(clk, load_A);								extra_load_A = LOAD_PRE + regA_limb;
				break;

			case 2:		// LOAD_B
				clk = greater(clk, reg[regB_index]);					extra_reg[regB_index] = LOAD_PRE + regB_limb;
				clk = greater(clk, load_B);								extra_load_B = LOAD_PRE + regB_limb;
				break;

			case 3:		// LOAD_AB
				clk = greater(clk, reg[regA_index]);					extra_reg[regA_index] = LOAD_PRE + regA_limb + LOAD_POST;
				clk = greater(clk, reg[regB_index]);					extra_reg[regB_index] = LOAD_PRE + regB_limb + LOAD_POST;
				clk = greater(clk, load_A);								extra_load_A = LOAD_PRE + regA_limb;
				clk = greater(clk, load_B);								extra_load_B = LOAD_PRE + regB_limb;
				break;

			case 4:		// UNLOAD
				clk = greater(clk, dma_unload);							extra_dma_unload = UNLOAD_PRE + regA_limb + UNLOAD_POST;
				clk = greater(clk, less_than(route0, route1));		extra_route = UNLOAD_PRE + regA_limb;
				clk = greater(clk, reg[regA_index]);					extra_reg[regA_index] = UNLOAD_PRE + regA_limb;
				break;

			case 8:		// MULT
				clk = greater(clk, dma_mult);								extra_dma_mult = MULT_PRE + (regA_limb*regB_limb) + MULT_POST;
				clk = greater(clk, less_than(route0, route1));		extra_route = MULT_PRE + (regA_limb*regB_limb) + MULT_POST;
				clk = greater(clk, multiplier);							extra_multiplier = MULT_PRE + (regA_limb*regB_limb) + MULT_POST;
				clk = greater(clk, reg[regA_index]);					extra_reg[regA_index] = MULT_PRE + (regA_limb*regB_limb);
				clk = greater(clk, reg[regB_index]);					extra_reg[regB_index] = MULT_PRE + (regA_limb*regB_limb);
				clk = greater(clk, reg[regC_index]);					extra_reg[regC_index] = MULT_PRE + (regA_limb*regB_limb) + MULT_POST;
				break;

			case 9:		// ADD
				clk = greater(clk, dma_add_sub);							extra_dma_add_sub = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				clk = greater(clk, less_than(route0, route1));		extra_route = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				clk = greater(clk, adder);									extra_adder = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				clk = greater(clk, reg[regA_index]);					extra_reg[regA_index] = ADD_SUB_PRE + greater(regA_limb, regB_limb);
				clk = greater(clk, reg[regB_index]);					extra_reg[regB_index] = ADD_SUB_PRE + greater(regA_limb, regB_limb);
				clk = greater(clk, reg[regC_index]);					extra_reg[regC_index] = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				break;

			case 10:		// SUB
				clk = greater(clk, dma_add_sub);							extra_dma_add_sub = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				clk = greater(clk, less_than(route0, route1));		extra_route = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				clk = greater(clk, adder);									extra_adder = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				clk = greater(clk, reg[regA_index]);					extra_reg[regA_index] = ADD_SUB_PRE + greater(regA_limb, regB_limb);
				clk = greater(clk, reg[regB_index]);					extra_reg[regB_index] = ADD_SUB_PRE + greater(regA_limb, regB_limb);
				clk = greater(clk, reg[regC_index]);					extra_reg[regC_index] = ADD_SUB_PRE + greater(regA_limb, regB_limb) + ADD_SUB_POST;
				break;

			default:
				break;

		}

		return clk;
	}


	void add_extras() {
		for(int i=0; i<NUM_OF_REGS; i++)
			reg[i] += extra_reg[i];
		if(route0 == 0)
			route0 += extra_route;
		else
			route1 += extra_route;
		dma_add_sub += extra_dma_add_sub;
		dma_mult += extra_dma_mult;
		dma_unload += extra_dma_unload;
		adder += extra_adder;
		multiplier += extra_multiplier;
		load_A += extra_load_A;
		load_B += extra_load_B;
	}


	int exec_cmd(int opcode, int regA_index, int regA_limb, int regB_index, int regB_limb, int regC_index) {
		// reset the extra time
		extra_reset();

		// calculate the awaiting resouce time period in clk
		int clk = STD_CTRL_DELAY + check_and_calculate_time_jump(opcode, regA_index, regA_limb, regB_index, regB_limb, regC_index);

		// spend x
		spend_time(clk);

		// add new time
		add_extras();

		// return x
		return clk;
	}


	int time_to_termination() {
		int clk = 0;

		for(int i=0; i<NUM_OF_REGS; i++)
			clk = greater(clk, reg[i]);
		clk = greater(clk, route0);
		clk = greater(clk, route1);
		clk = greater(clk, dma_add_sub);
		clk = greater(clk, dma_mult);
		clk = greater(clk, dma_unload);
		clk = greater(clk, adder);
		clk = greater(clk, multiplier);
		clk = greater(clk, load_A);
		clk = greater(clk, load_B);

		return clk;
	}

/*

int main()
{
	time_maker ssim;

	int total_time = 0;

	//exec_cmd(int opcode, int regA_index, int regA_limb, int regB_index, int regB_limb, int regC_index)
	cout << total_time << endl;
	total_time += ssim.exec_cmd(8, 4, 3, 6, 7, 2);
	cout << total_time << endl;
	total_time += ssim.exec_cmd(9, 4, 3, 6, 7, 2);
	cout << total_time << endl;
	total_time += ssim.exec_cmd(9, 4, 3, 6, 7, 2);
	cout << total_time << endl;
	total_time += ssim.time_to_termination();
	cout << total_time << endl;

	return 0;
}
*/
