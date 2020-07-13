-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_control_delay
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity cpu_cmc_mult_control_delay is
port(
	pi_clk										: in std_logic;

	pi_cmc_mult_start							: in std_logic;

	po_shutter_control_start				: out std_logic;
	po_shutter_former_mult_start			: out std_logic;
	po_size_converter_start					: out std_logic;
	po_data_last_start						: out std_logic;
	po_mult_cycler_pre_start				: out std_logic;
	po_mult_cycler_start						: out std_logic
);
end cpu_cmc_mult_control_delay;

architecture cpu_cmc_mult_control_delay of cpu_cmc_mult_control_delay is

	signal s_mult_stage_1_start						: std_logic;
	signal s_mult_stage_2_start						: std_logic;
	signal s_mult_stage_3_start						: std_logic;

begin

	po_size_converter_start <= s_mult_stage_1_start;
	po_shutter_control_start <= s_mult_stage_1_start;
	po_shutter_former_mult_start <= s_mult_stage_2_start;

	po_mult_cycler_pre_start <= s_mult_stage_2_start;
	po_mult_cycler_start <= s_mult_stage_3_start;

	po_data_last_start <= s_mult_stage_2_start;


	MULT_STAGE_1_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,								--: natural := 64;
		g_delay				=> 1								--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_data(0)			=> pi_cmc_mult_start,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> s_mult_stage_1_start		--: out std_logic_vector(g_data_width-1 downto 0)
	);


	MULT_STAGE_2_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,								--: natural := 64;
		g_delay				=> 1								--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_data(0)			=> s_mult_stage_1_start,	--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> s_mult_stage_2_start		--: out std_logic_vector(g_data_width-1 downto 0)
	);


	MULT_STAGE_3_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,								--: natural := 64;
		g_delay				=> 1								--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_data(0)			=> s_mult_stage_2_start,	--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> s_mult_stage_3_start		--: out std_logic_vector(g_data_width-1 downto 0)
	);

end architecture;
