
library IEEE;
use IEEE.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_up_down_with_last is
	generic (
		g_lfsr					: boolean := false;
		g_init_one				: boolean := false;
		g_init_two				: boolean := true;
		g_n						: natural := 16;
		--g_last_width			: natural := 4;
		g_cascade_last			: boolean := false
	);
	port (
		pi_clk					: in std_logic;
		pi_rst					: in std_logic;

		pi_change				: in std_logic;
		pi_direction			: in std_logic;

		po_cascade_last		: out std_logic;
		po_cascade_last_vec	: out std_logic_vector(g_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0);
		po_data					: out std_logic_vector(g_n-1 downto 0);
		--po_data_last			: out std_logic_vector(g_last_width-1 downto 0)
		po_data_last			: out std_logic_vector(2 downto 0)
	);
end lfsr_counter_up_down_with_last;

architecture lfsr_counter_up_down_with_last of lfsr_counter_up_down_with_last is

	constant c_tap											: tap_vector := select_tap(g_n);
	constant c_tap_rev									: tap_vector := reverse_tap(c_tap);

	constant c_value										: natural := 5;

	constant c_ctrl_num_of_parts						: natural := g_n / C_MAX_NUM_OF_IN_PER_MUX;
	constant c_ctrl_part_width							: natural := g_n / c_ctrl_num_of_parts;

	signal s_value											: std_logic_vector(g_n-1 downto 0);

	signal r_cnt											: std_logic_vector(g_n-1 downto 0);
	signal s_init_value									: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_up										: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_down										: std_logic_vector(g_n-1 downto 0);
	signal s_feedback										: std_logic;
	signal s_feedback_rev								: std_logic;

	signal r_last_long_active							: std_logic;
	signal r_last_long									: std_logic;

	signal s_last_vec										: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_last_vec										: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);

	--signal r_last_shreg									: std_logic_vector(g_last_width-1 downto 0);
	signal r_last_shreg									: std_logic_vector(2 downto 0);

begin

	CASCADE_GEN: if(g_cascade_last = true) generate
		po_cascade_last <= r_last_long;
		po_cascade_last_vec <= r_last_vec;
	end generate;

	po_data <= r_cnt;
	po_data_last <= r_last_shreg;


	LFSR_CNT_GEN: if(g_lfsr = true) generate						-- 564,1 MHz
		s_value <= to_lfsr(c_value, g_n);

		LFSR_TWO_GEN: if(g_init_two = true and g_init_one = false) generate
			s_init_value <= (2=>'1', others=>'0');
		end generate;

		LFSR_ONE_GEN: if(g_init_two = false and g_init_one = true) generate
			s_init_value <= (1=>'1', others=>'0');
		end generate;

		LFSR_ZERO_GEN: if(g_init_two = false and g_init_one = false) generate
			s_init_value <= (0=>'1', others=>'0');
		end generate;

		FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_feedback <= r_cnt(c_tap(0)-1) xor r_cnt(c_tap(1)-1) xor r_cnt(c_tap(2)-1) xor r_cnt(c_tap(3)-1);
			s_feedback_rev <= r_cnt(c_tap_rev(0)-1) xor r_cnt(c_tap_rev(1)-1) xor r_cnt(c_tap_rev(2)-1) xor r_cnt(c_tap_rev(3)-1);
		end generate;

		TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_feedback <= r_cnt(c_tap(2)-1) xor r_cnt(c_tap(3)-1);
			s_feedback_rev <= r_cnt(c_tap_rev(2)-1) xor r_cnt(c_tap_rev(3)-1);
		end generate;


		s_cnt_up <= r_cnt(g_n-2 downto 0) & s_feedback;
		s_cnt_down <= s_feedback_rev & r_cnt(g_n-1 downto 1);
	end generate;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate					-- 555,9 MHz
		s_value <= to_std_logic_vector(c_value, g_n);

		REGULAR_TWO_GEN: if(g_init_two = true and g_init_one = false) generate
			s_init_value <= (1=>'1', others=>'0');
		end generate;

		REGULAR_ONE_GEN: if(g_init_two = false and g_init_one = true) generate
			s_init_value <= (0=>'1', others=>'0');
		end generate;

		REGULAR_ZERO_GEN: if((g_init_two = false and g_init_one = false) or (g_init_two = true and g_init_one = true)) generate
			s_init_value <= (others=>'0');
		end generate;

		s_cnt_up <= r_cnt + 1;
		s_cnt_down <= r_cnt - 1;
	end generate;


	CNT_REG_PROC: process(pi_clk)
	begin

		if(pi_clk'event and pi_clk = '1') then
			if(pi_rst = '1') then
				r_cnt <= s_init_value;
			else

				if(pi_change = '1' and pi_direction = '0') then
					r_cnt <= s_cnt_up;
				elsif(pi_change = '1' and pi_direction = '1') then
					r_cnt <= s_cnt_down;
				end if;

			end if;
		end if;
	end process;


	SHREG_LAST_PROC: process(pi_clk)
	begin

		if(pi_clk'event and pi_clk = '1') then

			------------------
			-- R_LAST_SHREG --		5
			------------------
			if(pi_rst = '1') then
				if(g_init_two = false and g_init_one = true) then
					r_last_shreg <= (0=>'1', others=>'0');
				elsif(g_init_two = true and g_init_one = false) then
					r_last_shreg <= (1=>'1', others=>'0');
				else
					r_last_shreg <= (others=>'0');
				end if;
			else

				if(pi_change = '1') then
					if(pi_direction = '0') then																				-- UP
						r_last_shreg <= r_last_shreg(r_last_shreg'length-2 downto 0) & '0';
					elsif(pi_direction = '1' and r_last_long_active = '0') then										-- DOWN (short)
						r_last_shreg <= '0' & r_last_shreg(r_last_shreg'length-1 downto 1);
					elsif(pi_direction = '1' and r_last_long_active = '1' and r_last_long = '1') then		-- DOWN (long)
						r_last_shreg <= (1=>'1',others=>'0');
					elsif(r_last_long_active = '1') then																	-- DOWN/UP (long)
						r_last_shreg <= (others=>'0');
					end if;
				end if;

			end if;


			------------------------
			-- R_LAST_LONG_ACTIVE --
			------------------------
			if(pi_rst = '1') then
				r_last_long_active <= '0';
			else

				if(pi_change = '1' and pi_direction = '0' and r_last_shreg(r_last_shreg'length-1) = '1') then			-- UP
					r_last_long_active <= '1';
				elsif(pi_change = '1' and r_last_long = '1') then
					r_last_long_active <= '0';
				end if;

			end if;


			----------------
			-- R_LAST_VEC --
			----------------
			if(pi_change = '1') then			-- CE
				r_last_vec <= s_last_vec;
			end if;


			-----------------
			-- R_LAST_LONG --
			-----------------
			if(pi_rst = '1') then
				r_last_long <= '0';
			else

				if(pi_change = '1') then			-- CE

					if(and_reduce(r_last_vec) = '1') then
						r_last_long <= '1';
					else
						r_last_long <= '0';
					end if;

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



end lfsr_counter_up_down_with_last;
