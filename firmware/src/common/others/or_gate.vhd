-------------------------------------------
-- Auto-generated or_gate by or_gen.
-------------------------------------------
-- Program runs with the following parameters:
--		MAX_LUT_SIZE:						6
--		num_of_inputs:						17
--
-- The following paramers have been calculated:
--		num_of_stages:						2
-------------------------------------------

-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    24/12/2018
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    or_gate
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity or_gate is
generic (
	g_latency		: natural
);
port(
	pi_clk					: in std_logic;

	pi_data					: in std_logic_vector(16 downto 0);
	po_data					: out std_logic
);
end or_gate;

architecture or_gate of or_gate is

	constant THIS_BLOCK_LATENCY				: natural := 2;

	-- STAGE 2
	signal r_data_2			 : std_logic_vector(0 downto 0);

	-- STAGE 1
	signal r_data_1			 : std_logic_vector(5 downto 0);

begin

	LATENCY_TEST_GEN: if(THIS_BLOCK_LATENCY = g_latency) generate

		po_data <= r_data_2(0);				-- output port assignment

		OR_GATE_PROC: process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				-- ==============================
				-- stage number:        1
				-- num_of_rows:         6
				-- num_of_inputs:       17
				-- ==============================

				r_data_1(0) <= pi_data(0) or pi_data(1) or pi_data(2);
				r_data_1(1) <= pi_data(3) or pi_data(4) or pi_data(5);
				r_data_1(2) <= pi_data(6) or pi_data(7) or pi_data(8);
				r_data_1(3) <= pi_data(9) or pi_data(10) or pi_data(11);
				r_data_1(4) <= pi_data(12) or pi_data(13) or pi_data(14);
				r_data_1(5) <= pi_data(15) or pi_data(16);

				-- ==============================
				-- stage number:        2
				-- num_of_rows:         1
				-- num_of_inputs:       0
				-- ==============================

				r_data_2(0) <= r_data_1(0) or r_data_1(1) or r_data_1(2) or r_data_1(3) or r_data_1(4) or r_data_1(5);


			end if;
		end process;

	end generate;
end architecture;

