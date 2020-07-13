-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    oper_switchbox
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity oper_switchbox is
generic (
	g_output_data_last				: boolean := false;
	g_data_width						: natural := 64;
	g_select_width						: natural := 5
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_select							: in std_logic_vector(g_select_width-1 downto 0);
	pi_start								: in std_logic;

	pi_data								: in t_data_x1;
	pi_data_last						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic
);
end oper_switchbox;

architecture oper_switchbox of oper_switchbox is

	signal r_ctrl_on						: std_logic;
	signal r_data_last					: std_logic;

	type t_data is array (0 to g_data_width-1) of std_logic_vector(C_NUM_OF_ALL_REGISTERS-1 downto 0);
	signal s_data							: t_data;

begin

	MUX_GEN: for i in 0 to g_data_width-1 generate

		DATA_GEN: for j in 0 to C_NUM_OF_ALL_REGISTERS-1 generate
			s_data(i)(j) <= pi_data(j)(i);
		end generate;

		MUX_AUTO_INST: entity work.mux_auto_phys generic map (
			g_latency					=> 2				--: natural := 2
		)
		port map (
			pi_clk						=> pi_clk,		--: in std_logic;
			pi_addr						=> pi_select,	--: in std_logic_vector(4 downto 0);
			pi_data						=> s_data(i),	--: in std_logic_vector(18 downto 0);
			po_data						=> po_data(i)	--: out std_logic
		);

	end generate;


	DATA_LAST_ONE_OUTPUT_REG: if(g_output_data_last = true) generate

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				---------------
				-- R_CTRL_ON --
				---------------
				if(pi_rst = '1') then
					r_ctrl_on <= '0';
				else

					if(pi_start = '1') then
						r_ctrl_on <= '1';
					elsif(r_data_last = '1') then
						r_ctrl_on <= '0';
					end if;

				end if;


				r_data_last <= pi_data_last;


				------------------
				-- PO_DATA_LAST --	6
				------------------
				if(r_ctrl_on = '0') then
					po_data_last <= '0';
				else

					po_data_last <= r_data_last;

				end if;

			end if;
		end process;

	end generate;


	NO_DATA_LAST_REG_GEN: if(g_output_data_last = false) generate
		po_data_last <= '0';
	end generate;

end architecture;
