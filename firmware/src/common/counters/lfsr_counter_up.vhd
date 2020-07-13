
library IEEE;
use IEEE.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity lfsr_counter_up is
	generic (
		g_lfsr				: boolean := false;
		g_n					: natural := 16
	);
	port (
		pi_clk				: in std_logic;
		pi_rst				: in std_logic;

		pi_change			: in std_logic;

		po_data				: out std_logic_vector(g_n-1 downto 0)
	);
end lfsr_counter_up;

architecture lfsr_counter_up of lfsr_counter_up is

	constant c_tap				: tap_vector := select_tap(g_n);

	signal c_one				: std_logic_vector(g_n-1 downto 0) := (0=>'1', others=>'0');

	signal r_cnt				: std_logic_vector(g_n-1 downto 0);
	signal s_init_value		: std_logic_vector(g_n-1 downto 0);
	signal s_cnt_up			: std_logic_vector(g_n-1 downto 0);
	signal s_feedback			: std_logic;

begin

	po_data <= r_cnt;


	LFSR_CNT_GEN: if(g_lfsr = true) generate						-- 564,1 MHz
		s_init_value <= (0=>'1', others=>'0');

		FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_feedback <= r_cnt(c_tap(0)-1) xor r_cnt(c_tap(1)-1) xor r_cnt(c_tap(2)-1) xor r_cnt(c_tap(3)-1);
		end generate;

		TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_feedback <= r_cnt(c_tap(2)-1) xor r_cnt(c_tap(3)-1);
		end generate;

		s_cnt_up <= r_cnt(g_n-2 downto 0) & s_feedback;
	end generate;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate					-- 555,9 MHz
		s_init_value <= (others=>'0');
		s_cnt_up <= r_cnt + 1;
	end generate;


	SH_REG: process(pi_clk)
	begin

		if(pi_clk'event and pi_clk = '1') then
			if(pi_rst = '1') then
				r_cnt <= s_init_value;
			else

				if(pi_change = '1') then
					r_cnt <= s_cnt_up;
				end if;

			end if;
		end if;
	end process;

end lfsr_counter_up;
