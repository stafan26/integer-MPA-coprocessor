-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_carry_add
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

entity mult_carry_add is
generic (
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_data								: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_cout						: in std_logic;
	pi_data_last						: in std_logic;
	pi_data_zero						: in std_logic;
	pi_data_all_ones					: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_zero						: out std_logic;
	po_data_wr_en						: out std_logic
);
end mult_carry_add;

architecture mult_carry_add of mult_carry_add is

	signal r_data_out										: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_incremented							: std_logic_vector(g_data_width-1 downto 0);
	signal r_data_incremented							: std_logic_vector(g_data_width-1 downto 0);
	signal r_data_cout									: std_logic;
	signal s_data_last									: std_logic;
	signal r_data_zero									: std_logic;
	signal s_data_zero									: std_logic;

	signal s_data_wr_en									: std_logic;

	signal r_incremented_to_zero						: std_logic;
	signal s_incremented_to_zero						: std_logic;
	signal r_incremented_to_one						: std_logic;

begin

	po_data <= r_data_out;
	po_data_last <= s_data_last;
	po_data_zero <= s_data_zero;
	po_data_wr_en <= s_data_wr_en;


	DATA_LAST_OUT_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY+2			--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_last,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_last					--: out std_logic_vector(g_data_width-1 downto 0)
	);


	DATA_ZERO_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY+1			--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> r_data_zero,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_zero					--: out std_logic_vector(g_data_width-1 downto 0)
	);


	WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY+2			--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_wr_en,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_wr_en				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	INCREMENTED_TO_ZERO_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY				--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,									--: in std_logic;
		pi_data(0)				=> r_incremented_to_zero,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_incremented_to_zero				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------------
			-- R_DATA_COUT --		2
			-----------------
			if(pi_rst = '1') then
				r_data_cout <= '0';
			else
				if(pi_data_wr_en = '1') then
					r_data_cout <= pi_data_cout;
				end if;
			end if;


			---------------------------
			-- R_INCREMENTED_TO_ZERO --		4
			---------------------------
			if(pi_data_wr_en = '1' and pi_data_all_ones = '1' and r_data_cout = '1') then
				r_incremented_to_zero <= '1';
			else
				r_incremented_to_zero <= '0';
			end if;


			-----------------
			-- R_DATA_ZERO --
			-----------------
			if(pi_data_wr_en = '1' and pi_data_all_ones = '1' and r_data_cout = '1') then		-- 1111 + 1
				r_data_zero <= '1';
			elsif(pi_data_wr_en = '1' and pi_data_all_ones = '0' and r_data_cout = '1') then		-- xxxx + 1
				r_data_zero <= '0';
			else
				r_data_zero <= pi_data_zero;
			end if;


			----------------
			-- R_DATA_OUT --		4
			----------------
			if(s_incremented_to_zero = '1') then
				r_data_out <= (others=>'0');
			else
				r_data_out <= r_data_incremented;
			end if;


			------------
			-- STREAM --		0
			------------
			r_data_incremented <= s_data_incremented;
			r_incremented_to_one <= s_incremented_to_zero;
		end if;
	end process;


	INCR_64_WO_COUT_INST: entity work.incr_64_wo_cout generic map (
		g_data_width	=> g_data_width								--: natural := 64
	)
	port map (
		CLK				=> pi_clk,										--: in std_logic;
		A					=> pi_data,										--: in std_logic_vector(g_data_width-1 downto 0);
		B					=> r_data_cout,								--: in std_logic;
		S					=> s_data_incremented						--: out std_logic_vector(g_data_width-1 downto 0);
	);

end architecture;
