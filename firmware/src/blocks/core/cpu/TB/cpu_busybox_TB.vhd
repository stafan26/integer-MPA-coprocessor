-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    9/9/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_busybox_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

entity cpu_busybox_TB is
end cpu_busybox_TB;

architecture cpu_busybox_TB of cpu_busybox_TB is

	constant c_lfsr										: boolean := true;
	constant c_num_of_registers						: natural := 16;
	constant c_reg_addr_width							: natural := 4;

	constant c_filepath									: string := "prog.bin";
	constant c_ctrl_width								: natural := 8;


	constant c_cnt_wait									: natural := 128;
	signal r_cnt											: natural;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	type t_fsm is (FSM_AWAIT_FLAG,
							FSM_EXEC,
							FSM_DELAY);

	signal r_fsm_state									: t_fsm;

	signal s_m00_tdata									: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s_m00_tlast									: std_logic;
	signal s_m00_tvalid									: std_logic;
	signal s_m00_tready									: std_logic;

	signal s_cmd_opcode									: std_logic_vector(c_reg_addr_width-1 downto 0);
	signal s_cmd_opcode_post							: std_logic_vector(c_reg_addr_width-1 downto 0);
	signal s_cmd_reg_1									: std_logic_vector(c_reg_addr_width-1 downto 0);
	signal s_cmd_reg_2									: std_logic_vector(c_reg_addr_width-1 downto 0);
	signal s_cmd_reg_3									: std_logic_vector(c_reg_addr_width-1 downto 0);
	signal s_cmd_ready									: std_logic;
	signal r_cmd_taken									: std_logic;

	signal r_cmd_opcode									: std_logic_vector(c_reg_addr_width-1 downto 0);
	signal r_mult_last_en								: std_logic;
	signal r_add_last_both_en							: std_logic;

	signal r_mult_last									: std_logic;
	signal r_add_last										: std_logic_vector(1 downto 0);
	signal r_add_last_both								: std_logic;
	signal r_reg_last										: std_logic_vector(c_num_of_registers-1 downto 0);

	signal s_mult_busy									: std_logic;
	signal s_add_busy										: std_logic;
	signal s_reg_busy										: std_logic_vector(c_num_of_registers-1 downto 0);

	type t_opcode is (LOAD_A, LOAD_B, LOAD_AB, UNLOAD, ADD, SUB, MULT, ERROR);
	signal s_opcode										: t_opcode;

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


	FORCER_INST: entity work.forcer_prog generic map (
		g_filepath			=> c_filepath,			--: string := "i.txt";
		g_data_width		=> c_ctrl_width		--: natural := 8
	)
	port map (
		pi_clk				=> r_clk,				--: in std_logic;
		pi_rst				=> r_rst,				--: in std_logic;
		po_m00_tdata		=> s_m00_tdata,		--: out std_logic_vector(g_data_width-1 downto 0);
		po_m00_tlast		=> s_m00_tlast,		--: out std_logic;
		po_m00_tvalid		=> s_m00_tvalid,		--: out std_logic;
		pi_m00_tready		=> s_m00_tready		--: in std_logic
	);

	CPU_CMD_GATHER_INST: entity work.cpu_cmd_gather generic map (
		g_ctrl_width				=> c_ctrl_width,					--: natural := 8;
		g_reg_addr_width			=> c_reg_addr_width				--: natural := 4
	)
	port map (
		pi_clk						=> r_clk,							--: in std_logic;
		pi_rst						=> r_rst,							--: in std_logic;
		pi_ctrl_core_data			=> s_m00_tdata,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_core_data_last	=> s_m00_tlast,					--: in std_logic;
		pi_ctrl_core_valid		=> s_m00_tvalid,					--: in std_logic;
		po_ctrl_core_ready		=> s_m00_tready,					--: out std_logic;
		po_cmd_opcode				=> s_cmd_opcode,					--: out std_logic_vector(g_reg_addr_width-1 downto 0);
		po_cmd_reg_1				=> s_cmd_reg_1,					--: out std_logic_vector(g_reg_addr_width-1 downto 0);
		po_cmd_reg_2				=> s_cmd_reg_2,					--: out std_logic_vector(g_reg_addr_width-1 downto 0);
		po_cmd_reg_3				=> s_cmd_reg_3,					--: out std_logic_vector(g_reg_addr_width-1 downto 0);
		po_cmd_ready				=> s_cmd_ready,					--: out std_logic;
		pi_cmd_taken				=> r_cmd_taken						--: in std_logic
	);

	s_cmd_opcode_post <= x"8" when s_cmd_opcode = x"2" else s_cmd_opcode;


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_cmd_taken <= '0';

			if(r_rst = '1') then
				r_fsm_state <= FSM_AWAIT_FLAG;
			else

				case r_fsm_state is
					when FSM_AWAIT_FLAG =>
						if(s_cmd_ready = '1') then
							r_fsm_state <= FSM_EXEC;
						end if;

					when FSM_EXEC =>
						r_fsm_state <= FSM_DELAY;
						r_cmd_taken <= '1';
						r_cnt <= c_cnt_wait;

					when FSM_DELAY =>
						if(r_cnt = 0) then
							r_fsm_state <= FSM_AWAIT_FLAG;
						else
							r_cnt <= r_cnt - 1;
						end if;

				end case;

			end if;

		end if;
	end process;


	CPU_BUSYBOX_INST: entity work.cpu_busybox generic map (
		g_lfsr					=> c_lfsr,						--: boolean := true;
		g_num_of_registers	=> c_num_of_registers,		--: natural := 16;
		g_reg_addr_width		=> c_reg_addr_width			--: natural := 4
	)
	port map (
		pi_clk					=> r_clk,					--: in std_logic;
		pi_rst					=> r_rst,					--: in std_logic;
		pi_cmd_opcode			=> s_cmd_opcode_post,	--: in std_logic_vector(g_reg_addr_width-1 downto 0);
		pi_cmd_reg_1			=> s_cmd_reg_1,			--: in std_logic_vector(g_reg_addr_width-1 downto 0);
		pi_cmd_reg_2			=> s_cmd_reg_2,			--: in std_logic_vector(g_reg_addr_width-1 downto 0);
		pi_cmd_reg_3			=> s_cmd_reg_3,			--: in std_logic_vector(g_reg_addr_width-1 downto 0);
		pi_cmd_taken			=> r_cmd_taken,			--: in std_logic;
		pi_mult_last			=> r_mult_last,			--: in std_logic;
		pi_add_last				=> r_add_last,				--: in std_logic_vector(1 downto 0);
		pi_add_last_both		=> r_add_last_both,		--: in std_logic;
		pi_reg_last				=> r_reg_last,				--: in std_logic_vector(g_num_of_registers-1 downto 0);
		po_mult_busy			=> s_mult_busy,			--: out std_logic;
		po_add_busy				=> s_add_busy,				--: out std_logic;
		po_reg_busy				=> s_reg_busy				--: out std_logic_vector(g_num_of_registers-1 downto 0)
	);

	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_mult_last <= '0';
			r_add_last_both <= '0';
			r_add_last <= (others=>'0');
			r_reg_last <= (others=>'0');

			if(r_cmd_taken = '1') then
				r_cmd_opcode <= s_cmd_opcode_post;
			end if;


			if(r_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_MULT, c_reg_addr_width)) then
				r_mult_last_en <= '1';
			else
				r_mult_last_en <= '0';
			end if;


			if(r_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_ADD, c_reg_addr_width) or r_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_SUB, c_reg_addr_width)) then
				r_add_last_both_en <= '1';
			else
				r_add_last_both_en <= '0';
			end if;


			if(r_cnt = c_cnt_wait - 10) then
				r_reg_last <= (others=>'1');
			end if;


			if(r_cnt = c_cnt_wait - 20) then
				if(r_mult_last_en = '1') then
					r_mult_last <= '1';
				end if;

				if(r_add_last_both_en = '1') then
					r_add_last_both <= '1';
					r_add_last <= (others=>'1');
				end if;
			end if;

		end if;
	end process;


	s_opcode <= LOAD_A		when r_cmd_opcode = C_STD_OPCODE_LOAD_A	else
					LOAD_B		when r_cmd_opcode = C_STD_OPCODE_LOAD_B	else
					LOAD_AB		when r_cmd_opcode = C_STD_OPCODE_LOAD_AB	else
					UNLOAD		when r_cmd_opcode = C_STD_OPCODE_UNLOAD	else
					ADD			when r_cmd_opcode = C_STD_OPCODE_ADD		else
					SUB			when r_cmd_opcode = C_STD_OPCODE_SUB		else
					MULT			when r_cmd_opcode = C_STD_OPCODE_MULT		else
					ERROR;

end architecture;
