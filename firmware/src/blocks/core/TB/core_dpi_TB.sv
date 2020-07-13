`timescale 1ps / 1fs
//////////////////////////////////////////////////////////////////////////////////
// Company: SRS
// Engineer: Tomasz Stefanski & Kamil Rudnicki
//
// Create Date: 25.03.2017 11:33:42
// Design Name:
// Module Name: core_dpi_TB
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////






////////////////////////////
//
// TO DO:
// 	- fix clk period
// 	- fix values in test_pack
// 	- test_pack -> dpi_core_test_pack
// 	-
//
////////////////////////////


class rand_str;

	rand byte unsigned temp[];

	constraint str_len { temp.size() == 16; } // Length of the string

	constraint temp_str_ascii { foreach(temp[i]) temp[i] inside {[65:90], [97:122]}; } //To restrict between 'A-Z' and 'a-z'

	function string get_str();
		string str;
		foreach(temp[i])
			str = {str, string'(temp[i])};
		return str;
	endfunction

	function string get_sem_str();
		string str = "/sem.";
		foreach(temp[i])
			str = {str, string'(temp[i])};
		return str;
	endfunction
endclass


function int unsigned addr_width(input int unsigned depth);
	addr_width = 1;
	while(2**addr_width < depth) begin
		addr_width += 1;
	end
endfunction


//module core_dpi_TB #(string g_data_dir_path = "test of the generic")();
// Such a module declaration doesn't work, as there is DPI function compilation error due to " sign.
// The g_data_dir_path is pass through a `include "dpi_core_data_folder_location.svh" line below.
module core_dpi_TB();

// This include defines g_data_dir_path
`include "dpi_core_data_folder_location.svh"

	parameter c_data_width = 64;						//: natural := 16;
	parameter c_ctrl_width = 8;						//: natural := 16;
	parameter c_addr_width = 9;
	parameter c_opcode_width = 4;
	parameter c_num_of_logic_registers = 16;
	parameter c_num_of_phys_registers = c_num_of_logic_registers + 1;

	parameter c_reg_logic_addr_width = addr_width(c_num_of_logic_registers);
	parameter c_reg_phys_addr_width = addr_width(c_num_of_phys_registers);

	parameter c_lfsr = 1;
	parameter c_store_output_file = 0;

	parameter MAX_PREC = 2**c_addr_width;			// 512


	parameter string c_prog_filename			= "prog.bin";
	parameter string c_bus_A_filename		= "busA.bin";
	parameter string c_bus_B_filename		= "busB.bin";
	parameter string c_bus_Z_filename		= "busZ.bin";

	parameter string c_prog_filepath			= {g_data_dir_path, "/", c_prog_filename};
	parameter string c_bus_A_filepath		= {g_data_dir_path, "/", c_bus_A_filename};
	parameter string c_bus_B_filepath		= {g_data_dir_path, "/", c_bus_B_filename};
	parameter string c_bus_Z_filepath		= {g_data_dir_path, "/", c_bus_Z_filename};

	reg r_clk;					//: in std_logic;
	reg r_rst;					//: out std_logic;

	reg r_dpi_state = 0;		// 0 - uninitialized, 1 - started, 2 - stopped

	rand_str handle;
	rand_str semaphore;

	int File;
	string fullpath;

	longint unsigned r_tmp_data_1[0:MAX_PREC-1];
	longint unsigned r_tmp_data_2[0:MAX_PREC-1];
	longint unsigned r_tmp_data_3[0:MAX_PREC-1];

	import "DPI-C" function void tbEmusrupStart (
		input string dir,
		input int lfsr,
		input int num_of_addr_bits,
		input string handle,
		input string semaphore
	);


	import "DPI-C" function void tbEmusrupProceed (
		input string handle,
		input string semaphore,
		output int opcode_instr
	);


	import "DPI-C" function void tbEmusrupCheckLogic (
		input string handle,
		input string semaphore,
		input int data_logic_reg,
		output longint unsigned r_tmp_data [0:MAX_PREC-1],
		output int data_prec,
		output int data_sign,
		output int data_phys_reg
	);


	import "DPI-C" function void tbEmusrupStop (
		input string handle,
		input string semaphore
	);

	wire [c_ctrl_width-1:0] s_prog_tdata;
	wire s_prog_tlast;
	wire s_prog_tvalid;
	wire s_prog_tready;

	wire [c_data_width-1:0] s_data_A_tdata;
	wire s_data_A_tvalid;
	wire s_data_A_tready;

	wire [c_data_width-1:0] s_data_B_tdata;
	wire s_data_B_tvalid;
	wire s_data_B_tready;

	wire s_probe_wr_en;

	wire [c_data_width-1:0] s_output_tdata;
	wire s_output_tvalid;
	wire s_output_tlast;
	wire s_output_tready;

	wire s_error_opcode;
	wire [c_num_of_phys_registers-1:0]s_error_sign;
	wire [c_num_of_phys_registers-1:0]s_error_size;
	wire [c_num_of_phys_registers-1:0]s_error_phys;
	wire [c_num_of_phys_registers-1:0]s_error_data;
	wire s_error_read;
	wire s_error_write;

	reg r_force_stop;
	wire s_end_of_prog_file;
	wire s_end_of_sim;

	reg [c_opcode_width-1:0] r_dpi_instr										; //std_logic_vector(g_opcode_width-1 downto 0);

	wire [(2**c_addr_width)*c_data_width-1:0] r_dpi_data_1				; //std_logic_vector;
	wire [(2**c_addr_width)*c_data_width-1:0] r_dpi_data_2				; //std_logic_vector;
	wire [(2**c_addr_width)*c_data_width-1:0] r_dpi_data_3				; //std_logic_vector;

	reg r_dpi_data_sign_1															; //std_logic;
	reg r_dpi_data_sign_2															; //std_logic;
	reg r_dpi_data_sign_3															; //std_logic;
	reg [c_addr_width-1:0] r_dpi_data_size_1									; //std_logic_vector(g_addr_width-1 downto 0);
	reg [c_addr_width-1:0] r_dpi_data_size_2									; //std_logic_vector(g_addr_width-1 downto 0);
	reg [c_addr_width-1:0] r_dpi_data_size_3									; //std_logic_vector(g_addr_width-1 downto 0);
	reg [c_reg_logic_addr_width-1:0] s_reg_logic_1							; //std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	reg [c_reg_logic_addr_width-1:0] s_reg_logic_2							; //std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	reg [c_reg_logic_addr_width-1:0] s_reg_logic_3							; //std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	reg [c_reg_phys_addr_width-1:0] r_dpi_reg_phys_1						; //std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	reg [c_reg_phys_addr_width-1:0] r_dpi_reg_phys_2						; //std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	reg [c_reg_phys_addr_width-1:0] r_dpi_reg_phys_3						; //std_logic_vector(g_reg_phys_addr_width-1 downto 0);

//-----------------------------------------------------------------------------
//-------------------------   TESTBENCH DEFINITION   --------------------------
//-----------------------------------------------------------------------------

	initial begin
		r_force_stop = 0;

		handle = new;
		do begin
			handle.randomize();
			fullpath = {"/dev/shm/", handle.get_str()};
			File = $fopen(fullpath, "r");
			$display("File: %d.", File);
			if(File) begin
				$fclose(File);
			end
		end while(File);

		$display("	Default handle: %s", handle.get_str());

		semaphore = new;
		do begin
			semaphore.randomize();
			fullpath = {"/dev/shm", semaphore.get_sem_str()};
			File = $fopen(fullpath, "r");
			$display("File: %d.", File);
			if(File) begin
				$fclose(File);
			end
		end while(File);

		$display("	Default semaphore: %s", semaphore.get_sem_str());
	end

	// CLOCK
	initial begin
		r_clk <= 1'd0;
	end

	always
		#1111  r_clk =  ! r_clk;

	// RESET
	initial begin
		r_rst <= 1'd1;
		#250000	r_rst <= 1'd0;
	end

	always @(negedge r_clk)			// END OF SIMULATION
	begin

		if(s_end_of_sim == 1) begin
			$finish;
		end

	end


	genvar i;
	generate
		for(i=0; i<MAX_PREC; i++) begin:m
			localparam integer j = i*64;
			assign r_dpi_data_1[j +:64] = r_tmp_data_1[i][63:0];
			assign r_dpi_data_2[j +:64] = r_tmp_data_2[i][63:0];
			assign r_dpi_data_3[j +:64] = r_tmp_data_3[i][63:0];
		end
	endgenerate


	always @(negedge r_clk)			// PREPARE DATA ON THE NEGATIVE CLOCK EDGE
	begin

		if(s_probe_wr_en == 1'b1) begin

			if(r_dpi_state == 0) begin				// when service is not initialized, start the service and execute one step
				$display("Starting service...");
				// START SERVICE
				//    import "DPI-C" function void tbEmusrupStart(input string dir, input int lfsr, input int num_of_addr_bits, input string handle, input string semaphore);
				tbEmusrupStart(g_data_dir_path, c_lfsr, c_addr_width, handle.get_str(), semaphore.get_str());
				$display("Service started.");

				r_dpi_state = 1;

				$display("Handle: %s.", handle.get_str());
				$display("Semaphore: %s.", semaphore.get_sem_str());
			end


			if(r_dpi_state == 1) begin				// when service is not initialized, start the service and execute one step
				// EXECUTE ONE INSTRUCTION
				//    import "DPI-C" function void tbEmusrupProceed (input string handle, input string semaphore, output int opcode_instr);
				tbEmusrupProceed(handle.get_str(), semaphore.get_str(), r_dpi_instr);
				$display("Instruction: %d.", r_dpi_instr);
			end


			// GET THE VALUES
			//    import "DPI-C" function void tbEmusrupCheck (input string handle, input string semaphore, input int data_logic_reg,
			//        output longint unsigned data[0:(4*MAX_PREC)-1], output int data_prec, output int data_sign, output int data_phys_reg);
			tbEmusrupCheckLogic(handle.get_str(), semaphore.get_str(), s_reg_logic_1, r_tmp_data_1, r_dpi_data_size_1, r_dpi_data_sign_1, r_dpi_reg_phys_1);
			tbEmusrupCheckLogic(handle.get_str(), semaphore.get_str(), s_reg_logic_2, r_tmp_data_2, r_dpi_data_size_2, r_dpi_data_sign_2, r_dpi_reg_phys_2);
			tbEmusrupCheckLogic(handle.get_str(), semaphore.get_str(), s_reg_logic_3, r_tmp_data_3, r_dpi_data_size_3, r_dpi_data_sign_3, r_dpi_reg_phys_3);

		end if(s_end_of_prog_file == 1 && r_dpi_state == 1) begin

			$display("Stopping service...");
			// STOP SERVICE
			//     import "DPI-C" function void tbEmusrupStop (input string handle, input string semaphore);
			tbEmusrupStop(handle.get_str(), semaphore.get_str());
			r_dpi_state = 2;
			$display("Service stopped.");
		end

	end


	///////////////////////
	/////             /////
	/////   FEEDERS   /////
	/////             /////
	///////////////////////


	forcer_prog #(
		.g_filepath				(c_prog_filepath					),				//: string := "i.txt";
		.g_data_width			(c_ctrl_width						)				//: natural := 64
	)
	PROG_FORCER_INST (
		.pi_clk					(r_clk								),				//: in std_logic;
		.pi_rst					(r_rst								),				//: in std_logic;
		.po_m00_tdata			(s_prog_tdata						),				//: out std_logic_vector(g_data_width-1 downto 0);
		.po_m00_tlast			(s_prog_tlast						),				//: out std_logic;
		.po_m00_tvalid			(s_prog_tvalid						),				//: out std_logic;
		.pi_m00_tready			(s_prog_tready						)				//: in std_logic
	);


	forcer_data #(
		.g_filepath				(c_bus_A_filepath					),				//: string := "i.txt";
		.g_data_width			(c_data_width						)				//: natural := 64
	)
	BUS_A_FORCER_INST (
		.pi_clk					(r_clk								),				//: in std_logic;
		.pi_rst					(r_rst								),				//: in std_logic;
		.po_m00_tdata			(s_data_A_tdata					),				//: out std_logic_vector(g_data_width-1 downto 0);
		.po_m00_tvalid			(s_data_A_tvalid					),				//: out std_logic;
		.pi_m00_tready			(s_data_A_tready					)				//: in std_logic
	);


	forcer_data #(
		.g_filepath				(c_bus_B_filepath					),				//: string := "i.txt";
		.g_data_width			(c_data_width						)				//: natural := 64
	)
	BUS_B_FORCER_INST (
		.pi_clk					(r_clk								),				//: in std_logic;
		.pi_rst					(r_rst								),				//: in std_logic;
		.po_m00_tdata			(s_data_B_tdata					),				//: out std_logic_vector(g_data_width-1 downto 0);
		.po_m00_tvalid			(s_data_B_tvalid					),				//: out std_logic;
		.pi_m00_tready			(s_data_B_tready					)				//: in std_logic
	);


//	////////////////////
//	/////          /////
//	/////   FIFO   /////
//	/////          /////
//	////////////////////
//
//	FIFO36E1 #(
//		.ALMOST_EMPTY_OFFSET				(13'h0080						),				// Sets the almost empty threshold
//		.ALMOST_FULL_OFFSET				(13'h0080						),				// Sets almost full threshold
//		.DATA_WIDTH							(16								),				// Sets data width to 4-72
//		.DO_REG								(1									),				// Enable output register (1-0) Must be 1 if EN_SYN = FALSE
//		.EN_ECC_READ						("FALSE"							),				// Enable ECC decoder, FALSE, TRUE
//		.EN_ECC_WRITE						("FALSE"							),				// Enable ECC encoder, FALSE, TRUE
//		.EN_SYN								("TRUE"							),				// Specifies FIFO as Asynchronous (FALSE) or Synchronous (TRUE)
//		.FIFO_MODE							("FIFO36"						),				// Sets mode to "FIFO36" or "FIFO36_72"
//		.FIRST_WORD_FALL_THROUGH		("TRUE"							),				// Sets the FIFO FWFT to FALSE, TRUE
//		.INIT									(72'h000000000000000000		),				// Initial values on output port
//		.SIM_DEVICE							("7SERIES"						),				// Must be set to "7SERIES" for simulation behavior
//		.SRVAL								(72'h000000000000000000		)				// Set/Reset value for output port
//	)
//	FIFO36E1_INST (
//																									// ECC Signals: 1-bit (each) output: Error Correction Circuitry ports
//		.DBITERR								(									),				// 1-bit output: Double bit error status
//		.ECCPARITY							(									),				// 8-bit output: Generated error correction parity
//		.SBITERR								(									),				// 1-bit output: Single bit error status
//																									// Read Data: 64-bit (each) output: Read output data
//		.DO									(DO								),				// 64-bit output: Data output
//		.DOP									(									),				// 8-bit output: Parity data output
//																									// Status: 1-bit (each) output: Flags and other FIFO status outputs
//		.ALMOSTEMPTY						(									),				// 1-bit output: Almost empty flag
//		.ALMOSTFULL							(									),				// 1-bit output: Almost full flag
//		.EMPTY								(s_fifo_empty					),				// 1-bit output: Empty flag
//		.FULL									(FULL								),				// 1-bit output: Full flag
//		.RDCOUNT								(									),				// 13-bit output: Read count
//		.RDERR								(									),				// 1-bit output: Read error
//		.WRCOUNT								(									),				// 13-bit output: Write count
//		.WRERR								(									),				// 1-bit output: Write error
//																									// ECC Signals: 1-bit (each) input: Error Correction Circuitry ports
//		.INJECTDBITERR						(									),				// 1-bit input: Inject a double bit error input
//		.INJECTSBITERR						(									),
//																									// Read Control Signals: 1-bit (each) input: Read clock, enable and reset input signals
//		.RDCLK								(r_clk							),				// 1-bit input: Read clock
//		.RDEN									(RDEN								),				// 1-bit input: Read enable
//		.REGCE								(1									),				// 1-bit input: Clock enable
//		.RST									(RST								),				// 1-bit input: Reset
//		.RSTREG								(RSTREG							),				// 1-bit input: Output register set/reset
//																									// Write Control Signals: 1-bit (each) input: Write clock and enable input signals
//		.WRCLK								(r_clk							),				// 1-bit input: Rising edge write clock.
//		.WREN									(s_prog_wr_en					),				// 1-bit input: Write enable
//																									// Write Data: 64-bit (each) input: Write input data
//		.DI									(s_prog_data					),				// 64-bit input: Data input
//		.DIP									(									)				// 8-bit input: Parity input
//	);


	////////////////////////////////////////////
	/////                                  /////
	/////   CORE WITH PROBES AND CHECKER   /////
	/////                                  /////
	////////////////////////////////////////////

	core_with_probes_and_checker #(
		.g_sim								(1											),		//: boolean := false;
		.g_num_of_bram						(1											),		//: natural := 1;
		.g_opcode_width					(c_opcode_width						),		//: natural := 4;
		.g_lfsr								(c_lfsr									),		//: boolean := true;
		.g_num_of_logic_registers		(c_num_of_logic_registers			),		//: natural := C_NUM_OF_REGISTERS;
		.g_num_of_phys_registers		(c_num_of_phys_registers			),		//: natural := C_NUM_OF_ALL_REGISTERS;
		.g_reg_logic_addr_width			(c_reg_logic_addr_width				),		//: natural := 4;
		.g_reg_phys_addr_width			(c_reg_phys_addr_width				),		//: natural := 5;
		.g_data_width						(c_data_width							),		//: natural := C_STD_DATA_WIDTH;
		.g_addr_width						(c_addr_width							),		//: natural := C_STD_ADDR_WIDTH;
		.g_ctrl_width						(c_ctrl_width							)		//: natural := C_STD_CTRL_WIDTH
	)
	CORE_WITH_PROBES_AND_CHECKER_INST (
		.pi_clk								(r_clk									),		//: in std_logic;
		.pi_rst								(r_rst									),		//: in std_logic;
		.s00a_axis_tdata					(s_data_A_tdata						),		//: in std_logic_vector(g_data_width-1 downto 0);
		.s00a_axis_tvalid					(s_data_A_tvalid						),		//: in std_logic;
		.s00a_axis_tready					(s_data_A_tready						),		//: out std_logic;
		.s00b_axis_tdata					(s_data_B_tdata						),		//: in std_logic_vector(g_data_width-1 downto 0);
		.s00b_axis_tvalid					(s_data_B_tvalid						),		//: in std_logic;
		.s00b_axis_tready					(s_data_B_tready						),		//: out std_logic;
		.s00_ctrl_axis_tdata				(s_prog_tdata							),		//: in std_logic_vector(g_ctrl_width-1 downto 0);
		.s00_ctrl_axis_tlast				(s_prog_tlast							),		//: in std_logic;
		.s00_ctrl_axis_tvalid			(s_prog_tvalid							),		//: in std_logic;
		.s00_ctrl_axis_tready			(s_prog_tready							),		//: out std_logic;
		.m00_axis_tdata					(s_output_tdata						),		//: out std_logic_vector(g_data_width-1 downto 0);
		.m00_axis_tvalid					(s_output_tvalid						),		//: out std_logic;
		.m00_axis_tlast					(s_output_tlast						),		//: out std_logic;
		.m00_axis_tready					(s_output_tready						),		//: in std_logic

		// PROBES
		.po_probe_wr_en					(s_probe_wr_en							),		//: out std_logic;
		.po_probe_logic_1					(s_reg_logic_1							),		//: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		.po_probe_logic_2					(s_reg_logic_2							),		//: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		.po_probe_logic_3					(s_reg_logic_3							),		//: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);

		// EMUSRUP
		.pi_dpi_instr						(r_dpi_instr							),		//: in std_logic_vector(g_opcode_width-1 downto 0);
		.pi_dpi_data_1						(r_dpi_data_1							),		//: in std_logic_vector;
		.pi_dpi_data_2						(r_dpi_data_2							),		//: in std_logic_vector;
		.pi_dpi_data_3						(r_dpi_data_3							),		//: in std_logic_vector;
		.pi_dpi_data_sign_1				(r_dpi_data_sign_1					),		//: in std_logic;
		.pi_dpi_data_sign_2				(r_dpi_data_sign_2					),		//: in std_logic;
		.pi_dpi_data_sign_3				(r_dpi_data_sign_3					),		//: in std_logic;
		.pi_dpi_data_size_1				(r_dpi_data_size_1					),		//: in std_logic_vector(g_addr_width-1 downto 0);
		.pi_dpi_data_size_2				(r_dpi_data_size_2					),		//: in std_logic_vector(g_addr_width-1 downto 0);
		.pi_dpi_data_size_3				(r_dpi_data_size_3					),		//: in std_logic_vector(g_addr_width-1 downto 0);
		.pi_dpi_data_phys_1				(r_dpi_reg_phys_1						),		//: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		.pi_dpi_data_phys_2				(r_dpi_reg_phys_2						),		//: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		.pi_dpi_data_phys_3				(r_dpi_reg_phys_3						),		//: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);

		.po_error_opcode					(s_error_opcode						),		//: out std_logic;
		.po_error_read						(s_error_read							),		//: out std_logic;
		.po_error_write					(s_error_write							),		//: out std_logic;
		.po_error_data						(s_error_data							),		//: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		.po_error_sign						(s_error_sign							),		//: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		.po_error_size						(s_error_size							),		//: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		.po_error_phys						(s_error_phys							),		//: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

		.pi_force_stop						(r_force_stop							),		//: in std_logic;
		.po_end_of_prog_file				(s_end_of_prog_file					),		//: out std_logic
		.po_end_of_sim						(s_end_of_sim							)		//: out std_logic
	);




	//////////////////////
	/////            /////
	/////   OUTPUT   /////
	/////            /////
	//////////////////////

	generate
		if(c_store_output_file == 0) begin

			assign s_output_tready = 1;

		end else begin

			forcer_result #(
				.g_filepath					(c_bus_Z_filepath						),		//: string := "i.txt";
				.g_data_width				(c_data_width							)		//: natural := 64;
			)
			FORCER_RESULT_INST (
				.pi_clk						(r_clk									),		//: in std_logic;
				.pi_rst						(r_rst									),		//: in std_logic;
				.pi_close					(s_end_of_prog_file					),		//: in std_logic;													// TMP SOLUTION
				.pi_m00_tdata				(s_output_tdata						),		//: in std_logic_vector(g_data_width-1 downto 0);
				.pi_m00_tvalid				(s_output_tvalid						),		//: in std_logic;
				.po_m00_tready				(s_output_tready						)		//: out std_logic;
			);

		end
	endgenerate


endmodule
