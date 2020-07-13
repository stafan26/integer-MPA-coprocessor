-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    register_single
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

entity register_single is
generic (
	g_sim									: boolean := false;
	--g_num_of_bram						: natural := 1;
	--g_num_of_ram_blocks				: natural := 1;
	g_lfsr								: boolean := true;
	g_data_width						: natural := 64;
	g_addr_width						: natural := 9;
	g_ctrl_width						: natural := 8;
	g_id									: natural := 2
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_cpu_ch_1					: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_cpu_ch_1_valid_n		: in std_logic;
	pi_ctrl_cpu_ch_2					: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_cpu_ch_2_valid_n		: in std_logic;

	pi_cpu_addr_init_up_A			: in std_logic_vector(1 downto 0);
	pi_cpu_data_cycle_A				: in std_logic;
	pi_cpu_data_valid_A				: in std_logic;
	pi_cpu_data_last_A				: in std_logic_vector(1 downto 0);

	pi_cpu_addr_init_up_B			: in std_logic_vector(1 downto 0);
	pi_cpu_data_cycle_B				: in std_logic;
	pi_cpu_data_valid_B				: in std_logic;
	pi_cpu_data_last_B				: in std_logic_vector(1 downto 0);


	-- LOADER
	pi_loader_A_data					: in std_logic_vector(g_data_width-1 downto 0);
	pi_loader_A_data_last			: in std_logic;
	pi_loader_A_data_wr_en			: in std_logic;

	pi_loader_B_data					: in std_logic_vector(g_data_width-1 downto 0);
	pi_loader_B_data_last			: in std_logic;
	pi_loader_B_data_wr_en			: in std_logic;


	-- REG COPY
	pi_reg_data							: in std_logic_vector(g_data_width-1 downto 0);
	pi_reg_data_last					: in std_logic;
	pi_reg_data_wr_en					: in std_logic;


	-- ADDER
	pi_adder_data_up					: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	pi_adder_data_lo					: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	pi_adder_data_last				: in std_logic;
	pi_adder_data_wr_en				: in std_logic;


	-- MULT
	pi_mult_data						: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	pi_mult_data_last					: in std_logic;
	pi_mult_data_wr_en				: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0)
);
end register_single;

architecture register_single of register_single is

	constant c_flags_delay								: natural := 4;

	signal s_post_mux_data_hi							: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_mux_data_lo							: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_mux_data_last						: std_logic;
	signal s_post_mux_data_wr_en						: std_logic;

	signal s_post_drv_data								: std_logic_vector(g_data_width-1 downto 0);
	signal s_post_drv_data_last						: std_logic;
	signal s_post_drv_data_wr_en						: std_logic;

	signal s_select										: std_logic_vector(2 downto 0);
	signal s_start_rd										: std_logic;
	signal s_start_wr										: std_logic;
	signal s_cmc_channel									: std_logic;
	signal s_operand_B									: std_logic;

	signal s_select_hi_lo								: std_logic;
	signal s_set_zero										: std_logic;
	signal s_set_one										: std_logic;

	signal s_cpu_addr_init_up							: std_logic;
	signal s_cpu_data_cycle								: std_logic;
	signal s_cpu_data_valid								: std_logic;
	signal s_cpu_data_last_my							: std_logic;
	signal s_cpu_data_last_other						: std_logic;

begin

	REG_ADDRESS_SELECTOR_INST: entity work.reg_address_selector port map (
		pi_clk						=> pi_clk,										--: in std_logic;
		pi_rst						=> pi_rst,										--: in std_logic;

		pi_cpu_addr_init_up_A	=> pi_cpu_addr_init_up_A,					--: in std_logic_vector(1 downto 0);
		pi_cpu_data_cycle_A		=> pi_cpu_data_cycle_A,						--: in std_logic;
		pi_cpu_data_valid_A		=> pi_cpu_data_valid_A,						--: in std_logic;
		pi_cpu_data_last_A		=> pi_cpu_data_last_A,						--: in std_logic_vector(1 downto 0);

		pi_cpu_addr_init_up_B	=> pi_cpu_addr_init_up_B,					--: in std_logic_vector(1 downto 0);
		pi_cpu_data_cycle_B		=> pi_cpu_data_cycle_B,						--: in std_logic;
		pi_cpu_data_valid_B		=> pi_cpu_data_valid_B,						--: in std_logic;
		pi_cpu_data_last_B		=> pi_cpu_data_last_B,						--: in std_logic_vector(1 downto 0);

		pi_start						=> s_start_rd,									--: in std_logic;
		pi_cmc_channel				=> s_cmc_channel,								--: in std_logic;
		pi_operand_B				=> s_operand_B,								--: in std_logic;
		po_cpu_addr_init_up		=> s_cpu_addr_init_up,						--: out std_logic;
		po_cpu_data_cycle			=> s_cpu_data_cycle,							--: out std_logic;
		po_cpu_data_valid			=> s_cpu_data_valid,							--: out std_logic;
		po_cpu_data_last_my		=> s_cpu_data_last_my,						--: out std_logic;
		po_cpu_data_last_other	=> s_cpu_data_last_other					--: out std_logic
	);


	REG_SWITCHBOX_INST: entity work.reg_switchbox generic map (
		g_id							=> g_id,										--: natural := 36;
		g_data_width				=> g_data_width							--: natural := 64;
	)
	port map (
		pi_clk						=> pi_clk,									--: in std_logic;
		pi_rst						=> pi_rst,									--: in std_logic;
		pi_select					=> s_select,								--: in std_logic_vector(2 downto 0);
		pi_start						=> s_start_wr,								--: in std_logic;

		-- LOADER
		pi_loader_A_data			=> pi_loader_A_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		pi_loader_A_data_last	=> pi_loader_A_data_last,				--: in std_logic;
		pi_loader_A_data_wr_en	=> pi_loader_A_data_wr_en,				--: in std_logic;

		pi_loader_B_data			=> pi_loader_B_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		pi_loader_B_data_last	=> pi_loader_B_data_last,				--: in std_logic;
		pi_loader_B_data_wr_en	=> pi_loader_B_data_wr_en,				--: in std_logic;

		-- REG COPY
		pi_reg_data					=> pi_reg_data,							--: in std_logic_vector(g_data_width-1 downto 0);
		pi_reg_data_last			=> pi_reg_data_last,						--: in std_logic;
		pi_reg_data_wr_en			=> pi_reg_data_wr_en,					--: in std_logic;

		-- ADDER
		pi_adder_data_lo			=> pi_adder_data_lo,						--: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
		pi_adder_data_last		=> pi_adder_data_last,					--: in std_logic;
		pi_adder_data_wr_en		=> pi_adder_data_wr_en,					--: in std_logic;

		-- MULT
		pi_mult_data				=> pi_mult_data,							--: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
		pi_mult_data_last			=> pi_mult_data_last,					--: in std_logic;
		pi_mult_data_wr_en		=> pi_mult_data_wr_en,					--: in std_logic;

		po_data						=> s_post_mux_data_lo,					--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> s_post_mux_data_last,				--: out std_logic;
		po_data_wr_en				=> s_post_mux_data_wr_en				--: out std_logic;
	);


	DATA_B_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> g_data_width,		--: natural := 64;
		g_delay				=> 1						--: natural := 4
	)
	port map (
		pi_clk			=> pi_clk,					--: in std_logic;
		pi_data			=> pi_adder_data_up,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data			=> s_post_mux_data_hi	--: out std_logic_vector(g_data_width-1 downto 0)
	);



	REG_DRIVER_INST: entity work.reg_driver generic map (
		g_data_width				=> g_data_width							--: natural := 64;
	)
	port map (
		pi_clk						=> pi_clk,									--: in std_logic;
		pi_rst						=> pi_rst,									--: in std_logic;
		pi_data_hi					=> s_post_mux_data_hi,					--: in std_logic_vector(g_data_width-1 downto 0)
		pi_data_lo					=> s_post_mux_data_lo,					--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_last				=> s_post_mux_data_last,				--: in std_logic;
		pi_data_wr_en				=> s_post_mux_data_wr_en,				--: in std_logic;
		pi_select_hi_lo			=> s_select_hi_lo,						--: in std_logic;
		pi_set_zero					=> s_set_zero,								--: in std_logic;
		pi_set_one					=> s_set_one,								--: in std_logic
		po_data						=> s_post_drv_data,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> s_post_drv_data_last,				--: out std_logic;
		po_data_wr_en				=> s_post_drv_data_wr_en				--: out std_logic;
	);


	REG_BASE_INST: entity work.reg_base generic map (
		g_sim							=> g_sim,									--: boolean := false;
		g_lfsr						=> g_lfsr,									--: boolean := true;
		g_data_width				=> g_data_width,							--: natural := 64;
		g_addr_width				=> g_addr_width,							--: natural := 9;
		g_ctrl_width				=> g_ctrl_width,							--: natural := 8;
		g_id							=> g_id										--: natural := 2
	)
	port map (
		pi_clk						=> pi_clk,									--: in std_logic;
		pi_rst						=> pi_rst,									--: in std_logic;
		pi_ctrl_ch_1				=> pi_ctrl_cpu_ch_1,						--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_1_valid_n		=> pi_ctrl_cpu_ch_1_valid_n,			--: in std_logic;
		pi_ctrl_ch_2				=> pi_ctrl_cpu_ch_2,						--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_2_valid_n		=> pi_ctrl_cpu_ch_2_valid_n,			--: in std_logic;
		po_cmc_channel				=> s_cmc_channel,							--: out std_logic;
		po_operand_B				=> s_operand_B,							--: out std_logic;
		po_select					=> s_select,								--: out std_logic_vector(2 downto 0);
		po_start_rd					=> s_start_rd,								--: out std_logic;
		po_start_wr					=> s_start_wr,								--: out std_logic;
		po_select_hi_lo			=> s_select_hi_lo,						--: out std_logic;
		po_set_zero					=> s_set_zero,								--: out std_logic;
		po_set_one					=> s_set_one,								--: out std_logic
		pi_cpu_addr_init_up		=> s_cpu_addr_init_up,					--: in std_logic;
		pi_cpu_data_cycle			=> s_cpu_data_cycle,						--: in std_logic;
		pi_cpu_data_valid			=> s_cpu_data_valid,						--: in std_logic;
		pi_cpu_data_last_my		=> s_cpu_data_last_my,					--: in std_logic;
		pi_cpu_data_last_other	=> s_cpu_data_last_other,				--: in std_logic;
		pi_data						=> s_post_drv_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_last				=> s_post_drv_data_last,				--: in std_logic;
		pi_data_wr_en				=> s_post_drv_data_wr_en,				--: in std_logic;
		po_data						=> po_data									--: out std_logic_vector(g_data_width-1 downto 0);
	);


end architecture;
