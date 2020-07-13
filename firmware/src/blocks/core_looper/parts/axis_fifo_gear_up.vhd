-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    axis_fifo_gear_up
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

entity axis_fifo_gear_up is
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	S_AXIS_0_tdata						: in STD_LOGIC_VECTOR (31 downto 0);
	S_AXIS_0_tkeep						: in STD_LOGIC_VECTOR (3 downto 0);
	S_AXIS_0_tlast						: in STD_LOGIC;
	S_AXIS_0_tready					: out STD_LOGIC;
	S_AXIS_0_tvalid					: in STD_LOGIC;

	M_AXIS_0_tdata						: out STD_LOGIC_VECTOR (63 downto 0);
	M_AXIS_0_tlast						: out STD_LOGIC_VECTOR(1 downto 0);
	M_AXIS_0_tkeep						: out STD_LOGIC_VECTOR (7 downto 0);
	M_AXIS_0_tready					: in STD_LOGIC;
	M_AXIS_0_tvalid					: out STD_LOGIC
);
end axis_fifo_gear_up;

architecture axis_fifo_gear_up of axis_fifo_gear_up is

	signal r_in_tready				: std_logic;
	signal r_out_valid				: std_logic;

	signal r_higher					: std_logic;

	signal r_data_lo					: std_logic_vector(31 downto 0);
	signal r_data_hi					: std_logic_vector(31 downto 0);

	signal r_last_hi 					: std_logic;
	signal r_last_lo 					: std_logic;

	signal r_keep_lo					: std_logic_vector(3 downto 0);
	signal r_keep_hi					: std_logic_vector(3 downto 0);


begin

	S_AXIS_0_tready <= r_in_tready and M_AXIS_0_tready;

	M_AXIS_0_tdata <= r_data_hi & r_data_lo;
	M_AXIS_0_tlast <= r_last_hi & r_last_lo;
	M_AXIS_0_tkeep <= r_keep_hi & r_keep_lo;
	M_AXIS_0_tvalid <= r_out_valid;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------------
			-- R_IN_TREADY --
			-----------------
			if(pi_rst = '1') then
				r_in_tready <= '0';
			else

				if(r_out_valid = '0' or (r_out_valid = '1' and M_AXIS_0_tready = '1')) then
					r_in_tready <= '1';
				else
					r_in_tready <= '0';
				end if;

			end if;


			------------
			-- R_DATA --
			------------
			if(S_AXIS_0_tvalid = '1' and r_in_tready = '1' and r_higher = '0' and (r_out_valid = '0' or (r_out_valid = '1' and M_AXIS_0_tready = '1'))) then
				r_data_lo <= S_AXIS_0_tdata;
				r_last_lo <= S_AXIS_0_tlast;
				r_keep_lo <= S_AXIS_0_tkeep;
			end if;

			if(S_AXIS_0_tvalid = '1' and r_in_tready = '1' and r_higher = '1' and (r_out_valid = '0' or (r_out_valid = '1' and M_AXIS_0_tready = '1'))) then
				r_data_hi <= S_AXIS_0_tdata;
				r_last_hi <= S_AXIS_0_tlast;
				r_keep_hi <= S_AXIS_0_tkeep;
			end if;


			-----------------
			-- R_OUT_VALID --
			-----------------
			if(pi_rst = '1') then
				r_out_valid <= '0';
			else
				if(M_AXIS_0_tready = '1' and r_out_valid = '1') then
					r_out_valid <= '0';
				elsif(S_AXIS_0_tvalid = '1' and r_in_tready = '1' and r_higher = '1') then
					r_out_valid <= '1';
				end if;
			end if;


			--------------
			-- R_HIGHER --
			--------------
			if(pi_rst = '1') then
				r_higher <= '0';
			else
				if(S_AXIS_0_tvalid = '1' and r_in_tready = '1' and M_AXIS_0_tready = '1') then
					r_higher <= not r_higher;
				end if;
			end if;

		end if;
	end process;

end architecture;
