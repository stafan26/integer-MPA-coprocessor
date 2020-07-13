-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    multiplier
-- Module Name:    cpu_cmc_mult_size_converter
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

use work.my_pack.all;
use work.common_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- limit r_sm_last input signals from 8 to 6
--
-------------------------------------------
-------------------------------------------

entity cpu_cmc_mult_size_converter is
generic (
	g_lfsr							: boolean := true;
	g_addr_width					: natural := 10
);
port (
	pi_clk							: in std_logic;
	pi_rst							: in std_logic;
	pi_start							: in std_logic;
	pi_my_size_minus_one			: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last						: in std_logic_vector(4 downto 0);
	pi_other_size_minus_one		: in std_logic_vector(g_addr_width-1 downto 0);
	pi_other_last					: in std_logic_vector(4 downto 0);

	pi_taken							: in std_logic;

	po_my_last_n					: out std_logic;
	po_sm_last_period_n			: out std_logic;
	po_gr_last_period_n			: out std_logic
);
end cpu_cmc_mult_size_converter;

architecture cpu_cmc_mult_size_converter of cpu_cmc_mult_size_converter is

	constant c_tap							: tap_vector := select_tap(g_addr_width);
	constant c_tap_rev					: tap_vector := reverse_tap(c_tap);

	constant c_value_init				: natural := 4;
	constant c_value						: natural := 5;

	constant c_ctrl_num_of_parts		: natural := g_addr_width / C_MAX_NUM_OF_IN_PER_MUX;
	constant c_ctrl_part_width			: natural := g_addr_width / c_ctrl_num_of_parts;

	constant c_last_zero					: std_logic_vector(4 downto 0) := (others=>'0');

	signal s_value_init					: std_logic_vector(g_addr_width-1 downto 0);
	signal s_value							: std_logic_vector(g_addr_width-1 downto 0);

	signal r_start							: std_logic;

	signal s_my_cnt						: std_logic_vector(g_addr_width-1 downto 0);
	signal r_my_cnt						: std_logic_vector(g_addr_width-1 downto 0);
	signal s_other_cnt					: std_logic_vector(g_addr_width-1 downto 0);
	signal r_other_cnt					: std_logic_vector(g_addr_width-1 downto 0);

	signal r_my_last						: std_logic_vector(4 downto 0);
	signal r_my_last_long				: std_logic;
	signal r_my_last_long_init			: std_logic;

	signal r_other_last					: std_logic_vector(4 downto 0);
	signal r_other_last_long			: std_logic;
	signal r_other_last_long_init		: std_logic;

	signal r_my_short						: std_logic;
	signal r_other_short					: std_logic;

	signal s_my_cnt_feedback_rev		: std_logic;
	signal s_other_cnt_feedback_rev	: std_logic;

	signal r_my_done						: std_logic;
	signal r_other_done					: std_logic;

	signal s_my_last_vec_init			: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_my_last_vec_init			: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal s_other_last_vec_init		: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_other_last_vec_init		: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);

	signal s_my_last_vec					: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_my_last_vec					: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal s_other_last_vec				: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_other_last_vec				: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);

	signal r_sm_last_combined			: std_logic;

	signal r_sm_last_init				: std_logic_vector(2 downto 0);
	signal r_gr_last_init				: std_logic_vector(2 downto 0);

	signal r_my_up							: std_logic;

	signal r_sm_up_period				: std_logic;
	signal r_sm_last						: std_logic_vector(2 downto 0);
	signal r_sm_last_done_pre			: std_logic;
	signal r_sm_last_done_post			: std_logic;

	signal r_gr_up							: std_logic;
	signal r_gr_up_period				: std_logic;
	signal r_gr_last						: std_logic_vector(2 downto 0);

	signal r_sm_gr_last_and				: std_logic;
	signal r_sm_last_dly					: std_logic;

begin

	po_my_last_n <= r_my_up;

	po_sm_last_period_n <= r_sm_up_period;
	po_gr_last_period_n <= r_gr_up_period;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		s_value_init <= to_std_logic_vector(c_value_init, g_addr_width);
		s_value <= to_std_logic_vector(c_value, g_addr_width);
		s_my_cnt <= r_my_cnt - 1;
		s_other_cnt <= r_other_cnt - 1;
	end generate;

	LFSR_CNT_GEN: if(g_lfsr = true) generate
		s_value_init <= to_lfsr(c_value_init, g_addr_width);
		s_value <= to_lfsr(c_value, g_addr_width);

		-- REPHRASING: s_my_cnt <= r_my_cnt - 1;
		s_my_cnt <= s_my_cnt_feedback_rev & r_my_cnt(g_addr_width-1 downto 1);

		MY_CNT_FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_my_cnt_feedback_rev <= r_my_cnt(c_tap_rev(0)-1) xor r_my_cnt(c_tap_rev(1)-1) xor r_my_cnt(c_tap_rev(2)-1) xor r_my_cnt(c_tap_rev(3)-1);
		end generate;

		MY_CNT_TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_my_cnt_feedback_rev <= r_my_cnt(c_tap_rev(2)-1) xor r_my_cnt(c_tap_rev(3)-1);
		end generate;


		-- REPHRASING: s_other_cnt <= r_other_cnt - 1;
		s_other_cnt <= s_other_cnt_feedback_rev & r_other_cnt(g_addr_width-1 downto 1);

		OTHER_CNT_FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_other_cnt_feedback_rev <= r_other_cnt(c_tap_rev(0)-1) xor r_other_cnt(c_tap_rev(1)-1) xor r_other_cnt(c_tap_rev(2)-1) xor r_other_cnt(c_tap_rev(3)-1);
		end generate;

		OTHER_CNT_TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_other_cnt_feedback_rev <= r_other_cnt(c_tap_rev(2)-1) xor r_other_cnt(c_tap_rev(3)-1);
		end generate;
	end generate;


	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then

		------------
		-- INPUTS --
		------------

			r_start <= pi_start;

			----------------
			-- R_MY_SHORT --
			----------------
			if(pi_start = '1') then				-- CE

				if(pi_my_last /= c_last_zero) then
					r_my_short <= '1';
				else
					r_my_short <= '0';
				end if;
			end if;


			------------------------
			-- R_MY_LAST_VEC_INIT --
			------------------------
			if(pi_taken = '1') then
				r_my_last_vec_init <= (others=>'0');
			elsif(pi_start = '1') then
				r_my_last_vec_init <= s_my_last_vec_init;
			end if;


			-------------------
			-- R_MY_LAST_VEC --
			-------------------
			if(pi_taken = '1') then
				r_my_last_vec <= s_my_last_vec;
			end if;


			--------------
			-- R_MY_CNT --
			--------------
			if(pi_start = '1') then
				r_my_cnt <= pi_my_size_minus_one;
			elsif(r_my_done = '0' and pi_taken = '1') then
				r_my_cnt <= s_my_cnt;
			end if;


			---------------
			-- R_MY_LAST --
			---------------
			if(pi_start = '1') then
				r_my_last <= pi_my_last;
			elsif(pi_taken = '1' and (r_my_last_long_init = '1' or r_my_last_long = '1')) then
				r_my_last <= (3=>'1',others=>'0');
			elsif(pi_taken = '1') then
				r_my_last <= '0' & r_my_last(r_my_last'length-1 downto 1);
			end if;


			-------------------------
			-- R_MY_LAST_LONG_INIT --
			-------------------------
			if(pi_rst = '1') then
				r_my_last_long_init <= '0';
			else

				if(pi_taken = '1') then					-- CE

					if(r_my_short = '0' and and_reduce(r_my_last_vec_init) = '1') then
						r_my_last_long_init <= '1';
					else
						r_my_last_long_init <= '0';
					end if;

				end if;

			end if;


			--------------------
			-- R_MY_LAST_LONG --
			--------------------
			if(pi_rst = '1') then
				r_my_last_long <= '0';
			else

				if(pi_taken = '1') then					-- CE

					if(r_my_last_long_init = '0' and r_my_short = '0' and and_reduce(r_my_last_vec) = '1') then
						r_my_last_long <= '1';
					else
						r_my_last_long <= '0';
					end if;

				end if;

			end if;


			---------------
			-- R_MY_DONE --
			---------------
			if(pi_rst = '1') then
				r_my_done <= '1';
			elsif(pi_start = '1') then
				r_my_done <= '0';
			elsif(r_my_last(0) = '1' and pi_taken = '1') then
				r_my_done <= '1';
			end if;


			-------------------
			-- R_OTHER_SHORT --
			-------------------
			if(pi_start = '1') then				-- CE

				if(pi_other_last /= c_last_zero) then
					r_other_short <= '1';
				else
					r_other_short <= '0';
				end if;

			end if;


			---------------------------
			-- R_OTHER_LAST_VEC_INIT --
			---------------------------
			if(pi_taken = '1') then
				r_other_last_vec_init <= (others=>'0');
			elsif(pi_start = '1') then
				r_other_last_vec_init <= s_other_last_vec_init;
			end if;


			----------------------
			-- R_OTHER_LAST_VEC --
			----------------------
			if(pi_taken = '1') then
				r_other_last_vec <= s_other_last_vec;
			end if;


			-----------------
			-- R_OTHER_CNT --
			-----------------
			if(pi_start = '1') then
				r_other_cnt <= pi_other_size_minus_one;
			elsif(r_other_done = '0' and pi_taken = '1') then
				r_other_cnt <= s_other_cnt;
			end if;


			------------------
			-- R_OTHER_LAST --
			------------------
			if(pi_start = '1') then
				r_other_last <= pi_other_last;
			elsif(pi_taken = '1' and (r_other_last_long_init = '1' or r_other_last_long = '1')) then
				r_other_last <= (3=>'1',others=>'0');
			elsif(pi_taken = '1') then
				r_other_last <= '0' & r_other_last(r_other_last'length-1 downto 1);
			end if;


			----------------------------
			-- R_OTHER_LAST_LONG_INIT --
			----------------------------
			if(pi_rst = '1') then
				r_other_last_long_init <= '0';
			else

				if(pi_taken = '1') then					-- CE

					if(r_other_short = '0' and and_reduce(r_other_last_vec_init) = '1') then
						r_other_last_long_init <= '1';
					else
						r_other_last_long_init <= '0';
					end if;

				end if;

			end if;


			-----------------------
			-- R_OTHER_LAST_LONG --
			-----------------------
			if(pi_rst = '1') then
				r_other_last_long <= '0';
			else

				if(pi_taken = '1') then					-- CE

					if(r_other_last_long = '0' and r_other_short = '0' and and_reduce(r_other_last_vec) = '1') then
						r_other_last_long <= '1';
					else
						r_other_last_long <= '0';
					end if;

				end if;

			end if;


			------------------
			-- R_OTHER_DONE --
			------------------
			if(pi_rst = '1') then
				r_other_done <= '1';
			elsif(pi_start = '1') then
				r_other_done <= '0';
			elsif(r_other_last(0) = '1' and pi_taken = '1') then
				r_other_done <= '1';
			end if;


		-------------
		-- OUTPUTS --
		-------------

			-------------
			-- R_MY_UP --
			-------------
			if(pi_rst = '1') then
				r_my_up <= '1';
			else

				if(r_start = '1') then
					r_my_up <= '1';
				--elsif(pi_taken = '1' and (r_sm_last(0) = '1' or r_gr_last(0) = '1')) then
				elsif(pi_taken = '1' and r_my_last(0) = '1') then
					r_my_up <= '0';
				end if;

			end if;


			--------------------
			-- R_SM_UP_PERIOD --
			--------------------
			if(pi_rst = '1') then
				r_sm_up_period <= '1';
			else

				if(r_start = '1') then
					r_sm_up_period <= '1';
				elsif(pi_taken = '1' and (r_sm_last(1) = '1' or r_gr_last(1) = '1')) then
					r_sm_up_period <= '0';
				end if;

			end if;


			-------------------------
			-- R_SM_LAST_DONE_POST --
			-------------------------
			if(pi_start = '1') then
				r_sm_last_done_post <= '0';
			elsif(pi_taken = '1' and (r_sm_last(1) = '1' or r_gr_last(1) = '1')) then
				r_sm_last_done_post <= '1';
			end if;


			------------------------
			-- R_SM_LAST_DONE_PRE --
			------------------------
			if(r_start = '1' and r_sm_last_combined = '0') then
				r_sm_last_done_pre <= '0';
			elsif(r_start = '1' and r_sm_last_combined = '1') then
				r_sm_last_done_pre <= '1';
			elsif(pi_taken = '1' and (r_my_last(3) = '1' or r_other_last(3) = '1' or r_sm_last(0) = '1')) then
				r_sm_last_done_pre <= '1';
			end if;


			-------------
			-- R_GR_UP --			-- dla nierownych blisko siebie, np.: (7 i 6) lub (7 i 8)
			-------------
			if(pi_rst = '1') then
				r_gr_up <= '1';
			else

				if(r_start = '1') then
					r_gr_up <= '1';
				elsif((pi_taken = '1' and r_sm_last(0) = '1' and r_gr_last(0) = '1') or
						(pi_taken = '1' and r_sm_last_done_post = '1' and (r_sm_last(0) = '1' or r_gr_last(0) = '1'))) then
					r_gr_up <= '0';
				end if;

			end if;


			----------------------
			-- R_SM_GR_LAST_AND --			5
			----------------------
			if(pi_rst = '1') then
				r_sm_gr_last_and <= '0';
			else
				if(r_start = '1') then
					r_sm_gr_last_and <= '0';
				elsif(pi_taken = '1' and r_sm_last(2) = '1' and r_gr_last(2) = '1') then
					r_sm_gr_last_and <= '1';
				elsif(pi_taken = '1') then
					r_sm_gr_last_and <= '0';
				end if;
			end if;


			--------------------
			-- R_GR_UP_PERIOD --
			--------------------
			if(pi_rst = '1') then
				r_gr_up_period <= '1';
			else

				if(r_start = '1') then
					r_gr_up_period <= '1';
				elsif((pi_taken = '1' and r_sm_gr_last_and = '1') or
						(pi_taken = '1' and r_sm_last_done_post = '1' and r_gr_last(1) = '1')) then
					r_gr_up_period <= '0';
				end if;

			end if;


			-------------------
			-- R_SM_LAST_DLY --
			-------------------
			if(pi_rst = '1') then
				r_sm_last_dly <= '0';
			else
				if(pi_taken = '1') then
					r_sm_last_dly <= r_sm_last(0);
				end if;
			end if;

			--------------------
			-- R_SM_LAST_INIT --
			--------------------
			if(pi_start = '1') then			-- CE
				r_sm_last_init(0) <= (pi_my_last(0) or pi_other_last(0));
				r_sm_last_init(1) <= (pi_my_last(1) or pi_other_last(1)) and not (pi_my_last(0) or pi_other_last(0));
				r_sm_last_init(2) <= (pi_my_last(2) or pi_other_last(2)) and not (pi_my_last(0) or pi_other_last(0)) and not (pi_my_last(1) or pi_other_last(1));
			end if;

			------------------------
			-- R_SM_LAST_COMBINED --
			------------------------
			if(pi_start = '0') then
				r_sm_last_combined <= '0';
			else
				r_sm_last_combined <=	pi_my_last(2) or pi_other_last(2) or
												pi_my_last(1) or pi_other_last(1) or
												pi_my_last(0) or pi_other_last(0);
			end if;

			--------------------
			-- R_GR_LAST_INIT --
			--------------------
			if(pi_start = '1') then			-- CE
				r_gr_last_init(0) <= (pi_my_last(0) and pi_other_last(0));
				r_gr_last_init(1) <= (pi_my_last(1) and pi_other_last(1)) or ((pi_my_last(1) or pi_other_last(1)) and (pi_my_last(0) or pi_other_last(0)));
				r_gr_last_init(2) <= (pi_my_last(2) and pi_other_last(2)) or ((pi_my_last(2) or pi_other_last(2)) and (pi_my_last(0) or pi_other_last(0) or pi_my_last(1) or pi_other_last(1)));
			end if;


			---------------
			-- R_SM_LAST --
			---------------
			if(pi_rst = '1') then
				r_sm_last <= (others=>'0');
			else

				if(r_start = '1') then
					r_sm_last <= r_sm_last_init;
				elsif(pi_taken = '1' and r_sm_last_done_pre = '0' and (r_my_last(3) = '1' or r_other_last(3) = '1')) then
					r_sm_last <= '1' & r_sm_last(r_sm_last'length-1 downto 1);
				elsif(pi_taken = '1') then
					r_sm_last <= '0' & r_sm_last(r_sm_last'length-1 downto 1);
				end if;

			end if;


			---------------
			-- R_GR_LAST --
			---------------
			if(pi_rst = '1') then
				r_gr_last <= (others=>'0');
			else

				if(r_start = '1') then
					r_gr_last <= r_gr_last_init;
				elsif((pi_taken = '1' and r_sm_last_done_pre = '1' and (r_my_last(3) = '1' or r_other_last(3) = '1')) or
						(pi_taken = '1' and r_sm_last_done_pre = '0' and (r_my_last(3) = '1' and r_other_last(3) = '1'))) then
					r_gr_last <= '1' & r_gr_last(r_gr_last'length-1 downto 1);
				elsif(pi_taken = '1') then
					r_gr_last <= '0' & r_gr_last(r_gr_last'length-1 downto 1);
				end if;

			end if;


		end if;

	end process;


	-------------------
	-- LAST DETECTOR --
	-------------------
	NOP_HIGHER_GEN: for i in 0 to c_ctrl_num_of_parts-1 generate

		ZERO_BIT_GEN: if(i = 0) generate
			PART_NOT_EQUAL_GEN: if(c_ctrl_part_width < g_addr_width) generate
				s_my_last_vec_init(0) <= '1' when pi_my_size_minus_one(c_ctrl_part_width-1 downto 0) = s_value_init(c_ctrl_part_width-1 downto 0) else '0';
				s_other_last_vec_init(0) <= '1' when pi_other_size_minus_one(c_ctrl_part_width-1 downto 0) = s_value_init(c_ctrl_part_width-1 downto 0) else '0';

				s_my_last_vec(0) <= '1' when r_my_cnt(c_ctrl_part_width-1 downto 0) = s_value(c_ctrl_part_width-1 downto 0) else '0';
				s_other_last_vec(0) <= '1' when r_other_cnt(c_ctrl_part_width-1 downto 0) = s_value(c_ctrl_part_width-1 downto 0) else '0';
			end generate;

			PART_EQUAL_GEN: if(c_ctrl_part_width >= g_addr_width) generate
				s_my_last_vec_init(0) <= '1' when pi_my_size_minus_one = s_value_init else '0';
				s_other_last_vec_init(0) <= '1' when pi_other_size_minus_one = s_value_init else '0';

				s_my_last_vec(0) <= '1' when r_my_cnt = s_value else '0';
				s_other_last_vec(0) <= '1' when r_other_cnt = s_value else '0';
			end generate;
		end generate;

		GT_ZERO_GEN: if(i > 0) generate
			NOP_LAST_GEN: if(i = c_ctrl_num_of_parts-1) generate
				s_my_last_vec_init(i) <= '1' when pi_my_size_minus_one(pi_my_size_minus_one'length-1 downto i*c_ctrl_part_width) = s_value_init(pi_my_size_minus_one'length-1 downto i*c_ctrl_part_width) else '0';
				s_other_last_vec_init(i) <= '1' when pi_other_size_minus_one(pi_other_size_minus_one'length-1 downto i*c_ctrl_part_width) = s_value_init(pi_other_size_minus_one'length-1 downto i*c_ctrl_part_width) else '0';

				s_my_last_vec(i) <= '1' when r_my_cnt(r_my_cnt'length-1 downto i*c_ctrl_part_width) = s_value(r_my_cnt'length-1 downto i*c_ctrl_part_width) else '0';
				s_other_last_vec(i) <= '1' when r_other_cnt(r_other_cnt'length-1 downto i*c_ctrl_part_width) = s_value(r_other_cnt'length-1 downto i*c_ctrl_part_width) else '0';
			end generate;

			NOP_NOT_LAST_GEN: if(i /= c_ctrl_num_of_parts-1) generate
				s_my_last_vec_init(i) <= '1' when pi_my_size_minus_one(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) = s_value_init(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) else '0';
				s_other_last_vec_init(i) <= '1' when pi_other_size_minus_one(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) = s_value_init(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) else '0';

				s_my_last_vec(i) <= '1' when r_my_cnt(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) = s_value(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) else '0';
				s_other_last_vec(i) <= '1' when r_other_cnt(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) = s_value(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) else '0';
			end generate;
		end generate;

	end generate;

end architecture;
