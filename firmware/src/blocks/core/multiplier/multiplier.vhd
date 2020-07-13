-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    multiplier
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity multiplier is
generic (
	g_data_width						: natural := 64;
	g_addr_width						: natural := 9;
	g_ctrl_width						: natural := 8;
	g_select_width						: natural := 4;
	g_id									: natural := 2
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_ch_A						: in std_logic_vector(C_STD_CTRL_WIDTH-1 downto 0);
	pi_ctrl_ch_B						: in std_logic_vector(C_STD_CTRL_WIDTH-1 downto 0);
	pi_ctrl_valid_n					: in std_logic;

	pi_data								: in t_data_x1;
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;
	pi_data_cycle						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic;
	po_data_zero						: out std_logic
);
end multiplier;

architecture multiplier of multiplier is

	signal s_post_acc_data					: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_acc_data_cout			: std_logic;
	signal s_post_acc_data_zero			: std_logic;
	signal s_post_acc_data_all_ones		: std_logic;
	signal s_post_acc_data_last			: std_logic;
	signal s_post_acc_data_wr_en			: std_logic;

	signal s_post_add_data					: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_add_data_last			: std_logic;
	signal s_post_add_data_zero			: std_logic;
	signal s_post_add_data_wr_en			: std_logic;

	signal s_select_A							: std_logic_vector(g_select_width-1 downto 0);
	signal s_select_B							: std_logic_vector(g_select_width-1 downto 0);
	signal s_start								: std_logic;

	signal s_data_A							: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_B							: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_last						: std_logic;
	signal s_data_wr_en_pre					: std_logic;
	signal s_data_wr_en						: std_logic;
	signal s_data_cycle_pre					: std_logic;
	signal s_data_cycle						: std_logic;

	signal s_data_P							: std_logic_vector(2*g_data_width-1 downto 0);
	signal s_data_P_1							: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_P_2							: std_logic_vector(g_data_width-1 downto 0);

	signal s_data_last_out					: std_logic;

	signal s_switch_pre_acc					: std_logic;
	signal s_switch_out						: std_logic;

	signal s_load_acc_1						: std_logic;
	signal s_load_acc_2						: std_logic;

	signal s_acc_data_1						: std_logic_vector(g_data_width+g_addr_width-1 downto 0);
	signal s_acc_data_2						: std_logic_vector(g_data_width+g_addr_width-1 downto 0);

	signal s_data_long						: std_logic_vector(g_data_width+g_addr_width-1 downto 0);
	signal s_data_wr_en_out					: std_logic;

begin

	po_data				<= s_post_add_data				;			--: std_logic_vector(g_data_width-1 downto 0);
	po_data_last		<= s_post_add_data_last			;			--: std_logic;
	po_data_wr_en		<= s_post_add_data_wr_en		;			--: std_logic;
	po_data_zero		<= s_post_add_data_zero			;			--: std_logic;


	-------------
	-- CONTROL --
	-------------

	MULT_SYNC_INST: entity work.mult_sync port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data_last			=> s_data_last,					--: in std_logic;
		pi_cycle					=> s_data_cycle,					--: in std_logic;
		pi_wr_en					=> s_data_wr_en,					--: in std_logic;
		po_switch_pre_acc		=> s_switch_pre_acc,				--: out std_logic;
		po_switch_out			=> s_switch_out,					--: out std_logic;
		po_data_last_out		=> s_data_last_out,				--: out std_logic;
		po_load_acc_1			=> s_load_acc_1,					--: out std_logic;
		po_load_acc_2			=> s_load_acc_2,					--: out std_logic;
		po_wr_en					=> s_data_wr_en_out				--: out std_logic;
	);


	MULT_CTRL_INST: entity work.mult_ctrl generic map (
		g_ctrl_width			=> g_ctrl_width,					--: natural := 8;
		g_select_width			=> g_select_width,				--: natural := 4;
		g_id						=> g_id								--: natural := 2

	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_ctrl_ch_A			=> pi_ctrl_ch_A,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_B			=> pi_ctrl_ch_B,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n		=> pi_ctrl_valid_n,				--: in std_logic;
		po_select_A				=> s_select_A,						--: out std_logic_vector(g_select_width-1 downto 0);
		po_select_B				=> s_select_B,						--: out std_logic_vector(g_select_width-1 downto 0);
		po_start					=> s_start							--: out std_logic
	);

	-----------------
	-- SWITCHBOXES --
	-----------------

	MULT_SWITCHBOX_A_INST: entity work.oper_switchbox generic map (
		g_output_data_last	=> false,							--: boolean := false;
		g_data_width			=> g_data_width,					--: natural := 64
		g_select_width			=> g_select_width					--: natural := 4
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_rst					=> pi_rst,							--: in std_logic;
		pi_select				=> s_select_A,						--: in std_logic_vector(g_select_width-1 downto 0);
		pi_start					=> s_start,							--: in std_logic;
		pi_data					=> pi_data,							--: in t_data_x1;
		pi_data_last			=> pi_data_last,					--: in std_logic;
		po_data					=> s_data_A							--: out std_logic_vector(g_data_width-1 downto 0);
	);


	DATA_WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 1									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_data_wr_en,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_wr_en_pre				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	DATA_WR_EN_PRE_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 1									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> s_data_wr_en_pre,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_wr_en					--: out std_logic_vector(g_data_width-1 downto 0)
	);


	DATA_CYCLE_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 1									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_data_cycle,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_cycle_pre				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	MULTIPLIER_CYCLE_CROPPER_INST: entity work.mult_cycle_cropper
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_shutter				=> s_data_wr_en_pre,				--: in std_logic;
		pi_cycle					=> s_data_cycle_pre,				--: in std_logic;
		po_cycle					=> s_data_cycle					--: out std_logic
	);


	DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 2									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_data_last,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_last						--: out std_logic_vector(g_data_width-1 downto 0)
	);


	MULT_SWITCHBOX_B_INST: entity work.oper_switchbox generic map (
		g_output_data_last	=> false,							--: boolean := false;
		g_data_width			=> g_data_width,					--: natural := 64
		g_select_width			=> g_select_width					--: natural := 4
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_rst					=> pi_rst,							--: in std_logic;
		pi_select				=> s_select_B,						--: in std_logic_vector(g_select_width-1 downto 0);
		pi_start					=> s_start,							--: in std_logic;
		pi_data					=> pi_data,							--: in t_data_x1;
		pi_data_last			=> pi_data_last,					--: in std_logic;
		po_data					=> s_data_B							--: out std_logic_vector(g_data_width-1 downto 0);
	);

	--------------------
	-- MULTIPLICATION --
	--------------------


	MULT_64_INST: entity work.mult_64 port map (
		CLK						=> pi_clk,							--: in std_logic;
		A							=> s_data_A,						--: in std_logic_vector(63 downto 0);
		B							=> s_data_B,						--: in std_logic_vector(63 downto 0);
		S							=> s_data_P							--: out std_logic_vector(127 downto 0);
	);


	---------------
	-- POST_PROC --
	---------------

	MULT_DIVERSION_INST: entity work.mult_diversion generic map (
		g_data_width			=> g_data_width					--: natural := 64
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_switch				=> s_switch_pre_acc,				--: in std_logic;
		pi_data					=> s_data_P,						--: in std_logic_vector(2*g_data_width-1 downto 0);
		po_data_1				=> s_data_P_1,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_2				=> s_data_P_2						--: out std_logic_vector(g_data_width-1 downto 0);
	);


	MULT_ACC_1_INST: entity work.mult_acc_ip_64 generic map (
		g_data_width			=> g_data_width,					--: natural := 64
		g_addr_width			=> g_addr_width					--: natural := 9
	)
	port map (
		CLK						=> pi_clk,							--: in std_logic;
		B							=> s_data_P_1,						--: in std_logic_vector(g_data_in_width-1 downto 0);
		BYPASS					=> s_load_acc_1,					--: in std_logic;
		Q							=> s_acc_data_1					--: out std_logic_vector(g_data_out_width-1 downto 0);
	);


	MULT_ACC_2_INST: entity work.mult_acc_ip_64 generic map (
		g_data_width			=> g_data_width,					--: natural := 64
		g_addr_width			=> g_addr_width					--: natural := 9
	)
	port map (
		CLK						=> pi_clk,							--: in std_logic;
		B							=> s_data_P_2,						--: in std_logic_vector(g_data_in_width-1 downto 0);
		BYPASS					=> s_load_acc_2,					--: in std_logic;
		Q							=> s_acc_data_2					--: out std_logic_vector(g_data_out_width-1 downto 0);
	);


	MUX_INST: entity work.mult_mux generic map (
		g_reg_output			=> "YES",							--: string := "YES";
		g_data_width			=> g_data_width+g_addr_width	--: natural := 73
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_switch				=> s_switch_out,					--: in std_logic;
		pi_data_1				=> s_acc_data_1,					--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_2				=> s_acc_data_2,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_long						--: in std_logic_vector(g_data_width-1 downto 0)
	);

	MULT_PART_ADDER_INST: entity work.mult_part_adder generic map (
		g_data_width		=> g_data_width,						--: natural := 64;
		g_addr_width		=> g_addr_width						--: natural := 9
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_rst				=> pi_rst,								--: in std_logic;

		pi_data				=> s_data_long,						--: in std_logic_vector(g_data_width+g_addr_width-1 downto 0);
		pi_data_last		=> s_data_last_out,					--: in std_logic;
		pi_data_wr_en		=> s_data_wr_en_out,					--: in std_logic;
		po_data				=> s_post_acc_data,					--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_cout		=> s_post_acc_data_cout,			--: out std_logic;
		po_data_zero		=> s_post_acc_data_zero,			--: out std_logic;
		po_data_all_ones	=> s_post_acc_data_all_ones,		--: out std_logic;
		po_data_last		=> s_post_acc_data_last,			--: out std_logic;
		po_data_wr_en		=> s_post_acc_data_wr_en			--: out std_logic
	);


	--------------
	-- POST_ADD --
	--------------

	MULT_CARRY_ADD_INST: entity work.mult_carry_add generic map (
		g_data_width		=> g_data_width						--: natural := 64
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_rst				=> pi_rst,								--: in std_logic;
		pi_data				=> s_post_acc_data,					--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_cout		=> s_post_acc_data_cout,			--: in std_logic;
		pi_data_last		=> s_post_acc_data_last,			--: in std_logic;
		pi_data_zero		=> s_post_acc_data_zero,			--: in std_logic;
		pi_data_all_ones	=> s_post_acc_data_all_ones,		--: in std_logic;
		pi_data_wr_en		=> s_post_acc_data_wr_en,			--: in std_logic;
		po_data				=> s_post_add_data,					--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last		=> s_post_add_data_last,			--: out std_logic;
		po_data_zero		=> s_post_add_data_zero,			--: out std_logic;
		po_data_wr_en		=> s_post_add_data_wr_en			--: out std_logic
	);

end architecture;
