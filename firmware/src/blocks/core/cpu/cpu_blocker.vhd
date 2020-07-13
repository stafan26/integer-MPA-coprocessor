-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_blocker
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		-
--
-------------------------------------------
-------------------------------------------

entity cpu_blocker is
generic (
	g_num_of_phys_registers			: natural := 18
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_add_sub_busy					: in std_logic;
	pi_mult_busy						: in std_logic;
	pi_reg_busy							: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_unloader_busy					: in std_logic;

	pi_cmd_add_sub						: in std_logic;
	pi_cmd_mult							: in std_logic;
	pi_cmd_unload						: in std_logic;

	pi_phys_reg_active_all			: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_cmd_ready						: in std_logic;
	po_cmd_taken						: out std_logic;
	po_cmd_taken_n						: out std_logic
);
end cpu_blocker;

architecture cpu_blocker of cpu_blocker is

	constant c_dual_reg_cmp_width						: natural := C_MAX_NUM_OF_IN_PER_MUX / 2;
	constant c_num_of_reg_cmp_parts					: natural := g_num_of_phys_registers / c_dual_reg_cmp_width;

	constant c_cmd_pre_delay_width					: natural := 4;
	constant c_cmd_post_delay_width					: natural := 4;

	signal r_add_sub_mult_unloader_busy				: std_logic;
	signal r_reg_busy_vec								: std_logic_vector(c_num_of_reg_cmp_parts-1 downto 0);
	signal r_reg_busy										: std_logic;

	signal r_cmd_ready									: std_logic;
	signal r_cmd_ready_to_exec							: std_logic;
	signal r_cmd_busy										: std_logic_vector(c_cmd_pre_delay_width-1 downto 0);
	signal r_cmd_done										: std_logic_vector(c_cmd_post_delay_width-1 downto 0);

	signal r_cmd_taken									: std_logic;
	signal r_cmd_taken_n									: std_logic;

begin

	po_cmd_taken <= r_cmd_taken;
	po_cmd_taken_n <= r_cmd_taken_n;

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then


			-----------------
			-- MASKED_BUSY --
			-----------------

			----------------
			-- R_REG_BUSY --						-- 1 bit, r_busy = '1' only when busy and required, otherwise r_busy = '0'
			----------------
			r_reg_busy <= or_reduce(r_reg_busy_vec);

			----------------------------------
			-- R_ADD_SUB_MULT_UNLOADER_BUSY --
			----------------------------------
			if((pi_add_sub_busy = '1' and pi_cmd_add_sub = '1') or									-- ADD_SUB
				(pi_mult_busy = '1' and pi_cmd_mult = '1') or											-- MULT
				((pi_unloader_busy = '1' or pi_add_sub_busy = '1') and pi_cmd_unload = '1')		-- UNLOADER
			) then
				r_add_sub_mult_unloader_busy <= '1';
			else
				r_add_sub_mult_unloader_busy <= '0';
			end if;


			-----------------
			-- R_CMD_READY --
			-----------------
			r_cmd_ready <= pi_cmd_ready;


			----------------
			-- R_CMD_BUSY --
			----------------
			if(r_cmd_ready = '0' and pi_cmd_ready = '1') then
				r_cmd_busy <= (others=>'1');
			else
				r_cmd_busy <= '0' & r_cmd_busy(r_cmd_busy'length-1 downto 1);
			end if;


			-------------------------
			-- R_CMD_READY_TO_EXEC --
			-------------------------
			if(r_cmd_ready = '1' and pi_cmd_ready = '1' and r_cmd_busy(0) = '0') then
				r_cmd_ready_to_exec <= '1';
			else
				r_cmd_ready_to_exec <= '0';
			end if;


			----------------
			-- R_CMD_DONE --
			----------------
			if(r_cmd_taken = '1') then
				r_cmd_done <= (others=>'0');
			else
				r_cmd_done <= '1' & r_cmd_done(r_cmd_done'length-1 downto 1);
			end if;


			--------------------------------
			-- R_CMD_TAKEN / R_CMD_TAKEN_N--
			--------------------------------
			if(pi_rst = '1') then
				r_cmd_taken <= '0';
				r_cmd_taken_n <= '1';
			else
				if(r_add_sub_mult_unloader_busy = '0' and r_reg_busy = '0' and r_cmd_ready_to_exec = '1' and r_cmd_taken = '0' and r_cmd_done(0) = '1') then
					r_cmd_taken <= '1';
					r_cmd_taken_n <= '0';
				else
					r_cmd_taken <= '0';
					r_cmd_taken_n <= '1';
				end if;
			end if;

		end if;
	end process;


	--------------------
	-- R_REG_BUSY_VEC --
	--------------------
	R_REG_BUSY_VEC_GEN: for i in 0 to c_num_of_reg_cmp_parts-1 generate

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then
				if(i = c_num_of_reg_cmp_parts-1) then								-- GENERATE
					r_reg_busy_vec(i) <= or_reduce(pi_reg_busy(pi_reg_busy'length-1 downto i*c_dual_reg_cmp_width) and
																pi_phys_reg_active_all(pi_reg_busy'length-1 downto i*c_dual_reg_cmp_width));
				else																			-- GENERATE
					r_reg_busy_vec(i) <= or_reduce(pi_reg_busy((i+1)*c_dual_reg_cmp_width-1 downto i*c_dual_reg_cmp_width) and
																pi_phys_reg_active_all((i+1)*c_dual_reg_cmp_width-1 downto i*c_dual_reg_cmp_width));
				end if;
			end if;
		end process;

	end generate;

end architecture;
