//#include <QCoreApplication>
#include <cstdlib>
#include <sstream>
#include <iostream>
#include <string>
#include <cmath>
#include <ctime>

//#define DEBUG false

#define REG_NAME "r_data"
#define PORT_INPUT_NAME "pi_data"
#define PORT_OUTPUT_NAME "po_data"


int MAX_LUT_SIZE;

using namespace std;

string current_date() {
	time_t now = time(0);
	tm *ltm = localtime(&now);
	std::ostringstream ss;
	ss << ltm->tm_mday << "/";
	ss << 1+ltm->tm_mon << "/";
	ss << 1900+ltm->tm_year;
	return ss.str();
}


		/////////////////////
		// T_OR_GATE CLASS //
		/////////////////////


class t_or_gate {
	int stage_number;
	int row_number;
	int num_of_inputs;
	int starting_addr_bit_num;

public:
	t_or_gate() {stage_number = -1; row_number = -1; num_of_inputs = 0; starting_addr_bit_num = 0;}

	void print_or_inst();

	void set_stage_number(int stage_number) {this->stage_number = stage_number;};
	void set_row_number(int row_number) {this->row_number = row_number;};
	void set_starting_addr_bit_num(int starting_addr_bit_num) {this->starting_addr_bit_num = starting_addr_bit_num;};
	void incr_num_of_inputs() {num_of_inputs++;};
	void set_num_of_inputs(int num_of_inputs) {this->num_of_inputs = num_of_inputs;};
	int get_set_starting_addr_bit_num_for_next_row() {return starting_addr_bit_num+num_of_inputs;};
	string get_input_name();
};


		///////////////////////////
		// T_OR_GATE DEFINITIONS //
		///////////////////////////

void t_or_gate::print_or_inst() {
	int i;

	cout << "\t\t\t\t";
	if(stage_number < 0 || row_number < 0) {
		cout << "--ERROR: no mux here." << endl;
	} else {
		cout << REG_NAME << "_" << stage_number+1 << "(" << row_number << ") <= ";
		for(i = starting_addr_bit_num; i < starting_addr_bit_num + num_of_inputs - 1; i++) {
			cout << get_input_name() << "(" << i << ") or ";
		}
		cout << get_input_name() << "(" << i << ");" << endl;
	}
}


string t_or_gate::get_input_name() {
	string ret;
	if(stage_number == 0) {
		ret = PORT_INPUT_NAME;
	} else {
		ret = REG_NAME;
		ret.push_back('_');
		ret.push_back(char(stage_number+'0'));
	}
	return ret;
}

		///////////////////
		// T_STAGE CLASS //
		///////////////////

class t_stage {
	int num_of_stages;
	int stage_number;
	int num_of_rows;
	int num_of_inputs;
	t_or_gate *or_gate;

public:
	t_stage() {num_of_stages=0; stage_number=0; or_gate=NULL;};
	~t_stage();

	void init(int num_of_stages, int stage_number, int num_of_rows);
	void set_num_of_inputs(int num_of_inputs) {this->num_of_inputs=num_of_inputs;};
	void print_signals();
	void print_header();
	void print_or_inst();
};



		/////////////////////////
		// T_STAGE DEFINITIONS //
		/////////////////////////

void t_stage::init(int num_of_stages, int stage_number, int num_of_rows) {
	this->num_of_stages = num_of_stages;
	this->stage_number = stage_number;
	this->num_of_rows = num_of_rows;

	or_gate = new t_or_gate [num_of_rows];

	for(int i=0; i<num_of_rows; i++) {
		or_gate[i].set_stage_number(stage_number);
		or_gate[i].set_row_number(i);
	}

	// SET NUMBER OF INPUTS IN EACH STAGE
	if(stage_number > 0) {
		for(int i=0; i<num_of_rows; i++) {
			or_gate[i].set_num_of_inputs(MAX_LUT_SIZE);
		}
	} else if(stage_number == 0) {
		for(int i=0; i<num_of_inputs; i++) {
			or_gate[i%num_of_rows].incr_num_of_inputs();
		}
	}

	// SET ADDRESS BITS
	for(int i=1; i<num_of_rows; i++) {
		or_gate[i].set_starting_addr_bit_num(or_gate[i-1].get_set_starting_addr_bit_num_for_next_row());
	}
}


t_stage::~t_stage() {
	if(or_gate != NULL)
		delete[] or_gate;
}

void t_stage::print_signals() {
	cout << "	-- STAGE " << stage_number+1 << endl;
	if(num_of_rows > 0) {
		cout << "\tsignal " << REG_NAME << "_" << stage_number+1 << "\t\t\t : std_logic_vector(" << num_of_rows-1 << " downto 0);" << endl;
	}

	cout << endl;
}


void t_stage::print_header() {
	cout << "\t\t\t\t-- ==============================" << endl;
	cout << "\t\t\t\t-- stage number:        " << stage_number+1 << endl;
	cout << "\t\t\t\t-- num_of_rows:         " << num_of_rows << endl;
	cout << "\t\t\t\t-- num_of_inputs:       " << num_of_inputs << endl;
	cout << "\t\t\t\t-- ==============================" << endl;
	cout << endl;
}


void t_stage::print_or_inst() {
	for(int i=0; i<num_of_rows; i++)
		or_gate[i].print_or_inst();
	cout << endl;
}

		/////////////////
		// T_TOP CLASS //
		/////////////////

class t_top {
	int num_of_stages;
	int num_of_inputs;
	t_stage *stage;

	int calc_num_of_stages(int num_of_inputs);

public:
	t_top(int num_of_inputs);
	~t_top();
	int get_num_of_stages() {return num_of_stages;};
	int get_num_of_inputs() {return num_of_inputs;};

	void print_header();
	void print_signals();
	void print_proc();
};

		///////////////////////
		// T_TOP DEFINITIONS //
		///////////////////////

t_top::t_top(int num_of_inputs) {
	this->num_of_inputs = num_of_inputs;
	num_of_stages = calc_num_of_stages(num_of_inputs);
	if(num_of_stages > 0) {
		stage = new t_stage [num_of_stages];
		stage[0].set_num_of_inputs(num_of_inputs);
		for(int i=0; i<num_of_stages; i++) {
			stage[i].init(num_of_stages, i, pow(MAX_LUT_SIZE, (num_of_stages-i-1)));
		}
	}
}

t_top::~t_top() {
	if(stage != NULL)
		delete[] stage;
}

int t_top::calc_num_of_stages(int num_of_inputs) {
	int num_of_stages = 1;
	for(; pow(MAX_LUT_SIZE, num_of_stages) < num_of_inputs; num_of_stages++);
	return num_of_stages;
}


void t_top::print_signals() {
	cout << "	constant THIS_BLOCK_LATENCY				: natural := " << num_of_stages << ";" << endl;
	cout << endl;
	for(int i = num_of_stages-1; i>=0; i--) {
		stage[i].print_signals();
	}
	cout << "begin" << endl;
	cout << endl;
	cout << "	LATENCY_TEST_GEN: if(THIS_BLOCK_LATENCY = g_latency) generate" << endl;
	cout << endl;
	cout << "		" << PORT_OUTPUT_NAME << " <= " << REG_NAME << "_" << num_of_stages << "(0);				-- output port assignment" << endl;
	cout << endl;
}

void t_top::print_proc() {
	if(num_of_stages > 0) {
		cout << "		OR_GATE_PROC: process(pi_clk)" << endl;
		cout << "		begin" << endl;
		cout << "			if(rising_edge(pi_clk)) then" << endl;
		cout << endl;

		for(int i=0; i<num_of_stages; i++) {
			stage[i].print_header();
			stage[i].print_or_inst();
		}

		cout << endl;
		cout << "			end if;" << endl;
		cout << "		end process;" << endl;
		cout << endl;
	}
}



		////////////////////////////
		// GLOBAL PRINT FUNCTIONS //
		////////////////////////////


void print_vhdl_header(int num_of_inputs, int num_of_stages, string module_name) {
	cout << "-------------------------------------------" << endl;
	cout << "-- Auto-generated " << module_name << " by or_gen." << endl;
	cout << "-------------------------------------------" << endl;
	cout << "-- Program runs with the following parameters:" << endl;
	cout << "--		MAX_LUT_SIZE:						" << MAX_LUT_SIZE << endl;
	cout << "--		num_of_inputs:						" << num_of_inputs << endl;
	cout << "--" << endl;
	cout << "-- The following paramers have been calculated:" << endl;
	cout << "--		num_of_stages:						" << num_of_stages << endl;
	cout << "-------------------------------------------" << endl;
	cout << endl;
	cout << "-------------------------------------------" << endl;
	cout << "-- Company:        SRS" << endl;
	cout << "-- Engineer:       Kamil Rudnicki" << endl;
	cout << "-- Create Date:    " << current_date() << endl;
	cout << "-- Project Name:   MPALU" << endl;
	cout << "-- Design Name:    core" << endl;
	cout << "-- Module Name:    " << module_name << endl;
	cout << "-------------------------------------------" << endl;
	cout << endl;
	cout << "library ieee;" << endl;
	cout << "use ieee.std_logic_1164.all;" << endl;
	cout << endl;
	//cout << "use work.my_pack.all;" << endl;
	//cout << endl;
	cout << "entity " << module_name << " is" << endl;
	cout << "generic (" << endl;
	cout << "	g_latency		: natural" << endl;
	cout << ");" << endl;
	cout << "port(" << endl;
	cout << "	pi_clk					: in std_logic;" << endl;
	cout << endl;
	cout << "	pi_data					: in std_logic_vector(" << num_of_inputs-1 << " downto 0);" << endl;
	cout << "	po_data					: out std_logic" << endl;
	cout << ");" << endl;
	cout << "end " << module_name << ";" << endl;
	cout << endl;
	cout << "architecture " << module_name << " of " << module_name << " is" << endl;
	cout << endl;
}

void print_vhdl_tailer() {
	cout << "	end generate;" << endl;
	cout << "end architecture;" << endl;
	cout << endl;
}



		//////////
		// MAIN //
		//////////


int main(int argc, char *argv[])
{
	//QCoreApplication a(argc, argv);

	int num_of_inputs;

	if (argc != 4) {
		cout << "\tusage: or_gen MAX_LUT_SIZE num_of_inputs module_name" << endl;
	} else {
		MAX_LUT_SIZE = atoi(argv[1]);
		num_of_inputs = atoi(argv[2]);
		string module_name(argv[3]);

		t_top top(num_of_inputs);

		print_vhdl_header(top.get_num_of_inputs(), top.get_num_of_stages(), module_name);
		top.print_signals();
		top.print_proc();
		print_vhdl_tailer();
	}

	return 0;
	//return a.exec();
}
