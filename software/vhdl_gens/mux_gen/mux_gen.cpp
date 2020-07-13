//#include <QCoreApplication>
#include <cstdlib>
#include <sstream>
#include <iostream>
#include <string>
#include <cmath>
#include <ctime>

//#define DEBUG false

int MAX_MUX_SIZE = 8;

using namespace std;

int addr_width(int x) {
	int i = 0;
	while (x > pow(2, i)) {
		i++;
	}
	return i;
}

	string current_date() {
		time_t now = time(0);
		tm *ltm = localtime(&now);
		std::ostringstream ss;
		ss << ltm->tm_mday << "/";
		ss << 1+ltm->tm_mon << "/";
		ss << 1900+ltm->tm_year;
		return ss.str();
	}


		///////////////////
		// T_STAGE CLASS //
		///////////////////

class t_stage {
	int num_of_stages;
	int stage;
	int num_of_inputs;
	int num_of_rows;
	int start_addr_address;
	int addr_bits_width;
	int *start_data_address;
	int *data_bits_width;

public:
	t_stage() {start_data_address = NULL; data_bits_width = NULL;}

	void set_num_of_inputs(int x) {num_of_inputs = x;}
	void set_start_addr_address(int x) {start_addr_address = x;}
	int get_num_of_inputs() {return num_of_inputs;}
	int get_last_addr_bit() {return start_addr_address + addr_bits_width;}
	int get_num_of_rows() {return num_of_rows;}
	int get_addr_bits_width() {return addr_bits_width;}

	void init(int u, int x, int y, int z);
	~t_stage();
	int renumerate_stage_inputs();

	void print_mux_inst_low(int row);
	void print_mux_inst(int row);
	void print_header();
	void print_signals();
	void print_inst() {for(int i=0; i<num_of_rows; i++) print_mux_inst(i);}

};


		/////////////////////////
		// T_STAGE DEFINITIONS //
		/////////////////////////


void t_stage::init(int u, int x, int y, int z) {
	num_of_stages = u;
	stage = x;
	addr_bits_width = z;
	num_of_inputs = pow(2, z);
	num_of_rows = y;
	start_data_address = new int [num_of_rows];
	data_bits_width = new int [num_of_rows];

	for(int i=0; i<num_of_rows; i++) {
		start_data_address[i] = i * num_of_inputs;
		data_bits_width[i] = num_of_inputs;
	}
}

t_stage::~t_stage() {
		if(start_data_address != NULL)
			delete[] start_data_address;
		if(data_bits_width != NULL)
			delete[] data_bits_width;
}


int t_stage::renumerate_stage_inputs() {
	int local_num_of_rows = num_of_inputs;
	int non_zero_input_stages = 0;
	for(int i=0; i<num_of_rows; i++) {
		if(local_num_of_rows >= data_bits_width[i]) {
			local_num_of_rows -= data_bits_width[i];
			non_zero_input_stages++;
		} else {
			data_bits_width[i] = local_num_of_rows;
			if(local_num_of_rows != 0)
				non_zero_input_stages++;
			local_num_of_rows = 0;
		}

	}

	return non_zero_input_stages;
}


void t_stage::print_header() {
	cout << "\t-- ==============================" << endl;
	cout << "\t-- STAGE_NUMBER:       " << stage << " (" << num_of_stages-1 << " downto 0)" << endl;
	cout << "\t-- num_of_inputs:      " << num_of_inputs << endl;
	cout << "\t-- num_of_rows:        " << num_of_rows << endl;
	cout << "\t-- start_addr_address: " << start_addr_address << endl;
	cout << "\t-- addr_bits_width:    " << addr_bits_width << endl;
	cout << "\t-- ==============================" << endl;
	cout << endl;
}

void t_stage::print_signals() {
	cout << "	-- STAGE " << stage << endl;
	if(stage > 0) {
		cout << "\tsignal s_data_" << stage << "\t\t\t : std_logic_vector(" << num_of_rows-1 << " downto 0);" << endl;
	}

	if(stage < num_of_stages-1) {
		for(int i=num_of_stages-1; i>stage; i--)
			cout << "\tsignal r_addr_" << stage << "_" << i-1 << "\t\t\t : std_logic_vector(" << addr_bits_width-1 << " downto 0);" << endl;
	};
	cout << endl;
}


void t_stage::print_mux_inst_low(int row) {
	cout << "\tMUX_" << stage << "_" << row << "_INST: entity work.mux_" << data_bits_width[row] << "_1 generic map (" << endl;
	cout << "\t\tg_registered_output\t\t=> true\t\t--: boolean := true" << endl;
	cout << "\t)" << endl;
	cout << "\tport map (" << endl;
	cout << "\t\tpi_clk\t\t=> pi_clk,\t\t--: in std_logic;" << endl;
	if(addr_width(data_bits_width[row]) > 0) {
		cout << "\t\tpi_addr\t\t=> ";
		if(stage == num_of_stages-1)
			cout<< "pi_addr(";
		else
			cout<< "r_addr_" << stage << "_" << stage << "(";
		cout << addr_width(data_bits_width[row])-1 << " downto " << "0),\t\t--: in std_logic_vector(" << addr_width(data_bits_width[row])-1 << " downto 0);" << endl;
	}

	cout << "\t\tpi_data\t\t=> ";
	if(num_of_stages == stage+1)
		cout << "pi_data(";
	else
		cout << "s_data_" << stage+1 << "(";
	cout << start_data_address[row]+data_bits_width[row]-1 << " downto " << start_data_address[row] << "),\t\t--: in std_logic_vector(" << data_bits_width[row]-1 << " downto 0);" << endl;


	cout << "\t\tpo_data\t\t=> ";
	if(stage != 0)
		cout << "s_data_" << stage << "(" << row << ")\t\t";
	else
		cout << "po_data\t\t";
	cout << "--: out std_logic" << endl;

	cout << "\t);" << endl;
	cout << endl;
}


void t_stage::print_mux_inst(int row) {
	if(data_bits_width[row] == 0) {
		cout << "PRINTED MUX_" << data_bits_width[row] << " " << stage << "_" << row << " - to be empty" << endl;
	} else if(data_bits_width[row] > 0 && data_bits_width[row] <= 16 && data_bits_width[row] <= MAX_MUX_SIZE) {
		print_mux_inst_low(row);
		//cout << "PRINTED MUX_" << data_bits_width[row] << " " << stage << "_" << row << endl;
	} else {
		cout << "Illegal mux "<< stage << "_" << row << " (data_bits_width[row] = " << data_bits_width[row] << ")" << endl;
	}
}


		/////////////////
		// T_TOP CLASS //
		/////////////////

class t_top {
	int num_of_addr_bits;
	int num_of_stages;
	int num_of_inputs;
	t_stage *stage;

public:
	t_top(int num_of_inputs);
	~t_top () {delete[] stage;}
	int get_num_of_stages() {return num_of_stages;}
	void print_header();
	void print_inst();
	void print_signals();
	void print_proc();

};

void t_top::print_proc() {
	if(num_of_stages-2 >= 0) {
		cout << "	ADDRESS_DELAYER_PROC: process(pi_clk)" << endl;
		cout << "	begin" << endl;
		cout << "		if(rising_edge(pi_clk)) then" << endl;
		cout << endl;
	}

	for(int i=num_of_stages-2; i>=0; i--) {
		for(int j=num_of_stages-2; j>=0; j--){
			if(i <= j) {
				cout << "			r_addr_" << i << "_" << j << " <= ";
				if(j == num_of_stages-2)
					cout << "pi_addr(" << stage[i].get_last_addr_bit()-1 << " downto " << stage[i+1].get_last_addr_bit() << ");" << endl;
				else
					cout << "r_addr_" << i << "_" << j+1 << ";" << endl;
			}
		}
	}

	if(num_of_stages-2 >= 0) {
		cout << endl;
		cout << "		end if;" << endl;
		cout << "	end process;" << endl;
		cout << endl;
	}
}


		///////////////////////
		// T_TOP DEFINITIONS //
		///////////////////////

t_top::t_top(int num_of_inputs) {
	int max_mux_addr_width = addr_width(MAX_MUX_SIZE);
	this->num_of_inputs = num_of_inputs;

	num_of_addr_bits = addr_width(num_of_inputs);

	// ceil => q = (x + y - 1) / y;
	num_of_stages = (num_of_addr_bits + max_mux_addr_width - 1) / max_mux_addr_width;

	stage = new t_stage [num_of_stages];

	int min_num_off_addr_bits_for_every_stage = num_of_addr_bits/num_of_stages;
	int remaining_bits_to_distribute = num_of_addr_bits - (min_num_off_addr_bits_for_every_stage * num_of_stages);

	int addr_bits_width;
	int num_of_rows;

	int addr_bits_widths[num_of_stages];

	for(int i=0; i < num_of_stages; i++) {
		addr_bits_width = min_num_off_addr_bits_for_every_stage;
		if(remaining_bits_to_distribute > 0) {
			addr_bits_width++;
			remaining_bits_to_distribute--;
		}
		addr_bits_widths[i] = addr_bits_width;
	}

	int res_outputs = num_of_inputs;
	int start_addr_address;
	for(int i = num_of_stages-1; i>=0 ; i--) {

		// ceil => q = (x + y - 1) / y;
		num_of_rows = (res_outputs + pow(2, addr_bits_widths[i]) - 1) / pow(2, addr_bits_widths[i]);

		stage[i].init(num_of_stages, i, num_of_rows, addr_bits_widths[i]);
		stage[i].set_num_of_inputs(res_outputs);

		if(i == num_of_stages-1)
			start_addr_address = 0;
		else
			start_addr_address = stage[i+1].get_last_addr_bit();
		stage[i].set_start_addr_address(start_addr_address);

		stage[i].renumerate_stage_inputs();
		res_outputs = num_of_rows;

		//cout << "T1: " << res_outputs << endl;
	}
}


void t_top::print_header() {
	cout << "\t-- ==============================" << endl;
	cout << "\t-- num_of_addr_bits:    " << num_of_addr_bits << endl;
	cout << "\t-- num_of_stages:       " << num_of_stages << endl;
	cout << "\t-- num_of_inputs:       " << num_of_inputs << endl;
	cout << "\t-- ==============================" << endl;
	cout << endl;
}

void t_top::print_inst() {
	for(int i = num_of_stages-1; i>=0; i--) {
		stage[i].print_header();
		cout << endl;
		stage[i].print_inst();
		cout << endl;
	}
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
}



		////////////////////////////
		// GLOBAL PRINT FUNCTIONS //
		////////////////////////////


void print_vhdl_header(int num_of_inputs, int num_of_stages, string module_name) {
	cout << "-------------------------------------------" << endl;
	cout << "-- Auto-generated mux by " << module_name << "." << endl;
	cout << "-------------------------------------------" << endl;
	cout << "-- Program runs with the following parameters:" << endl;
	cout << "--		num_of_inputs:						" << num_of_inputs << endl;
	cout << "--" << endl;
	cout << "-- The following paramers have been calculated:" << endl;
	cout << "--		num_of_stages:						" << num_of_stages << endl;
	cout << "--		num_of_address_bits:				" << addr_width(num_of_inputs) << endl;
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
	if(addr_width(num_of_inputs) > 0)
		cout << "	pi_addr					: in std_logic_vector(" << addr_width(num_of_inputs)-1 << " downto 0);" << endl;
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
	if (argc != 4) {
		cout << "\tusage: mux_gen MAX_MUX_SIZE num_of_inputs module_name" << endl;
	} else {
		MAX_MUX_SIZE = atoi(argv[1]);
		t_top arr(atoi(argv[2]));
		string module_name(argv[3]);

		print_vhdl_header(atoi(argv[2]), arr.get_num_of_stages(), module_name);
		arr.print_signals();

		arr.print_header();

		arr.print_proc();
		arr.print_inst();
		print_vhdl_tailer();

	}

	return 0;
	//return a.exec();
}
