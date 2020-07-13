
library IEEE;
use IEEE.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_up_down_3_last is
	generic (
		g_lfsr						: boolean := false;
		g_n							: natural := 16
	);
	port (
		pi_clk						: in std_logic;
		pi_rst						: in std_logic;

		pi_change_en				: in std_logic;
		pi_change_up				: in std_logic;
		pi_change_down_n			: in std_logic;

		pi_data_last				: in std_logic;

		po_data						: out std_logic_vector(g_n-1 downto 0);
		po_data_last				: out std_logic_vector(2 downto 0);
		po_cascade_last			: out std_logic := '0';
		po_cascade_last_vec		: out std_logic_vector(g_n/C_MAX_NUM_OF_IN_PER_MUX-1 downto 0) := (others=>'0')
	);
end lfsr_counter_up_down_3_last;

architecture lfsr_counter_up_down_3_last of lfsr_counter_up_down_3_last is

	constant c_tap											: tap_vector := select_tap(g_n);
	constant c_tap_rev									: tap_vector := reverse_tap(c_tap);

	constant c_value										: natural := 5;

	constant c_ctrl_num_of_parts						: natural := g_n / C_MAX_NUM_OF_IN_PER_MUX;
	constant c_ctrl_part_width							: natural := g_n / c_ctrl_num_of_parts;

	signal s_value											: std_logic_vector(g_n-1 downto 0);

	signal r_data											: std_logic_vector(g_n-1 downto 0);
	signal r_data_down									: std_logic_vector(g_n-1 downto 0);
	signal r_data_last									: std_logic_vector(2 downto 0);

	signal r_first											: std_logic;

	signal r_cnt_up										: std_logic_vector(g_n-1 downto 0);
	signal s_init_value									: std_logic_vector(g_n-1 downto 0);
	signal s_init_value_plus_one						: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_up										: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_down										: std_logic_vector(g_n-1 downto 0);
	signal s_feedback										: std_logic;
	signal s_feedback_rev								: std_logic;

	signal r_last_up										: std_logic_vector(2 downto 0);
	signal r_last_down_detected						: std_logic;
	signal r_last_down_vec_out							: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_last_down_vec								: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal s_last_down_vec								: std_logic_vector(c_ctrl_num_of_parts-1 downto 0);
	signal r_last_down_vec_and							: std_logic;

begin

	po_data <= r_data;
	po_data_last <= r_data_last;
	po_cascade_last <= r_last_down_detected;
	po_cascade_last_vec <= r_last_down_vec_out;


	LFSR_CNT_GEN: if(g_lfsr = true) generate						-- 564,1 MHz
		s_value <= to_lfsr(c_value, g_n);
		s_init_value <= (0=>'1', others=>'0');
		s_init_value_plus_one <= (1=>'1', others=>'0');

		FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_feedback <= r_cnt_up(c_tap(0)-1) xor r_cnt_up(c_tap(1)-1) xor r_cnt_up(c_tap(2)-1) xor r_cnt_up(c_tap(3)-1);
			s_feedback_rev <= r_data(c_tap_rev(0)-1) xor r_data(c_tap_rev(1)-1) xor r_data(c_tap_rev(2)-1) xor r_data(c_tap_rev(3)-1);
		end generate;

		TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_feedback <= r_cnt_up(c_tap(2)-1) xor r_cnt_up(c_tap(3)-1);
			s_feedback_rev <= r_data(c_tap_rev(2)-1) xor r_data(c_tap_rev(3)-1);
		end generate;


		s_cnt_up <= r_cnt_up(g_n-2 downto 0) & s_feedback;
		s_cnt_down <= s_feedback_rev & r_data(g_n-1 downto 1);
	end generate;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate					-- 555,9 MHz
		s_value <= to_std_logic_vector(c_value, g_n);
		s_init_value <= (others=>'0');
		s_init_value_plus_one <= (0=>'1',others=>'0');

		s_cnt_up <= r_cnt_up + 1;
		s_cnt_down <= r_data - 1;
	end generate;



	CNT_UP_PROC: process(pi_clk)
	begin
		if(pi_clk'event and pi_clk = '1') then

			--------------
			-- R_CNT_UP --	4+1
			--------------
			if(pi_rst = '1') then
				r_cnt_up <= s_init_value_plus_one;
			else

				if(pi_change_en = '1' and pi_change_up = '1') then
					r_cnt_up <= s_cnt_up;
				end if;

			end if;


			---------------
			-- R_LAST_UP --		4+1
			---------------
			if(pi_rst = '1') then
				r_last_up <= (1=>'1',others=>'0');
			else

				if(pi_change_en = '1' and pi_change_up = '1') then
					r_last_up <= r_last_up(r_last_up'length-2 downto 0) & '0';
				end if;

			end if;

		end if;
	end process;



	DATA_DOWN_PROC: process(pi_clk)
	begin
		if(pi_clk'event and pi_clk = '1') then

--			-----------------
--			-- R_DATA_DOWN --		2
--			-----------------
			r_data_down <= s_cnt_down;


			---------------------
			-- R_LAST_DOWN_VEC --	5
			---------------------
			r_last_down_vec <= s_last_down_vec;


			-------------------------
			-- R_LAST_DOWN_VEC_AND --	2
			-------------------------
			r_last_down_vec_and <= and_reduce(r_last_down_vec_out);


			-------------------------
			-- R_LAST_DOWN_VEC_OUT --		TODO: too many - a to da sie spakowac
			-------------------------
			if(pi_change_en = '1') then
				if(pi_change_up = '1' and r_last_down_detected = '1') then			-- going UP
					r_last_down_vec_out <= (others=>'1');
				elsif(pi_change_up = '1' and r_last_down_detected = '0') then		-- going UP
					r_last_down_vec_out <= (others=>'0');
				elsif(pi_change_down_n = '0' and (r_last_down_detected = '1' or r_last_down_vec_and = '1')) then	-- going DOWN
					r_last_down_vec_out <= (others=>'0');
				elsif(pi_change_down_n = '0' and r_last_down_detected = '0') then	-- going DOWN
					r_last_down_vec_out <= r_last_down_vec;
				end if;
			end if;


			--------------------------
			-- R_LAST_DOWN_DETECTED --		6
			--------------------------
			if((pi_change_en = '1' and pi_change_up = '1') or
			(pi_change_en = '1' and pi_change_up = '0' and pi_change_down_n = '0')) then
				if((pi_change_up = '1' and r_data_last(2) = '1') or								-- going UP
				(pi_change_down_n = '0' and r_last_down_vec_and = '1')) then					-- going DOWN
					r_last_down_detected <= '1';
				else
					r_last_down_detected <= '0';
				end if;
			end if;

		end if;
	end process;



	SHREG_LAST_PROC: process(pi_clk)
	begin

		if(pi_clk'event and pi_clk = '1') then

			------------
			-- R_DATA --		6+1
			------------
			if(pi_rst = '1') then
				r_data <= s_init_value;
			else

				if(pi_change_en = '1' and pi_change_up = '1' and pi_change_down_n = '1') then
					r_data <= r_cnt_up;
				elsif(pi_change_en = '1' and pi_change_up = '0' and pi_change_down_n = '0') then
					r_data <= r_data_down;
				end if;

			end if;


			-----------------
			-- R_DATA_LAST --	6+1
			-----------------
			if(pi_rst = '1') then
				r_data_last <= (0=>'1',others=>'0');
			else

				if(pi_change_en = '1' and pi_change_up = '1' and pi_change_down_n = '1') then
					r_data_last <= r_last_up;
				elsif(pi_change_en = '1' and pi_change_up = '0' and pi_change_down_n = '0') then
					r_data_last <= r_last_down_detected & r_data_last(r_data_last'length-1 downto 1);
				end if;

			end if;


			-------------
			-- R_FIRST --		3+1
			-------------
			if(pi_rst = '1') then
				r_first <= '1';
			else

				if(pi_change_en = '1') then
					r_first <= '0';
				elsif(pi_data_last = '1') then
					r_first <= '1';
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
				s_last_down_vec(0) <= '1' when r_data(c_ctrl_part_width-1 downto 0) = s_value(c_ctrl_part_width-1 downto 0) else '0';
			end generate;

			PART_EQUAL_GEN: if(c_ctrl_part_width >= g_n) generate
				s_last_down_vec(0) <= '1' when r_data = s_value else '0';
			end generate;
		end generate;

		GT_ZERO_GEN: if(i > 0) generate
			NOP_LAST_GEN: if(i = c_ctrl_num_of_parts-1) generate
				s_last_down_vec(i) <= '1' when r_data(r_data'length-1 downto i*c_ctrl_part_width) = s_value(r_data'length-1 downto i*c_ctrl_part_width) else '0';
			end generate;

			NOP_NOT_LAST_GEN: if(i /= c_ctrl_num_of_parts-1) generate
				s_last_down_vec(i) <= '1' when r_data(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) = s_value(((i+1)*c_ctrl_part_width)-1 downto i*c_ctrl_part_width) else '0';
			end generate;
		end generate;

	end generate;

end lfsr_counter_up_down_3_last;
