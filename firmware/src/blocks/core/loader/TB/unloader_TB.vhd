-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    unloader_TB
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

entity unloader_TB is
end unloader_TB;

architecture unloader_TB of unloader_TB is

	constant c_data_width								: natural := 64;
	constant c_addr_width								: natural := 9;
	constant c_ctrl_width								: natural := 8;
	constant c_select_width								: natural := 5;
	constant c_select										: natural := 3;
	constant c_lfsr										: boolean := false;

	signal r_cnt											: natural;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal r_t_data										: t_data_x1;
	signal r_t_data_last									: std_logic;
	signal r_t_data_wr_en								: std_logic;

	signal r_start											: std_logic;
	signal r_select										: std_logic_vector(c_select_width-1 downto 0);

	signal r_size											: std_logic_vector(c_addr_width-1 downto 0);
	signal s_last											: std_logic_vector(2 downto 0);


	signal r_data											: std_logic_vector(c_data_width-1 downto 0);
	signal r_data_last									: std_logic;
	signal r_data_wr_en									: std_logic;


	signal s_busy											: std_logic;
	signal m00_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal m00_axis_tvalid								: std_logic;
	signal m00_axis_tready								: std_logic;

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
		wait for 500ns;
		r_rst <= '0';
		wait;
	end process;


	s_last <=	"001" when (c_lfsr = false and r_size = 1) or (c_lfsr = true and r_size = 2) else
					"010" when (c_lfsr = false and r_size = 2) or (c_lfsr = true and r_size = 4) else
					"100" when (c_lfsr = false and r_size = 3) or (c_lfsr = true and r_size = 8) else
					"000";

	m00_axis_tready <= '1';


	UNLOADER_INST: entity work.unloader generic map (
		g_lfsr					=> false,					--: boolean := true;
		g_addr_width			=> c_addr_width,			--: natural := 9;
		g_data_width			=> c_data_width,			--: natural := 64;
		g_ctrl_width			=> c_ctrl_width,			--: natural := 8;
		g_select_width			=> c_select_width			--: natural := 4;
	)
	port map (
		pi_clk					=> r_clk,					--: in std_logic;
		pi_rst					=> r_rst,					--: in std_logic;
		po_busy					=> s_busy,					--: out std_logic;
		pi_start					=> r_start,					--: in std_logic;
		pi_select				=> r_select,				--: in std_logic_vector(g_select_width-1 downto 0);
		pi_sign					=> '1',						--: in std_logic;

		pi_size					=> r_size,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_last					=> s_last,					--: in std_logic_vector(2 downto 0);

		pi_data					=> r_t_data,				--: in t_data_x1;
		pi_data_last			=> r_t_data_last,			--: in std_logic;
		pi_data_wr_en			=> r_t_data_wr_en,		--: in std_logic;

		m00_axis_tdata			=> m00_axis_tdata,		--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid		=> m00_axis_tvalid,		--: out std_logic;
		m00_axis_tready		=> m00_axis_tready		--: in std_logic
	);


	r_t_data(c_select) <= r_data;
	r_t_data_last <= r_data_last;
	r_t_data_wr_en <= r_data_wr_en;

	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_start <= '0';
			r_select <= (others=>'0');
			r_size <= (others=>'0');
			r_data <= (others=>'0');
			r_data_last <= '0';

			if(r_rst = '1') then
				r_cnt <= 0;
				r_data_wr_en <= '0';
			else

				r_cnt <= r_cnt + 1;

				if(r_cnt = 5) then
					r_start <= '1';
					r_select <= to_std_logic_vector(c_select, c_select_width);
					r_size <= (2=>'1',others=>'0');
				end if;


				if(r_cnt = 20) then
					r_data_last <= '1';
				else
					r_data_last <= '0';
				end if;

				if(r_cnt > 10 and r_cnt < 21) then
					r_data <= to_std_logic_vector(r_cnt, c_data_width);
					r_data_wr_en <= '1';
				else
					r_data <= (others=>'0');
					r_data_wr_en <= '0';
				end if;



			end if;

		end if;
	end process;




end architecture;
