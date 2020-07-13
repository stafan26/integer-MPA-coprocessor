-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    21/5/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_cmc_unload
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
-------------------------------------------
-------------------------------------------


entity cpu_cmc_unload is
generic (
	g_lfsr						: boolean := true;
	g_addr_width				: natural := 9
);
port(
	pi_clk						: in std_logic;
	pi_rst						: in std_logic;

	pi_cmc_unload_start		: in std_logic;

	pi_my_size					: in std_logic_vector(g_addr_width-1 downto 0);
	pi_my_last					: in std_logic_vector(3 downto 0);

	po_cmc_data_cycle			: out std_logic;
	po_cmc_data_valid			: out std_logic;
	po_cmc_data_last			: out std_logic
);
end cpu_cmc_unload;

architecture cpu_cmc_unload of cpu_cmc_unload is

	signal r_cmc_unloader_wr_en							: std_logic;
	signal s_cmc_unloader_last								: std_logic;
	signal r_cmc_data_cycle									: std_logic;

begin

	po_cmc_data_cycle <= r_cmc_data_cycle;
	po_cmc_data_valid <= r_cmc_unloader_wr_en;
	po_cmc_data_last <= s_cmc_unloader_last;


	CPU_CMC_UNLOAD_LAST_INST: entity work.lfsr_counter_down_3_last_1 generic map (
		g_lfsr							=> g_lfsr,								--: boolean := false;
		g_n								=> g_addr_width						--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_load							=> pi_cmc_unload_start,				--: in std_logic;
		pi_data							=> pi_my_size,							--: in std_logic_vector(g_n-1 downto 0);
		pi_last							=> pi_my_last(2 downto 0),			--: in std_logic_vector(2 downto 0);
		--pi_last							=> pi_my_last(3 downto 0),			--: in std_logic_vector(3 downto 0);
		pi_change						=> r_cmc_unloader_wr_en,			--: in std_logic;
		po_last							=> s_cmc_unloader_last				--: out std_logic;
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			r_cmc_data_cycle <= pi_cmc_unload_start;

			--------------------------
			-- R_CMC_UNLOADER_WR_EN --
			--------------------------
			if(pi_rst = '1') then
				r_cmc_unloader_wr_en <= '0';
			else

				if(pi_cmc_unload_start = '1') then
					r_cmc_unloader_wr_en <= '1';
				elsif(s_cmc_unloader_last = '1') then
					r_cmc_unloader_wr_en <= '0';
				end if;

			end if;

		end if;
	end process;

end architecture;
