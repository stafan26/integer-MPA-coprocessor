-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    loader
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- check if asynchronous data arrival from CPU works fine
--
-------------------------------------------
-------------------------------------------

entity loader is
generic (
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_start								: in std_logic;

	s00_axis_tdata						: in std_logic_vector(g_data_width-1 downto 0);
	s00_axis_tvalid					: in std_logic;
	s00_axis_tready					: out std_logic;

	po_rst								: out std_logic;
	po_load								: out std_logic;
	po_change							: out std_logic;
	pi_last								: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_sign						: out std_logic;
	po_wr_en								: out std_logic
);
end loader;

architecture loader of loader is

	signal r_load											: std_logic;
	signal r_change										: std_logic;

	signal r_last											: std_logic;
	signal r_data_last									: std_logic;
	signal r_sign											: std_logic;

	signal r_ctrl_tready									: std_logic;
	signal r_ctrl_analyse								: std_logic;

begin

	po_rst <= r_ctrl_analyse;
	po_load <= r_load;
	po_change <= r_change;

	s00_axis_tready <= r_ctrl_tready;
	po_data_last <= r_data_last;
	po_data_sign <= r_sign;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------
			-- STREAM --
			------------
			po_data <= s00_axis_tdata;
			r_last <= pi_last;

		end if;
	end process;



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-------------------
			-- R_CTRL_TREADY --
			-------------------
			if(pi_rst = '1' or pi_last = '1') then
				r_ctrl_tready <= '0';
			else

				if(r_ctrl_analyse = '1') then			-- CE
					if(pi_start = '1') then
						r_ctrl_tready <= '1';
					elsif(pi_last = '1') then
						r_ctrl_tready <= '0';
					end if;
				end if;

			end if;


			--------------------
			-- R_CTRL_ANALYSE --
			--------------------
			if(pi_rst = '1') then
				r_ctrl_analyse <= '1';
			else

				if(pi_start = '1') then
					r_ctrl_analyse <= '0';
				elsif(s00_axis_tvalid = '1' and r_ctrl_tready = '1' and pi_last = '1') then
					r_ctrl_analyse <= '1';
				end if;

			end if;


			------------
			-- R_LOAD --
			------------
			if(pi_rst = '1') then
				r_load <= '1';
			else

				if(s00_axis_tvalid = '1' and r_ctrl_tready = '1' and pi_last = '1') then
					r_load <= '1';
				elsif(s00_axis_tvalid = '1' and r_ctrl_tready = '1') then
					r_load <= '0';
				end if;

			end if;


			------------
			-- R_SIGN --
			------------
			if(r_load = '1') then
				r_sign <= s00_axis_tdata(15);
			end if;


			--------------
			-- R_CHANGE --
			--------------
			if(pi_rst = '1') then
				r_change <= '0';
			else

				if(s00_axis_tvalid = '1' and r_ctrl_tready = '1' and pi_last = '0') then
					r_change <= '1';
				else
					r_change <= '0';
				end if;

			end if;


			-----------------
			-- R_DATA_LAST --
			-----------------
			if(r_change = '1' and pi_last = '1') then
				r_data_last <= '1';
			else
				r_data_last <= '0';
			end if;


			--------------
			-- PO_WR_EN --
			--------------
			if(r_last = '0') then
				po_wr_en <= r_change;
			else
				po_wr_en <= '0';
			end if;


		end if;
	end process;

end architecture;
