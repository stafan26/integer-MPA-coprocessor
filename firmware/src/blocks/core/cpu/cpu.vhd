-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity cpu is
generic (
	g_sim									: boolean := false;
	g_lfsr								: boolean := true;
	g_num_of_logic_registers		: natural := 16;
	g_num_of_phys_registers			: natural := 18;
	g_reg_logic_addr_width			: natural := 4;
	g_reg_phys_addr_width			: natural := 5;
	g_opcode_width						: natural := 4;
	g_ctrl_width						: natural := 8;
	g_addr_width						: natural := 9
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_core_data					: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_core_data_last			: in std_logic;
	pi_ctrl_core_valid				: in std_logic;
	po_ctrl_core_ready				: out std_logic;

	pi_loader_A_wr_en					: in std_logic;
	pi_loader_A_data_last			: in std_logic;
	pi_loader_A_sign					: in std_logic;

	pi_loader_B_wr_en					: in std_logic;
	pi_loader_B_data_last			: in std_logic;
	pi_loader_B_sign					: in std_logic;

	po_cmc_unloader_last				: out std_logic;
	po_cmc_unloader_wr_en			: out std_logic;

	pi_adder_wr_en						: in std_logic;
	pi_adder_data_last				: in std_logic;
	pi_adder_zero						: in std_logic_vector(1 downto 0);
	pi_adder_all_ones					: in std_logic;

	pi_mult_wr_en						: in std_logic;
	pi_mult_data_last					: in std_logic;
	pi_mult_zero						: in std_logic;

	po_loader_start					: out std_logic_vector(1 downto 0);

	pi_unloader_busy					: in std_logic;
	po_unloader_start					: out std_logic;
	po_unloader_select				: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	po_unloader_size					: out std_logic_vector(g_addr_width-1 downto 0);
	po_unloader_last					: out std_logic_vector(2 downto 0);
	po_unloader_sign					: out std_logic;

	po_reg_ctrl_ch_1					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_reg_ctrl_ch_1_valid_n		: out std_logic;
	po_reg_ctrl_ch_2					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_reg_ctrl_ch_2_valid_n		: out std_logic;
	po_com_ctrl							: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_com_ctrl_valid_n				: out std_logic;
	po_oper_ctrl_ch_1					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_oper_ctrl_ch_2					: out std_logic_vector(g_ctrl_width-1 downto 0);
	po_oper_ctrl_valid_n				: out std_logic;

	po_cmc_addr_init_up_A			: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle_A				: out std_logic;
	po_cmc_data_valid_A				: out std_logic;
	po_cmc_data_last_A				: out std_logic_vector(2 downto 0);
	po_cmc_addr_init_up_B			: out std_logic_vector(1 downto 0);
	po_cmc_data_cycle_B				: out std_logic;
	po_cmc_data_valid_B				: out std_logic;
	po_cmc_data_last_B				: out std_logic_vector(2 downto 0);

	po_adder_data_last				: out std_logic;
	po_adder_data_wr_en				: out std_logic;

	po_mult_data_last					: out std_logic;
	po_mult_data_wr_en				: out std_logic;
	po_mult_data_cycle				: out std_logic
);
end cpu;

architecture cpu of cpu is

	signal s_ctrl_core_ready					: std_logic;

	signal s_cmd_opcode							: std_logic_vector(g_opcode_width-1 downto 0);
	signal s_logic_reg_1							: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_logic_reg_2							: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_logic_reg_3							: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_logic_reg_3_oh						: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal s_logic_reg_all_oh					: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal s_use_aux_reg							: std_logic;

	signal s_phys_reg_1							: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_phys_reg_2							: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_phys_reg_3							: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_phys_reg_3_aux						: std_logic_vector(g_reg_phys_addr_width-1 downto 0);

	signal s_phys_reg_1_oh						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_phys_reg_2_oh						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_phys_reg_3_oh						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_phys_reg_all_oh					: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal s_cmd_add_sub							: std_logic;
	signal s_cmd_mult								: std_logic;
	signal s_cmd_unload							: std_logic;

	signal s_logic_reg_1_busy_mode			: std_logic_vector(2 downto 0);
	signal s_logic_reg_2_busy_mode			: std_logic_vector(2 downto 0);
	signal s_logic_reg_3_busy_mode			: std_logic_vector(2 downto 0);
	signal s_logic_reg_3_aux_busy_mode		: std_logic_vector(2 downto 0);

	signal s_logic_reg_1_busy_mode_dly		: std_logic_vector(2 downto 0);
	signal s_logic_reg_2_busy_mode_dly		: std_logic_vector(2 downto 0);
	signal s_logic_reg_3_busy_mode_dly		: std_logic_vector(2 downto 0);
	signal s_logic_reg_3_aux_busy_mode_dly	: std_logic_vector(2 downto 0);

	signal s_cmd_valid							: std_logic;
	signal s_cmd_taken							: std_logic;
	signal s_cmd_taken_n							: std_logic;
	signal s_cmd_ready							: std_logic;

	signal s_reg_mode_start						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_reg_mode_B							: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_reg_mode_aux						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_reg_mode								: std_logic_vector(2 downto 0);

	signal s_cpu_sign								: std_logic;
	signal s_cpu_update							: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_adder_sign_inverted				: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal s_swap_pre								: std_logic;

	signal s_main_size							: std_logic_vector(g_addr_width-1 downto 0);
	signal s_main_last							: std_logic_vector(4 downto 0);
	signal s_main_sign							: std_logic;
	signal s_main_zero							: std_logic;
	signal s_main_one								: std_logic;

	signal s_other_size							: std_logic_vector(g_addr_width-1 downto 0);
	signal s_other_last							: std_logic_vector(4 downto 0);
	signal s_other_sign							: std_logic;
	signal s_other_zero							: std_logic;
	signal s_other_one							: std_logic;

	signal s_cmc_add_sub_start					: std_logic;
	signal s_cmc_mult_start						: std_logic;
	signal s_cmc_unload_start					: std_logic;

	signal s_cmc_start							: std_logic;
	signal s_cmc_oper								: std_logic_vector(1 downto 0);
	signal s_cmc_channel							: std_logic;

	signal s_cmc_unloader_last					: std_logic;
	signal s_cmc_unloader_wr_en				: std_logic;

	signal s_cmc_channel_busy					: std_logic_vector(1 downto 0);
	signal s_cmc_add_sub_last					: std_logic;
	signal s_cmc_add_sub_wr_en					: std_logic;
	signal s_cmc_mult_last						: std_logic;
	signal s_cmc_mult_cycle						: std_logic;
	signal s_cmc_mult_wr_en						: std_logic;

	signal s_add_sub_busy						: std_logic;
	signal s_mult_busy							: std_logic;
	signal s_reg_busy								: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_cmc_busy 							: std_logic_vector(1 downto 0);

	signal s_set_zero								: std_logic;
	signal s_set_one								: std_logic;
	signal s_set_zero_or_one					: std_logic;

	signal f_oper_num								: natural;

begin

	PERIPHERAL_DELAYER_INST: entity work.cpu_peripheral_delayer port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_unloader_wr_en			=> s_cmc_unloader_wr_en,		--: in std_logic;
		po_unloader_wr_en			=> po_cmc_unloader_wr_en,		--: out std_logic;
		pi_unloader_last			=> s_cmc_unloader_last,			--: in std_logic;
		po_unloader_last			=> po_cmc_unloader_last,		--: out std_logic;

		pi_adder_data_wr_en		=> s_cmc_add_sub_wr_en,			--: in std_logic;
		po_adder_data_wr_en		=> po_adder_data_wr_en,			--: out std_logic;
		pi_adder_data_last		=> s_cmc_add_sub_last,			--: in std_logic;
		po_adder_data_last		=> po_adder_data_last,			--: out std_logic;

		pi_mult_data_wr_en		=> s_cmc_mult_wr_en,				--: in std_logic;
		po_mult_data_wr_en		=> po_mult_data_wr_en,			--: out std_logic;
		pi_mult_data_cycle		=> s_cmc_mult_cycle,				--: in std_logic;
		po_mult_data_cycle		=> po_mult_data_cycle,			--: out std_logic;
		pi_mult_data_last			=> s_cmc_mult_last,				--: in std_logic;
		po_mult_data_last			=> po_mult_data_last				--: out std_logic
	);


	OPERATION_NUMBER_GEN: if(g_sim = true) generate

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then

				----------------
				-- F_OPER_NUM --
				----------------
				if(pi_rst = '1') then
					f_oper_num <= 0;
				else

					--if(pi_ctrl_core_data_last = '1' and pi_ctrl_core_valid = '1' and s_ctrl_core_ready = '1') then
					if(s_cmd_valid = '1' and s_cmd_taken = '1') then
						f_oper_num <= f_oper_num + 1;
					end if;

				end if;

			end if;
		end process;

	end generate;

	po_ctrl_core_ready <= s_ctrl_core_ready;



	CPU_PREFETCH_INST: entity work.cpu_prefetch generic map (
		g_ctrl_width						=> g_ctrl_width,						--: natural := 8;
		g_num_of_logic_registers		=> g_num_of_logic_registers,		--: natural := 16;
		g_opcode_width						=> g_opcode_width,					--: natural := 4;
		g_reg_logic_addr_width			=> g_reg_logic_addr_width			--: natural := 4
	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_rst							=> pi_rst,									--: in std_logic;
		pi_ctrl_core_data				=> pi_ctrl_core_data,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_core_data_last		=> pi_ctrl_core_data_last,				--: in std_logic;
		pi_ctrl_core_valid			=> pi_ctrl_core_valid,					--: in std_logic;
		po_ctrl_core_ready			=> s_ctrl_core_ready,					--: out std_logic;
		po_cmd_opcode					=> s_cmd_opcode,							--: out std_logic_vector(g_opcode_width-1 downto 0);
		po_cmd_reg_1					=> s_logic_reg_1,							--: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		po_cmd_reg_2					=> s_logic_reg_2,							--: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		po_cmd_reg_3					=> s_logic_reg_3,							--: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		po_cmd_reg_3_oh				=> s_logic_reg_3_oh,						--: out std_logic_vector(g_num_of_logic_registers-1 downto 0);
		po_cmd_reg_all_oh				=> s_logic_reg_all_oh,					--: out std_logic_vector(g_num_of_logic_registers-1 downto 0);
		po_use_aux_reg					=> s_use_aux_reg,							--: out std_logic;

		po_reg_1_busy_mode			=> s_logic_reg_1_busy_mode,			--: out std_logic_vector(2 downto 0);
		po_reg_2_busy_mode			=> s_logic_reg_2_busy_mode,			--: out std_logic_vector(2 downto 0);
		po_reg_3_busy_mode			=> s_logic_reg_3_busy_mode,			--: out std_logic_vector(2 downto 0);
		po_reg_3_aux_busy_mode		=> s_logic_reg_3_aux_busy_mode,		--: out std_logic_vector(2 downto 0);

		po_cmd_add_sub					=> s_cmd_add_sub,							--: out std_logic;
		po_cmd_mult						=> s_cmd_mult,								--: out std_logic;
		po_cmd_unload					=> s_cmd_unload,							--: out std_logic;

		po_cmd_ready					=> s_cmd_ready,							--: out std_logic;
		pi_cmd_taken					=> s_cmd_taken								--: in std_logic
	);


	CPU_MAPPER_INST: entity work.cpu_mapper generic map (
		g_sim								=> g_sim,									--: boolean := false;
		g_num_of_logic_registers	=> g_num_of_logic_registers,			--: natural := 16;
		g_num_of_phys_registers		=> g_num_of_phys_registers,			--: natural := 18;
		g_reg_logic_addr_width		=> g_reg_logic_addr_width,				--: natural := 4;
		g_reg_phys_addr_width		=> g_reg_phys_addr_width				--: natural := 5
	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_rst							=> pi_rst,									--: in std_logic;

		pi_swap_pre						=> s_swap_pre,								--: in std_logic;																	-- from CPU
		pi_swap_post					=> pi_adder_wr_en,						--: in std_logic;																	-- from ADDER
		pi_swap_post_en				=> pi_adder_all_ones,					--: in std_logic;																	-- from ADDER

		pi_logic_reg_1					=> s_logic_reg_1,							--: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		pi_logic_reg_2					=> s_logic_reg_2,							--: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		pi_logic_reg_3					=> s_logic_reg_3,							--: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
		pi_logic_reg_3_oh				=> s_logic_reg_3_oh,						--: in std_logic_vector(g_num_of_logic_registers-1 downto 0);

		pi_logic_reg_all_oh			=> s_logic_reg_all_oh,					--: in std_logic_vector(g_num_of_logic_registers-1 downto 0);
		pi_use_aux_reg					=> s_use_aux_reg,							--: in std_logic;

		po_phys_reg_1					=> s_phys_reg_1,							--: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		po_phys_reg_1_oh				=> s_phys_reg_1_oh,						--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_phys_reg_2					=> s_phys_reg_2,							--: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		po_phys_reg_2_oh				=> s_phys_reg_2_oh,						--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_phys_reg_3					=> s_phys_reg_3,							--: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		po_phys_reg_3_oh				=> s_phys_reg_3_oh,						--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_phys_reg_3_aux				=> s_phys_reg_3_aux,						--: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		--po_phys_reg_3_aux_oh			=> s_phys_reg_3_aux_oh,					--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_phys_reg_all_oh			=> s_phys_reg_all_oh						--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	);



	LOGIC_REG_1_BUSY_MODE_DATA_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 3,													--: natural := 1;
		g_delay					=> 2													--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data					=> s_logic_reg_1_busy_mode,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_logic_reg_1_busy_mode_dly				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	LOGIC_REG_2_BUSY_MODE_DATA_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 3,													--: natural := 1;
		g_delay					=> 2													--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data					=> s_logic_reg_2_busy_mode,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_logic_reg_2_busy_mode_dly				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	LOGIC_REG_3_BUSY_MODE_DATA_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 3,													--: natural := 1;
		g_delay					=> 2													--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data					=> s_logic_reg_3_busy_mode,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_logic_reg_3_busy_mode_dly				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	LOGIC_REG_3_AUX_BUSY_MODE_DATA_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 3,													--: natural := 1;
		g_delay					=> 2													--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,											--: in std_logic;
		pi_data					=> s_logic_reg_3_aux_busy_mode,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_logic_reg_3_aux_busy_mode_dly			--: out std_logic_vector(g_data_width-1 downto 0)
	);



	CPU_BLOCKER_INST: entity work.cpu_blocker generic map (
		g_num_of_phys_registers		=> g_num_of_phys_registers				--: natural := 18
	)
	port map (
		pi_clk							=> pi_clk,							--: in std_logic;
		pi_rst							=> pi_rst,							--: in std_logic;
		pi_add_sub_busy				=> s_add_sub_busy,				--: in std_logic;
		pi_mult_busy					=> s_mult_busy,					--: in std_logic;
		pi_reg_busy						=> s_reg_busy,						--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_unloader_busy				=> pi_unloader_busy,				--: in std_logic;

		pi_cmd_add_sub					=> s_cmd_add_sub,					--: in std_logic;
		pi_cmd_mult						=> s_cmd_mult,						--: in std_logic;
		pi_cmd_unload					=> s_cmd_unload,					--: in std_logic;
		pi_phys_reg_active_all		=> s_phys_reg_all_oh,			--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);

		po_cmd_taken					=> s_cmd_taken,					--: out std_logic;
		po_cmd_taken_n					=> s_cmd_taken_n,					--: out std_logic;
		pi_cmd_ready					=> s_cmd_ready						--: in std_logic
	);



	CPU_BUSYBOX_INST: entity work.cpu_busybox generic map (
		g_lfsr							=> g_lfsr,									--: boolean := true;
		g_num_of_phys_registers		=> g_num_of_phys_registers				--: natural := 18
	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_rst							=> pi_rst,									--: in std_logic;
		pi_phys_reg_active_all		=> s_phys_reg_all_oh,					--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_phys_reg_1_oh				=> s_phys_reg_1_oh,						--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_phys_reg_2_oh				=> s_phys_reg_2_oh,						--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_phys_reg_3_oh				=> s_phys_reg_3_oh,						--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_reg_1_busy_mode			=> s_logic_reg_1_busy_mode_dly,		--: in std_logic_vector(2 downto 0);
		pi_reg_2_busy_mode			=> s_logic_reg_2_busy_mode_dly,		--: in std_logic_vector(2 downto 0);
		pi_reg_3_busy_mode			=> s_logic_reg_3_busy_mode_dly,		--: in std_logic_vector(2 downto 0);
		pi_reg_3_aux_busy_mode		=> s_logic_reg_3_aux_busy_mode_dly,	--: in std_logic_vector(2 downto 0);
		pi_cmd_add_sub					=> s_cmd_add_sub,							--: in std_logic;
		pi_cmd_mult						=> s_cmd_mult,								--: in std_logic;
		pi_cmd_taken					=> s_cmd_taken,							--: in std_logic;
		pi_cmc_add_sub_last			=> s_cmc_add_sub_last,					--: in std_logic;
		pi_cmc_mult_last				=> s_cmc_mult_last,						--: in std_logic;
		pi_loader_A_data_last		=> pi_loader_A_data_last,				--: in std_logic;
		pi_loader_B_data_last		=> pi_loader_B_data_last,				--: in std_logic;
		pi_unloader_data_last		=> s_cmc_unloader_last,					--: in std_logic;
		po_add_sub_busy				=> s_add_sub_busy,						--: out std_logic;
		po_mult_busy					=> s_mult_busy,							--: out std_logic;
		po_reg_busy						=> s_reg_busy								--: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
	);



	CPU_CMC_INST: entity work.cpu_cmc generic map (
		g_lfsr							=> g_lfsr,									--: boolean := true;
		g_addr_width					=> g_addr_width							--: natural := 9
	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_rst							=> pi_rst,									--: in std_logic;
		pi_cmc_add_sub_start			=> s_cmc_add_sub_start,					--: in std_logic;
		pi_cmc_mult_start				=> s_cmc_mult_start,						--: in std_logic;
		pi_cmc_unload_start			=> s_cmc_unload_start,					--: in std_logic;
		pi_cmc_start					=> s_cmc_start,							--: in std_logic;
		pi_cmc_oper						=> s_cmc_oper,								--: in std_logic_vector(1 downto 0);
		pi_cmc_channel					=> s_cmc_channel,							--: in std_logic;
		pi_my_size						=> s_main_size,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_my_last						=> s_main_last,							--: in std_logic_vector(4 downto 0);
		pi_other_size					=> s_other_size,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_other_last					=> s_other_last,							--: in std_logic_vector(4 downto 0);
		po_cmc_busy						=> s_cmc_busy, 							--: out std_logic_vector(1 downto 0);
		po_cmc_addr_init_up_A		=> po_cmc_addr_init_up_A,				--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_A			=> po_cmc_data_cycle_A,					--: out std_logic;
		po_cmc_data_valid_A			=> po_cmc_data_valid_A,					--: out std_logic;
		po_cmc_data_last_A			=> po_cmc_data_last_A,					--: out std_logic_vector(2 downto 0);
		po_cmc_unload_last			=> s_cmc_unloader_last,					--: out std_logic;
		po_cmc_unload_wr_en			=> s_cmc_unloader_wr_en,				--: out std_logic;
		po_cmc_addr_init_up_B		=> po_cmc_addr_init_up_B,				--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_B			=> po_cmc_data_cycle_B,					--: out std_logic;
		po_cmc_data_valid_B			=> po_cmc_data_valid_B,					--: out std_logic;
		po_cmc_data_last_B			=> po_cmc_data_last_B,					--: out std_logic_vector(2 downto 0);
		po_cmc_add_sub_last			=> s_cmc_add_sub_last,					--: out std_logic;
		po_cmc_add_sub_wr_en			=> s_cmc_add_sub_wr_en,					--: out std_logic;
		po_cmc_mult_last				=> s_cmc_mult_last,						--: out std_logic;
		po_cmc_mult_cycle				=> s_cmc_mult_cycle,						--: out std_logic;
		po_cmc_mult_wr_en				=> s_cmc_mult_wr_en						--: out std_logic;
	);


	CPU_FOLLOWER_INST: entity work.cpu_follower generic map (
		g_lfsr							=> g_lfsr,							--: boolean := true;
		g_num_of_phys_registers		=> g_num_of_phys_registers,	--: natural := 16;
		g_reg_phys_addr_width		=> g_reg_phys_addr_width,		--: natural := 4;
		g_ctrl_width					=> g_ctrl_width,					--: natural := 8;
		g_addr_width					=> g_addr_width					--: natural := 9;
	)
	port map (
		pi_clk							=> pi_clk,						--: in std_logic;
		pi_rst							=> pi_rst,						--: in std_logic;

		pi_reg_mode_start				=> s_reg_mode_start,			--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_reg_mode_B					=> s_reg_mode_B,				--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_reg_mode_aux				=> s_reg_mode_aux,			--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_reg_mode						=> s_reg_mode,					--: in std_logic_vector(2 downto 0);

		pi_loader_A_wr_en				=> pi_loader_A_wr_en,		--: in std_logic;
		pi_loader_A_data_last		=> pi_loader_A_data_last,	--: in std_logic;
		pi_loader_A_sign				=> pi_loader_A_sign,			--: in std_logic;

		pi_loader_B_wr_en				=> pi_loader_B_wr_en,		--: in std_logic;
		pi_loader_B_data_last		=> pi_loader_B_data_last,	--: in std_logic;
		pi_loader_B_sign				=> pi_loader_B_sign,			--: in std_logic;

		pi_adder_wr_en					=> pi_adder_wr_en,			--: in std_logic;
		pi_adder_data_last			=> pi_adder_data_last,		--: in std_logic;
		pi_adder_zero					=> pi_adder_zero,				--: in std_logic_vector(1 downto 0);
		pi_adder_all_ones				=> pi_adder_all_ones,		--: in std_logic;
		pi_adder_sign_inverted		=> s_adder_sign_inverted,	--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);

		pi_mult_wr_en					=> pi_mult_wr_en,				--: in std_logic;
		pi_mult_data_last				=> pi_mult_data_last,		--: in std_logic;
		pi_mult_zero					=> pi_mult_zero,				--: in std_logic;

		pi_set_zero						=> s_set_zero,					--: in std_logic;
		pi_set_one						=> s_set_one,					--: in std_logic;
		pi_set_zero_or_one			=> s_set_zero_or_one,		--: in std_logic;

		pi_cpu_sign						=> s_cpu_sign,					--: in std_logic;
		pi_cpu_update					=> s_cpu_update,				--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_cmd_phys_reg_1				=> s_phys_reg_1,				--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_cmd_phys_reg_2				=> s_phys_reg_2,				--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);

		po_main_size					=> s_main_size,				--: out std_logic_vector(g_addr_width-1 downto 0);
		po_main_last					=> s_main_last,				--: out std_logic_vector(4 downto 0);
		po_main_sign					=> s_main_sign,				--: out std_logic;
		po_main_zero					=> s_main_zero,				--: out std_logic;					-- TO BE USED WITH NEW FEATURES
		po_main_one						=> s_main_one,					--: out std_logic;					-- TO BE USED WITH NEW FEATURES

		po_other_size					=> s_other_size,				--: out std_logic_vector(g_addr_width-1 downto 0);
		po_other_last					=> s_other_last,				--: out std_logic_vector(4 downto 0);
		po_other_sign					=> s_other_sign,				--: out std_logic;
		po_other_zero					=> s_other_zero,				--: out std_logic;					-- TO BE USED WITH NEW FEATURES
		po_other_one					=> s_other_one					--: out std_logic;					-- TO BE USED WITH NEW FEATURES
	);


	po_unloader_size <= s_main_size;
	po_unloader_last <= s_main_last(2 downto 0);
	po_unloader_sign <= s_main_sign;



	CPU_EXECUTER_INST: entity work.cpu_executer generic map (
		g_num_of_phys_registers		=> g_num_of_phys_registers,			--: natural := 18;
		g_reg_phys_addr_width		=> g_reg_phys_addr_width,				--: natural := 5;
		g_ctrl_width					=> g_ctrl_width,							--: natural := 8
		g_opcode_width					=> g_opcode_width							--: natural := 4

	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_rst							=> pi_rst,									--: in std_logic;
		pi_cmd_opcode					=> s_cmd_opcode,							--: in std_logic_vector(g_opcode_width-1 downto 0);
		pi_cmd_reg_1					=> s_phys_reg_1,							--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_cmd_reg_2					=> s_phys_reg_2,							--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_cmd_reg_3					=> s_phys_reg_3,							--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_cmd_reg_3_aux				=> s_phys_reg_3_aux,						--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_cmd_taken					=> s_cmd_taken,							--: in std_logic;
		pi_cmd_taken_n					=> s_cmd_taken_n,							--: in std_logic;

		po_reg_mode_start				=> s_reg_mode_start,						--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_reg_mode_B					=> s_reg_mode_B,							--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_reg_mode_aux				=> s_reg_mode_aux,						--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_reg_mode						=> s_reg_mode,								--: out std_logic_vector(2 downto 0);

		po_cpu_sign						=> s_cpu_sign,								--: out std_logic;
		po_cpu_update					=> s_cpu_update,							--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

		po_swap_pre						=> s_swap_pre,								--: out std_logic;

		pi_main_sign					=> s_main_sign,							--: in std_logic;
		pi_other_sign					=> s_other_sign,							--: in std_logic;

		pi_cmc_busy						=> s_cmc_busy, 							--: in std_logic_vector(1 downto 0);

		po_cmc_add_sub_start			=> s_cmc_add_sub_start,					--: out std_logic;
		po_cmc_mult_start				=> s_cmc_mult_start,						--: out std_logic;
		po_cmc_unload_start			=> s_cmc_unload_start,					--: out std_logic;

		po_set_zero						=> s_set_zero,								--: out std_logic;
		po_set_one						=> s_set_one,								--: out std_logic;
		po_set_zero_or_one			=> s_set_zero_or_one,					--: out std_logic;

		po_cmc_start					=> s_cmc_start,							--: out std_logic;
		po_cmc_oper						=> s_cmc_oper,								--: out std_logic_vector(1 downto 0);
		po_cmc_channel					=> s_cmc_channel,							--: out std_logic;

		po_adder_sign_inverted		=> s_adder_sign_inverted,				--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

		po_loader_start				=> po_loader_start,						--: out std_logic_vector(1 downto 0);
		po_unloader_start				=> po_unloader_start,					--: out std_logic;
		po_unloader_select			=> po_unloader_select,					--: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		po_reg_ctrl_ch_1				=> po_reg_ctrl_ch_1,						--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_reg_ctrl_ch_1_valid_n	=> po_reg_ctrl_ch_1_valid_n,			--: out std_logic;
		po_reg_ctrl_ch_2				=> po_reg_ctrl_ch_2,						--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_reg_ctrl_ch_2_valid_n	=> po_reg_ctrl_ch_2_valid_n,			--: out std_logic;
		po_com_ctrl						=> po_com_ctrl,							--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_com_ctrl_valid_n			=> po_com_ctrl_valid_n,					--: out std_logic;
		po_oper_ctrl_ch_1				=> po_oper_ctrl_ch_1,					--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_oper_ctrl_ch_2				=> po_oper_ctrl_ch_2,					--: out std_logic_vector(g_ctrl_width-1 downto 0);
		po_oper_ctrl_valid_n			=> po_oper_ctrl_valid_n					--: out std_logic;
	);

end architecture;
