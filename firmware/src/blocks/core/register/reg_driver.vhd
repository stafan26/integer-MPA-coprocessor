-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_driver
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity reg_driver is
generic (
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_data_hi							: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_lo							: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	pi_select_hi_lo					: in std_logic;
	pi_set_zero							: in std_logic;
	pi_set_one							: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic
);
end reg_driver;

architecture reg_driver of reg_driver is

	signal r_select_hi_lo								: std_logic;

begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			--------------------
			-- R_SELECT_HI_LO --
			--------------------
			if(pi_rst = '1') then
				r_select_hi_lo <= '0';
			else

				if(pi_select_hi_lo = '1') then
					r_select_hi_lo <= '1';
				elsif(pi_data_last = '1') then
					r_select_hi_lo <= '0';
				end if;

			end if;


			-------------
			-- PO_DATA --		-- 5
			-------------
			if(pi_set_zero = '1') then
				po_data <= (others=>'0');
			elsif(pi_set_one = '1') then
				po_data <= (0=>'1',others=>'0');
			elsif(r_select_hi_lo = '0') then
				po_data <= pi_data_lo;
			else
				po_data <= pi_data_hi;
			end if;


			------------------
			-- PO_DATA_LAST --
			------------------
			if((pi_data_wr_en = '1' and pi_data_last = '1') or pi_set_zero = '1' or pi_set_one = '1') then
				po_data_last <= '1';
			else
				po_data_last <= '0';
			end if;


			-------------------
			-- PO_DATA_WR_EN --
			-------------------
			if(pi_data_wr_en = '1' or pi_set_zero = '1' or pi_set_one = '1') then
				po_data_wr_en <= '1';
			else
				po_data_wr_en <= '0';
			end if;

		end if;
	end process;

end architecture;
