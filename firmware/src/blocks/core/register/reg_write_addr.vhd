-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_write_addr
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.common_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity reg_write_addr is
generic (
	g_lfsr								: boolean := false;
	g_addr_width						: natural := 9
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_data_wr_en						: in std_logic;
	pi_data_last						: in std_logic;

	po_write_addr						: out std_logic_vector(g_addr_width-1 downto 0)
);
end reg_write_addr;

architecture reg_write_addr of reg_write_addr is

	constant c_tap											: tap_vector := select_tap(g_addr_width);

	signal c_write_addr									: std_logic_vector(g_addr_width-1 downto 0);
	signal s_write_addr									: std_logic_vector(g_addr_width-1 downto 0);
	signal r_write_addr									: std_logic_vector(g_addr_width-1 downto 0);
	signal s_write_addr_feedback						: std_logic;

begin

	po_write_addr <= r_write_addr;


	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		c_write_addr <= (others=>'0');
		s_write_addr <= r_write_addr + 1;
	end generate;

	LFSR_CNT_GEN: if(g_lfsr = true) generate
		c_write_addr <= (0=>'1',others=>'0');

		-- REPHRASING: s_up_fifo_plus <= r_cnt_fifo + 1;
		s_write_addr <= r_write_addr(g_addr_width-2 downto 0) & s_write_addr_feedback;

		WRITE_ADDR_PLUS_FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_write_addr_feedback <= r_write_addr(c_tap(0)-1) xor r_write_addr(c_tap(1)-1) xor r_write_addr(c_tap(2)-1) xor r_write_addr(c_tap(3)-1);
		end generate;

		WRITE_ADDR_PLUS_TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_write_addr_feedback <= r_write_addr(c_tap(2)-1) xor r_write_addr(c_tap(3)-1);
		end generate;

	end generate;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------------
			-- R_WRITE_ADDR --
			------------------
			if(pi_rst = '1') then
				r_write_addr <= c_write_addr;
			else

				if(pi_data_wr_en = '1' and pi_data_last = '1') then
					r_write_addr <= c_write_addr;
				elsif(pi_data_wr_en = '1' and pi_data_last = '0') then
					r_write_addr <= s_write_addr;
				end if;

			end if;

		end if;
	end process;


end architecture;
