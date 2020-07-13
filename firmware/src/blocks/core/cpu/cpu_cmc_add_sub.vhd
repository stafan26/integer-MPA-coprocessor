-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_add_sub
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
-------------------------------------------
-------------------------------------------


entity cpu_cmc_add_sub is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;
	pi_rst						: in std_logic;

	pi_cmc_add_sub_start		: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(3 downto 0);
	pi_other_size				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last				: in std_logic_vector(3 downto 0);

	po_cmc_data_cycle			: out std_logic;
	po_cmc_data_valid			: out std_logic;
	po_cmc_data_last			: out std_logic_vector(1 downto 0);
	po_cmc_data_last_both	: out std_logic
);
end cpu_cmc_add_sub;

architecture cpu_cmc_add_sub of cpu_cmc_add_sub is

	signal s_cmc_data_valid				: std_logic;
	signal s_cmc_data_last				: std_logic_vector(1 downto 0);
	signal s_cmc_data_last_both		: std_logic;

begin

	CMC_DATA_CYCLE_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,											--: natural := 64;
		g_delay				=> 1											--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,									--: in std_logic;
		pi_data(0)			=> pi_cmc_add_sub_start,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_data_cycle						--: out std_logic_vector(g_data_width-1 downto 0)
	);


	CPU_CMC_ADD_SUB_DATA_LAST_INST: entity work.cpu_cmc_add_sub_data_last generic map (
		g_lfsr						=> g_lfsr,							--: boolean := true;
		g_addr_width				=> g_addr_width					--: natural := 9
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_start						=> pi_cmc_add_sub_start,		--: in std_logic;
		pi_my_size					=> pi_my_size,						--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last					=> pi_my_last,						--: in std_logic_vector(3 downto 0);
		pi_other_size				=> pi_other_size,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last				=> pi_other_last,					--: in std_logic_vector(3 downto 0);
		po_data_valid				=> s_cmc_data_valid,				--: out std_logic
		po_last						=> s_cmc_data_last,				--: out std_logic_vector(1 downto 0);
		po_last_both				=> s_cmc_data_last_both			--: out std_logic
	);

	CMC_DATA_VALID_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,											--: natural := 64;
		g_delay				=> 1											--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,									--: in std_logic;
		pi_data(0)			=> s_cmc_data_valid,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_data_valid						--: out std_logic_vector(g_data_width-1 downto 0)
	);

	CMC_DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 2,											--: natural := 64;
		g_delay				=> 1											--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,									--: in std_logic;
		pi_data				=> s_cmc_data_last,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> po_cmc_data_last						--: out std_logic_vector(g_data_width-1 downto 0)
	);

	CMC_DATA_LAST_BOTH_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,											--: natural := 64;
		g_delay				=> 1											--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,									--: in std_logic;
		pi_data(0)			=> s_cmc_data_last_both,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_data_last_both				--: out std_logic_vector(g_data_width-1 downto 0)
	);





end architecture;
