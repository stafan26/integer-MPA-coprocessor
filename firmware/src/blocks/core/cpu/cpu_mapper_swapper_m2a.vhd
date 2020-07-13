-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_mapper_swapper_m2a
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

entity cpu_mapper_swapper_m2a is
generic (
	g_reg_phys_addr_width			: natural := 5;
	g_num_of_phys_registers			: natural := 16;
	g_num_of_shadow_registers		: natural := 2;
	g_reg_shadow_addr_width			: natural := 1
);
port(
	pi_clk								: in std_logic;

	pi_swap_pre							: in std_logic;
	pi_shadow_channel					: in std_logic_vector(g_reg_shadow_addr_width-1 downto 0);

	pi_data								: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_data_oh							: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_data								: out std_logic_vector(g_num_of_shadow_registers*g_reg_phys_addr_width-1 downto 0);
	po_data_oh							: out std_logic_vector(g_num_of_shadow_registers*g_num_of_phys_registers-1 downto 0)
);
end cpu_mapper_swapper_m2a;

architecture cpu_mapper_swapper_m2a of cpu_mapper_swapper_m2a is

	signal r_data_reg				: std_logic_vector(g_num_of_shadow_registers*g_reg_phys_addr_width-1 downto 0);
	signal r_data_reg_oh			: std_logic_vector(g_num_of_shadow_registers*g_num_of_phys_registers-1 downto 0);

begin

	po_data <= r_data_reg;
	po_data_oh <= r_data_reg_oh;

	SWAP_ROUTER_AUX_GEN: for i in 0 to g_num_of_shadow_registers-1 generate

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				------------------
				-- R_SHADOW_REG --
				------------------
				if(pi_swap_pre = '1' and pi_shadow_channel = i) then
					r_data_reg(g_reg_phys_addr_width*(i+1)-1 downto g_reg_phys_addr_width*i) <= pi_data;
					r_data_reg_oh(g_num_of_phys_registers*(i+1)-1 downto g_num_of_phys_registers*i) <= pi_data_oh;
				end if;

			end if;
		end process;

	end generate;

end architecture;
