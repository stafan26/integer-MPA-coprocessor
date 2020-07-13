-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_acc_ip_64_TB
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

entity mult_acc_ip_64_TB is
end mult_acc_ip_64_TB;

architecture mult_acc_ip_64_TB of mult_acc_ip_64_TB is

	constant c_data_width								: natural := 64;
	constant c_addr_width								: natural := 9;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;
	signal r_rst_dly										: std_logic;

	signal r_bypass										: std_logic_vector(63 downto 0);

	signal s_cnt											: std_logic_vector(c_data_width-1 downto 0);

	signal s_prod_acc										: std_logic_vector(c_data_width+c_addr_width-1 downto 0);
	signal s_prod_acc_lo									: std_logic_vector(47 downto 0);
	signal s_prod_acc_hi									: std_logic_vector(c_data_width+c_addr_width-48-1 downto 0);

	signal s_prod_acc_ipc								: std_logic_vector(c_data_width+c_addr_width-1 downto 0);
	signal s_prod_acc_lo_ipc							: std_logic_vector(47 downto 0);
	signal s_prod_acc_hi_ipc							: std_logic_vector(c_data_width+c_addr_width-48-1 downto 0);

	signal r_cmp											: std_logic;
	signal r_cmp_lo										: std_logic;
	signal r_cmp_hi										: std_logic;
	signal r_cmp_all										: std_logic;
	signal r_change										: std_logic_vector(20 downto 0);

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


	s_prod_acc_hi <= s_prod_acc(c_data_width+c_addr_width-1 downto 48);
	s_prod_acc_lo <= s_prod_acc(47 downto 0);

	s_prod_acc_hi_ipc <= s_prod_acc_ipc(c_data_width+c_addr_width-1 downto 48);
	s_prod_acc_lo_ipc <= s_prod_acc_ipc(47 downto 0);


	XXX_64_INST: entity work.mult_acc_ip_64_73 port map (
		CLK							=> r_clk,								--: in std_logic;
		BYPASS						=> r_bypass(0),						--: in std_logic;
		B								=> s_cnt,								--: in std_logic_vector(g_data_width-1 downto 0);
		Q								=> s_prod_acc							--: out std_logic_vector(g_data_width+g_addr_width-1 downto 0);
	);

	XXX_64_IPC_INST: entity work.mult_acc_ip_64 generic map (
		g_data_width				=> c_data_width,						--: natural := 64;
		g_addr_width				=> c_addr_width						--: natural := 64;
	)
	port map (
		CLK							=> r_clk,								--: in std_logic;
		BYPASS						=> r_bypass(0),						--: in std_logic;
		B								=> s_cnt,								--: in std_logic_vector(g_data_width-1 downto 0);
		Q								=> s_prod_acc_ipc						--: out std_logic_vector(g_data_width+g_addr_width-1 downto 0);
	);


--	CNT_A_INST: entity work.lfsr_counter_up generic map (
--		g_lfsr		=> false,					--: boolean := false;
--		g_n			=> c_data_width			--: natural := 16
--	)
--	port map (
--		pi_clk		=> r_clk,					--: in std_logic;
--		pi_rst		=> r_rst,					--: in std_logic;
--		pi_change	=> r_change(0),			--: in std_logic;
--		po_data		=> s_cnt_A					--: out std_logic_vector(g_n-1 downto 0)
--	);


--	CNT_A_INST: entity work.lfsr_counter_down generic map (
--		g_lfsr		=> false,					--: boolean := false;
--		g_n			=> c_data_width			--: natural := 16
--	)
--	port map (
--		pi_clk		=> r_clk,					--: in std_logic;
--		pi_rst		=> r_rst,					--: in std_logic;
--		pi_load		=> '1',
--		pi_data		=> (others=>'1'),
--		pi_change	=> '1',						--: in std_logic;
--		po_data		=> s_cnt_A					--: out std_logic_vector(g_n-1 downto 0)
--	);

	CNT_A_INST: entity work.lfsr_counter_down generic map (
		g_lfsr		=> true,						--: boolean := false;
		g_n			=> c_data_width			--: natural := 16
	)
	port map (
		pi_clk		=> r_clk,					--: in std_logic;
		pi_rst		=> r_rst,					--: in std_logic;
		pi_load		=> r_rst_dly,
		pi_data		=> (10=>'1',0=>'1',others=>'0'),
		pi_change	=> r_change(0),			--: in std_logic;
		po_data		=> s_cnt					--: out std_logic_vector(g_n-1 downto 0)
	);


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			-----------
			-- R_CMP --
			-----------
			if(r_rst = '1') then
				r_cmp <= '1';
			else
				if(s_prod_acc = s_prod_acc_ipc) then
					r_cmp <= '1';
				else
					r_cmp <= '0';
				end if;
			end if;


			--------------
			-- R_CMP_LO --
			--------------
			if(r_rst = '1') then
				r_cmp_lo <= '1';
			else
				if(s_prod_acc_lo = s_prod_acc_lo_ipc) then
					r_cmp_lo <= '1';
				else
					r_cmp_lo <= '0';
				end if;
			end if;


			--------------
			-- R_CMP_HI --
			--------------
			if(r_rst = '1') then
				r_cmp_hi <= '1';
			else
				if(s_prod_acc_hi = s_prod_acc_hi_ipc) then
					r_cmp_hi <= '1';
				else
					r_cmp_hi <= '0';
				end if;
			end if;


			---------------
			-- R_CMP_ALL --
			---------------
			if(r_rst = '1') then
				r_cmp_all <= '1';
			else
				if(s_prod_acc /= s_prod_acc_ipc) then
					r_cmp_all <= '0';
				end if;
			end if;

			--------------
			-- R_CHANGE --
			--------------
			if(r_rst = '1') then
				r_change <= (1=>'1',others=>'1');
			else
				r_change <= r_change(r_change'length-2 downto 0) & r_change(r_change'length-1);
			end if;


			--------------
			-- R_BYPASS --
			--------------
			if(r_rst = '1') then
				r_bypass <= (1=>'1',others=>'0');
			else
				r_bypass <= r_bypass(r_bypass'length-2 downto 0) & r_bypass(r_bypass'length-1);
			end if;



			r_rst_dly <= r_rst;

		end if;
	end process;


end architecture;
