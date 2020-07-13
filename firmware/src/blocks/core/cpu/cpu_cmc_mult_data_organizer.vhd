-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_data_organizer
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

entity cpu_cmc_mult_data_organizer is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;

	pi_load						: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(4 downto 0);
	pi_other_size				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last				: in std_logic_vector(4 downto 0);

	po_my_size					: out std_logic_vector(g_addr_width-1 downto 0);
	po_my_last					: out std_logic_vector(4 downto 0);
	po_other_size				: out std_logic_vector(g_addr_width-1 downto 0);
	po_other_last				: out std_logic_vector(4 downto 0);

	po_my_size_minus_one		: out std_logic_vector(g_addr_width-1 downto 0);
	po_other_size_minus_one	: out std_logic_vector(g_addr_width-1 downto 0);

	po_one_limb					: out std_logic
);
end cpu_cmc_mult_data_organizer;

architecture cpu_cmc_mult_data_organizer of cpu_cmc_mult_data_organizer is

	signal s_one_limb_last			: std_logic_vector(1 downto 0);

begin

	---------------------
	-- 0 MODIFICATIONS --
	---------------------

	MY_SIZE_INST: entity work.ff generic map (
		g_data_width		=> g_addr_width				--: natural := 10
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> pi_my_size,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> po_my_size					--: out std_logic_vector(g_data_width-1 downto 0)
	);

	MY_LAST_INST: entity work.ff generic map (
		g_data_width		=> 5								--: natural := 10
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> pi_my_last,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> po_my_last					--: out std_logic_vector(g_data_width-1 downto 0)
	);


	OTHER_SIZE_INST: entity work.ff generic map (
		g_data_width		=> g_addr_width				--: natural := 10
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> pi_other_size,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> po_other_size				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	OTHER_LAST_INST: entity work.ff generic map (
		g_data_width		=> 5								--: natural := 10
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> pi_other_last,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> po_other_last				--: out std_logic_vector(g_data_width-1 downto 0)
	);



	----------------------
	-- -1 MODIFICATIONS --
	----------------------


	MY_COUNTER_MINUS_ONE_INST: entity work.lfsr_counter_minus_one generic map (
		g_lfsr				=> g_lfsr,						--: boolean := false;
		g_n					=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> pi_my_size,					--: in std_logic_vector(g_n-1 downto 0);
		po_data				=> po_my_size_minus_one		--: out std_logic_vector(g_n-1 downto 0)
	);


	OTHER_COUNTER_MINUS_ONE_INST: entity work.lfsr_counter_minus_one generic map (
		g_lfsr				=> g_lfsr,						--: boolean := false;
		g_n					=> g_addr_width				--: natural := 9
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> pi_other_size,				--: in std_logic_vector(g_n-1 downto 0);
		po_data				=> po_other_size_minus_one	--: out std_logic_vector(g_n-1 downto 0)
	);


	------------------
	--   ONE LIMB   --
	------------------

	s_one_limb_last <= pi_other_last(0) & pi_my_last(0);

	ONE_LIMB_FLAG_INST: entity work.or_ff generic map (
		g_data_width		=> 2
	)
	port map (
		pi_clk				=> pi_clk,						--: in std_logic;
		pi_load				=> pi_load,						--: in std_logic;
		pi_data				=> s_one_limb_last,			--: in std_logic_vector(g_dat_width-1 downto 0);
		po_data				=> po_one_limb					--: out std_logic
	);

end architecture;
