-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    15/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_sync
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- fix the delays in data_delay instances
--
-------------------------------------------
-------------------------------------------

entity mult_sync is
port(
	pi_clk					: in std_logic;

	pi_data_last			: in std_logic;
	pi_cycle					: in std_logic;
	pi_wr_en					: in std_logic;

	po_switch_pre_acc		: out std_logic;
	po_switch_out			: out std_logic;

	po_data_last_out		: out std_logic;
	po_load_acc_1			: out std_logic;
	po_load_acc_2			: out std_logic;

	po_wr_en					: out std_logic
);
end mult_sync;

architecture mult_sync of mult_sync is

	signal r_load_acc_1									: std_logic;
	signal r_load_acc_2									: std_logic;

	signal r_data_last_prev								: std_logic;

	signal s_switch_pre_acc								: std_logic;
	signal r_switch_pre_acc								: std_logic;
	signal r_switch_pre_acc_prev						: std_logic;

	signal r_switch_out									: std_logic;

	signal r_wr_en_out									: std_logic;

	signal r_first											: std_logic;

begin

	po_switch_pre_acc <= s_switch_pre_acc;


	DATA_LAST_ACC_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,													--: natural := 1;
		g_delay					=> C_MULT_64_DELAY+C_MULT_64_ACC_DELAY+2	--: natural := 18
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data(0)				=> r_data_last_prev,								--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_data_last_out								--: out std_logic_vector(g_data_width-1 downto 0)
	);

	WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,													--: natural := 1;
		g_delay					=> C_MULT_64_DELAY+C_MULT_64_ACC_DELAY+1	--: natural := 17
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data(0)				=> r_wr_en_out,									--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_wr_en											--: out std_logic_vector(g_data_width-1 downto 0)
	);


	SWITCH_PRE_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_MULT_64_DELAY			--: natural := 17
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> r_switch_pre_acc,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_switch_pre_acc			--: out std_logic_vector(g_data_width-1 downto 0)
	);


	SWITCH_OUT_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,													--: natural := 1;
		g_delay					=> C_MULT_64_DELAY+C_MULT_64_ACC_DELAY+1	--: natural := 16
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data(0)				=> r_switch_out,									--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_switch_out									--: in std_logic_vector(g_data_width-1 downto 0)
	);


	LOAD_ACC_1_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_MULT_64_DELAY								--: natural := 18
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> r_load_acc_1,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_load_acc_1				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	LOAD_ACC_2_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_MULT_64_DELAY								--: natural := 18
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> r_load_acc_2,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_load_acc_2				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			r_data_last_prev <= pi_data_last;


			if(pi_cycle = '1' or pi_data_last = '1' or r_data_last_prev = '1') then
				r_wr_en_out <= '1';
			else
				r_wr_en_out <= '0';
			end if;



			if(pi_wr_en = '0' and r_data_last_prev = '0') then
				r_switch_pre_acc <= '0';
			elsif((pi_wr_en = '1' and pi_cycle = '1' and pi_data_last = '0')) then
				r_switch_pre_acc <= not r_switch_pre_acc;
			end if;


			if(pi_wr_en = '0' and r_data_last_prev = '0') then
				r_switch_out <= '0';
			elsif((pi_wr_en = '1' and pi_cycle = '1') or r_data_last_prev = '1') then
				r_switch_out <= not r_switch_out;
			end if;


			r_switch_pre_acc_prev <= r_switch_pre_acc;

			if(pi_wr_en = '0') then					-- RST
				r_first <= '1';
			else
				if(pi_data_last = '1') then
					r_first <= '1';
				else
					r_first <= '0';
				end if;
			end if;


			if((pi_wr_en = '1' and r_first = '1') or
			(r_switch_pre_acc_prev = '0' and r_switch_pre_acc = '1')) then
				r_load_acc_1 <= '1';
			else
				r_load_acc_1 <= '0';
			end if;

			if((pi_wr_en = '1' and r_first = '1') or
			(r_switch_pre_acc_prev = '1' and r_switch_pre_acc = '0')) then
				r_load_acc_2 <= '1';
			else
				r_load_acc_2 <= '0';
			end if;

		end if;
	end process;


end architecture;
