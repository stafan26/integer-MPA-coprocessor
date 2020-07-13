-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    core_with_probes
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.test_pack.all;
--use work.dpi_test_pack.all;
--use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity core_with_probes is
generic (
	g_sim									: boolean := false;
	g_num_of_bram						: natural := 1;
	g_opcode_width						: natural := 4;
	g_lfsr								: boolean := true;
	g_num_of_logic_registers		: natural := C_NUM_OF_REGISTERS;
	g_num_of_phys_registers			: natural := C_NUM_OF_ALL_REGISTERS;
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
	s00_ctrl_axis_tdata				: in std_logic_vector(g_ctrl_width-1 downto 0);
	s00_ctrl_axis_tlast				: in std_logic;
	s00_ctrl_axis_tvalid				: in std_logic;
	s00_ctrl_axis_tready				: out std_logic;
	m00_axis_tdata						: out std_logic_vector(g_data_width-1 downto 0);
	m00_axis_tvalid					: out std_logic;
	m00_axis_tlast						: out std_logic;
	m00_axis_tready					: in std_logic;

	po_probe_instr						: out std_logic_vector(g_opcode_width-1 downto 0);
	po_probe_wr_en						: out std_logic;

	po_probe_reg_busy					: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_probe_data						: out t_mm;
	po_probe_data_sign				: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_probe_data_size				: out t_size;
	po_probe_data_logic				: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_probe_data_phys				: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

	pi_force_stop						: in std_logic;
	po_end_of_prog_file				: out std_logic;
	po_end_of_sim						: out std_logic
);
end core_with_probes;

architecture core_with_probes of core_with_probes is

	signal r_probe_reg_busy			: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_end_of_prog_file		: std_logic;
	signal r_end_of_sim				: std_logic;

	signal r_cnt_valid				: natural;

--	type t_ram is array (0 to 2**g_addr_width-1) of std_logic_vector(g_data_width-1 downto 0);
--	type t_mm is array (0 to g_num_of_phys_registers-1) of t_ram;
--
--	signal a_signs						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
--	signal a_regs						: t_mm;
--
--	signal a_reg_busy					: std_logic_vector(g_num_of_phys_registers-1 downto 0);

begin

	--------------------
	-----          -----
	-----   CORE   -----
	-----          -----
	--------------------

	CORE_INST: entity work.core generic map (
		g_sim								=> g_sim,								--: boolean := false;
		g_num_of_bram					=> g_num_of_bram,						--: natural := 1;
		g_lfsr							=> g_lfsr,								--: boolean := true;
		g_num_of_logic_registers	=> g_num_of_logic_registers,		--: natural := C_NUM_OF_REGISTERS;
		g_num_of_phys_registers		=> g_num_of_phys_registers,		--: natural := C_NUM_OF_ALL_REGISTERS;
		g_data_width					=> g_data_width,						--: natural := C_STD_DATA_WIDTH;
		g_addr_width					=> g_addr_width,						--: natural := C_STD_ADDR_WIDTH;
		g_ctrl_width					=> g_ctrl_width						--: natural := C_STD_CTRL_WIDTH
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		s00a_axis_tdata				=> s00a_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid				=> s00a_axis_tvalid,					--: in std_logic;
		s00a_axis_tready				=> s00a_axis_tready,					--: out std_logic;
		s00b_axis_tdata				=> s00b_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid				=> s00b_axis_tvalid,					--: in std_logic;
		s00b_axis_tready				=> s00b_axis_tready,					--: out std_logic;
		s00_ctrl_axis_tdata			=> s00_ctrl_axis_tdata,				--: in std_logic_vector(g_ctrl_width-1 downto 0);
		s00_ctrl_axis_tlast			=> s00_ctrl_axis_tlast,				--: in std_logic;
		s00_ctrl_axis_tvalid			=> s00_ctrl_axis_tvalid,			--: in std_logic;
		s00_ctrl_axis_tready			=> s00_ctrl_axis_tready,			--: out std_logic;
		m00_axis_tdata					=> m00_axis_tdata,					--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid				=> m00_axis_tvalid,					--: out std_logic;
		m00_axis_tlast					=> m00_axis_tlast,					--: out std_logic;
		m00_axis_tready				=> m00_axis_tready					--: in std_logic
	);

	po_probe_reg_busy <= r_probe_reg_busy;
	r_probe_reg_busy <= << signal .core_with_probes.CORE_INST.CPU_INST.CPU_BUSYBOX_INST.r_reg_busy : std_logic_vector(g_num_of_phys_registers-1 downto 0) >>;
	po_probe_data_sign <= << signal .core_with_probes.CORE_INST.CPU_INST.CPU_FOLLOWER_INST.s_sign : std_logic_vector(g_num_of_phys_registers-1 downto 0) >>;
	po_probe_data_size <= << signal .core_with_probes.CORE_INST.CPU_INST.CPU_FOLLOWER_INST.s_size : t_size >>;

--	SIGNS_GEN: for i in 0 to g_num_of_phys_registers-1 generate
--		po_probe_data(i) <= <<signal .core_dpi_TB.CORE_INST.REGISTER_GEN(i).REGISTER_SINGLE_INST.REG_BASE_INST.MY_BRAM.r_ram : t_ram>>;
--		po_probe_data_logic				: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
--		po_probe_data_phys				: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
--	end generate;

	po_probe_instr <= << signal .core_with_probes.CORE_INST.CPU_INST.s_cmd_opcode : std_logic_vector(g_opcode_width-1 downto 0) >>;
	po_probe_wr_en <= << signal .core_with_probes.CORE_INST.CPU_INST.s_cmd_taken : std_logic >>;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(s00_ctrl_axis_tvalid = '0' and pi_rst = '0' and r_probe_reg_busy = (r_probe_reg_busy'length-1 downto 0 => '0')) then
				r_cnt_valid <= r_cnt_valid + 1;
			else
				r_cnt_valid <= 0;
			end if;

			if(r_cnt_valid = 16 or pi_force_stop = '1') then
				r_end_of_prog_file <= '1';
			else
				r_end_of_prog_file <= '0';
			end if;

			r_end_of_sim <= r_end_of_prog_file;
		end if;
	end process;

	po_end_of_prog_file <= r_end_of_prog_file;
	po_end_of_sim <= r_end_of_sim;

end architecture;
