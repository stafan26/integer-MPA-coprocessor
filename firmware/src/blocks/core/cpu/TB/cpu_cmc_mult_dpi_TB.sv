`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SRS
// Engineer: Tomasz Stefanski & Kamil Rudnicki
//
// Create Date: 25.03.2017 11:33:42
// Design Name:
// Module Name: cpu_cmc_mult_dpi_TB
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



module cpu_cmc_mult_dpi_TB();

	parameter MIN_PREC = 1;				// 1
	parameter MAX_PREC = 10;			// 511
	parameter C_DELAY_MAX = 50;
	parameter c_lfsr = 1;
	parameter c_addr_width = 9;

	parameter NUM_ITERATIONS = 100000000;

	int seed_sv = 1;

	parameter c_dpi_delay = 3;
	parameter c_addr_unit_delay = 3;

	reg r_clk;								//: in std_logic;
	reg r_rst;								//: out std_logic;

	int a[0:(MAX_PREC*MAX_PREC+1-1)];
	int b[0:(MAX_PREC*MAX_PREC+1-1)];
	int cycle[0:(MAX_PREC*MAX_PREC+1-1)];
	int addr_init_up[0:(MAX_PREC*MAX_PREC+1-1)];
	int last[0:(MAX_PREC*MAX_PREC+1-1)];
	int valid[0:(MAX_PREC*MAX_PREC+1-1)];

	int a_prec;
	int b_prec;

	int r_cnt_total;
	int r_counter;
	int r_delay;
	reg        r_ok;
	reg        r_ok_1_2_A;
	reg        r_ok_1_2_B;
	reg        r_ok_1_3_A;
	reg        r_ok_1_3_B;
	reg        r_ok_all;
	reg [c_addr_width-1:0] r_dpi_index_A_pre_dly;
	reg [c_addr_width-1:0] r_dpi_index_B_pre_dly;
	reg [c_addr_width-1:0] r_dpi_index_A_pre_lfsr;
	reg [c_addr_width-1:0] r_dpi_index_B_pre_lfsr;
	reg [c_addr_width-1:0] r_dpi_index_A;
	reg [c_addr_width-1:0] r_dpi_index_B;

	reg        r_dpi_cycle;
	reg        r_dpi_cycle_dly;
	reg        r_dpi_cycle_ref_dly;
	reg  [1:0] r_dpi_addr_init_up;
	reg  [1:0] r_dpi_addr_init_up_dly;
	reg  [1:0] r_dpi_addr_init_up_ref_dly;
	reg        r_dpi_last;
	reg        r_dpi_last_dly;
	reg        r_dpi_last_ref_dly;
	reg        r_dpi_valid;
	reg        r_dpi_valid_dly;
	reg        r_dpi_valid_ref_dly;

	reg [8:0] r_my_size;
	reg [4:0] r_my_last;
	reg [8:0] r_other_size;
	reg [4:0] r_other_last;

	reg r_cmc_mult_start;

	wire [8:0] s_my_size;
	wire [4:0] s_my_last;
	wire [8:0] s_other_size;
	wire [4:0] s_other_last;

	int fsm_state;

	wire [1:0] s_cmc_addr_init_up;
	wire [1:0] s_cmc_addr_init_up_dly;
	wire s_cmc_data_cycle;
	wire s_cmc_data_cycle_dly;
	wire s_cmc_data_valid;
	wire s_cmc_data_valid_dly;
	wire s_cmc_data_last_both;
	wire s_cmc_data_last_both_dly;
	wire [c_addr_width-1:0] s_index_A;
	wire [c_addr_width-1:0] s_index_A_dly;
	wire [c_addr_width-1:0] s_index_B;
	wire [c_addr_width-1:0] s_index_B_dly;
	wire [c_addr_width-1:0] s_index_A_dpi_ref;
	wire [c_addr_width-1:0] s_index_B_dpi_ref;
	wire index_A_ok_1 = r_dpi_index_A == s_index_A_dpi_ref ? 1'b1 : 1'b0;
	wire index_A_ok_2 = r_dpi_index_A == s_index_A ? 1'b1 : 1'b0;
	wire index_B_ok_1 = r_dpi_index_B == s_index_B_dpi_ref ? 1'b1 : 1'b0;
	wire index_B_ok_2 = r_dpi_index_B == s_index_B ? 1'b1 : 1'b0;


	import "DPI-C" function void mult_regs_address(
											output int Aind[0:(MAX_PREC*MAX_PREC+1-1)], input int Alimbs,
											output int Bind[0:(MAX_PREC*MAX_PREC+1-1)], input int Blimbs,
											output int cycle[0:(MAX_PREC*MAX_PREC+1-1)],
											output int addr_init_up[0:(MAX_PREC*MAX_PREC+1-1)],
											output int last[0:(MAX_PREC*MAX_PREC+1-1)],
											output int valid[0:(MAX_PREC*MAX_PREC+1-1)]);

	import "DPI-C" function void tbDisplay();


//-----------------------------------------------------------------------------
//-------------------------   TESTBENCH DEFINITION   --------------------------
//-----------------------------------------------------------------------------

	// CLOCK
	initial begin
		r_clk <= 1'd0;
	end

	always
		#10  r_clk =  ! r_clk;

	// RESET
	initial begin
		r_rst <= 1'd1;
		#250		r_rst <= 1'd0;
	end


	parameter FSM_RESET = 0,
					FSM_CHECK_STATE = 1,
					FSM_OBTAIN_NEW_VALUES = 2,
					FSM_DRIVE_LOGIC = 3,
					FSM_WAIT_PRE_PRINT = 4,
					FSM_PRINT_DPI_REF = 5,
					FSM_DRIVE_DATA = 6,
					FSM_WAIT_POST_FINISH = 8,
					FSM_DONE = 16,
					FSM_ERROR = 32;



	// DATA PREPERATION FOR CPU_CMC_MULT

	to_lfsr_sim_only #(
		.g_lfsr						(c_lfsr								),		//: boolean := true
		.g_addr_width				(c_addr_width						),		//: natural := 9
		.g_last_width				(5										)		//: natural := 5
	)
	to_lfsr_sim_only_A_inst (
		.pi_clk						(r_clk								),		//: out std_logic;
		.pi_data						(a_prec[c_addr_width-1:0]-1	),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_data						(s_my_size							),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_last						(s_my_last							)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);


	to_lfsr_sim_only #(
		.g_lfsr						(c_lfsr								),		//: boolean := true
		.g_addr_width				(c_addr_width						),		//: natural := 9
		.g_last_width				(5										)		//: natural := 5
	)
	to_lfsr_sim_only_B_inst (
		.pi_clk						(r_clk								),		//: out std_logic;
		.pi_data						(b_prec[c_addr_width-1:0]-1	),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_data						(s_other_size						),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_last						(s_other_last						)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);





	always @(posedge r_clk)
	begin

		r_dpi_index_A_pre_dly <= 0;
		r_dpi_index_B_pre_dly <= 0;
		r_dpi_cycle <= 1'b0;
		r_dpi_addr_init_up <= 0;
		r_dpi_last <= 0;
		r_dpi_valid <= 0;
		r_cmc_mult_start <= 1'b0;

		if(r_rst)
		begin

			fsm_state <= FSM_RESET;
			$srandom(seed_sv);
			r_cnt_total <= 0;
			r_ok <= 1'b1;

		end
		else
		begin

			case (fsm_state)

				FSM_RESET:
				begin
					fsm_state <= FSM_CHECK_STATE;
				end


				FSM_CHECK_STATE:
				begin
					if(r_cnt_total < NUM_ITERATIONS)
					begin
						fsm_state <= FSM_OBTAIN_NEW_VALUES;
					end
					else
					begin

						if(r_ok)
							fsm_state <= FSM_DONE;
						else
							fsm_state <= FSM_ERROR;

					end
				end


				FSM_OBTAIN_NEW_VALUES:
				begin
					fsm_state <= FSM_DRIVE_LOGIC;
					a_prec = $urandom_range(MAX_PREC, MIN_PREC);
					b_prec = $urandom_range(MAX_PREC, MIN_PREC);
					mult_regs_address(
											a, a_prec,
											b, b_prec,
											cycle, addr_init_up, last, valid);
				end


				FSM_DRIVE_LOGIC:
				begin
					fsm_state <= FSM_WAIT_PRE_PRINT;
					r_my_size <= s_my_size;
					r_my_last <= s_my_last;
					r_other_size <= s_other_size;
					r_other_last <= s_other_last;
					r_cmc_mult_start <= 1'b1;
					r_delay <= 2;
				end


				FSM_WAIT_PRE_PRINT:
				begin
					r_counter <= 0;
					if(r_delay == 0)
						fsm_state <= FSM_PRINT_DPI_REF;
					else
						r_delay <= r_delay - 1;
				end


				FSM_PRINT_DPI_REF:
				begin

					if(r_counter < a_prec*b_prec+1)
					begin
						r_counter <= r_counter + 1;

						r_dpi_index_A_pre_dly <= a[r_counter][15:0];
						r_dpi_index_B_pre_dly <= b[r_counter][15:0];
						r_dpi_addr_init_up <= addr_init_up[r_counter][1:0];
						r_dpi_cycle <= cycle[r_counter][0];
						r_dpi_last <= last[r_counter][0];
						r_dpi_valid <= valid[r_counter][0];
					end
					else
					begin
						fsm_state <= FSM_WAIT_POST_FINISH;
						r_delay <= 0;
					end
				end


				FSM_WAIT_POST_FINISH:
				begin
					if(r_delay < C_DELAY_MAX)
					begin
						r_delay <= r_delay + 1;
					end
					else
					begin
						fsm_state <= FSM_CHECK_STATE;
						r_cnt_total <= r_cnt_total + 1;
					end
				end


				FSM_DONE:
				begin
					$finish;
				end


				FSM_ERROR:
				begin
					$finish;
				end

			endcase
		end
	end



//
//	multiplier_TB_wrapper #(
//		.g_data_width				(c_data_width						),		//: natural := 64;
//		.g_addr_width				(c_addr_width						),		//: natural := 9;
//		.g_ctrl_width				(c_ctrl_width						),		//: natural := 8;
//		.g_select_width			(c_select_width					),		//: natural := 4;
//		.g_id							(c_id									)		//: natural := 2;
//	)
//	multiplier_TB_wrapper_inst (
//		.pi_clk						(r_clk								),		//: in std_logic;
//		.pi_rst						(r_rst								),		//: in std_logic;
//
//		.pi_ctrl_ch_A				(r_ctrl_A							),		//: in std_logic_vector(C_STD_CTRL_WIDTH-1 downto 0);
//		.pi_ctrl_ch_B				(r_ctrl_B							),		//: in std_logic_vector(C_STD_CTRL_WIDTH-1 downto 0);
//		.pi_ctrl_valid_n			(r_ctrl_valid_n					),		//: in std_logic;
//
//		.pi_data_0					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_1					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_2					(r_data_A							),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_3					(r_data_B							),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_4					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_5					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_6					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_7					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_8					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_9					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_10					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_11					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//		.pi_data_12					(										),		//: std_logic_vector(g_data_width-1 downto 0);
//
//		.pi_data_last				(r_data_last						),		//: std_logic;
//		.pi_data_wr_en				(r_data_wr_en						),		//: std_logic;
//		.pi_data_cycle				(r_data_cycle						),		//: std_logic;
//
//		.po_data						(s_data								),		//: std_logic_vector(g_data_width-1 downto 0);
//		.po_data_last				(s_data_last						),		//: std_logic;
//		.po_data_wr_en				(s_data_wr_en						),		//: std_logic;
//		.po_data_zero				(s_data_zero						)		//: std_logic;
//	);



	data_delayer #(
		.g_data_width		(1									),		//: natural := 64;
		.g_delay				(c_dpi_delay					)		//: natural := 4
	)
	R_DPI_VALID_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_valid						),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_valid_dly					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(1									),		//: natural := 64;
		.g_delay				(c_dpi_delay					)		//: natural := 4
	)
	R_DPI_LAST_DLY_INST (
		.pi_clk				(r_clk								),		//: in std_logic;
		.pi_data				(r_dpi_last							),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_last_dly					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);


	data_delayer #(
		.g_data_width		(1									),		//: natural := 64;
		.g_delay				(c_dpi_delay					)		//: natural := 4
	)
	R_DPI_CYCLE_DLY_INST (
		.pi_clk				(r_clk								),		//: in std_logic;
		.pi_data				(r_dpi_cycle							),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_cycle_dly					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);


	data_delayer #(
		.g_data_width		(2									),		//: natural := 64;
		.g_delay				(c_dpi_delay					)		//: natural := 4
	)
	R_DPI_ADDR_INIT_UP_DLY_INST (
		.pi_clk				(r_clk								),		//: in std_logic;
		.pi_data				(r_dpi_addr_init_up				),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_addr_init_up_dly			)		//: out std_logic_vector(g_data_width-1 downto 0)
	);




	always @(posedge r_clk)
	begin

		if(r_rst)
		begin
			r_ok_1_3_A <= 1'b1;
			r_ok_1_3_B <= 1'b1;
		end
		else if(r_dpi_valid_dly)
		begin
			if(r_dpi_index_A == s_index_A_dpi_ref)
				r_ok_1_3_A <= 1;
			else
				r_ok_1_3_A <= 0;

			if(r_dpi_index_B == s_index_B_dpi_ref)
				r_ok_1_3_B <= 1;
			else
				r_ok_1_3_B <= 0;

		end

	end



	always @(posedge r_clk)
	begin

		if(r_rst)
		begin
			r_ok_1_2_A <= 1'b1;
			r_ok_1_2_B <= 1'b1;
		end
		else if(r_dpi_valid_dly)
		begin
			if(r_dpi_index_A == s_index_A_dly)
				r_ok_1_2_A <= 1;
			else
				r_ok_1_2_A <= 0;

			if(r_dpi_index_B == s_index_B_dly)
				r_ok_1_2_B <= 1;
			else
				r_ok_1_2_B <= 0;

		end

	end




	// REFERENCE r_dpi_index_A and r_dpi_index_B

//	assign r_dpi_index_A_pre_lfsr = r_dpi_index_A_pre_dly;
//	assign r_dpi_index_B_pre_lfsr = r_dpi_index_B_pre_dly;

	data_delayer #(
		.g_data_width		(c_addr_width					),		//: natural := 64;
		.g_delay				(2									)		//: natural := 4
	)
	DPI_INDEX_A_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_index_A_pre_dly					),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_index_A_pre_lfsr					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	to_lfsr_sim_only #(
		.g_lfsr						(c_lfsr								),		//: boolean := true
		.g_addr_width				(c_addr_width						),		//: natural := 9
		.g_last_width				(5										)		//: natural := 5
	)
	to_lfsr_sim_only_A_index_inst (
		.pi_clk						(r_clk								),		//: out std_logic;
		.pi_data						(r_dpi_index_A_pre_lfsr			),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_data						(r_dpi_index_A						),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_last						(										)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);


	data_delayer #(
		.g_data_width		(c_addr_width								),		//: natural := 64;
		.g_delay				(2												)		//: natural := 4
	)
	DPI_INDEX_B_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_index_B_pre_dly					),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_index_B_pre_lfsr					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);


	to_lfsr_sim_only #(
		.g_lfsr						(c_lfsr								),		//: boolean := true
		.g_addr_width				(c_addr_width						),		//: natural := 9
		.g_last_width				(5										)		//: natural := 5
	)
	to_lfsr_sim_only_B_index_inst (
		.pi_clk						(r_clk								),		//: out std_logic;
		.pi_data						(r_dpi_index_B_pre_lfsr			),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_data						(r_dpi_index_B						),		//: out std_logic_vector(g_addr_width-1 downto 0);
		.po_last						(										)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);




	// REG_ADDRESSING_UNIT_A and REG_ADDRESSING_UNIT_B based on DPI cycle, addr_init, valid and last
	// This is used for verification of cycle and adr_init_up signals as r_dpi_index_A and r_dpi_index_B are correct.

	data_delayer #(
		.g_data_width		(2												),		//: natural := 64;
		.g_delay				(c_addr_unit_delay						)		//: natural := 4
	)
	R_DPI_ADDR_INIT_UP_REF_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_addr_init_up						),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_addr_init_up_ref_dly			)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(1												),		//: natural := 64;
		.g_delay				(c_addr_unit_delay						)		//: natural := 4
	)
	R_DPI_CYCLE_REF_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_cycle								),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_cycle_ref_dly						)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(1												),		//: natural := 64;
		.g_delay				(c_addr_unit_delay						)		//: natural := 4
	)
	R_DPI_VALID_REF_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_valid								),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_valid_ref_dly						)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(1												),		//: natural := 64;
		.g_delay				(c_addr_unit_delay						)		//: natural := 4
	)
	R_DPI_LAST_REF_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(r_dpi_last									),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(r_dpi_last_ref_dly						)		//: out std_logic_vector(g_data_width-1 downto 0)
	);



	reg_addressing_unit #(
		.g_lfsr						(c_lfsr								),		//: boolean := false;
		.g_addr_width				(c_addr_width						)		//: natural := 9
	)
	reg_addressing_unit_a_ref_inst (
		.pi_clk						(r_clk								),		//: in std_logic;
		.pi_rst						(r_rst								),		//: in std_logic;
		.pi_addr_init_up			(r_dpi_addr_init_up_ref_dly[0]),		//: in std_logic;
		.pi_data_cycle				(r_dpi_cycle_ref_dly				),		//: in std_logic;
		.pi_data_valid				(r_dpi_valid_ref_dly				),		//: in std_logic;
		.pi_data_last_my			(r_dpi_last_ref_dly				),		//: in std_logic;
		.pi_data_last_other		(r_dpi_last_ref_dly				),		//: in std_logic;
		.pi_addr_up_down			(1'b0									),		//: in std_logic;
		.po_read_addr				(s_index_A_dpi_ref				)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);

	reg_addressing_unit #(
		.g_lfsr						(c_lfsr								),		//: boolean := false;
		.g_addr_width				(c_addr_width						)		//: natural := 9
	)
	reg_addressing_unit_b_ref_inst (
		.pi_clk						(r_clk								),		//: in std_logic;
		.pi_rst						(r_rst								),		//: in std_logic;
		.pi_addr_init_up			(r_dpi_addr_init_up_ref_dly[1]),		//: in std_logic;
		.pi_data_cycle				(r_dpi_cycle_ref_dly				),		//: in std_logic;
		.pi_data_valid				(r_dpi_valid_ref_dly				),		//: in std_logic;
		.pi_data_last_my			(r_dpi_last_ref_dly				),		//: in std_logic;
		.pi_data_last_other		(r_dpi_last_ref_dly				),		//: in std_logic;
		.pi_addr_up_down			(1'b1									),		//: in std_logic;
		.po_read_addr				(s_index_B_dpi_ref				)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);



	// DESIGN UNDER TEST

	cpu_cmc_mult  #(
		.g_lfsr						(c_lfsr								),		//: boolean := false;
		.g_addr_width				(c_addr_width						)		//: natural := 9
	)
	cpu_cmc_mult_inst (
		.pi_clk						(r_clk								),		//: in std_logic;
		.pi_rst						(r_rst								),		//: in std_logic;
		.pi_cmc_mult_start		(r_cmc_mult_start					),		//: in std_logic;
		.pi_my_size					(s_my_size							),		//: in std_logic_vector(g_addr_width-1 downto 0);
		.pi_my_last					(s_my_last							),		//: in std_logic_vector(4 downto 0);
		.pi_other_size				(s_other_size						),		//: in std_logic_vector(g_addr_width-1 downto 0);
		.pi_other_last				(s_other_last						),		//: in std_logic_vector(4 downto 0);
		.po_cmc_addr_init_up		(s_cmc_addr_init_up				),		//: out std_logic_vector(1 downto 0);
		.po_cmc_data_cycle		(s_cmc_data_cycle					),		//: out std_logic;
		.po_cmc_data_valid		(s_cmc_data_valid					),		//: out std_logic;
		.po_cmc_data_last_both	(s_cmc_data_last_both			)		//: out std_logic
	);



	reg_addressing_unit #(
		.g_lfsr						(c_lfsr								),		//: boolean := false;
		.g_addr_width				(c_addr_width						)		//: natural := 9
	)
	reg_addressing_unit_a_inst (
		.pi_clk						(r_clk								),		//: in std_logic;
		.pi_rst						(r_rst								),		//: in std_logic;
		.pi_addr_init_up			(s_cmc_addr_init_up[0]			),		//: in std_logic;
		.pi_data_cycle				(s_cmc_data_cycle					),		//: in std_logic;
		.pi_data_valid				(s_cmc_data_valid					),		//: in std_logic;
		.pi_data_last_my			(s_cmc_data_last_both			),		//: in std_logic;
		.pi_data_last_other		(s_cmc_data_last_both			),		//: in std_logic;
		.pi_addr_up_down			(1'b0									),		//: in std_logic;
		.po_read_addr				(s_index_A							)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);

	reg_addressing_unit #(
		.g_lfsr						(c_lfsr								),		//: boolean := false;
		.g_addr_width				(c_addr_width						)		//: natural := 9
	)
	reg_addressing_unit_b_inst (
		.pi_clk						(r_clk								),		//: in std_logic;
		.pi_rst						(r_rst								),		//: in std_logic;
		.pi_addr_init_up			(s_cmc_addr_init_up[1]			),		//: in std_logic;
		.pi_data_cycle				(s_cmc_data_cycle					),		//: in std_logic;
		.pi_data_valid				(s_cmc_data_valid					),		//: in std_logic;
		.pi_data_last_my			(s_cmc_data_last_both			),		//: in std_logic;
		.pi_data_last_other		(s_cmc_data_last_both			),		//: in std_logic;
		.pi_addr_up_down			(1'b1									),		//: in std_logic;
		.po_read_addr				(s_index_B							)		//: out std_logic_vector(g_addr_width-1 downto 0);
	);


parameter c_cycler_dly = 1;

	data_delayer #(
		.g_data_width		(2												),		//: natural := 64;
		.g_delay				(c_cycler_dly								)		//: natural := 4
	)
	S_CMC_ADDR_INIT_UP_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(s_cmc_addr_init_up						),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(s_cmc_addr_init_up_dly					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(1												),		//: natural := 64;
		.g_delay				(c_cycler_dly								)		//: natural := 4
	)
	S_CMC_DATA_CYCLE_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(s_cmc_data_cycle							),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(s_cmc_data_cycle_dly					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);


	data_delayer #(
		.g_data_width		(1												),		//: natural := 64;
		.g_delay				(c_cycler_dly								)		//: natural := 4
	)
	S_CMC_DATA_VALID_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(s_cmc_data_valid							),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(s_cmc_data_valid_dly					)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(1												),		//: natural := 64;
		.g_delay				(c_cycler_dly								)		//: natural := 4
	)
	S_CMC_DATA_LAST_BOTH_DLY_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(s_cmc_data_last_both					),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(s_cmc_data_last_both_dly				)		//: out std_logic_vector(g_data_width-1 downto 0)
	);


	data_delayer #(
		.g_data_width		(c_addr_width								),		//: natural := 64;
		.g_delay				(c_cycler_dly								)		//: natural := 4
	)
	S_INDEX_A_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(s_index_A									),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(s_index_A_dly								)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

	data_delayer #(
		.g_data_width		(c_addr_width								),		//: natural := 64;
		.g_delay				(c_cycler_dly								)		//: natural := 4
	)
	S_INDEX_B_INST (
		.pi_clk				(r_clk										),		//: in std_logic;
		.pi_data				(s_index_B									),		//: in std_logic_vector(g_data_width-1 downto 0);
		.po_data				(s_index_B_dly								)		//: out std_logic_vector(g_data_width-1 downto 0)
	);

endmodule
