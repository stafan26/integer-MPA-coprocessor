-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_address_selector
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--use work.pro_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity reg_address_selector is
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_cpu_addr_init_up_A			: in std_logic_vector(1 downto 0);
	pi_cpu_data_cycle_A				: in std_logic;
	pi_cpu_data_valid_A				: in std_logic;
	pi_cpu_data_last_A				: in std_logic_vector(1 downto 0);

	pi_cpu_addr_init_up_B			: in std_logic_vector(1 downto 0);
	pi_cpu_data_cycle_B				: in std_logic;
	pi_cpu_data_valid_B				: in std_logic;
	pi_cpu_data_last_B				: in std_logic_vector(1 downto 0);

	pi_start								: in std_logic;
	pi_cmc_channel						: in std_logic;
	pi_operand_B						: in std_logic;

	po_cpu_addr_init_up				: out std_logic;
	po_cpu_data_cycle					: out std_logic;
	po_cpu_data_valid					: out std_logic;
	po_cpu_data_last_my				: out std_logic;
	po_cpu_data_last_other			: out std_logic

);
end reg_address_selector;

architecture reg_address_selector of reg_address_selector is

	signal r_switch										: std_logic;
	signal r_cpu_data_last_my							: std_logic;

begin

	po_cpu_data_last_my <= r_cpu_data_last_my;

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			--------------
			-- R_SWITCH --
			--------------
			if(pi_rst = '1') then
				r_switch <= '0';
			else

				if(pi_start = '1') then
					r_switch <= '1';
				elsif(r_cpu_data_last_my = '1') then
					r_switch <= '0';
				end if;

			end if;


			------------
			-- STREAM --
			------------
			if(pi_start = '0' and r_switch = '0') then
				po_cpu_data_cycle <= '0';
			else
				if(pi_cmc_channel = '0') then
					po_cpu_data_cycle <= pi_cpu_data_cycle_A;
				else
					po_cpu_data_cycle <= pi_cpu_data_cycle_B;
				end if;
			end if;

			if(pi_start = '0' and r_switch = '0') then
				po_cpu_data_valid <= '0';
			else
				if(pi_cmc_channel = '0') then
					po_cpu_data_valid <= pi_cpu_data_valid_A;
				else
					po_cpu_data_valid <= pi_cpu_data_valid_B;
				end if;
			end if;


			-------------------------
			-- PO_CPU_ADDR_INIT_UP --
			-------------------------
			if(pi_start = '0' and r_switch = '0') then
				po_cpu_addr_init_up <= '0';
			else
				if(pi_operand_B = '0' and pi_cmc_channel = '0') then
					po_cpu_addr_init_up <= pi_cpu_addr_init_up_A(0);
				elsif(pi_operand_B = '0' and pi_cmc_channel = '1') then
					po_cpu_addr_init_up <= pi_cpu_addr_init_up_B(0);
				elsif(pi_operand_B = '1' and pi_cmc_channel = '0') then
					po_cpu_addr_init_up <= pi_cpu_addr_init_up_A(1);
				else
					po_cpu_addr_init_up <= pi_cpu_addr_init_up_B(1);
				end if;
			end if;


			------------------------
			-- R_CPU_DATA_LAST_MY --
			------------------------
			if(pi_start = '0' and r_switch = '0') then
				r_cpu_data_last_my <= '0';
			else
				if(pi_operand_B = '0' and pi_cmc_channel = '0') then
					r_cpu_data_last_my <= pi_cpu_data_last_A(0);
				elsif(pi_operand_B = '0' and pi_cmc_channel = '1') then
					r_cpu_data_last_my <= pi_cpu_data_last_B(0);
				elsif(pi_operand_B = '1' and pi_cmc_channel = '0') then
					r_cpu_data_last_my <= pi_cpu_data_last_A(1);
				else
					r_cpu_data_last_my <= pi_cpu_data_last_B(1);
				end if;
			end if;


			----------------------------
			-- PO_CPU_DATA_LAST_OTHER --
			----------------------------
			if(pi_start = '0' and r_switch = '0') then
				po_cpu_data_last_other <= '0';
			else
				if(pi_operand_B = '0' and pi_cmc_channel = '0') then
					po_cpu_data_last_other <= pi_cpu_data_last_A(1);
				elsif(pi_operand_B = '0' and pi_cmc_channel = '1') then
					po_cpu_data_last_other <= pi_cpu_data_last_B(1);
				elsif(pi_operand_B = '1' and pi_cmc_channel = '0') then
					po_cpu_data_last_other <= pi_cpu_data_last_A(0);
				else
					po_cpu_data_last_other <= pi_cpu_data_last_B(0);
				end if;
			end if;

		end if;
	end process;

end architecture;
