-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    core
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

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

entity core is
generic (
	g_sim									: boolean := false;
	g_num_of_bram						: natural := 1;
	g_lfsr								: boolean := true;
	g_num_of_logic_registers		: natural := C_NUM_OF_REGISTERS;
	g_num_of_phys_registers			: natural := 17;
	g_reg_logic_addr_width			: natural := 4;
	g_reg_phys_addr_width			: natural := 5;
	g_data_width						: natural := C_STD_DATA_WIDTH;
	g_addr_width						: natural := C_STD_ADDR_WIDTH;
	g_ctrl_width						: natural := C_STD_CTRL_WIDTH
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	s00a_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00a_axis_tvalid					: in std_logic;
	s00a_axis_tready					: out std_logic;

	s00b_axis_tdata					: in std_logic_vector(g_data_width-1 downto 0);
	s00b_axis_tvalid					: in std_logic;
	s00b_axis_tready					: out std_logic;

	s00_ctrl_axis_tdata				: in std_logic_vector(g_ctrl_width downto 0);
	s00_ctrl_axis_tlast				: in std_logic;
	s00_ctrl_axis_tvalid				: in std_logic;
	s00_ctrl_axis_tready				: out std_logic;

	m00_axis_tdata						: out std_logic_vector(g_data_width-1 downto 0);
	m00_axis_tvalid					: out std_logic;
	m00_axis_tlast						: out std_logic;
	m00_axis_tready					: in std_logic
);
end core;

architecture core of core is

	-- loader signals
	signal s_loader_data_A								: std_logic_vector(g_data_width-1 downto 0);
	signal s_loader_data_last_A						: std_logic;
	signal s_loader_data_sign_A						: std_logic;
	signal s_loader_wr_en_A								: std_logic;
	signal s_loader_data_B								: std_logic_vector(g_data_width-1 downto 0);
	signal s_loader_data_last_B						: std_logic;
	signal s_loader_data_sign_B						: std_logic;
	signal s_loader_wr_en_B								: std_logic;
	signal s_loader_start								: std_logic_vector(1 downto 0);

	signal s_unloader_busy								: std_logic;
	signal s_unloader_start								: std_logic;
	signal s_unloader_select							: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_unloader_size								: std_logic_vector(g_addr_width-1 downto 0);
	signal s_unloader_last								: std_logic_vector(2 downto 0);
	signal s_unloader_sign								: std_logic;

	signal s_reg_ctrl_ch_1								: std_logic_vector(g_ctrl_width-1 downto 0);
	signal s_reg_ctrl_ch_1_valid_n					: std_logic;
	signal s_reg_ctrl_ch_2								: std_logic_vector(g_ctrl_width-1 downto 0);
	signal s_reg_ctrl_ch_2_valid_n					: std_logic;
	signal s_oper_ctrl_ch_1								: std_logic_vector(g_ctrl_width-1 downto 0);
	signal s_oper_ctrl_ch_2								: std_logic_vector(g_ctrl_width-1 downto 0);
	signal s_oper_ctrl_valid_n							: std_logic;

	signal s_cmc_addr_init_up_A						: std_logic_vector(1 downto 0);
	signal s_cmc_data_cycle_A							: std_logic;
	signal s_cmc_data_valid_A							: std_logic;
	signal s_cmc_data_last_A							: std_logic_vector(2 downto 0);
	signal s_cmc_addr_init_up_B						: std_logic_vector(1 downto 0);
	signal s_cmc_data_cycle_B							: std_logic;
	signal s_cmc_data_valid_B							: std_logic;
	signal s_cmc_data_last_B							: std_logic_vector(2 downto 0);

	signal s_reg_data										: t_data_x1;

	signal s_cpu_unloader_data_last					: std_logic;
	signal s_cpu_unloader_data_wr_en					: std_logic;

	signal s_com_ctrl										: std_logic_vector(g_ctrl_width-1 downto 0);
	signal s_com_ctrl_valid_n							: std_logic;

	signal s_com_data										: std_logic_vector(g_data_width-1 downto 0);
	signal s_com_data_last								: std_logic;
	signal s_com_data_wr_en								: std_logic;

	signal s_cpu_adder_data_last						: std_logic;
	signal s_cpu_adder_data_wr_en						: std_logic;

	signal s_adder_data_up								: std_logic_vector(g_data_width-1 downto 0);		-- REG
	signal s_adder_data_lo								: std_logic_vector(g_data_width-1 downto 0);		-- REG
	signal s_adder_data_last							: std_logic;												-- REG & CPU
	signal s_adder_data_wr_en							: std_logic;												-- REG & CPU
	signal s_adder_data_all_ones						: std_logic;												-- REG & CPU
	signal s_adder_data_zero							: std_logic_vector(1 downto 0);						-- CPU

	signal s_cpu_mult_data_last						: std_logic;
	signal s_cpu_mult_data_wr_en						: std_logic;
	signal s_cpu_mult_data_cycle						: std_logic;

	signal s_mult_data									: std_logic_vector(g_data_width-1 downto 0);
	signal s_mult_data_last								: std_logic;
	signal s_mult_data_wr_en							: std_logic;
	signal s_mult_data_zero								: std_logic;

begin

	LOADER_INST: entity work.loader_bay generic map (
		g_lfsr								=> g_lfsr,								--: boolean := false;
		g_addr_width						=> g_addr_width,						--: natural := 9;
		g_data_width						=> g_data_width						--: natural := 64;
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;
		pi_start								=> s_loader_start,					--: in std_logic_vector(1 downto 0);
		s00a_axis_tdata					=> s00a_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid					=> s00a_axis_tvalid,					--: in std_logic;
		s00a_axis_tready					=> s00a_axis_tready,					--: out std_logic;
		s00b_axis_tdata					=> s00b_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid					=> s00b_axis_tvalid,					--: in std_logic;
		s00b_axis_tready					=> s00b_axis_tready,					--: out std_logic;
		po_data_A							=> s_loader_data_A,					--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last_A						=> s_loader_data_last_A,			--: out std_logic;
		po_data_sign_A						=> s_loader_data_sign_A,			--: out std_logic;
		po_wr_en_A							=> s_loader_wr_en_A,					--: out std_logic;
		po_data_B							=> s_loader_data_B,					--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last_B						=> s_loader_data_last_B,			--: out std_logic;
		po_data_sign_B						=> s_loader_data_sign_B,			--: out std_logic;
		po_wr_en_B							=> s_loader_wr_en_B					--: out std_logic
	);


	UNLOADER_INST: entity work.unloader generic map (
		g_lfsr								=> g_lfsr,								--: boolean := true;
		g_addr_width						=> g_addr_width,						--: natural := 9;
		g_data_width						=> g_data_width,						--: natural := 64;
		g_ctrl_width						=> g_ctrl_width,						--: natural := 8;
		g_select_width						=> g_reg_phys_addr_width			--: natural := 4;
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;
		po_busy								=> s_unloader_busy,					--: out std_logic;
		pi_start								=> s_unloader_start,					--: in std_logic;
		pi_select							=> s_unloader_select,				--: in std_logic_vector(g_select_width-1 downto 0);
		pi_size								=> s_unloader_size,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_last								=> s_unloader_last,					--: in std_logic_vector(2 downto 0);
		pi_sign								=> s_unloader_sign,					--: in std_logic_vector(2 downto 0);
		pi_data								=> s_reg_data,							--: in t_data_x1;
		pi_data_last						=> s_cpu_unloader_data_last,		--: in std_logic;
		pi_data_wr_en						=> s_cpu_unloader_data_wr_en,		--: in std_logic;
		m00_axis_tdata						=> m00_axis_tdata,					--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid					=> m00_axis_tvalid,					--: out std_logic;
		m00_axis_tlast						=> m00_axis_tlast,					--: out std_logic;
		m00_axis_tready					=> m00_axis_tready					--: in std_logic
	);


	CPU_INST: entity work.cpu generic map (
		g_sim									=> g_sim,												--: boolean := false;
		g_lfsr								=> g_lfsr,												--: boolean := true;
		g_num_of_phys_registers			=> g_num_of_phys_registers,						--: natural := 16;
		g_reg_phys_addr_width			=> g_reg_phys_addr_width,							--: natural := 4;
		g_reg_logic_addr_width			=> g_reg_logic_addr_width,							--: natural := 4;
		g_ctrl_width						=> g_ctrl_width,										--: natural := 8;
		g_addr_width						=> g_addr_width										--: natural := 9
	)
	port map (
		pi_clk								=> pi_clk,												--: in std_logic;
		pi_rst								=> pi_rst,												--: in std_logic;
		pi_ctrl_core_data					=> s00_ctrl_axis_tdata(7 downto 0),								--: in std_logic_vector(g_ctrl_width-1 downto 0);
		--pi_ctrl_core_data_last			=> s00_ctrl_axis_tlast,								--: in std_logic;
		pi_ctrl_core_data_last			=> s00_ctrl_axis_tdata(8),								--: in std_logic;
		pi_ctrl_core_valid				=> s00_ctrl_axis_tvalid,							--: in std_logic;
		po_ctrl_core_ready				=> s00_ctrl_axis_tready,							--: out std_logic;

		pi_loader_A_wr_en					=> s_loader_wr_en_A,									--: in std_logic;
		pi_loader_A_data_last			=> s_loader_data_last_A,							--: in std_logic;
		pi_loader_A_sign					=> s_loader_data_sign_A,							--: in std_logic;

		pi_loader_B_wr_en					=> s_loader_wr_en_B,									--: in std_logic;
		pi_loader_B_data_last			=> s_loader_data_last_B,							--: in std_logic;
		pi_loader_B_sign					=> s_loader_data_sign_B,							--: in std_logic;

		po_cmc_unloader_last				=> s_cpu_unloader_data_last,						--: out std_logic;
		po_cmc_unloader_wr_en			=> s_cpu_unloader_data_wr_en,						--: out std_logic;

		pi_adder_wr_en						=> s_adder_data_wr_en,								--: in std_logic;
		pi_adder_data_last				=> s_adder_data_last,								--: in std_logic;
		pi_adder_zero						=> s_adder_data_zero,								--: in std_logic_vector(1 downto 0);
		pi_adder_all_ones					=> s_adder_data_all_ones,							--: in std_logic;

		pi_mult_wr_en						=> s_mult_data_wr_en,								--: in std_logic;
		pi_mult_data_last					=> s_mult_data_last,									--: in std_logic;
		pi_mult_zero						=> s_mult_data_zero,									--: in std_logic;

		po_loader_start					=> s_loader_start,									--: std_logic_vector(1 downto 0);

		pi_unloader_busy					=> s_unloader_busy,									--: in std_logic;
		po_unloader_start					=> s_unloader_start,									--: out std_logic;
		po_unloader_select				=> s_unloader_select,								--: out std_logic_vector(3 downto 0);
		po_unloader_size					=> s_unloader_size,									--: out std_logic_vector(g_addr_width-1 downto 0);
		po_unloader_last					=> s_unloader_last,									--: out std_logic_vector(2 downto 0);
		po_unloader_sign					=> s_unloader_sign,									--: out std_logic;

		po_reg_ctrl_ch_1					=> s_reg_ctrl_ch_1,									--: std_logic_vector(g_ctrl_width-1 downto 0);
		po_reg_ctrl_ch_1_valid_n		=> s_reg_ctrl_ch_1_valid_n,						--: std_logic;
		po_reg_ctrl_ch_2					=> s_reg_ctrl_ch_2,									--: std_logic_vector(g_ctrl_width-1 downto 0);
		po_reg_ctrl_ch_2_valid_n		=> s_reg_ctrl_ch_2_valid_n,						--: std_logic;
		po_com_ctrl							=> s_com_ctrl,											--: std_logic_vector(g_ctrl_width-1 downto 0);
		po_com_ctrl_valid_n				=> s_com_ctrl_valid_n,								--: std_logic;
		po_oper_ctrl_ch_1					=> s_oper_ctrl_ch_1,									--: std_logic_vector(g_ctrl_width-1 downto 0);
		po_oper_ctrl_ch_2					=> s_oper_ctrl_ch_2,									--: std_logic_vector(g_ctrl_width-1 downto 0);
		po_oper_ctrl_valid_n				=> s_oper_ctrl_valid_n,								--: std_logic;
		po_cmc_addr_init_up_A			=> s_cmc_addr_init_up_A,							--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_A				=> s_cmc_data_cycle_A,								--: out std_logic;
		po_cmc_data_valid_A				=> s_cmc_data_valid_A,								--: out std_logic;
		po_cmc_data_last_A				=> s_cmc_data_last_A,								--: out std_logic_vector(2 downto 0);
		po_cmc_addr_init_up_B			=> s_cmc_addr_init_up_B,							--: out std_logic_vector(1 downto 0);
		po_cmc_data_cycle_B				=> s_cmc_data_cycle_B,								--: out std_logic;
		po_cmc_data_valid_B				=> s_cmc_data_valid_B,								--: out std_logic;
		po_cmc_data_last_B				=> s_cmc_data_last_B,								--: out std_logic_vector(2 downto 0)
		po_adder_data_last				=> s_cpu_adder_data_last,							--: out std_logic;
		po_adder_data_wr_en				=> s_cpu_adder_data_wr_en,							--: out std_logic

		po_mult_data_last					=> s_cpu_mult_data_last,							--: out std_logic;
		po_mult_data_wr_en				=> s_cpu_mult_data_wr_en,							--: out std_logic;
		po_mult_data_cycle				=> s_cpu_mult_data_cycle							--: out std_logic;
	);


	ADDER_INST: entity work.adder generic map (
		g_data_width						=> g_data_width,						--: natural := 64;
		g_addr_width						=> g_addr_width,						--: natural := 9;
		g_ctrl_width						=> g_ctrl_width,						--: natural := 8;
		g_select_width						=> g_reg_phys_addr_width,			--: natural := 5;
		g_id									=> C_STD_ID_ADDER						--: natural := 2;
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;
		pi_ctrl_ch_A						=> s_oper_ctrl_ch_1,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_B						=> s_oper_ctrl_ch_2,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n					=> s_oper_ctrl_valid_n,				--: in std_logic;

		pi_data								=> s_reg_data,							--: in t_data_x1;
		pi_data_last						=> s_cpu_adder_data_last,			--: in std_logic;
		pi_data_wr_en						=> s_cpu_adder_data_wr_en,			--: in std_logic;

		po_data_up							=> s_adder_data_up,					--: out std_logic_vector(g_data_width-1 downto 0);		-- REG
		po_data_lo							=> s_adder_data_lo,					--: out std_logic_vector(g_data_width-1 downto 0);		-- REG
		po_data_last						=> s_adder_data_last,				--: out std_logic;												-- REG & CPU
		po_data_wr_en						=> s_adder_data_wr_en,				--: out std_logic;												-- REG & CPU
		po_data_all_ones					=> s_adder_data_all_ones,			--: out std_logic;												-- REG & CPU
		po_data_zero						=> s_adder_data_zero					--: out std_logic_vector(1 downto 0);						-- CPU
	);


	MULTIPLIER_INST: entity work.multiplier generic map (
		g_data_width						=> g_data_width,						--: natural := 64;
		g_addr_width						=> g_addr_width,						--: natural := 9;
		g_ctrl_width						=> g_ctrl_width,						--: natural := 8;
		g_select_width						=> g_reg_phys_addr_width,			--: natural := 5;
		g_id									=> C_STD_ID_MULT						--: natural := 2
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;
		pi_ctrl_ch_A						=> s_oper_ctrl_ch_1,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_B						=> s_oper_ctrl_ch_2,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n					=> s_oper_ctrl_valid_n,				--: in std_logic;

		pi_data								=> s_reg_data,							--: in t_data_x1;
		pi_data_last						=> s_cpu_mult_data_last,			--: in std_logic;
		pi_data_wr_en						=> s_cpu_mult_data_wr_en,			--: in std_logic;
		pi_data_cycle						=> s_cpu_mult_data_cycle,			--: in std_logic;

		po_data								=> s_mult_data,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last						=> s_mult_data_last,					--: out std_logic;
		po_data_wr_en						=> s_mult_data_wr_en,				--: out std_logic;
		po_data_zero						=> s_mult_data_zero					--: out std_logic;
	);


	REGISTER_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		REGISTER_SINGLE_INST: entity work.register_single generic map (
			g_sim									=> g_sim,								--: boolean := true;
			g_lfsr								=> g_lfsr,								--: boolean := true;
			g_data_width						=> g_data_width,						--: natural := 64;
			g_addr_width						=> g_addr_width,						--: natural := 9;
			g_ctrl_width						=> g_ctrl_width,						--: natural := 8;
			g_id									=> i										--: natural := 2
		)
		port map (
			pi_clk								=> pi_clk,								--: in std_logic;
			pi_rst								=> pi_rst,								--: in std_logic;
			pi_ctrl_cpu_ch_1					=> s_reg_ctrl_ch_1,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
			pi_ctrl_cpu_ch_1_valid_n		=> s_reg_ctrl_ch_1_valid_n,		--: in std_logic;
			pi_ctrl_cpu_ch_2					=> s_reg_ctrl_ch_2,					--: in std_logic_vector(g_ctrl_width-1 downto 0);
			pi_ctrl_cpu_ch_2_valid_n		=> s_reg_ctrl_ch_2_valid_n,		--: in std_logic;

			pi_cpu_addr_init_up_A			=> s_cmc_addr_init_up_A,			--: in std_logic_vector(1 downto 0);
			pi_cpu_data_cycle_A				=> s_cmc_data_cycle_A,				--: in std_logic;
			pi_cpu_data_valid_A				=> s_cmc_data_valid_A,				--: in std_logic;
			pi_cpu_data_last_A				=> s_cmc_data_last_A(1 downto 0),--: in std_logic_vector(1 downto 0);

			pi_cpu_addr_init_up_B			=> s_cmc_addr_init_up_B,			--: in std_logic_vector(1 downto 0);
			pi_cpu_data_cycle_B				=> s_cmc_data_cycle_B,				--: in std_logic;
			pi_cpu_data_valid_B				=> s_cmc_data_valid_B,				--: in std_logic;
			pi_cpu_data_last_B				=> s_cmc_data_last_B(1 downto 0),--: in std_logic_vector(1 downto 0);

			-- LOADER
			pi_loader_A_data					=> s_loader_data_A,					--: in std_logic_vector(g_data_width-1 downto 0);
			pi_loader_A_data_last			=> s_loader_data_last_A,			--: in std_logic;
			pi_loader_A_data_wr_en			=> s_loader_wr_en_A,					--: in std_logic;

			pi_loader_B_data					=> s_loader_data_B,					--: in std_logic_vector(g_data_width-1 downto 0);
			pi_loader_B_data_last			=> s_loader_data_last_B,			--: in std_logic;
			pi_loader_B_data_wr_en			=> s_loader_wr_en_B,					--: in std_logic;


			-- REG COPY
			pi_reg_data							=> s_com_data,							--: in std_logic_vector(g_data_width-1 downto 0);
			pi_reg_data_last					=> s_com_data_last,					--: in std_logic;
			pi_reg_data_wr_en					=> s_com_data_wr_en,					--: in std_logic;


			-- ADDER
			pi_adder_data_up					=> s_adder_data_up,					--: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
			pi_adder_data_lo					=> s_adder_data_lo,					--: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
			pi_adder_data_last				=> s_adder_data_last,				--: in std_logic;
			pi_adder_data_wr_en				=> s_adder_data_wr_en,				--: in std_logic;


			-- MULT
			pi_mult_data						=> s_mult_data,						--: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
			pi_mult_data_last					=> s_mult_data_last,					--: in std_logic;
			pi_mult_data_wr_en				=> s_mult_data_wr_en,				--: in std_logic;

			po_data								=> s_reg_data(i)						--: out std_logic_vector(g_data_width-1 downto 0);
		);
	end generate;


	COMMON_INST: entity work.common generic map (
		g_id									=> C_STD_ID_COMMON,					--: natural := 30;
		g_ctrl_width						=> g_ctrl_width,						--: natural := 8;
		g_data_width						=> g_data_width,						--: natural := 64;
		g_select_width						=> g_reg_phys_addr_width			--: natural := 4
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_rst								=> pi_rst,								--: in std_logic;
		pi_ctrl								=> s_com_ctrl,							--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n					=> s_com_ctrl_valid_n,				--: in std_logic;

		pi_data								=> s_reg_data,							--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_last						=> s_cmc_data_last_A(2),			--: in std_logic;
		pi_data_wr_en						=> s_cmc_data_valid_A,				--: in std_logic;

		po_data								=> s_com_data,							--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last						=> s_com_data_last,					--: out std_logic;
		po_data_wr_en						=> s_com_data_wr_en					--: out std_logic
	);

end architecture;
