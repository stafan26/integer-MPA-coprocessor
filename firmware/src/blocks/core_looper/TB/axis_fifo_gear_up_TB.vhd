-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    axis_fifo_gear_up_TB
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

entity axis_fifo_gear_up_TB is
end axis_fifo_gear_up_TB;

architecture axis_fifo_gear_up_TB of axis_fifo_gear_up_TB is

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_in_data_flip								: std_logic;
	signal r_in_data										: std_logic_vector(30 downto 0);
	signal s_in_data										: std_logic_vector(31 downto 0);

	signal s_in_tready									: std_logic;
	signal r_in_tvalid									: std_logic;

	signal s_out_tdata									: std_logic_vector (63 downto 0);
	signal r_out_tready									: std_logic;
	signal s_out_tvalid									: std_logic;


begin

	process
	begin
		r_clk <= '1';
		wait for 5ns;
		r_clk <= '0';
		wait for 5ns;
	end process;

	process
	begin
		r_rst <= '1';
		wait for 555ns;
		r_rst <= '0';
		wait;
	end process;

	s_in_data <= r_in_data_flip & r_in_data;

	AXIS_FIFO_GEARBOX_INST: entity work.axis_fifo_gear_up port map (
		pi_clk				=> r_clk,					--: in std_logic;
		pi_rst				=> r_rst,					--: in std_logic;

		S_AXIS_0_tdata		=> s_in_data,				--: in STD_LOGIC_VECTOR ( 31 downto 0 );
		S_AXIS_0_tkeep		=> (others=>'0'),			--: in STD_LOGIC_VECTOR ( 3 downto 0 );
		S_AXIS_0_tlast		=> '0',						--: in STD_LOGIC;
		S_AXIS_0_tready	=> s_in_tready,			--: out STD_LOGIC;
		S_AXIS_0_tvalid	=> r_in_tvalid,			--: in STD_LOGIC;

		M_AXIS_0_tdata		=> s_out_tdata,			--: out STD_LOGIC_VECTOR ( 63 downto 0 );
		M_AXIS_0_tready	=> r_out_tready,			--: in STD_LOGIC;
		M_AXIS_0_tvalid	=> s_out_tvalid			--: out STD_LOGIC
	);


	process
	begin
		r_in_tvalid <= '0';
		wait for 841ns;
		r_in_tvalid <= '1';
		wait for 10ns;
		r_in_tvalid <= '0';
		wait for 20ns;
		r_in_tvalid <= '1';
		wait for 10ns;
		r_in_tvalid <= '0';
		wait for 20ns;
		r_in_tvalid <= '1';
		wait for 20ns;
		r_in_tvalid <= '0';
		wait for 10ns;
		r_in_tvalid <= '1';
		wait for 20ns;
		r_in_tvalid <= '0';
		wait for 10ns;
		r_in_tvalid <= '1';
		wait for 100ns;
		r_in_tvalid <= '0';
		wait for 100ns;
		r_in_tvalid <= '1';
		wait for 100ns;
		r_in_tvalid <= '0';
		wait for 10ns;
		r_in_tvalid <= '1';
		wait;
	end process;


	process
	begin
		r_out_tready <= '0';
		wait for 1255ns;
		r_out_tready <= '1';
		wait for 100ns;
		r_out_tready <= '0';
		wait for 200ns;
		r_out_tready <= '1';
		wait for 100ns;
		r_out_tready <= '0';
		wait for 200ns;
		r_out_tready <= '1';
		wait for 200ns;
		r_out_tready <= '0';
		wait for 100ns;
		r_out_tready <= '1';
		wait;
	end process;




	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			---------------
			-- R_DATA_IN --
			---------------
			if(r_rst = '1') then
				r_in_data <= (others=>'0');
				r_in_data_flip <= '0';
			else

				if(s_in_tready = '1' and r_in_tvalid = '1') then
					r_in_data <= r_in_data + 1;
					r_in_data_flip <= not r_in_data_flip;
				end if;

			end if;

		end if;
	end process;

end architecture;
