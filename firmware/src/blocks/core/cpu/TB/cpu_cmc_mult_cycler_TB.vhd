-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_mult_cycler_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cmc_mult_cycler_TB is generic (
	g_data_dir_path			: string := "dir"
);
end cpu_cmc_mult_cycler_TB;

architecture cpu_cmc_mult_cycler_TB of cpu_cmc_mult_cycler_TB is

	constant c_cnt_sm_lock								: boolean := false;
	constant c_cnt_sm_min								: natural := 2;
	constant c_cnt_gt_max								: natural := 9;

	signal r_cnt_sm										: natural;
	signal r_cnt_sm_tmp									: natural;
	signal r_cnt_gt										: natural;
	signal r_cnt_gt_tmp									: natural;

	signal r_rst_cycler									: std_logic;

	signal r_cnt_last										: natural;
	signal s_cnt_last_fl									: std_logic;

	type fsm_type is (
						FSM_WAIT,
						FSM_ASSIGN,
						FSM_START,
						FSM_AWAIT_CYCLE,
						FSM_BRANCH,
						FSM_DONE
					);

	signal fsm_state										: fsm_type;

	constant c_lfsr										: boolean := true;
	constant c_addr_width								: natural := 9;

	constant c_my_size_cnt								: natural := 1;
	constant c_other_size_cnt							: natural := 6;

	constant c_delay										: natural := 20;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_mult_pre										: std_logic;
	signal r_mult											: std_logic;

	signal r_cnt											: integer;

--	signal r_mult_data_last								: std_logic;
	signal s_change_en									: std_logic;
	signal s_change_up									: std_logic;
	signal r_change_up									: std_logic;
	signal s_change_down_n								: std_logic;
	signal r_change_down_n								: std_logic;

begin

	process
	begin
		r_clk <= '1';
		wait for 5ns;
		r_clk <= '0';
		wait for 5ns;
	end process;


	process
	begin
		r_rst <= '1';
		wait for 555ns;
		r_rst <= '0';
		wait;
	end process;


	CPU_CMC_MULT_CYCLER_INST: entity work.cpu_cmc_mult_cycler generic map (
		g_lfsr					=> c_lfsr,						--: boolean := false;
		g_addr_width			=> c_addr_width				--: natural := 9
	)
	port map (
		pi_clk					=> r_clk,						--: in std_logic;
		pi_rst					=> r_rst,						--: in std_logic;
		pi_mult_pre_start		=> r_mult_pre,					--: in std_logic;
		pi_mult_start			=> r_mult,						--: in std_logic;
		pi_ultimate_last		=> s_cnt_last_fl,				--: in std_logic;
		pi_change_up			=> s_change_up,				--: in std_logic;
		pi_change_down_n		=> s_change_down_n,			--: in std_logic;
		po_change				=> s_change_en					--: out std_logic
	);



	s_cnt_last_fl <= '1' when r_cnt_last = 0 else '0';


	LAST_PORTION_PROC: process(r_clk)
	begin

		if(rising_edge(r_clk)) then

			----------------
			-- R_CNT_LAST --
			----------------
			if(r_rst_cycler = '1') then
				r_cnt_last <= r_cnt_sm * r_cnt_gt;
			else

				if(r_cnt_last /= 0) then
					r_cnt_last <= r_cnt_last - 1;
				end if;

			end if;

		end if;
	end process;




	s_change_up <= '1' when r_cnt_sm_tmp > 0 else '0';
	s_change_down_n <= '1' when r_cnt_gt_tmp > 0 else '0';


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_mult <= r_mult_pre;

			r_change_up <= s_change_up;
			r_change_down_n <= s_change_down_n;

			if(r_rst = '0' and r_rst_cycler = '0') then

				if(s_change_en = '1') then
					if(r_cnt_sm_tmp /= 0) then
						r_cnt_sm_tmp <= r_cnt_sm_tmp - 1;
					end if;

					if(r_cnt_gt_tmp /= 0) then
						r_cnt_gt_tmp <= r_cnt_gt_tmp - 1;
					end if;
				end if;

			end if;


			r_mult_pre <= '0';

			if(r_rst = '1') then
				fsm_state <= FSM_WAIT;
				r_rst_cycler <= '1';
				r_cnt <= c_delay;
				r_cnt_gt <= c_cnt_sm_min;
				r_cnt_sm <= c_cnt_sm_min;

			else

				case fsm_state is

					when FSM_WAIT =>
						if(r_cnt = 0) then
							fsm_state <= FSM_ASSIGN;
						else
							r_cnt <= r_cnt - 1;
						end if;


					when FSM_ASSIGN =>
						fsm_state <= FSM_START;
						r_cnt_gt_tmp <= r_cnt_gt-1;
						r_cnt_sm_tmp <= r_cnt_sm-1;


					when FSM_START =>
						fsm_state <= FSM_AWAIT_CYCLE;
						r_rst_cycler <= '0';
						r_mult_pre <= '1';


					when FSM_AWAIT_CYCLE =>
						if(s_cnt_last_fl = '1') then
							fsm_state <= FSM_BRANCH;
							r_rst_cycler <= '1';

						end if;


					when FSM_BRANCH =>
						if((c_cnt_sm_lock = false and r_cnt_sm = r_cnt_gt and r_cnt_gt = c_cnt_gt_max) or
						(c_cnt_sm_lock = true and r_cnt_sm = c_cnt_sm_min and r_cnt_gt = c_cnt_gt_max)) then
							fsm_state <= FSM_DONE;
						else
							fsm_state <= FSM_WAIT;
							r_cnt <= 10;
							if(c_cnt_sm_lock = false and r_cnt_sm < r_cnt_gt) then
								r_cnt_sm <= r_cnt_sm + 1;
							else
								r_cnt_gt <= r_cnt_gt + 1;
								r_cnt_sm <= c_cnt_sm_min;
							end if;
						end if;


					when FSM_DONE =>


				end case;

			end if;

		end if;
	end process;

end architecture;
