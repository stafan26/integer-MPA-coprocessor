library IEEE;
use IEEE.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_minus_two is
	generic (
		g_lfsr				: boolean := false;
		g_n					: natural := 9
	);
	port (
		pi_clk				: in std_logic;
		pi_load				: in std_logic;
		pi_data				: in std_logic_vector(g_n-1 downto 0);
		po_data				: out std_logic_vector(g_n-1 downto 0)
	);
end lfsr_counter_minus_two;

architecture lfsr_counter_minus_two of lfsr_counter_minus_two is

	constant c_tap											: tap_vector := select_tap(g_n);
	constant c_tap_rev									: tap_vector := reverse_tap(c_tap);
	constant c_tap_rev_rev								: tap_vector := reverse_tap_2(c_tap_rev);

	signal s_feedback_rev								: std_logic;
	signal s_feedback_rev_rev							: std_logic;

	signal s_data											: std_logic_vector(g_n-1 downto 0);
	signal r_data											: std_logic_vector(g_n-1 downto 0);

begin

	po_data <= r_data;

	LFSR_CNT_GEN: if(g_lfsr = true) generate

		FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_feedback_rev <= pi_data(c_tap_rev(0)-1) xor pi_data(c_tap_rev(1)-1) xor pi_data(c_tap_rev(2)-1) xor pi_data(c_tap_rev(3)-1);
			s_feedback_rev_rev <= pi_data(c_tap_rev_rev(0)-1) xor pi_data(c_tap_rev_rev(1)-1) xor pi_data(c_tap_rev_rev(2)-1) xor pi_data(c_tap_rev_rev(3)-1);
		end generate;

		TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_feedback_rev <= pi_data(c_tap_rev(2)-1) xor pi_data(c_tap_rev(3)-1);
			s_feedback_rev_rev <= pi_data(c_tap_rev_rev(2)-1) xor pi_data(c_tap_rev_rev(3)-1);
		end generate;

		s_data <= s_feedback_rev_rev & s_feedback_rev & pi_data(g_n-1 downto 2);
	end generate;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		s_data <= pi_data - 2;
	end generate;


	SH_REG: process(pi_clk)
	begin
		if(pi_clk'event and pi_clk = '1') then
			if(pi_load = '1') then
				r_data <= s_data;
			end if;
		end if;
	end process;

end lfsr_counter_minus_two;
