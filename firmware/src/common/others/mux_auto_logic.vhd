-------------------------------------------
-- Auto-generated mux by mux_auto_logic.
-------------------------------------------
-- Program runs with the following parameters:
--		num_of_inputs:						16
--
-- The following paramers have been calculated:
--		num_of_stages:						1
--		num_of_address_bits:				4
-------------------------------------------

-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    4/8/2018
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mux_auto_logic
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity mux_auto_logic is
generic (
	g_latency		: natural
);
port(
	pi_clk					: in std_logic;

	pi_addr					: in std_logic_vector(3 downto 0);
	pi_data					: in std_logic_vector(15 downto 0);
	po_data					: out std_logic
);
end mux_auto_logic;

architecture mux_auto_logic of mux_auto_logic is

	constant THIS_BLOCK_LATENCY				: natural := 1;

	-- STAGE 0

begin

	LATENCY_TEST_GEN: if(THIS_BLOCK_LATENCY = g_latency) generate

	-- ==============================
	-- num_of_addr_bits:    4
	-- num_of_stages:       1
	-- num_of_inputs:       16
	-- ==============================

	-- ==============================
	-- STAGE_NUMBER:       0 (0 downto 0)
	-- num_of_inputs:      16
	-- num_of_rows:        1
	-- start_addr_address: 0
	-- addr_bits_width:    4
	-- ==============================


	MUX_0_0_INST: entity work.mux_16_1 generic map (
		g_registered_output		=> true		--: boolean := true
	)
	port map (
		pi_clk		=> pi_clk,		--: in std_logic;
		pi_addr		=> pi_addr(3 downto 0),		--: in std_logic_vector(3 downto 0);
		pi_data		=> pi_data(15 downto 0),		--: in std_logic_vector(15 downto 0);
		po_data		=> po_data		--: out std_logic
	);


	end generate;
end architecture;

