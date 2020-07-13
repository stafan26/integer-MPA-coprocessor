-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_mapper_swapper
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity cpu_mapper_swapper is
generic (
	g_num_of_logic_registers		: natural := 16
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_swap_pre							: in std_logic;
	pi_logic_reg_oh					: in std_logic_vector(g_num_of_logic_registers-1 downto 0);

	pi_swap_post						: in std_logic;
	pi_swap_post_en					: in std_logic;

	po_shadow_reg_swap				: out std_logic;
	po_main_reg_swap					: out std_logic_vector(g_num_of_logic_registers-1 downto 0)
);
end cpu_mapper_swapper;

architecture cpu_mapper_swapper of cpu_mapper_swapper is

	signal r_logic_reg									: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal r_shadow_reg_swap							: std_logic;
	signal r_main_reg_swap								: std_logic_vector(g_num_of_logic_registers-1 downto 0);

begin

	po_shadow_reg_swap <= r_shadow_reg_swap;
	po_main_reg_swap <= r_main_reg_swap;

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			----------------
			-- R_SWAP_PRE --
			----------------
			if(pi_swap_pre = '1') then
				r_logic_reg <= pi_logic_reg_oh;
			end if;


			-----------------------
			-- R_SHADOW_REG_SWAP --
			-----------------------
			if(pi_swap_post = '1' and pi_swap_post_en = '1') then
				r_shadow_reg_swap <= '1';
			else
				r_shadow_reg_swap <= '0';
			end if;


			---------------------
			-- R_MAIN_REG_SWAP --
			---------------------
			if(pi_swap_post = '1' and pi_swap_post_en = '1') then
				r_main_reg_swap <= r_logic_reg;
			else
				r_main_reg_swap <= (others=>'0');
			end if;

		end if;
	end process;

end architecture;
