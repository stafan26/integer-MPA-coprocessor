-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult
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
--
-------------------------------------------
-------------------------------------------


entity cpu_cmc_mult is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;
	pi_rst						: in std_logic;

	pi_cmc_mult_start			: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(4 downto 0);
	pi_other_size				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last				: in std_logic_vector(4 downto 0);

	po_cmc_addr_init_up		: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle			: out std_logic;
	po_cmc_data_valid			: out std_logic;
	po_cmc_data_last_both	: out std_logic
);
end cpu_cmc_mult;

architecture cpu_cmc_mult of cpu_cmc_mult is

	signal s_size_converter_start						: std_logic;
	signal s_data_last_start							: std_logic;
	signal s_mult_cycler_pre_start					: std_logic;
	signal s_mult_cycler_start							: std_logic;

	signal s_my_size										: std_logic_vector(g_addr_width-1 downto 0);
	signal s_my_last										: std_logic_vector(4 downto 0);

	signal s_other_size									: std_logic_vector(g_addr_width-1 downto 0);
	signal s_other_last									: std_logic_vector(4 downto 0);

	signal s_my_size_minus_one							: std_logic_vector(g_addr_width-1 downto 0);
	signal s_other_size_minus_one						: std_logic_vector(g_addr_width-1 downto 0);

	signal s_one_limb										: std_logic;

	signal s_change_A										: std_logic;

	signal s_change_period_up							: std_logic;
	signal s_change_period_down_n						: std_logic;

	signal s_valid											: std_logic;
	signal s_addr_init									: std_logic_vector(1 downto 0);
	signal s_cycle											: std_logic;
	signal s_last											: std_logic;

begin

	CPU_CMC_CONTROL_DELAY_INST: entity work.cpu_cmc_mult_control_delay port map (
		pi_clk										=> pi_clk,									--: in std_logic;
		--pi_rst										=> pi_rst,									--: in std_logic;
		pi_cmc_mult_start							=> pi_cmc_mult_start,					--: in std_logic;
		po_size_converter_start					=> s_size_converter_start,				--: out std_logic;
		po_data_last_start						=> s_data_last_start,					--: out std_logic;
		po_mult_cycler_pre_start				=> s_mult_cycler_pre_start,			--: out std_logic
		po_mult_cycler_start						=> s_mult_cycler_start					--: out std_logic
	);


	----------------
	-- INPUT DATA --
	----------------

	CPU_CMC_DATA_ORGANIZER_INST: entity work.cpu_cmc_mult_data_organizer generic map (
		g_lfsr							=> g_lfsr,									--: boolean := true;
		g_addr_width					=> g_addr_width							--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_load							=> pi_cmc_mult_start,					--: in std_logic;
		pi_my_size						=> pi_my_size,								--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last						=> pi_my_last,								--: in std_logic_vector(4 downto 0);
		pi_other_size					=> pi_other_size,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last					=> pi_other_last,							--: in std_logic_vector(4 downto 0);
		po_my_size						=> s_my_size,								--: out std_logic_vector(g_addr_width-1 downto 0);
		po_my_last						=> s_my_last,								--: out std_logic_vector(4 downto 0);
		po_other_size					=> s_other_size,							--: out std_logic_vector(g_addr_width-1 downto 0);
		po_other_last					=> s_other_last,							--: out std_logic_vector(4 downto 0);
		po_my_size_minus_one			=> s_my_size_minus_one,					--: out std_logic_vector(g_addr_width-1 downto 0);
		po_other_size_minus_one		=> s_other_size_minus_one,				--: out std_logic_vector(g_addr_width-1 downto 0);
		po_one_limb						=> s_one_limb								--: out std_logic;
	);


	----------
	-- MAIN --
	----------

	CPU_CMC_SIZE_CONVERTER_INST: entity work.cpu_cmc_mult_size_converter generic map (
		g_lfsr						=> g_lfsr,							--: boolean := true;
		g_addr_width				=> g_addr_width					--: natural := 10
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_start						=> s_size_converter_start,		--: in std_logic;
		pi_my_size_minus_one		=> s_my_size_minus_one,			--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last					=> s_my_last,						--: in std_logic_vector(4 downto 0);
		pi_other_size_minus_one	=> s_other_size_minus_one,		--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last				=> s_other_last,					--: in std_logic_vector(4 downto 0);
		pi_taken						=> s_cycle,							--: in std_logic;
		po_my_last_n				=> s_change_A,						--: in std_logic;
		po_sm_last_period_n		=> s_change_period_up,			--: out std_logic;
		po_gr_last_period_n		=> s_change_period_down_n		--: out std_logic;
	);


	---------------
	--   CYCLER  --
	---------------

	CPU_CMC_MULT_CYCLER_INST: entity work.cpu_cmc_mult_cycler generic map (
		g_lfsr						=> g_lfsr,							--: boolean := false;
		g_addr_width				=> g_addr_width					--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_mult_pre_start			=> s_mult_cycler_pre_start,	--: in std_logic;
		pi_mult_start				=> s_mult_cycler_start,			--: in std_logic;
		pi_ultimate_last			=> s_last,							--: in std_logic;
		pi_one_limb					=> s_one_limb,						--: in std_logic;
		pi_change_A					=> s_change_A,						--: in std_logic;
		pi_change_period_up		=> s_change_period_up,			--: in std_logic;
		pi_change_period_down_n	=> s_change_period_down_n,		--: in std_logic;
		po_addr_init				=> s_addr_init,					--: out std_logic_vector(1 downto 0);
		po_change					=> s_cycle							--: out std_logic
	);



	CPU_CMC_DATA_LAST_INST: entity work.cpu_cmc_mult_data_last generic map (
		g_lfsr						=> g_lfsr,							--: boolean := true;
		g_addr_width				=> g_addr_width					--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_data_last_start		=> s_data_last_start,			--: in std_logic;
		pi_my_size					=> s_my_size,						--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last					=> s_my_last,						--: in std_logic_vector(4 downto 0);
		pi_other_size				=> s_other_size,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last				=> s_other_last,					--: in std_logic_vector(4 downto 0);
		po_data_valid				=> s_valid,							--: out std_logic
		po_last						=> s_last							--: out std_logic
	);

	-----------------
	--   OUTPUTS   --
	-----------------

	po_cmc_addr_init_up <= s_addr_init;

	DATA_VALID_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,								--: natural := 64;
		g_delay				=> 3								--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_data(0)			=> s_valid,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_data_valid			--: out std_logic_vector(g_data_width-1 downto 0)
	);


	DATA_CYCLE_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,								--: natural := 64;
		g_delay				=> 2								--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_data(0)			=> s_cycle,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_data_cycle			--: out std_logic_vector(g_data_width-1 downto 0)
	);


	DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,								--: natural := 64;
		g_delay				=> 3								--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_data(0)			=> s_last,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_data_last_both	--: out std_logic_vector(g_data_width-1 downto 0)
	);

end architecture;
