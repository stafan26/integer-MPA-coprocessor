-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_follower
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

entity cpu_follower is
generic (
	g_lfsr								: boolean := true;
	g_num_of_phys_registers			: natural := 18;
	g_ctrl_width						: natural := 8;
	g_reg_phys_addr_width			: natural := 5;
	g_addr_width						: natural := 9
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_reg_mode_start					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_reg_mode_B						: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_reg_mode_aux					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_reg_mode							: in std_logic_vector(2 downto 0);

	pi_loader_A_wr_en					: in std_logic;
	pi_loader_A_data_last			: in std_logic;
	pi_loader_A_sign					: in std_logic;

	pi_loader_B_wr_en					: in std_logic;
	pi_loader_B_data_last			: in std_logic;
	pi_loader_B_sign					: in std_logic;

	pi_adder_wr_en						: in std_logic;
	pi_adder_data_last				: in std_logic;
	pi_adder_zero						: in std_logic_vector(1 downto 0);
	pi_adder_all_ones					: in std_logic;
	pi_adder_sign_inverted			: in std_logic_vector(g_num_of_phys_registers-1 downto 0);

	pi_mult_wr_en						: in std_logic;
	pi_mult_data_last					: in std_logic;
	pi_mult_zero						: in std_logic;

	pi_set_zero							: in std_logic;
	pi_set_one							: in std_logic;
	pi_set_zero_or_one				: in std_logic;

	pi_cpu_sign							: in std_logic;
	pi_cpu_update						: in std_logic_vector(g_num_of_phys_registers-1 downto 0);

	pi_cmd_phys_reg_1					: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_cmd_phys_reg_2					: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);

	po_main_size						: out std_logic_vector(g_addr_width-1 downto 0);
	po_main_last						: out std_logic_vector(4 downto 0);
	po_main_sign						: out std_logic;
	po_main_zero						: out std_logic;
	po_main_one							: out std_logic;

	po_other_size						: out std_logic_vector(g_addr_width-1 downto 0);
	po_other_last						: out std_logic_vector(4 downto 0);
	po_other_sign						: out std_logic;
	po_other_zero						: out std_logic;
	po_other_one						: out std_logic
);
end cpu_follower;

architecture cpu_follower of cpu_follower is

	type t_dynamic_lasts is array (0 to g_num_of_phys_registers-1) of std_logic_vector(4 downto 0);

	constant c_rec_size				: natural := (g_addr_width+8);
	signal s_data						: std_logic_vector(g_num_of_phys_registers*c_rec_size-1 downto 0);

	signal s_main_data_out			: std_logic_vector(c_rec_size-1 downto 0);
	signal s_other_data_out			: std_logic_vector(c_rec_size-1 downto 0);

	signal s_size						: t_size;
	signal s_last						: t_dynamic_lasts;
	signal s_sign						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_zero						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_one						: std_logic_vector(g_num_of_phys_registers-1 downto 0);


	signal s_in_wr_en					: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_in_data_last			: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_in_sign					: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_in_zero					: std_logic_vector(g_num_of_phys_registers-1 downto 0);

begin

	REGISTERS_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		CPU_REG_SHUTTER_INST: entity work.cpu_follower_data_last_switchbox port map (
			pi_clk						=> pi_clk,								--: in std_logic;
			pi_rst						=> pi_rst,								--: in std_logic;
			pi_reg_mode_start			=> pi_reg_mode_start(i),			--: in std_logic;
			pi_reg_mode_B				=> pi_reg_mode_B(i),					--: in std_logic;
			pi_reg_mode_aux			=> pi_reg_mode_aux(i),				--: in std_logic;
			pi_reg_mode					=> pi_reg_mode,						--: in std_logic_vector(2 downto 0);
			pi_loader_A_wr_en			=> pi_loader_A_wr_en,				--: in std_logic;
			pi_loader_A_data_last	=> pi_loader_A_data_last,			--: in std_logic;
			pi_loader_A_sign			=> pi_loader_A_sign,					--: in std_logic;
			pi_loader_B_wr_en			=> pi_loader_B_wr_en,				--: in std_logic;
			pi_loader_B_data_last	=> pi_loader_B_data_last,			--: in std_logic;
			pi_loader_B_sign			=> pi_loader_B_sign,					--: in std_logic;
			pi_adder_wr_en				=> pi_adder_wr_en,					--: in std_logic;
			pi_adder_data_last		=> pi_adder_data_last,				--: in std_logic;
			pi_adder_zero				=> pi_adder_zero,						--: in std_logic_vector(1 downto 0);
			pi_adder_all_ones			=> pi_adder_all_ones,				--: in std_logic;
			pi_mult_wr_en				=> pi_mult_wr_en,						--: in std_logic;
			pi_mult_data_last			=> pi_mult_data_last,				--: in std_logic;
			pi_mult_zero				=> pi_mult_zero,						--: in std_logic;

			pi_set_zero					=> pi_set_zero,						--: in std_logic;
			pi_set_one					=> pi_set_one,							--: in std_logic;
			pi_set_zero_or_one		=> pi_set_zero_or_one,				--: in std_logic;

			po_wr_en						=> s_in_wr_en(i),						--: out std_logic;
			po_data_last				=> s_in_data_last(i),				--: out std_logic;
			po_sign						=> s_in_sign(i),						--: out std_logic;
			po_zero						=> s_in_zero(i)						--: out std_logic;
		);


		CPU_REG_OBSERVER_INST: entity work.cpu_follower_reg_observer generic map (
			g_lfsr						=> g_lfsr,								--: boolean := true;
			g_addr_width				=> g_addr_width						--: natural := 9
		)
		port map (
			pi_clk						=> pi_clk,								--: in std_logic;
			pi_rst						=> pi_rst,								--: in std_logic;

			pi_data_last				=> s_in_data_last(i),				--: in std_logic;
			pi_sign						=> s_in_sign(i),						--: in std_logic;
			pi_wr_en						=> s_in_wr_en(i),						--: in std_logic;
			pi_zero						=> s_in_zero(i),						--: in std_logic;

			pi_cpu_sign					=> pi_cpu_sign,						--: in std_logic;
			pi_cpu_update				=> pi_cpu_update(i),					--: in std_logic;
			pi_adder_sign_inverted	=> pi_adder_sign_inverted(i),		--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);

			po_size						=> s_size(i),							--: out std_logic_vector(g_addr_width-1 downto 0);
			po_last						=> s_last(i),							--: out std_logic_vector(4 downto 0);
			po_sign						=> s_sign(i),							--: out std_logic;
			po_zero						=> s_zero(i),							--: out std_logic;
			po_one						=> s_one(i)								--: out std_logic
		);

		s_data((i+1)*c_rec_size-1 downto i*c_rec_size) <=  s_one(i) & s_zero(i) & s_sign(i) & s_last(i) & s_size(i);

	end generate;


	MAIN_NUM_MUX_STREAM_INST: entity work.mux generic map (
		g_word_width		=> c_rec_size,										--: natural := 16;
		g_num_of_words		=> g_num_of_phys_registers,					--: natural := 14;
		g_addr_width		=> g_reg_phys_addr_width						--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,											--: in std_logic;
		pi_addr				=> pi_cmd_phys_reg_1,							--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_data				=> s_data,											--: in std_logic_vector(g_num_of_words*g_word_width-1 downto 0);
		po_data				=> s_main_data_out								--: out std_logic
	);


	po_main_one  <= s_main_data_out(g_addr_width+7);
	po_main_zero <= s_main_data_out(g_addr_width+6);
	po_main_sign <= s_main_data_out(g_addr_width+5);
	po_main_last <= s_main_data_out(g_addr_width+5-1 downto g_addr_width);
	po_main_size <= s_main_data_out(g_addr_width-1 downto 0);


	AUX_NUM_MUX_STREAM_INST: entity work.mux generic map (
		g_word_width		=> c_rec_size,								--: natural := 16;
		g_num_of_words		=> g_num_of_phys_registers,			--: natural := 14;
		g_addr_width		=> g_reg_phys_addr_width				--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,									--: in std_logic;
		pi_addr				=> pi_cmd_phys_reg_2,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_data				=> s_data,									--: in std_logic_vector(g_num_of_words*g_word_width-1 downto 0);
		po_data				=> s_other_data_out						--: out std_logic
	);


	po_other_one  <= s_other_data_out(g_addr_width+7);
	po_other_zero <= s_other_data_out(g_addr_width+6);
	po_other_sign <= s_other_data_out(g_addr_width+5);
	po_other_last <= s_other_data_out(g_addr_width+5-1 downto g_addr_width+0);
	po_other_size <= s_other_data_out(g_addr_width-1 downto 0);


end architecture;
