-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    adder
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

entity adder is
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

	pi_ctrl_ch_A						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_ch_B						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_valid_n					: in std_logic;

	pi_data								: in t_data_x1;
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data_up							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_lo							: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic;
	po_data_all_ones					: out std_logic;
	po_data_zero						: out std_logic_vector(1 downto 0)

);
end adder;

architecture adder of adder is


	signal s_data_up							: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_lo							: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_cout						: std_logic_vector(1 downto 0);
	signal s_data_zero						: std_logic_vector(1 downto 0);
	signal s_data_all_ones					: std_logic;
	signal s_data_last						: std_logic;
	signal s_data_wr_en						: std_logic;
	signal s_data_wr_en_proc				: std_logic;

	signal s_post_carry_data_up			: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_carry_data_lo			: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_carry_data_last			: std_logic;
	signal s_post_carry_data_zero			: std_logic_vector(1 downto 0);
	signal s_post_carry_data_all_ones	: std_logic;
	signal s_post_carry_data_wr_en		: std_logic;

	signal s_data_A							: std_logic_vector(63 downto 0);
	signal s_data_B							: std_logic_vector(63 downto 0);

	signal s_select_A							: std_logic_vector(g_select_width-1 downto 0);
	signal s_select_B							: std_logic_vector(g_select_width-1 downto 0);
	signal s_start								: std_logic;
	signal s_sub								: std_logic;
	signal s_sub_dly							: std_logic;

begin

	po_data_up			<= s_post_carry_data_up				;			--: std_logic_vector(g_data_width-1 downto 0);
	po_data_lo			<= s_post_carry_data_lo				;			--: std_logic_vector(g_data_width-1 downto 0);
	po_data_last		<= s_post_carry_data_last			;			--: std_logic;
	po_data_wr_en		<= s_post_carry_data_wr_en			;			--: std_logic;
	po_data_all_ones	<= s_post_carry_data_all_ones		;			--: std_logic;
	po_data_zero		<= s_post_carry_data_zero			;			--: std_logic_vector(1 downto 0);


	-----------------
	-- SWITCHBOXES --
	-----------------

	ADDER_SWITCHBOX_A_INST: entity work.oper_switchbox generic map (
		g_output_data_last		=> false,										--: boolean := false;
		g_data_width				=> g_data_width,								--: natural := 64
		g_select_width				=> g_select_width								--: natural := 5
	)
	port map (
		pi_clk						=> pi_clk,										--: in std_logic;
		pi_rst						=> pi_rst,										--: in std_logic;
		pi_select					=> s_select_A,									--: in std_logic_vector(3 downto 0);
		pi_start						=> s_start,										--: in std_logic;
		pi_data						=> pi_data,										--: in t_data_x1;
		pi_data_last				=> pi_data_last,								--: in std_logic;
		po_data						=> s_data_A										--: out std_logic_vector(g_data_width-1 downto 0);
	);


	ADDER_CTRL_INST: entity work.adder_ctrl generic map (
		g_ctrl_width				=> g_ctrl_width,				--: natural := 8;
		g_select_width				=> g_select_width,			--: natural := 5
		g_id							=> g_id							--: natural := 2
	)
	port map (
		pi_clk						=> pi_clk,						--: in std_logic;
		pi_ctrl_ch_A				=> pi_ctrl_ch_A,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_B				=> pi_ctrl_ch_B,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n			=> pi_ctrl_valid_n,			--: in std_logic;
		po_select_A					=> s_select_A,					--: out std_logic_vector(3 downto 0);
		po_select_B					=> s_select_B,					--: out std_logic_vector(3 downto 0);
		po_start						=> s_start,						--: out std_logic;
		po_sub						=> s_sub							--: out std_logic
	);


	ADDER_DATA_RANGER_INST: entity work.adder_data_ranger port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_rst					=> pi_rst,						--: in std_logic;
		pi_data					=> pi_data_wr_en,				--: in std_logic;
		po_data					=> s_data_wr_en_proc			--: out std_logic
	);


	DATA_WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY				--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> s_data_wr_en_proc,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_wr_en				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY+2			--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_last,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_last					--: out std_logic_vector(g_data_width-1 downto 0)
	);

	SUB_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY				--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> s_sub,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_sub_dly					--: out std_logic_vector(g_data_width-1 downto 0)
	);



	ADDER_SWITCHBOX_B_INST: entity work.oper_switchbox generic map (
		g_output_data_last		=> false,										--: boolean := false;
		g_data_width				=> g_data_width,								--: natural := 64
		g_select_width				=> g_select_width								--: natural := 4
	)
	port map (
		pi_clk						=> pi_clk,										--: in std_logic;
		pi_rst						=> pi_rst,										--: in std_logic;
		pi_select					=> s_select_B,									--: in std_logic_vector(3 downto 0);
		pi_start						=> s_start,										--: in std_logic;
		pi_data						=> pi_data,										--: in t_data_x1;
		pi_data_last				=> pi_data_last,								--: in std_logic;
		po_data						=> s_data_B										--: out std_logic_vector(g_data_width-1 downto 0);
	);


	----------------
	-- OPERATIONS --
	----------------

	ADD_SUB_64_INST: entity work.add_sub_64 port map (
		CLK							=> pi_clk,										--: in std_logic;
		A								=> s_data_A,									--: in std_logic_vector(63 downto 0);
		B								=> s_data_B,									--: in std_logic_vector(63 downto 0);
		SUB							=> s_sub,										--: in std_logic;
		S								=> s_data_lo,									--: out std_logic_vector(63 downto 0);
		C_OUT							=> s_data_cout(0),							--: out std_logic;
		ZERO							=> s_data_zero(0),							--: out std_logic;
		ALL_ONES						=> s_data_all_ones							--: out std_logic;
	);

	SUB_64_INST: entity work.sub_64 port map (
		CLK							=> pi_clk,										--: in std_logic;
		A								=> s_data_B,									--: in std_logic_vector(63 downto 0);
		B								=> s_data_A,									--: in std_logic_vector(63 downto 0);
		S								=> s_data_up,									--: out std_logic_vector(63 downto 0);
		C_OUT							=> s_data_cout(1),							--: out std_logic;
		ZERO							=> s_data_zero(1)								--: out std_logic;
	);



	-----------
	-- CARRY --
	-----------

	ADDER_CARRY_ADDER_A_INST: entity work.adder_carry_add_sub generic map (
		g_data_width			=> g_data_width						--: natural := 64
	)
	port map (
		pi_clk					=> pi_clk,								--: in std_logic;
		pi_rst					=> pi_rst,								--: in std_logic;
		pi_data					=> s_data_lo,							--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_cout			=> s_data_cout(0),					--: in std_logic;
		pi_data_last			=> s_data_last,						--: in std_logic;
		pi_data_zero			=> s_data_zero(0),					--: in std_logic;
		pi_data_all_ones		=> s_data_all_ones,					--: in std_logic;
		pi_data_wr_en			=> s_data_wr_en,						--: in std_logic;
		pi_data_sub				=> s_sub_dly,							--: in std_logic;

		po_data					=> s_post_carry_data_lo,			--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_zero			=> s_post_carry_data_zero(0),		--: out std_logic;
		po_data_all_ones		=> s_post_carry_data_all_ones,	--: out std_logic;
		po_data_last			=> s_post_carry_data_last,			--: out std_logic;
		po_data_wr_en			=> s_post_carry_data_wr_en			--: out std_logic
	);


	ADDER_CARRY_ADDER_B_INST: entity work.adder_carry_sub generic map (
		g_data_width			=> g_data_width						--: natural := 64
	)
	port map (
		pi_clk					=> pi_clk,								--: in std_logic;
		pi_rst					=> pi_rst,								--: in std_logic;
		pi_data					=> s_data_up,							--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_cout			=> s_data_cout(1),					--: in std_logic;
		pi_data_last			=> s_data_last,						--: in std_logic;
		pi_data_zero			=> s_data_zero(1),					--: in std_logic;
		pi_data_wr_en			=> s_data_wr_en,						--: in std_logic;

		po_data					=> s_post_carry_data_up,			--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_zero			=> s_post_carry_data_zero(1)		--: out std_logic;
	);

end architecture;
