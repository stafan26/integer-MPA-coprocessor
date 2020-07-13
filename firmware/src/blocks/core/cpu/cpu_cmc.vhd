-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- limit r_sm_last input signals from 7 to 6 in SIZE_CONVERTER
--		- remove last_both? data_last could generate proper, individual data_last signals
--		- remove the data_delay modules for output CMC signals
--
-------------------------------------------
-------------------------------------------


entity cpu_cmc is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;
	pi_rst						: in std_logic;

	pi_cmc_add_sub_start		: in std_logic;
	pi_cmc_mult_start			: in std_logic;
	pi_cmc_unload_start		: in std_logic;

	pi_cmc_start				: in std_logic;
	pi_cmc_oper					: in std_logic_vector(1 downto 0);
	pi_cmc_channel				: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(4 downto 0);
	pi_other_size				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last				: in std_logic_vector(4 downto 0);

	po_cmc_busy					: out std_logic_vector(1 downto 0);

	po_cmc_addr_init_up_A	: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle_A		: out std_logic;
	po_cmc_data_valid_A		: out std_logic;
	po_cmc_data_last_A		: out std_logic_vector(2 downto 0);

	po_cmc_addr_init_up_B	: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle_B		: out std_logic;
	po_cmc_data_valid_B		: out std_logic;
	po_cmc_data_last_B		: out std_logic_vector(2 downto 0);

	po_cmc_unload_last		: out std_logic;
	po_cmc_unload_wr_en		: out std_logic;

	po_cmc_add_sub_last		: out std_logic;
	po_cmc_add_sub_wr_en		: out std_logic;

	po_cmc_mult_last			: out std_logic;
	po_cmc_mult_cycle			: out std_logic;
	po_cmc_mult_wr_en			: out std_logic
);
end cpu_cmc;

architecture cpu_cmc of cpu_cmc is

	signal s_cmc_add_sub_data_cycle						: std_logic;
	signal s_cmc_add_sub_data_valid						: std_logic;
	signal s_cmc_add_sub_data_last						: std_logic_vector(1 downto 0);
	signal s_cmc_add_sub_data_last_both					: std_logic;

	signal s_cmc_mult_addr_init_up						: std_logic_vector(1 downto 0);
	signal s_cmc_mult_data_cycle							: std_logic;
	signal s_cmc_mult_data_valid							: std_logic;
	signal s_cmc_mult_data_last_both						: std_logic;

	signal s_cmc_unload_data_cycle						: std_logic;
	signal s_cmc_unload_data_valid						: std_logic;
	signal s_cmc_unload_data_valid_dly					: std_logic;
	signal s_cmc_unload_data_last							: std_logic;

begin

	po_cmc_add_sub_last <= s_cmc_add_sub_data_last_both;
	po_cmc_add_sub_wr_en <= s_cmc_add_sub_data_valid;
	po_cmc_mult_last <= s_cmc_mult_data_last_both;
	po_cmc_mult_cycle <= s_cmc_mult_data_cycle;
	po_cmc_mult_wr_en <= s_cmc_mult_data_valid;

	po_cmc_unload_last <= s_cmc_unload_data_last;
	po_cmc_unload_wr_en <= s_cmc_unload_data_valid;


	CPU_CMC_ADD_SUB_INST: entity work.cpu_cmc_add_sub generic map (
		g_lfsr							=> g_lfsr,								--: boolean := true;
		g_addr_width					=> g_addr_width						--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_cmc_add_sub_start			=> pi_cmc_add_sub_start,			--: in std_logic;
		pi_my_size						=> pi_my_size,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last						=> pi_my_last(3 downto 0),			--: in std_logic_vector(3 downto 0);
		pi_other_size					=> pi_other_size,						--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last					=> pi_other_last(3 downto 0),		--: in std_logic_vector(3 downto 0);
		po_cmc_data_cycle				=> s_cmc_add_sub_data_cycle,		--: out std_logic;
		po_cmc_data_valid				=> s_cmc_add_sub_data_valid,		--: out std_logic;
		po_cmc_data_last				=> s_cmc_add_sub_data_last,		--: out std_logic_vector(1 downto 0);
		po_cmc_data_last_both		=> s_cmc_add_sub_data_last_both	--: out std_logic
	);


	CPU_CMC_MULT_INST: entity work.cpu_cmc_mult generic map (
		g_lfsr							=> g_lfsr,								--: boolean := true;
		g_addr_width					=> g_addr_width						--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_cmc_mult_start				=> pi_cmc_mult_start,				--: in std_logic;
		pi_my_size						=> pi_my_size,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last						=> pi_my_last,							--: in std_logic_vector(4 downto 0);
		pi_other_size					=> pi_other_size,						--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last					=> pi_other_last,						--: in std_logic_vector(4 downto 0);
		po_cmc_addr_init_up			=> s_cmc_mult_addr_init_up,		--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle				=> s_cmc_mult_data_cycle,			--: out std_logic;
		po_cmc_data_valid				=> s_cmc_mult_data_valid,			--: out std_logic;
		po_cmc_data_last_both		=> s_cmc_mult_data_last_both		--: out std_logic
	);


	CPU_CMC_UNLOAD_INST: entity work.cpu_cmc_unload generic map (
		g_lfsr							=> g_lfsr,								--: boolean := true;
		g_addr_width					=> g_addr_width						--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_cmc_unload_start			=> pi_cmc_unload_start,				--: in std_logic;
		pi_my_size						=> pi_my_size,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last						=> pi_my_last(3 downto 0),			--: in std_logic_vector(3 downto 0);
		po_cmc_data_cycle				=> s_cmc_unload_data_cycle,		--: out std_logic;
		po_cmc_data_valid				=> s_cmc_unload_data_valid,		--: out std_logic;
		po_cmc_data_last				=> s_cmc_unload_data_last			--: out std_logic
	);


	CPU_CMC_SWITCH_INST: entity work.cpu_cmc_switch generic map (
		g_lfsr								=> g_lfsr,								--: boolean := true;
		g_addr_width						=> g_addr_width						--: natural := 9
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;

		pi_cmc_start						=> pi_cmc_start,						--: in std_logic;
		pi_cmc_oper							=> pi_cmc_oper,						--: in std_logic_vector(1 downto 0);
		pi_cmc_channel						=> pi_cmc_channel,					--: in std_logic;

		pi_cmc_add_sub_data_cycle		=> s_cmc_add_sub_data_cycle,		--: in std_logic;
		pi_cmc_add_sub_data_valid		=> s_cmc_add_sub_data_valid,		--: in std_logic;
		pi_cmc_add_sub_data_last		=> s_cmc_add_sub_data_last,		--: in std_logic_vector(1 downto 0);
		pi_cmc_add_sub_data_last_both	=> s_cmc_add_sub_data_last_both,	--: in std_logic;

		pi_cmc_mult_addr_init_up		=> s_cmc_mult_addr_init_up,		--: in std_logic_vector(1 downto 0);
		pi_cmc_mult_data_cycle			=> s_cmc_mult_data_cycle,			--: in std_logic;
		pi_cmc_mult_data_valid			=> s_cmc_mult_data_valid,			--: in std_logic;
		pi_cmc_mult_data_last_both		=> s_cmc_mult_data_last_both,		--: in std_logic;

		pi_cmc_unload_data_cycle		=> s_cmc_unload_data_cycle,		--: in std_logic;
		pi_cmc_unload_data_valid		=> s_cmc_unload_data_valid_dly,	--: in std_logic;
		pi_cmc_unload_data_last			=> s_cmc_unload_data_last,			--: in std_logic;

		po_cmc_busy							=> po_cmc_busy,						--: out std_logic_vector(1 downto 0);

		po_cmc_addr_init_up_A			=> po_cmc_addr_init_up_A,			--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_A				=> po_cmc_data_cycle_A,				--: out std_logic;
		po_cmc_data_valid_A				=> po_cmc_data_valid_A,				--: out std_logic;
		po_cmc_data_last_A				=> po_cmc_data_last_A,				--: out std_logic_vector(2 downto 0);

		po_cmc_addr_init_up_B			=> po_cmc_addr_init_up_B,			--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_B				=> po_cmc_data_cycle_B,				--: out std_logic;
		po_cmc_data_valid_B				=> po_cmc_data_valid_B,				--: out std_logic;
		po_cmc_data_last_B				=> po_cmc_data_last_B				--: out std_logic_vector(2 downto 0)
	);


	R_CMC_UNLOADER_WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,											--: natural := 1;
		g_delay					=> 1											--: natural := 3
	)
	port map (
		pi_clk					=> pi_clk,									--: in std_logic;
		pi_data(0)				=> s_cmc_unload_data_valid,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_cmc_unload_data_valid_dly		--: out std_logic_vector(g_data_width-1 downto 0)
	);

end architecture;
