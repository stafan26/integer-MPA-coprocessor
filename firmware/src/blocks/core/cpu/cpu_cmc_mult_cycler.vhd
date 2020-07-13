-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_cycler
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity cpu_cmc_mult_cycler is generic (
	g_data_dir_path				: string := "dir";
	g_lfsr							: boolean := false;
	g_addr_width					: natural := 9
);
port (
	pi_clk							: in std_logic;
	pi_rst							: in std_logic;

	pi_mult_pre_start				: in std_logic;
	pi_mult_start					: in std_logic;

	pi_ultimate_last				: in std_logic;
	pi_one_limb						: in std_logic;
	pi_change_A						: in std_logic;
	pi_change_period_up			: in std_logic;
	pi_change_period_down_n		: in std_logic;
	po_addr_init					: out std_logic_vector(1 downto 0);
	po_change						: out std_logic
	);
end cpu_cmc_mult_cycler;

architecture cpu_cmc_mult_cycler of cpu_cmc_mult_cycler is

	signal s_rst_cycler									: std_logic;
	signal s_cmc_on										: std_logic;

	signal s_change_en									: std_logic;

	signal s_last											: std_logic;
	signal s_last_but_one								: std_logic;

	signal s_data											: std_logic_vector(g_addr_width-1 downto 0);
	signal s_data_last									: std_logic_vector(2 downto 0);
	signal s_cascade_last								: std_logic := '0';
	signal s_cascade_last_vec							: std_logic_vector(g_addr_width/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');

begin

	po_change <= s_change_en;


	LFSR_COUNTER_UP_DOWN_3_LAST_INST: entity work.lfsr_counter_up_down_3_last generic map (
		g_lfsr						=> g_lfsr,								--: boolean := false;
		g_n							=> g_addr_width						--: natural := 16
	)
	port map (
		pi_clk						=> pi_clk,								--: in std_logic;
		pi_rst						=> s_rst_cycler,						--: in std_logic;

		pi_change_en				=> s_change_en,						--: in std_logic;
		pi_change_up				=> pi_change_period_up,				--: in std_logic;
		pi_change_down_n			=> pi_change_period_down_n,		--: in std_logic;
		--pi_change_down_n_last	=> s_change_down_last,				--: in std_logic;

		pi_data_last				=> pi_ultimate_last,					--: in std_logic;

		po_data						=> s_data,								--: out std_logic_vector(g_addr_width-1 downto 0);
		po_data_last				=> s_data_last,						--: out std_logic_vector(2 downto 0);
		po_cascade_last			=> s_cascade_last,					--: out std_logic := '0';
		po_cascade_last_vec		=> s_cascade_last_vec				--: out std_logic_vector(g_addr_width/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0')
	);


	LFSR_COUNTER_DOWN_3_LAST_2_CAS_INST: entity work.lfsr_counter_down_3_last_2_cas generic map (
		g_lfsr						=> g_lfsr,							--: boolean := false;
		g_n							=> g_addr_width					--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> s_rst_cycler,					--: in std_logic;
		pi_load						=> s_change_en,					--: in std_logic;
		pi_data						=> s_data,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_last						=> s_data_last,					--: in std_logic_vector(2 downto 0);
		pi_cascade_last			=> s_cascade_last,				--: in std_logic := '0';
		pi_cascade_last_vec		=> s_cascade_last_vec,			--: in std_logic_vector(g_addr_width/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');
		pi_change					=> s_cmc_on,						--: in std_logic;
		po_last						=> s_last,							--: out std_logic;
		po_last_but_one			=> s_last_but_one					--: out std_logic
	);


	CPU_CMC_MULT_CYCLER_CTRL_INST: entity work.cpu_cmc_mult_cycler_ctrl port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_mult_pre_start			=> pi_mult_pre_start,			--: in std_logic;
		pi_mult_start				=> pi_mult_start,					--: in std_logic;
		pi_ultimate_last			=> pi_ultimate_last,				--: in std_logic;
		pi_one_limb					=> pi_one_limb,					--: in std_logic;
		pi_change_A					=> pi_change_A,					--: in std_logic;
		pi_last_but_one			=> s_last_but_one,				--: in std_logic;
		po_rst_cycler				=> s_rst_cycler,					--: out std_logic;
		po_cmc_on					=> s_cmc_on,						--: out std_logic;
		po_addr_init				=> po_addr_init,					--: out std_logic_vector(1 downto 0);
		po_change_en				=> s_change_en						--: out std_logic
	);

end architecture;
