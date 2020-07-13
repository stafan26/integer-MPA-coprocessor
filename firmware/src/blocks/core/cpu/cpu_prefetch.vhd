-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_prefetch
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

entity cpu_prefetch is
generic (
	g_ctrl_width						: natural := 8;
	g_num_of_logic_registers		: natural := 16;
	g_opcode_width						: natural := 4;
	g_reg_logic_addr_width			: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_core_data					: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_core_data_last			: in std_logic;
	pi_ctrl_core_valid				: in std_logic;
	po_ctrl_core_ready				: out std_logic;

	po_cmd_opcode						: out std_logic_vector(g_opcode_width-1 downto 0);
	po_cmd_reg_1						: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	po_cmd_reg_2						: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	po_cmd_reg_3						: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	po_cmd_reg_3_oh					: out std_logic_vector(g_num_of_logic_registers-1 downto 0);
	po_cmd_reg_all_oh					: out std_logic_vector(g_num_of_logic_registers-1 downto 0);
	po_use_aux_reg						: out std_logic;

	po_cmd_add_sub						: out std_logic;
	po_cmd_mult							: out std_logic;
	po_cmd_unload						: out std_logic;

	po_reg_1_busy_mode				: out std_logic_vector(2 downto 0);
	po_reg_2_busy_mode				: out std_logic_vector(2 downto 0);
	po_reg_3_busy_mode				: out std_logic_vector(2 downto 0);
	po_reg_3_aux_busy_mode			: out std_logic_vector(2 downto 0);

	po_cmd_ready						: out std_logic;
	pi_cmd_taken						: in std_logic
);
end cpu_prefetch;

architecture cpu_prefetch of cpu_prefetch is

	constant c_num_of_ctrl_words					: natural := div_up(3*g_reg_logic_addr_width+g_opcode_width, g_ctrl_width);

	signal r_cmd										: std_logic_vector(c_num_of_ctrl_words*g_ctrl_width-1 downto 0);

	alias a_cmd_opcode								: std_logic_vector(g_opcode_width-1 downto 0) is r_cmd(g_opcode_width-1 downto 0);
	alias a_cmd_reg_1									: std_logic_vector(g_reg_logic_addr_width-1 downto 0) is
																				r_cmd(1*g_reg_logic_addr_width+g_opcode_width-1 downto 0*g_reg_logic_addr_width+g_opcode_width);
	alias a_cmd_reg_2									: std_logic_vector(g_reg_logic_addr_width-1 downto 0) is
																				r_cmd(2*g_reg_logic_addr_width+g_opcode_width-1 downto 1*g_reg_logic_addr_width+g_opcode_width);
	alias a_cmd_reg_3									: std_logic_vector(g_reg_logic_addr_width-1 downto 0) is
																				r_cmd(3*g_reg_logic_addr_width+g_opcode_width-1 downto 2*g_reg_logic_addr_width+g_opcode_width);

	signal r_cmd_add_sub								: std_logic;
	signal r_cmd_mult									: std_logic;
	signal r_cmd_unload								: std_logic;

	signal r_ctrl_core_ready_to_read				: std_logic;
	signal r_cmd_processed							: std_logic;
	signal r_cmd_ready								: std_logic;

	signal r_reg_1_oh									: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal r_reg_2_oh									: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal r_reg_3_oh									: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal r_reg_all_oh								: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal r_use_aux_reg								: std_logic;
	signal r_use_logic_reg							: std_logic_vector(2 downto 0);

	signal r_reg_1_busy_mode						: std_logic_vector(2 downto 0);
	signal r_reg_2_busy_mode						: std_logic_vector(2 downto 0);
	signal r_reg_3_busy_mode						: std_logic_vector(2 downto 0);
	signal r_reg_3_aux_busy_mode					: std_logic_vector(2 downto 0);

begin

	po_ctrl_core_ready <= r_ctrl_core_ready_to_read;
	po_cmd_ready <= r_cmd_ready;

	po_cmd_opcode <= a_cmd_opcode;
	po_cmd_reg_1  <= a_cmd_reg_1;
	po_cmd_reg_2  <= a_cmd_reg_2;
	po_cmd_reg_3  <= a_cmd_reg_3;

	--po_cmd_reg_1_oh <= r_reg_1_oh;
	--po_cmd_reg_2_oh <= r_reg_2_oh;
	po_cmd_reg_3_oh <= r_reg_3_oh;
	po_cmd_reg_all_oh <= r_reg_all_oh;
	po_use_aux_reg <= r_use_aux_reg;

	po_reg_1_busy_mode <= r_reg_1_busy_mode;
	po_reg_2_busy_mode <= r_reg_2_busy_mode;
	po_reg_3_busy_mode <= r_reg_3_busy_mode;
	po_reg_3_aux_busy_mode <= r_reg_3_aux_busy_mode;

	po_cmd_add_sub <= r_cmd_add_sub;
	po_cmd_mult <= r_cmd_mult;
	po_cmd_unload <= r_cmd_unload;

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------
			-- R_CMD --
			-----------
			if(r_ctrl_core_ready_to_read = '1' and pi_ctrl_core_valid = '1') then
				r_cmd <= r_cmd(r_cmd'length-g_ctrl_width-1 downto 0) & pi_ctrl_core_data;
			end if;


			-------------------------------
			-- R_CTRL_CORE_READY_TO_READ --
			-------------------------------
			if(pi_rst = '1') then
				--r_ctrl_core_ready_to_read <= '1';
				r_ctrl_core_ready_to_read <= '0';
			else

				if(pi_cmd_taken = '1') then
					r_ctrl_core_ready_to_read <= '1';
				elsif(pi_ctrl_core_valid = '1' and pi_ctrl_core_data_last = '1') then
					r_ctrl_core_ready_to_read <= '0';
				end if;

			end if;


			-----------------
			-- R_CMD_READY --
			-----------------
			if(pi_rst = '1') then
				r_cmd_ready <= '0';
			else

				if(pi_cmd_taken = '1') then
					r_cmd_ready <= '0';
				elsif(r_cmd_processed = '1') then
					r_cmd_ready <= '1';
				end if;

			end if;


			------------
			-- STREAM --
			------------
			r_cmd_processed <= pi_ctrl_core_valid and pi_ctrl_core_data_last;

			r_reg_1_oh <= (others=>'0');
			r_reg_2_oh <= (others=>'0');
			r_reg_3_oh <= (others=>'0');

			r_reg_1_oh(to_natural(a_cmd_reg_1)) <= '1';
			r_reg_2_oh(to_natural(a_cmd_reg_2)) <= '1';
			r_reg_3_oh(to_natural(a_cmd_reg_3)) <= '1';

			r_reg_all_oh <= ((g_num_of_logic_registers-1 downto 0 => r_use_logic_reg(0)) and r_reg_1_oh) or
									((g_num_of_logic_registers-1 downto 0 => r_use_logic_reg(1)) and r_reg_2_oh) or
									((g_num_of_logic_registers-1 downto 0 => r_use_logic_reg(2)) and r_reg_3_oh);


			-----------------------
			-- R_REG_1_BUSY_MODE --
			-----------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_LOAD_A, g_opcode_width) =>			r_reg_1_busy_mode <= "110";
				when to_std_logic_vector(C_STD_OPCODE_LOAD_B, g_opcode_width) =>			r_reg_1_busy_mode <= "111";
				when to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) =>			r_reg_1_busy_mode <= "110";
				when to_std_logic_vector(C_STD_OPCODE_UNLOAD, g_opcode_width) =>			r_reg_1_busy_mode <= "010";
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_reg_1_busy_mode <= "000";
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_reg_1_busy_mode <= "000";
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>				r_reg_1_busy_mode <= "001";
				when others =>																				r_reg_1_busy_mode <= (others=>'0');
			end case;


			-----------------------
			-- R_REG_2_BUSY_MODE --
			-----------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) =>			r_reg_2_busy_mode <= "111";
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_reg_2_busy_mode <= "000";
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_reg_2_busy_mode <= "000";
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>				r_reg_2_busy_mode <= "001";
				when others =>																				r_reg_2_busy_mode <= (others=>'0');
			end case;


			-----------------------
			-- R_REG_3_BUSY_MODE --
			-----------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_reg_3_busy_mode <= "100";
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_reg_3_busy_mode <= "100";
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>				r_reg_3_busy_mode <= "101";
				when others =>																				r_reg_3_busy_mode <= (others=>'0');
			end case;


			---------------------------
			-- R_REG_3_AUX_BUSY_MODE --
			---------------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_reg_3_aux_busy_mode <= "100";
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_reg_3_aux_busy_mode <= "100";
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>				r_reg_3_aux_busy_mode <= "101";
				when others =>																				r_reg_3_aux_busy_mode <= (others=>'0');
			end case;



			---------------------
			-- R_USE_LOGIC_REG --
			---------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_LOAD_A, g_opcode_width) =>			r_use_logic_reg <= "001";
				when to_std_logic_vector(C_STD_OPCODE_LOAD_B, g_opcode_width) =>			r_use_logic_reg <= "001";
				when to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) =>			r_use_logic_reg <= "011";
				when to_std_logic_vector(C_STD_OPCODE_UNLOAD, g_opcode_width) =>			r_use_logic_reg <= "001";
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_use_logic_reg <= "111";
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_use_logic_reg <= "111";
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>				r_use_logic_reg <= "111";
				when others =>																				r_use_logic_reg <= (others=>'0');
			end case;


			-------------------
			-- R_USE_AUX_REG --
			-------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_use_aux_reg <= '1';
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_use_aux_reg <= '1';
				when others =>																				r_use_aux_reg <= '0';
			end case;


			-------------------
			-- R_CMD_ADD_SUB --
			-------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>				r_cmd_add_sub <= '1';
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>				r_cmd_add_sub <= '1';
				when others =>																				r_cmd_add_sub <= '0';
			end case;


			----------------
			-- R_CMD_MULT --
			----------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>				r_cmd_mult <= '1';
				when others =>																				r_cmd_mult <= '0';
			end case;

			------------------
			-- R_CMD_UNLOAD --
			------------------
			case a_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_UNLOAD, g_opcode_width) =>			r_cmd_unload <= '1';
				when others =>																				r_cmd_unload <= '0';
			end case;

		end if;
	end process;

end architecture;
