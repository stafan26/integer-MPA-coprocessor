library IEEE;
use IEEE.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_down_5_last_2 is
	generic (
		g_lfsr					: boolean := false;
		g_n						: natural := 9
	);
	port (
		pi_clk					: in std_logic;
		pi_rst					: in std_logic;

		pi_load					: in std_logic;
		pi_data					: in std_logic_vector(g_n-1 downto 0);
		pi_last					: in std_logic_vector(4 downto 0);
		pi_change				: in std_logic;
		po_last					: out std_logic;
		po_last_but_one		: out std_logic
	);
end lfsr_counter_down_5_last_2;

architecture lfsr_counter_down_5_last_2 of lfsr_counter_down_5_last_2 is

	constant c_tap											: tap_vector := select_tap(g_n);
	constant c_tap_rev									: tap_vector := reverse_tap(c_tap);

	constant c_value										: natural := 4;

	constant c_ctrl_num_of_parts						: natural := g_n / C_MAX_NUM_OF_IN_PER_MUX;
	constant c_ctrl_part_width							: natural := g_n / c_ctrl_num_of_parts;

	signal s_value											: std_logic_vector(g_n-1 downto 0);

	signal r_shift_en										: std_logic;
	signal r_last_shreg									: std_logic_vector(4 downto 0);

	signal r_cnt											: std_logic_vector(g_n-1 downto 0);
	signal s_init_value									: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_down										: std_logic_vector(g_n-1 downto 0);
	signal s_feedback_rev								: std_logic;

	signal r_change										: std_logic;
	signal r_last_ish										: std_logic;

	signal s_last_vec										: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_last_vec										: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);

begin

	po_last <= r_last_shreg(0);
	po_last_but_one <= r_last_shreg(1);


	LFSR_CNT_GEN: if(g_lfsr = true) generate

		s_init_value <= (0=>'1', others=>'0');
		s_value <= to_lfsr(c_value, g_n);

		FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_feedback_rev <= r_cnt(c_tap_rev(0)-1) xor r_cnt(c_tap_rev(1)-1) xor r_cnt(c_tap_rev(2)-1) xor r_cnt(c_tap_rev(3)-1);
		end generate;

		TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_feedback_rev <= r_cnt(c_tap_rev(2)-1) xor r_cnt(c_tap_rev(3)-1);
		end generate;

		s_cnt_down <= s_feedback_rev & r_cnt(g_n-1 downto 1);
	end generate;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		s_init_value <= (others=>'0');
		s_value <= to_std_logic_vector(c_value, g_n);
		s_cnt_down <= r_cnt - 1;
	end generate;


	SH_REG: process(pi_clk)
	begin
		if(pi_clk'event and pi_clk = '1') then
			if(pi_rst = '1') then
				r_cnt <= s_init_value;
			else

				if(pi_load = '1') then
					r_cnt <= pi_data;
				elsif(pi_change = '1' and r_shift_en = '1') then
					r_cnt <= s_cnt_down;
				end if;

			end if;
		end if;
	end process;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------------
			-- R_LAST_SHREG --			6
			------------------
			if(pi_rst = '1') then
				r_last_shreg <= (others=>'0');
			else
				if(pi_load = '1') then																-- SHORT TERM
					r_last_shreg <= pi_last;
				elsif(pi_change = '1' and r_last_ish = '1') then							-- LONG TERM
					r_last_shreg <= (1=>'1',others=>'0');
				elsif(pi_change = '1' and r_shift_en = '1') then
					r_last_shreg <= '0' & r_last_shreg(r_last_shreg'length-1 downto 1);
				end if;
			end if;


			----------------
			-- R_LAST_VEC --
			----------------
			if(pi_change = '1') then
				r_last_vec <= s_last_vec;
			end if;
			r_change <= pi_change;


			----------------
			-- R_LAST_ISH --
			----------------
			if(pi_rst = '1') then
				r_last_ish <= '0';
			else

				if(and_reduce(r_last_vec) = '1' and pi_change = '1') then
					r_last_ish <= '1';
				elsif(pi_change = '1') then
					r_last_ish <= '0';
				end if;

			end if;


			----------------
			-- R_SHIFT_EN --
			----------------
			if(pi_rst = '1') then
				r_shift_en <= '0';
			else

				if(pi_load = '1') then
					r_shift_en <= '1';
				elsif(pi_change = '1' and r_last_shreg(0) = '1') then
					r_shift_en <= '0';
				end if;

			end if;

		end if;
	end process;


	-------------------
	-- LAST DETECTOR --
	-------------------
	NOP_HIGHER_GEN: for i in 0 to c_ctrl_num_of_parts-1 generate

		ZERO_BIT_GEN: if(i = 0) generate
			PART_NOT_EQUAL_GEN: if(c_ctrl_part_width < g_n) generate
				s_last_vec(0) <= '1' when r_cnt(c_ctrl_part_width-1 downto 0) = s_value(c_ctrl_part_width-1 downto 0) else '0';
			end generate;

			PART_EQUAL_GEN: if(c_ctrl_part_width >= g_n) generate
				s_last_vec(0) <= '1' when r_cnt = s_value else '0';
			end generate;
		end generate;

		GT_ZERO_GEN: if(i > 0) generate
			NOP_LAST_GEN: if(i = c_ctrl_num_of_parts-1) generate
				s_last_vec(i) <= '1' when r_cnt(r_cnt'length-1 downto i*c_ctrl_part_width) = s_value(r_cnt'length-1 downto i*c_ctrl_part_width) else '0';
			end generate;

			NOP_NOT_LAST_GEN: if(i /= c_ctrl_num_of_parts-1) generate
				s_last_vec(i) <= '1' when r_cnt(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) = s_value(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) else '0';
			end generate;
		end generate;

	end generate;


end lfsr_counter_down_5_last_2;
