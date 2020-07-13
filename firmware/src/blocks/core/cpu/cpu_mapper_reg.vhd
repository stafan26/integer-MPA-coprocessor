-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_mapper_reg
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity cpu_mapper_reg is
generic (
	g_reg_width							: natural := 5;
	g_reg_oh_width						: natural := 14;
	g_init_id							: natural := 2
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_load								: in std_logic;
	pi_reg_on							: in std_logic;
	pi_data								: in std_logic_vector(g_reg_width-1 downto 0);
	pi_data_oh							: in std_logic_vector(g_reg_oh_width-1 downto 0);
	po_data								: out std_logic_vector(g_reg_width-1 downto 0);
	po_data_oh							: out std_logic_vector(g_reg_oh_width-1 downto 0)
);
end cpu_mapper_reg;

architecture cpu_mapper_reg of cpu_mapper_reg is

	signal r_data							: std_logic_vector(g_reg_width-1 downto 0);
	signal r_data_oh						: std_logic_vector(g_reg_oh_width-1 downto 0);
	signal r_data_out_oh					: std_logic_vector(g_reg_oh_width-1 downto 0);

begin

	po_data <= r_data;
	po_data_oh <= r_data_out_oh;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------
			-- R_DATA --
			------------
			if(pi_rst = '1') then
				r_data <= to_std_logic_vector(g_init_id, g_reg_width);
			else

				if(pi_load = '1') then
					r_data <= pi_data;
				end if;

			end if;


			---------------
			-- R_DATA_OH --
			---------------
			if(pi_rst = '1') then
				r_data_oh <= (g_init_id=>'1',others=>'0');
			else

				if(pi_load = '1') then
					r_data_oh <= pi_data_oh;
				end if;

			end if;


			-------------------
			-- R_DATA_OUT_OH --
			-------------------
			if(pi_load = '1' and pi_reg_on = '1') then
				r_data_out_oh <= pi_data_oh;
			elsif(pi_reg_on = '1') then
				r_data_out_oh <= r_data_oh;
			else
				r_data_out_oh <= (others=>'0');
			end if;

		end if;
	end process;

end architecture;
