
library IEEE;
use IEEE.std_logic_1164.all;

use work.my_pack.all;
use work.common_pack.all;

entity cpu_cnt_last is
	generic (
		g_lfsr				: boolean := true;
		g_n					: natural := 60
	);
	port (
		pi_clk				: in std_logic;
		pi_rst				: in std_logic;

		pi_load				: in std_logic;
		pi_data				: in std_logic_vector(g_n-1 downto 0);
		pi_start				: in std_logic;

		po_last				: out std_logic
	);
end cpu_cnt_last;

architecture cpu_cnt_last of cpu_cnt_last is

	signal s_data				: std_logic_vector(g_n-1 downto 0);
	signal s_one				: std_logic_vector(g_n-1 downto 0);
	signal r_last				: std_logic;
	signal r_enable			: std_logic;

begin

	po_last <= r_last;


	LFSR_CNT_GEN: if(g_lfsr = true) generate
		s_one <= (1=>'1', others=>'0');
	end generate;

	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		s_one <= (0=>'1', others=>'0');
	end generate;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			--------------
			-- R_ENABLE --
			--------------
			if(pi_rst = '1') then
				r_enable <= '0';
			else

				if(pi_start = '1') then
					r_enable <= '1';
				elsif(r_last = '1') then
					r_enable <= '0';
				end if;

			end if;


			------------
			-- R_LAST --
			------------
			if(pi_rst = '1') then
				r_last <= '0';
			else

				if(s_data = s_one) then
					r_last <= '1';
				else
					r_last <= '0';
				end if;

			end if;

		end if;
	end process;



	LFSR_COUNTER_DOWN_INST: entity work.lfsr_counter_down generic map (
		g_lfsr					=> g_lfsr,					--: boolean := false;
		g_n						=> g_n						--: natural := 60
	)
	port map (
		pi_clk					=> pi_clk,					--: in std_logic;
		pi_rst					=> pi_rst,					--: in std_logic;
		pi_load					=> pi_load,					--: in std_logic;
		pi_data					=> pi_data,					--: in std_logic_vector(g_n-1 downto 0);
		pi_change				=> r_enable,				--: in std_logic;
		po_data					=> s_data					--: out std_logic_vector(g_n-1 downto 0)
	);






end cpu_cnt_last;
