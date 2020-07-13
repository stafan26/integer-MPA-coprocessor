
library IEEE;
use IEEE.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity switchbox_x4_TB is
end switchbox_x4_TB;

architecture switchbox_x4_TB of switchbox_x4_TB is

	constant c_id										: natural := to_natural(x"13");
	constant c_data_width							: natural := 8;
	constant c_ctrl_width							: natural := 8;
	constant c_extra_width							: natural := 4;

	signal r_clk										: std_logic;
	signal r_rst										: std_logic;

	signal r_ctrl_ch_1								: std_logic_vector(c_ctrl_width-1 downto 0);
	signal r_ctrl_ch_2								: std_logic_vector(c_ctrl_width-1 downto 0);
	signal r_ctrl_valid								: std_logic_vector(3 downto 0);


	signal r_data										: std_logic_vector(c_data_width-1 downto 0);

	signal s_data_ch_1								: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_ch_2								: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_ch_3								: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_ch_4								: std_logic_vector(c_data_width-1 downto 0);

	signal r_data_last_ch_2								: std_logic;


	-- OUTPUTS

	signal s_ctrl										: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s_ctrl_valid								: std_logic;

	signal s_data										: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_last								: std_logic;
	signal s_data_extra								: std_logic_vector(c_extra_width-1 downto 0);

begin


	s_data_ch_1 <= r_data;
	s_data_ch_2 <= '0' & r_data(r_data'length-1 downto 1);
	s_data_ch_3 <= x"0" & r_data(r_data'length-5 downto 0);
	s_data_ch_4 <= r_data(r_data'length-5 downto 0) & x"0";


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


	SWITCHBOX_X4_EXTRA_INST: entity work.switchbox_x4_extra generic map (
--		g_output_ctrl				=> c_output_ctrl,								--: string := "YES";
--		g_output_data_last		=> c_output_data_last,						--: string := "YES";
--		g_ctrl_pass_through		=> c_ctrl_pass_through,						--: string := "YES";
		g_id							=> c_id,											--: natural := 36;
		g_data_width				=> c_data_width,								--: natural := 64;
		g_ctrl_width				=> c_ctrl_width,								--: natural := 8;
		g_extra_width				=> c_extra_width								--: natural := 4
	)
	port map (
		pi_clk						=> r_clk,										--: in std_logic;
		pi_rst						=> r_rst,										--: in std_logic;
		pi_ctrl_ch_1				=> r_ctrl_ch_1,								--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_2				=> r_ctrl_ch_2,								--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_3				=> (others=>'0'),								--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_4				=> (others=>'0'),								--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid				=> r_ctrl_valid,								--: in std_logic_vector(3 downto 0);
		po_ctrl						=> s_ctrl,										--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_ctrl_valid				=> s_ctrl_valid,								--: out std_logic;
		pi_data_ch_1				=> s_data_ch_1,								--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_2				=> s_data_ch_2,								--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_3				=> s_data_ch_3,								--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_4				=> s_data_ch_4,								--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_last_ch_1			=> '0',											--: in std_logic;
		pi_data_last_ch_2			=> r_data_last_ch_2,							--: in std_logic;
		pi_data_last_ch_3			=> '0',											--: in std_logic;
		pi_data_last_ch_4			=> '0',											--: in std_logic;
		pi_data_extra_ch_1		=> (others=>'0'),								--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_2		=> (others=>'0'),								--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_3		=> (others=>'0'),								--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_4		=> (others=>'0'),								--: in std_logic_vector(g_extra_width-1 downto 0);
		po_data						=> s_data,										--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> s_data_last,								--: out std_logic;
		po_data_extra				=> s_data_extra								--: out std_logic_vector(g_extra_width-1 downto 0)
	);


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			------------
			-- R_DATA --
			------------
			if(r_rst = '1') then
				r_data <= (others=>'0');
			else
				r_data <= r_data + 1;
			end if;


			r_ctrl_ch_1 <= x"00";
			r_ctrl_ch_2 <= x"00";
			r_ctrl_valid <= (others=>'0');
			r_data_last_ch_2 <= '0';

			if(r_data = 10) then
				r_ctrl_ch_1 <= x"12";
				r_ctrl_ch_2 <= x"13";
				r_ctrl_valid <= x"3";
			elsif(r_data = 11) then
				r_ctrl_ch_1 <= x"20";
				r_ctrl_ch_2 <= x"22";
			elsif(r_data = 12) then
				r_ctrl_ch_1 <= x"60";
				r_ctrl_ch_2 <= x"62";
			elsif(r_data = 20) then
				r_data_last_ch_2 <= '1';
			elsif(r_data = 28) then
				r_data_last_ch_2 <= '1';
			end if;

		end if;
	end process;


end switchbox_x4_TB;
