
#ifndef TIME_MAKER_H_INCLUDED
#define TIME_MAKER_H_INCLUDED

//time delay definitions

#define NUM_OF_REGS 16

#define STD_CTRL_DELAY 5
#define LOAD_PRE 10
#define LOAD_POST 10
#define UNLOAD_PRE 10
#define UNLOAD_POST 10
#define ADD_SUB_PRE 10
#define ADD_SUB_POST 10
#define MULT_PRE 10
#define MULT_POST 10

//functions
//===========================================================================
	void sim_reset();
//===========================================================================
	void time_maker();
//===========================================================================
	void extra_reset();
//===========================================================================
	int use_resource(int x, int clk);
//===========================================================================
	void spend_time(int clk);
//===========================================================================
	int greater(int a, int b);
//===========================================================================
	int less_than(int a, int b);
//===========================================================================
	int check_and_calculate_time_jump(int opcode, int regA_index, int regA_limb, int regB_index, int regB_limb, int regC_index);
//===========================================================================
	void add_extras();
//===========================================================================
	int exec_cmd(int opcode, int regA_index, int regA_limb, int regB_index, int regB_limb, int regC_index);
//===========================================================================
	int time_to_termination();
//===========================================================================
#endif
