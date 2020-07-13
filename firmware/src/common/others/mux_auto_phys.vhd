-------------------------------------------
-- Auto-generated mux by mux_auto_phys.
-------------------------------------------
-- Program runs with the following parameters:
--		num_of_inputs:						17
--
-- The following paramers have been calculated:
--		num_of_stages:						2
--		num_of_address_bits:				5
-------------------------------------------

-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    17/8/2018
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mux_auto_phys
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mux_auto_phys is
generic (
	g_latency		: natural
);
port(
	pi_clk					: in std_logic;

	pi_addr					: in std_logic_vector(4 downto 0);
	pi_data					: in std_logic_vector(16 downto 0);
	po_data					: out std_logic
);
end mux_auto_phys;

architecture mux_auto_phys of mux_auto_phys is

	constant THIS_BLOCK_LATENCY				: natural := 2;

	-- STAGE 1
	signal s_data_1			 : std_logic_vector(4 downto 0);

	-- STAGE 0
	signal r_addr_0_0			 : std_logic_vector(2 downto 0);

begin

	LATENCY_TEST_GEN: if(THIS_BLOCK_LATENCY = g_latency) generate

	-- ==============================
	-- num_of_addr_bits:    5
	-- num_of_stages:       2
	-- num_of_inputs:       17
	-- ==============================

	ADDRESS_DELAYER_PROC: process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			r_addr_0_0 <= pi_addr(4 downto 2);

		end if;
	end process;

	-- ==============================
	-- STAGE_NUMBER:       1 (1 downto 0)
	-- num_of_inputs:      17
	-- num_of_rows:        5
	-- start_addr_address: 0
	-- addr_bits_width:    2
	-- ==============================


	MUX_1_0_INST: entity work.mux_4_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_addr		=> pi_addr(1 downto 0),		--: in std_logic_vector(1 downto 0);
		pi_data		=> pi_data(3 downto 0),		--: in std_logic_vector(3 downto 0);
		po_data		=> s_data_1(0)		--: out std_logic
	);

	MUX_1_1_INST: entity work.mux_4_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_addr		=> pi_addr(1 downto 0),		--: in std_logic_vector(1 downto 0);
		pi_data		=> pi_data(7 downto 4),		--: in std_logic_vector(3 downto 0);
		po_data		=> s_data_1(1)		--: out std_logic
	);

	MUX_1_2_INST: entity work.mux_4_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_addr		=> pi_addr(1 downto 0),		--: in std_logic_vector(1 downto 0);
		pi_data		=> pi_data(11 downto 8),		--: in std_logic_vector(3 downto 0);
		po_data		=> s_data_1(2)		--: out std_logic
	);

	MUX_1_3_INST: entity work.mux_4_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_addr		=> pi_addr(1 downto 0),		--: in std_logic_vector(1 downto 0);
		pi_data		=> pi_data(15 downto 12),		--: in std_logic_vector(3 downto 0);
		po_data		=> s_data_1(3)		--: out std_logic
	);

	MUX_1_4_INST: entity work.mux_1_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_data		=> pi_data(16 downto 16),		--: in std_logic_vector(0 downto 0);
		po_data		=> s_data_1(4)		--: out std_logic
	);


	-- ==============================
	-- STAGE_NUMBER:       0 (1 downto 0)
	-- num_of_inputs:      5
	-- num_of_rows:        1
	-- start_addr_address: 2
	-- addr_bits_width:    3
	-- ==============================


	MUX_0_0_INST: entity work.mux_5_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_addr		=> r_addr_0_0(2 downto 0),		--: in std_logic_vector(2 downto 0);
		pi_data		=> s_data_1(4 downto 0),		--: in std_logic_vector(4 downto 0);
		po_data		=> po_data		--: out std_logic
	);


	end generate;
end architecture;

