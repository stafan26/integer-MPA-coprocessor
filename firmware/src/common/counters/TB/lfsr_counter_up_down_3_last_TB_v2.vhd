-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    lfsr_counter_up_down_3_last_TB_v2
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity lfsr_counter_up_down_3_last_TB_v2 is generic (
	g_data_dir_path		: string
);
end lfsr_counter_up_down_3_last_TB_v2;

architecture lfsr_counter_up_down_3_last_TB_v2 of lfsr_counter_up_down_3_last_TB_v2 is

	constant c_lfsr										: boolean := false;
	constant c_n											: natural := 9;
	constant c_cnt_sm_lock								: boolean := false;
	constant c_cnt_sm_min								: natural := 2;
	constant c_cnt_gt_max								: natural := 9;

	type fsm_type is (
						FSM_WAIT,
						FSM_ASSIGN,
						FSM_START,
						FSM_AWAIT_CYCLE,
						FSM_BRANCH,
						FSM_DONE
					);

	signal fsm_state										: fsm_type;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;
	signal r_rst_cycler									: std_logic;
	signal r_dma_start									: std_logic;
	signal r_dma_on										: std_logic;

	signal r_cnt											: natural;
	signal r_cnt_data										: natural;

	signal r_cnt_last										: natural;
	signal s_cnt_last_fl									: std_logic;

	signal r_cnt_sm										: natural;
	signal r_cnt_sm_tmp									: natural;
	signal r_cnt_gt										: natural;
	signal r_cnt_gt_tmp									: natural;

	signal r_change_en									: std_logic;
	signal s_change_up									: std_logic;
	signal s_change_down_n								: std_logic;
	--signal s_change_down_last							: std_logic;

	signal r_first											: std_logic;
	signal r_zero											: std_logic;
	signal s_last											: std_logic;
	signal s_last_but_one								: std_logic;

	signal s_data											: std_logic_vector(c_n-1 downto 0);
	signal s_data_last									: std_logic_vector(2 downto 0);
	signal s_cascade_last								: std_logic := '0';
	signal s_cascade_last_vec							: std_logic_vector(c_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');

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
		wait for 200ns;
		r_rst <= '0';
		wait;
	end process;


	LFSR_COUNTER_UP_DOWN_3_LAST_INST: entity work.lfsr_counter_up_down_3_last generic map (
		g_lfsr						=> c_lfsr,								--: boolean := false;
		g_n							=> c_n									--: natural := 16
	)
	port map (
		pi_clk						=> r_clk,								--: in std_logic;
		pi_rst						=> r_rst_cycler,						--: in std_logic;

		pi_change_en				=> r_change_en,						--: in std_logic;
		pi_change_up				=> s_change_up,						--: in std_logic;
		pi_change_down_n			=> s_change_down_n,					--: in std_logic;
		--pi_change_down_n_last	=> s_change_down_last,				--: in std_logic;

		pi_data_last				=> s_cnt_last_fl,						--: in std_logic;

		po_data						=> s_data,								--: out std_logic_vector(g_n-1 downto 0);
		po_data_last				=> s_data_last,						--: out std_logic_vector(2 downto 0);
		po_cascade_last			=> s_cascade_last,					--: out std_logic := '0';
		po_cascade_last_vec		=> s_cascade_last_vec				--: out std_logic_vector(g_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0')
	);


	LFSR_COUNTER_DOWN_3_LAST_2_CAS_INST: entity work.lfsr_counter_down_3_last_2_cas generic map (
		g_lfsr						=> c_lfsr,							--: boolean := false;
		g_n							=> c_n								--: natural := 9
	)
	port map (
		pi_clk						=> r_clk,							--: in std_logic;
		pi_rst						=> r_rst_cycler,					--: in std_logic;
		pi_load						=> r_change_en,					--: in std_logic;
		pi_data						=> s_data,							--: in std_logic_vector(g_n-1 downto 0);
		pi_last						=> s_data_last,					--: in std_logic_vector(2 downto 0);
		pi_cascade_last			=> s_cascade_last,				--: in std_logic := '0';
		pi_cascade_last_vec		=> s_cascade_last_vec,			--: in std_logic_vector(g_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0');
		pi_change					=> r_dma_on,						--: in std_logic;
		po_last						=> s_last,							--: out std_logic;
		po_last_but_one			=> s_last_but_one					--: out std_logic
	);


	process(r_clk)
	begin

		if(rising_edge(r_clk)) then

			--------------
			-- R_DMA_ON --
			--------------
			if(r_rst = '1') then
				r_dma_on <= '0';
			else

				if(r_dma_start = '1') then
					r_dma_on <= '1';
				elsif(s_cnt_last_fl = '1') then
					r_dma_on <= '0';
				end if;

			end if;

			------------
			-- R_ZERO --
			------------
			if(r_rst = '1') then
				r_zero <= '0';
			else

				if(r_dma_start = '1' and s_change_up = '0') then
					r_zero <= '1';
				elsif(s_cnt_last_fl = '1') then
					r_zero <= '0';
				end if;

			end if;


			-------------
			-- R_FIRST --
			-------------
			if(r_rst = '1') then
				r_first <= '0';
			else

				if(r_dma_start = '1') then
					r_first <= '1';
				elsif(s_change_up = '1') then
					r_first <= '0';
				end if;

			end if;


			-----------------
			-- R_CHANGE_EN --
			-----------------
			if(r_dma_start = '1' or					-- start
			r_zero = '1' or							-- for 1 limb
			r_first = '1' or							-- ??
			s_last_but_one = '1') then				-- for 2 or more limbs
				r_change_en <= '1';
			else
				r_change_en <= '0';
			end if;

		end if;
	end process;




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
	--s_change_down_last <= '1' when r_cnt_gt_tmp = 1 else '0';


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			if(r_rst = '0' and r_rst_cycler = '0') then

				if(r_change_en = '1') then
					if(r_cnt_sm_tmp /= 0) then
						r_cnt_sm_tmp <= r_cnt_sm_tmp - 1;
					end if;

					if(r_cnt_gt_tmp /= 0) then
						r_cnt_gt_tmp <= r_cnt_gt_tmp - 1;
					end if;
				end if;

			end if;


			r_dma_start <= '0';

			if(r_rst = '1') then
				fsm_state <= FSM_WAIT;
				r_rst_cycler <= '1';
				r_cnt <= 10;
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
						r_dma_start <= '1';


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
