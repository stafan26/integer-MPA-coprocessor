-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    switchbox_x2_extra
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
-------------------------------------------
-------------------------------------------

entity switchbox_x2_extra is
generic (
	g_output_data_last				: string := "YES";
	g_data_width						: natural := 64;
	g_extra_width						: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_select							: in std_logic;
	pi_start								: in std_logic;

	pi_data_ch_1						: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_ch_2						: in std_logic_vector(g_data_width-1 downto 0);

	pi_data_last_ch_1					: in std_logic;
	pi_data_last_ch_2					: in std_logic;

	pi_data_extra_ch_1				: in std_logic_vector(g_extra_width-1 downto 0);
	pi_data_extra_ch_2				: in std_logic_vector(g_extra_width-1 downto 0);

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_extra						: out std_logic_vector(g_extra_width-1 downto 0)
);
end switchbox_x2_extra;

architecture switchbox_x2_extra of switchbox_x2_extra is

	signal r_ctrl_on										: std_logic;

begin


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
				elsif(pi_data_last_ch_1 = '1' and pi_select = '0') or (pi_data_last_ch_2 = '1' and pi_select = '1') then
					r_ctrl_on <= '0';
				end if;

			end if;

		end if;
	end process;



							-------------
							-- OUTPUTS --
							-------------


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-------------
			-- PO_DATA --		6
			-------------
			case pi_select is
				when '0' =>		po_data <= pi_data_ch_1;
				when '1' =>		po_data <= pi_data_ch_2;
				when others =>		po_data <= (others=>'0');

			end case;

		end if;
	end process;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-------------------
			-- PO_DATA_EXTRA --		6
			-------------------
			if(r_ctrl_on = '0') then
				po_data_extra <= (others=>'0');
			else

				case pi_select is
					when '0' =>		po_data_extra <= pi_data_extra_ch_1;
					when '1' =>		po_data_extra <= pi_data_extra_ch_2;
					when others =>		po_data_extra <= (others=>'0');
				end case;

			end if;

		end if;
	end process;


	DATA_LAST_ONE_OUTPUT_REG: if(g_output_data_last = "YES") generate
		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				------------------
				-- PO_DATA_LAST --	6
				------------------
				if(r_ctrl_on = '0') then
					po_data_last <= '0';
				else

					case pi_select is
						when '0' =>		po_data_last <= pi_data_last_ch_1;
						when '1' =>		po_data_last <= pi_data_last_ch_2;
						when others =>		po_data_last <= '0';
					end case;

				end if;
			end if;
		end process;

	end generate;


	NO_DATA_LAST_REG_GEN: if(g_output_data_last = "NO") generate
		po_data_last <= '0';
	end generate;

end architecture;
