-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_executer
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

entity cpu_executer is
generic (
	g_num_of_phys_registers			: natural := 18;
	g_reg_phys_addr_width			: natural := 5;
	g_opcode_width						: natural := 4;
	g_ctrl_width						: natural := 8
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_cmd_opcode						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_cmd_reg_1						: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_cmd_reg_2						: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_cmd_reg_3						: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_cmd_reg_3_aux					: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_cmd_taken						: in std_logic;
	pi_cmd_taken_n						: in std_logic;

	po_reg_mode_start					: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_reg_mode_B						: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_reg_mode_aux					: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_reg_mode							: out std_logic_vector(2 downto 0);

	po_cpu_sign							: out std_logic;
	po_cpu_update						: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

	po_swap_pre							: out std_logic;

	pi_main_sign						: in std_logic;
	pi_other_sign						: in std_logic;

	pi_cmc_busy							: in std_logic_vector(1 downto 0);

	po_cmc_add_sub_start				: out std_logic;
	po_cmc_mult_start					: out std_logic;
	po_cmc_unload_start				: out std_logic;

	po_set_zero							: out std_logic;
	po_set_one							: out std_logic;
	po_set_zero_or_one				: out std_logic;

	po_cmc_start						: out std_logic;
	po_cmc_oper							: out std_logic_vector(1 downto 0);
	po_cmc_channel						: out std_logic;

	po_adder_sign_inverted			: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

	po_loader_start					: out std_logic_vector(1 downto 0);

	po_unloader_start					: out std_logic;
	po_unloader_select				: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);

	po_reg_ctrl_ch_1					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_reg_ctrl_ch_1_valid_n		: out std_logic;
	po_reg_ctrl_ch_2					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_reg_ctrl_ch_2_valid_n		: out std_logic;
	po_com_ctrl							: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_com_ctrl_valid_n				: out std_logic;
	po_oper_ctrl_ch_1					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_oper_ctrl_ch_2					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_oper_ctrl_valid_n				: out std_logic

);
end cpu_executer;

architecture cpu_executer of cpu_executer is

	constant c_ctrl_ch_1_length						: natural := 4;
	constant c_ctrl_ch_2_length						: natural := 4;

	constant c_ctrl_zero									: std_logic_vector(g_ctrl_width-1 downto 0) := (others=>'0');

	signal r_main_sign									: std_logic;
	signal r_other_sign 									: std_logic;
	signal r_cpu_update_mask							: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_cpu_update_mask							: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_swap_pre_current							: std_logic;
	signal r_swap_pre										: std_logic;

	signal r_instr_load_A_en							: std_logic;
	signal r_instr_load_B_en							: std_logic;
	signal r_instr_load_AB_en							: std_logic;
	signal r_instr_unload_en							: std_logic;
	signal r_instr_set_zero_en							: std_logic;
	signal r_instr_set_one_en							: std_logic;
	signal r_instr_set_zero_or_one_en				: std_logic;
	signal r_instr_sign_to_step						: std_logic;
	signal r_instr_add_en								: std_logic;
	signal r_instr_sub_en								: std_logic;
	signal r_instr_add_sub_en							: std_logic;
	signal r_instr_mult_en								: std_logic;
	signal r_instr_oper_dly								: std_logic;
	signal r_instr_oper_dly_dly						: std_logic;
	signal r_instr_add_sub_dly							: std_logic;
	signal r_instr_add_sub_dly_dly					: std_logic;

	signal r_cmc_start									: std_logic;
	signal r_cmc_oper										: std_logic_vector(1 downto 0);
	signal r_cmc_channel									: std_logic;

	signal r_add_sub										: std_logic;
	signal r_single_mode									: std_logic;

	signal r_reg_mode_start								: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_reg_mode_B									: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_reg_mode_aux								: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_reg_mode										: std_logic_vector(2 downto 0);

	signal r_load_ab										: std_logic;
	signal r_cmd_write_reg_1							: std_logic;
	signal r_cmd_reg_1									: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_cmd_reg_3									: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_cmd_reg_3_aux								: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_aux_used										: std_logic;

	signal r_adder_sign_inverted						: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_loader_start								: std_logic_vector(1 downto 0);
	signal r_unloader_start								: std_logic;
	signal r_unload_reg									: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal r_reg_ctrl_ch_1								: std_logic_vector(c_ctrl_ch_1_length*g_ctrl_width-1 downto 0);
	signal r_reg_ctrl_ch_1_valid_n					: std_logic;
	signal r_reg_ctrl_ch_2								: std_logic_vector(c_ctrl_ch_2_length*g_ctrl_width-1 downto 0);
	signal r_reg_ctrl_ch_2_valid_n					: std_logic;
	signal r_com_ctrl										: std_logic_vector(g_ctrl_width-1 downto 0);
	signal r_com_ctrl_valid_n							: std_logic;

	signal r_oper_ctrl_ch_1								: std_logic_vector(2*g_ctrl_width-1 downto 0);
	signal r_oper_ctrl_ch_2								: std_logic_vector(2*g_ctrl_width-1 downto 0);
	signal r_oper_ctrl_valid_n							: std_logic;

begin

	LOADER_START_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 2,						--: natural := 64;
		g_delay				=> 1						--: natural := 4
	)
	port map (
		pi_clk			=> pi_clk,					--: in std_logic;
		pi_data			=> r_loader_start,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data			=> po_loader_start		--: out std_logic_vector(g_data_width-1 downto 0)
	);


	CMC_ADD_SUB_START_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,									--: natural := 64;
		g_delay				=> 1									--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,							--: in std_logic;
		pi_data(0)			=> r_instr_add_sub_en,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> po_cmc_add_sub_start			--: out std_logic_vector(g_data_width-1 downto 0)
	);


	po_cmc_mult_start <= r_instr_mult_en;
	po_cmc_unload_start <= r_unloader_start;

	po_set_zero <= r_instr_set_zero_en;
	po_set_one <= r_instr_set_one_en;
	po_set_zero_or_one <= r_instr_set_zero_or_one_en;

	po_cmc_start <= r_cmc_start;
	po_cmc_oper <= r_cmc_oper;
	po_cmc_channel <= r_cmc_channel;

	po_reg_mode_start <= r_reg_mode_start;
	po_reg_mode_B <= r_reg_mode_B;
	po_reg_mode_aux <= r_reg_mode_aux;
	po_reg_mode <= r_reg_mode;

	po_swap_pre <= r_swap_pre;
	po_adder_sign_inverted <= r_adder_sign_inverted;

	po_unloader_start				<= r_unloader_start;																									--: out std_logic;
	po_unloader_select			<= r_unload_reg;
	po_reg_ctrl_ch_1				<= r_reg_ctrl_ch_1(r_reg_ctrl_ch_1'length-1 downto r_reg_ctrl_ch_1'length-g_ctrl_width);		--: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_reg_ctrl_ch_1_valid_n	<= r_reg_ctrl_ch_1_valid_n;																						--: out std_logic;
	po_reg_ctrl_ch_2				<= r_reg_ctrl_ch_2(r_reg_ctrl_ch_2'length-1 downto r_reg_ctrl_ch_2'length-g_ctrl_width);		--: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_reg_ctrl_ch_2_valid_n	<= r_reg_ctrl_ch_2_valid_n;																						--: out std_logic;
	po_com_ctrl						<= r_com_ctrl(r_com_ctrl'length-1 downto r_com_ctrl'length-g_ctrl_width);							--: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_com_ctrl_valid_n			<= r_com_ctrl_valid_n;																								--: out std_logic;
	po_oper_ctrl_ch_1				<= r_oper_ctrl_ch_1(r_oper_ctrl_ch_1'length-1 downto r_oper_ctrl_ch_1'length-g_ctrl_width);	--: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_oper_ctrl_ch_2				<= r_oper_ctrl_ch_2(r_oper_ctrl_ch_2'length-1 downto r_oper_ctrl_ch_2'length-g_ctrl_width);	--: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_oper_ctrl_valid_n			<= r_oper_ctrl_valid_n;																								--: out std_logic


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(pi_rst = '1') then
				r_cmc_channel <= '1';
			else

				if(pi_cmd_taken = '1') then
					case pi_cmc_busy is
						when "00" =>		r_cmc_channel <= not r_cmc_channel;
						when "01" =>		r_cmc_channel <= '1';
						when "10" =>		r_cmc_channel <= '0';
						when others =>		r_cmc_channel <= '0';
					end case;
				end if;
			end if;

		end if;
	end process;



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------------------
			-- R_SWAP_PRE_CURRENT --
			------------------------
			if((pi_cmd_opcode = C_STD_OPCODE_ADD and pi_main_sign = '1' and pi_other_sign = '0') or
			(pi_cmd_opcode = C_STD_OPCODE_ADD and pi_main_sign = '0' and pi_other_sign = '1') or
			(pi_cmd_opcode = C_STD_OPCODE_SUB and pi_main_sign = '1' and pi_other_sign = '1') or
			(pi_cmd_opcode = C_STD_OPCODE_SUB and pi_main_sign = '0' and pi_other_sign = '0')
			) then
				r_swap_pre_current <= '1';
			else
				r_swap_pre_current <= '0';
			end if;


			----------------
			-- R_SWAP_PRE --
			----------------
			if(pi_cmd_taken = '1' and r_swap_pre_current = '1') then
				r_swap_pre <= '1';
			else
				r_swap_pre <= '0';
			end if;


--			---------------------------
--			-- R_ADDER_SIGN_INVERTED --
--			---------------------------
--			if(pi_rst = '1') then
--				r_adder_sign_inverted <= '0';
--			else
--				if(r_instr_add_en = '1' and r_main_sign = '1' and r_other_sign = '0') then
--					r_adder_sign_inverted <= r_cmd_reg_3;
--				else
--					r_adder_sign_inverted <= (others=>'0');
--				end if;
--			end if;

		end if;
	end process;


	MULT_UPDATE_GEN: for i in 0 to g_num_of_phys_registers-1 generate
		s_cpu_update_mask(i) <= '1' when pi_cmd_reg_3 = i else '0';

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				-------------------
				-- PO_CPU_UPDATE --		6
				-------------------
				if(r_instr_mult_en = '1') then				-- MULT
					po_cpu_update(i) <= r_cpu_update_mask(i);
				elsif(r_instr_add_en = '1') then				-- ADD
					po_cpu_update(i) <= r_cpu_update_mask(i) and (r_main_sign xnor r_other_sign);
				elsif(r_instr_sub_en = '1') then				-- SUB
					po_cpu_update(i) <= r_cpu_update_mask(i) and (r_main_sign xor r_other_sign);
				else
					po_cpu_update(i) <= '0';
				end if;

			end if;
		end process;

	end generate;


	R_CMD_REG_X_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				-----------------
				-- R_CMD_REG_1 --		5
				-----------------
				if(to_natural(pi_cmd_reg_1) = i) then
					r_cmd_reg_1(i) <= '1';
				else
					r_cmd_reg_1(i) <= '0';
				end if;


				-----------------
				-- R_CMD_REG_3 --		5
				-----------------
				if(to_natural(pi_cmd_reg_3) = i) then
					r_cmd_reg_3(i) <= '1';
				else
					r_cmd_reg_3(i) <= '0';
				end if;


				---------------------
				-- R_CMD_REG_3_AUX --		5
				---------------------
				if(to_natural(pi_cmd_reg_3_aux) = i) then
					r_cmd_reg_3_aux(i) <= '1';
				else
					r_cmd_reg_3_aux(i) <= '0';
				end if;

			end if;
		end process;

	end generate;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			r_cpu_update_mask <= s_cpu_update_mask;
			r_main_sign <= pi_main_sign;
			r_other_sign <= pi_other_sign;


			-----------------
			-- PO_CPU_SIGN --			5
			-----------------
			if(r_instr_mult_en = '1') then				-- MULT
				po_cpu_sign <= r_main_sign xor r_other_sign;
			elsif(r_instr_add_en = '1') then				-- ADD
				po_cpu_sign <= r_main_sign;
			elsif(r_instr_sub_en = '1') then				-- SUB
				po_cpu_sign <= r_main_sign;
			else
				po_cpu_sign <= '0';
			end if;


			---------------
			-- R_ADD_SUB --
			---------------
			if(pi_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width)) then
				r_add_sub <= pi_main_sign xor pi_other_sign;
			elsif(pi_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width)) then
				r_add_sub <= pi_main_sign xnor pi_other_sign;
			else
				r_add_sub <= '0';
			end if;


			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_LOAD_A	) then r_instr_load_A_en	<= '1'; else r_instr_load_A_en	<= '0'; end if;
			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_LOAD_B	) then r_instr_load_B_en	<= '1'; else r_instr_load_B_en	<= '0'; end if;
			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_LOAD_AB	) then r_instr_load_AB_en	<= '1'; else r_instr_load_AB_en	<= '0'; end if;
			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_UNLOAD	) then r_instr_unload_en	<= '1'; else r_instr_unload_en	<= '0'; end if;

			if(pi_cmd_taken = '1' and (pi_cmd_opcode = C_STD_OPCODE_SET_ZERO or (pi_main_sign = '1' and pi_cmd_opcode = C_STD_OPCODE_SIGN_TO_STEP))) then r_instr_set_zero_en	<= '1'; else r_instr_set_zero_en	<= '0'; end if;

			if(pi_cmd_taken = '1' and (pi_cmd_opcode = C_STD_OPCODE_SET_ONE or (pi_main_sign = '0' and pi_cmd_opcode = C_STD_OPCODE_SIGN_TO_STEP))) then r_instr_set_one_en	<= '1'; else r_instr_set_one_en	<= '0'; end if;
			if(pi_cmd_taken = '1' and (pi_cmd_opcode = C_STD_OPCODE_SET_ZERO or pi_cmd_opcode = C_STD_OPCODE_SET_ONE or pi_cmd_opcode = C_STD_OPCODE_SIGN_TO_STEP)) then r_instr_set_zero_or_one_en	<= '1'; else r_instr_set_zero_or_one_en	<= '0'; end if;

			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_ADD		) then r_instr_add_en		<= '1'; else r_instr_add_en		<= '0'; end if;
			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_SUB		) then r_instr_sub_en		<= '1'; else r_instr_sub_en		<= '0'; end if;
			if(pi_cmd_taken = '1' and pi_cmd_opcode = C_STD_OPCODE_MULT		) then r_instr_mult_en		<= '1'; else r_instr_mult_en		<= '0'; end if;


			if(pi_cmd_taken = '1' and (pi_cmd_opcode = C_STD_OPCODE_UNLOAD or
												pi_cmd_opcode = C_STD_OPCODE_ADD or
												pi_cmd_opcode = C_STD_OPCODE_SUB or
												pi_cmd_opcode = C_STD_OPCODE_MULT)	) then
				r_cmc_start <= '1';
			else
				r_cmc_start <= '0';
			end if;


			if(pi_cmd_taken = '1') then
				if(pi_cmd_opcode = C_STD_OPCODE_ADD) then
					r_cmc_oper <= "00";
				elsif(pi_cmd_opcode = C_STD_OPCODE_SUB) then
					r_cmc_oper <= "00";
				elsif(pi_cmd_opcode = C_STD_OPCODE_MULT) then
					r_cmc_oper <= "01";
				elsif(pi_cmd_opcode = C_STD_OPCODE_UNLOAD) then
					r_cmc_oper <= "10";
				end if;
			end if;



			if(pi_cmd_taken = '1' and
			(pi_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) or
			pi_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) )) then
				r_instr_add_sub_en <= '1';
			else
				r_instr_add_sub_en <= '0';
			end if;


------------------
-- NEW APPROACH --
------------------

			--------------------
			-- R_LOADER_START --
			--------------------
			if(r_instr_load_A_en = '1' or r_instr_load_AB_en = '1') then
				r_loader_start(0) <= '1';
			else
				r_loader_start(0) <= '0';
			end if;

			if(r_instr_load_B_en = '1' or r_instr_load_AB_en = '1') then
				r_loader_start(1) <= '1';
			else
				r_loader_start(1) <= '0';
			end if;


			----------------------
			-- R_UNLOADER_START --
			----------------------
			r_unloader_start <= r_instr_unload_en;


		----------------
		-- R_REG_CTRL --
		----------------

			---------------------
			-- R_REG_CTRL_CH_1 --
			---------------------
			if(r_instr_load_A_en = '1' or r_instr_load_AB_en = '1') then			-- LOAD_A
				r_reg_ctrl_ch_1 <= "100" & pi_cmd_reg_1 &											-- REG_WRITE_1
											"00000001" &													-- REG_WRITE_2 (set SRC)
											x"00" &															-- NOP
											x"00";															-- NOP
			elsif(r_instr_add_sub_en = '1') then											-- ADD_SUB
				r_reg_ctrl_ch_1 <= '0' & r_cmc_channel & '0' & pi_cmd_reg_1 &				-- REG_READ_1
											x"01" &															-- REG_READ_2
											"100" & pi_cmd_reg_3 &										-- REG_WRITE_1
											"00000010";														-- REG_WRITE_2 (set SRC)
			elsif(r_instr_mult_en = '1') then												-- MULT
				r_reg_ctrl_ch_1 <= '0' & r_cmc_channel & '0' & pi_cmd_reg_1 &				-- REG_READ_1
											x"00" &															-- REG_READ_2
											"100" & pi_cmd_reg_3 &										-- REG_WRITE_1
											"00000011";														-- REG_WRITE_2 (set SRC)
			elsif(r_instr_set_zero_en = '1') then											-- SET_ZERO
				r_reg_ctrl_ch_1 <= "110" & pi_cmd_reg_1 &											-- REG_WRITE_1
											"01000000" &													-- REG_WRITE_2
											"00000000" &													-- NOP
											"00000000";														-- NOP
			elsif(r_instr_set_one_en = '1') then											-- SET_ONE
				r_reg_ctrl_ch_1 <= "110" & pi_cmd_reg_1 &											-- REG_WRITE_1
											"00100000" &													-- REG_WRITE_2
											"00000000" &													-- NOP
											"00000000";														-- NOP
			else
				r_reg_ctrl_ch_1 <= r_reg_ctrl_ch_1(r_reg_ctrl_ch_1'length-g_ctrl_width-1 downto 0) & c_ctrl_zero;
			end if;

			---------------------
			-- R_REG_CTRL_CH_2 --
			---------------------
			if(r_instr_load_B_en = '1') then													-- LOAD_B
				r_reg_ctrl_ch_2 <= "100" & pi_cmd_reg_1 &											-- REG_WRITE_1
											"00000101" &													-- REG_WRITE_2 (set SRC)
											x"00" &															-- NOP
											x"00";															-- NOP
			elsif(r_instr_load_AB_en = '1') then											-- LOAD_AB
				r_reg_ctrl_ch_2 <= "100" & pi_cmd_reg_2 &											-- REG_WRITE_1
											"00000101" &													-- REG_WRITE_2 (set SRC)
											x"00" &															-- NOP
											x"00";															-- NOP
			elsif(r_instr_unload_en = '1') then												-- UNLOAD
				r_reg_ctrl_ch_2 <= '0' & r_cmc_channel & '0' & pi_cmd_reg_1 &				-- REG_READ_1
											x"01" &															-- REG_READ_2
											x"00" &															-- NOP
											x"00";															-- NOP
			elsif(r_instr_add_sub_en = '1') then											-- ADD_SUB
				r_reg_ctrl_ch_2 <= '0' & r_cmc_channel & '0' & pi_cmd_reg_2 &				-- REG_READ_1
											x"01" &															-- REG_READ_2
											"100" & pi_cmd_reg_3_aux &									-- REG_WRITE_1
											"10000010";														-- REG_WRITE_2 (set SRC)
			elsif(r_instr_mult_en = '1') then												-- MULT
				r_reg_ctrl_ch_2 <= '0' & r_cmc_channel & '0' & pi_cmd_reg_2 &				-- REG_READ_1
											x"01" &															-- REG_READ_2
											x"00" &															-- NOP
											x"00";															-- NOP
			else
				r_reg_ctrl_ch_2 <= r_reg_ctrl_ch_2(r_reg_ctrl_ch_2'length-g_ctrl_width-1 downto 0) & c_ctrl_zero;
			end if;

			r_unload_reg <= pi_cmd_reg_1;																-- REG_WRITE_1

			r_instr_oper_dly <= r_instr_add_sub_en or r_instr_mult_en;
			r_instr_oper_dly_dly <= r_instr_oper_dly;
			r_instr_add_sub_dly <= r_instr_add_sub_en;
			r_instr_add_sub_dly_dly <= r_instr_add_sub_dly;
			r_reg_ctrl_ch_1_valid_n <= not(r_instr_load_A_en or r_instr_load_AB_en or r_instr_add_sub_en or r_instr_mult_en or r_instr_oper_dly_dly);
			r_reg_ctrl_ch_2_valid_n <= not(r_instr_load_B_en or r_instr_load_AB_en or r_instr_add_sub_en or r_instr_mult_en or r_instr_unload_en or r_instr_add_sub_dly_dly);

--		----------------
--		-- R_COM_CTRL --
--		----------------
--			if(r_instr_unload_en = '1') then													-- LOAD_B
--				r_com_ctrl <= "0000" & pi_cmd_reg_1;											-- REG_READ
--			else
--				r_com_ctrl <= (others=>'0');
--				--r_com_ctrl <= r_com_ctrl(r_com_ctrl'length-g_ctrl_width-1 downto 0) & c_ctrl_zero;
--			end if;
--
--			r_com_ctrl_valid_n <= not(r_instr_unload_en);

r_com_ctrl <= (others=>'0');
r_com_ctrl_valid_n <= '1';


		-----------------
		-- R_OPER_CTRL --
		-----------------

			----------------------
			-- R_OPER_CTRL_CH_1 --
			----------------------
			if(r_instr_add_sub_en = '1') then																					-- ADD_SUB
				r_oper_ctrl_ch_1 <= '0' & r_add_sub & to_std_logic_vector(C_STD_ID_ADDER, C_STD_ID_SIZE) &			-- ADD_ID
											"000" & pi_cmd_reg_1;																			-- SRC_A
			elsif(r_instr_mult_en = '1') then																					-- MULT
				r_oper_ctrl_ch_1 <= to_std_logic_vector(C_STD_ID_MULT, g_ctrl_width) &										-- MULT_ID
											"000" & pi_cmd_reg_1;																			-- SRC_A
			else
				r_oper_ctrl_ch_1 <= r_oper_ctrl_ch_1(r_oper_ctrl_ch_1'length-g_ctrl_width-1 downto 0) & c_ctrl_zero;
			end if;


			----------------------
			-- R_OPER_CTRL_CH_2 --
			----------------------
			if(r_instr_add_sub_en = '1') then																					-- ADD_SUB
				r_oper_ctrl_ch_2 <= "00" & to_std_logic_vector(C_STD_ID_ADDER, C_STD_ID_SIZE) &							-- ADD_ID
											"000" & pi_cmd_reg_2;																			-- SRC_B
			elsif(r_instr_mult_en = '1') then																					-- MULT
				r_oper_ctrl_ch_2 <= to_std_logic_vector(C_STD_ID_MULT, g_ctrl_width) &										-- MULT_ID
											"000" & pi_cmd_reg_2;																			-- SRC_B
			else
				r_oper_ctrl_ch_2 <= r_oper_ctrl_ch_2(r_oper_ctrl_ch_2'length-g_ctrl_width-1 downto 0) & c_ctrl_zero;
			end if;


			r_oper_ctrl_valid_n <= not(r_instr_add_sub_en or r_instr_mult_en);


			------------------
			-- R_REG_MODE_B --
			------------------
			r_reg_mode_B <= (others=>'0');
			if(r_single_mode = '0') then
				r_reg_mode_B(to_natural(pi_cmd_reg_2)) <= '1';
			end if;


			-------------------
			-- R_SINGLE_MODE --
			-------------------
			case pi_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_LOAD_A, g_opcode_width) =>				r_single_mode <= '1';
				when to_std_logic_vector(C_STD_OPCODE_LOAD_B, g_opcode_width) =>				r_single_mode <= '1';
				when to_std_logic_vector(C_STD_OPCODE_UNLOAD, g_opcode_width) =>				r_single_mode <= '1';
				when to_std_logic_vector(C_STD_OPCODE_SET_ZERO, g_opcode_width) =>			r_single_mode <= '1';
				when to_std_logic_vector(C_STD_OPCODE_SET_ONE, g_opcode_width) =>				r_single_mode <= '1';
				when others =>																					r_single_mode <= '0';
			end case;

			----------------
			-- R_REG_MODE --
			----------------
			case pi_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_LOAD_A, g_opcode_width) =>				r_reg_mode <= "010";
				when to_std_logic_vector(C_STD_OPCODE_LOAD_B, g_opcode_width) =>				r_reg_mode <= "011";
				when to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) =>				r_reg_mode <= "010";
				when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) =>					r_reg_mode <= "110";
				when to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) =>					r_reg_mode <= "110";
				when to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>					r_reg_mode <= "100";
				when others =>																					r_reg_mode <= (others=>'0');
			end case;



			case pi_cmd_opcode is
				when to_std_logic_vector(C_STD_OPCODE_LOAD_A, g_opcode_width) =>				r_cmd_write_reg_1 <= '1';
				when to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) =>				r_cmd_write_reg_1 <= '1';
				when others =>																					r_cmd_write_reg_1 <= '0';
			end case;

			if(pi_cmd_opcode = to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width)) then
				r_load_ab <= '1';
			else
				r_load_ab <= '0';
			end if;


			---------------------------
			-- R_ADDER_SIGN_INVERTED --
			---------------------------
			if(pi_rst = '1') then
				r_adder_sign_inverted <= (others=>'0');
			else
				if((r_instr_add_en = '1' and r_main_sign = '1' and r_other_sign = '0') or
				(r_instr_sub_en = '1' and r_main_sign = '1' and r_other_sign = '1')
				) then
					r_adder_sign_inverted <= r_cmd_reg_3 or r_cmd_reg_3_aux;
				else
					r_adder_sign_inverted <= (others=>'0');
				end if;
			end if;


			----------------------
			-- R_REG_MODE_START --		-- 5
			----------------------
			if(pi_cmd_taken_n = '1') then
				r_reg_mode_start <= (others=>'0');
			else

				if(r_cmd_write_reg_1 = '1' and r_load_ab = '0') then
					r_reg_mode_start <= r_cmd_reg_1;
				elsif(r_cmd_write_reg_1 = '1' and r_load_ab = '1') then
					r_reg_mode_start <= r_cmd_reg_1 or r_reg_mode_B;
				elsif(r_cmd_write_reg_1 = '0' and r_aux_used = '1') then
					r_reg_mode_start <= r_cmd_reg_3 or r_cmd_reg_3_aux;
				elsif(r_cmd_write_reg_1 = '0' and r_aux_used = '0') then
					r_reg_mode_start <= r_cmd_reg_3;
				else
					r_reg_mode_start <= (others=>'0');
				end if;
			end if;

			if(pi_cmd_taken = '1' and r_aux_used = '1') then
				r_reg_mode_aux <= r_cmd_reg_3_aux;
			else
				r_reg_mode_aux <= (others=>'0');
			end if;

			----------------
			-- R_AUX_USED --
			----------------
			if((pi_cmd_opcode = C_STD_OPCODE_ADD and pi_main_sign = '0' and pi_other_sign = '1') or
			(pi_cmd_opcode = C_STD_OPCODE_ADD and pi_main_sign = '1' and pi_other_sign = '0') or
			(pi_cmd_opcode = C_STD_OPCODE_SUB and pi_main_sign = '0' and pi_other_sign = '0') or
			(pi_cmd_opcode = C_STD_OPCODE_SUB and pi_main_sign = '1' and pi_other_sign = '1')
			) then
				r_aux_used <= '1';
			else
				r_aux_used <= '0';
			end if;

		end if;
	end process;

end architecture;
