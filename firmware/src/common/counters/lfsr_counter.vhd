
library IEEE;
use IEEE.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter is
	generic (
		g_lfsr				: boolean := false;
		g_n					: natural := 60
	);
	port (
		pi_clk				: in std_logic;

		pi_load				: in std_logic;
		pi_data				: in std_logic_vector(g_n-1 downto 0);

		pi_change			: in std_logic;
		pi_direction		: in std_logic;

		po_data				: out std_logic_vector(g_n-1 downto 0)
	);
end lfsr_counter;

architecture lfsr_counter of lfsr_counter is

	constant c_tap				: tap_vector := select_tap(g_n);
	constant c_tap_rev		: tap_vector := reverse_tap(c_tap);

	signal r_cnt				: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_up			: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_down			: std_logic_vector(g_n-1 downto 0);
	signal s_feedback			: std_logic;
	signal s_feedback_rev	: std_logic;

begin

	po_data <= r_cnt;

	LFSR_CNT_GEN: if(g_lfsr = true) generate						-- 550,4 MHz	16bits

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


	REGULAR_CNT_GEN: if(g_lfsr = false) generate					-- 544,7 MHz	16bits
		s_cnt_up <= r_cnt + 1;
		s_cnt_down <= r_cnt - 1;
	end generate;


	SH_REG: process(pi_clk)
	begin
		if(pi_clk'event and pi_clk = '1') then

			if(pi_load = '1') then				-- RST
				r_cnt <= pi_data;
			else

				if(pi_change = '1') then		-- CE
					if(pi_direction = '1') then
						r_cnt <= s_cnt_up;
					else
						r_cnt <= s_cnt_down;
					end if;
				end if;

			end if;

		end if;
	end process;

end lfsr_counter;
