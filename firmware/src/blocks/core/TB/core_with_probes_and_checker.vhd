-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    core_with_probes_and_checker
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.test_pack.all;
--use work.dpi_test_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity core_with_probes_and_checker is
generic (
	g_sim									: boolean := false;
	g_num_of_bram						: natural := 1;
	g_opcode_width						: natural := 4;
	g_lfsr								: boolean := true;
	g_num_of_logic_registers		: natural := C_NUM_OF_REGISTERS;
	g_num_of_phys_registers			: natural := C_NUM_OF_ALL_REGISTERS;
	g_reg_logic_addr_width			: natural := addr_width(C_NUM_OF_REGISTERS);
	g_reg_phys_addr_width			: natural := addr_width(C_NUM_OF_ALL_REGISTERS);
--	g_reg_logic_addr_width			: natural := 4;
--	g_reg_phys_addr_width			: natural := 5;
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

	po_probe_wr_en						: out std_logic;
	po_probe_logic_1					: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	po_probe_logic_2					: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	po_probe_logic_3					: out std_logic_vector(g_reg_logic_addr_width-1 downto 0);

	pi_dpi_instr						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_dpi_data_1						: in std_logic_vector(2**g_addr_width*g_data_width-1 downto 0);
	pi_dpi_data_2						: in std_logic_vector(2**g_addr_width*g_data_width-1 downto 0);
	pi_dpi_data_3						: in std_logic_vector(2**g_addr_width*g_data_width-1 downto 0);
	pi_dpi_data_sign_1				: in std_logic;
	pi_dpi_data_sign_2				: in std_logic;
	pi_dpi_data_sign_3				: in std_logic;
	pi_dpi_data_size_1				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_dpi_data_size_2				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_dpi_data_size_3				: in std_logic_vector(g_addr_width-1 downto 0);
	pi_dpi_data_phys_1				: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_dpi_data_phys_2				: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	pi_dpi_data_phys_3				: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);

	po_error_opcode					: out std_logic;

	po_error_read						: out std_logic;
	po_error_write						: out std_logic;
	po_error_data						: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_error_sign						: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_error_size						: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_error_phys						: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

	pi_force_stop						: in std_logic;
	po_end_of_prog_file				: out std_logic;
	po_end_of_sim						: out std_logic
);
end core_with_probes_and_checker;

architecture core_with_probes_and_checker of core_with_probes_and_checker is

	signal c_dpi_delay				: natural := 5;

	signal s_probe_instr				: std_logic_vector(g_opcode_width-1 downto 0);
	signal s_probe_logic_1			: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_probe_logic_2			: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_probe_logic_3			: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_probe_wr_en				: std_logic;

	signal s_probe_instr_dly		: std_logic_vector(g_opcode_width-1 downto 0);
	signal s_probe_logic_1_dly		: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_probe_logic_2_dly		: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_probe_logic_3_dly		: std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	signal s_probe_wr_en_dly		: std_logic;

	signal s_probe_reg_busy			: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_probe_data_sign 		: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_probe_data_size 		: t_size;
	signal s_probe_data_phys 		: t_phys;
	signal r_probe_data				: t_mm;

	signal s_dpi_data_1				: t_ram;
	signal s_dpi_data_2				: t_ram;
	signal s_dpi_data_3				: t_ram;

	signal r_end_of_prog_file		: std_logic;
	signal r_end_of_prog_file_flag: std_logic;
	signal r_end_of_sim				: std_logic;

	signal r_cnt_valid				: natural;

begin

	------------------------------
	-----                    -----
	-----   DATA REPACKING   -----
	-----                    -----
	------------------------------

	DPI_DATA_GEN: for i in 0 to 2**g_addr_width-1 generate
		s_dpi_data_1(i) <= pi_dpi_data_1(i*g_data_width+g_data_width-1 downto i*g_data_width);
		s_dpi_data_2(i) <= pi_dpi_data_2(i*g_data_width+g_data_width-1 downto i*g_data_width);
		s_dpi_data_3(i) <= pi_dpi_data_3(i*g_data_width+g_data_width-1 downto i*g_data_width);
	end generate;


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



	PROBE_INSTR_INST: entity work.data_delayer generic map (
		g_data_width		=> g_opcode_width,					--: natural := 64;
		g_delay				=> c_dpi_delay							--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_data				=> s_probe_instr,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> s_probe_instr_dly					--: out std_logic_vector(g_data_width-1 downto 0)
	);

	PROBE_LOGIC_1_INST: entity work.data_delayer generic map (
		g_data_width		=> g_reg_logic_addr_width,			--: natural := 64;
		g_delay				=> c_dpi_delay							--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_data				=> s_probe_logic_1,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> s_probe_logic_1_dly				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	PROBE_LOGIC_2_INST: entity work.data_delayer generic map (
		g_data_width		=> g_reg_logic_addr_width,			--: natural := 64;
		g_delay				=> c_dpi_delay							--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_data				=> s_probe_logic_2,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> s_probe_logic_2_dly				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	PROBE_LOGIC_3_INST: entity work.data_delayer generic map (
		g_data_width		=> g_reg_logic_addr_width,			--: natural := 64;
		g_delay				=> c_dpi_delay							--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_data				=> s_probe_logic_3,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> s_probe_logic_3_dly				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	PROBE_WR_EN_INST: entity work.data_delayer generic map (
		g_data_width		=> 1,										--: natural := 64;
		g_delay				=> c_dpi_delay							--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,								--: in std_logic;
		pi_data(0)			=> s_probe_wr_en,						--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)			=> s_probe_wr_en_dly					--: out std_logic_vector(g_data_width-1 downto 0)
	);





	----------------------
	-----            -----
	-----   PROBES   -----
	-----            -----
	----------------------
	po_probe_logic_1 <= s_probe_logic_1_dly;
	po_probe_logic_2 <= s_probe_logic_2_dly;
	po_probe_logic_3 <= s_probe_logic_3_dly;
	po_probe_wr_en <= s_probe_wr_en_dly;

	s_probe_instr <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.s_cmd_opcode : std_logic_vector(g_opcode_width-1 downto 0) >>;
	s_probe_logic_1 <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.s_logic_reg_1 : std_logic_vector(g_reg_logic_addr_width-1 downto 0) >>;
	s_probe_logic_2 <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.s_logic_reg_2 : std_logic_vector(g_reg_logic_addr_width-1 downto 0) >>;
	s_probe_logic_3 <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.s_logic_reg_3 : std_logic_vector(g_reg_logic_addr_width-1 downto 0) >>;
	s_probe_wr_en <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.s_cmd_taken : std_logic >>;

	s_probe_reg_busy <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.CPU_BUSYBOX_INST.r_reg_busy : std_logic_vector(g_num_of_phys_registers-1 downto 0) >>;
	s_probe_data_sign <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.CPU_FOLLOWER_INST.s_sign : std_logic_vector(g_num_of_phys_registers-1 downto 0) >>;
	s_probe_data_size <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.CPU_FOLLOWER_INST.s_size : t_size >>;
	s_probe_data_phys <= << signal .core_with_probes_and_checker.CORE_INST.CPU_INST.CPU_MAPPER_INST.s_phys_reg : t_phys >>;


	DATA_PROBE_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		DATA_PROBE_PROC: process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then
				r_probe_data(i) <= << signal .core_with_probes_and_checker.CORE_INST.REGISTER_GEN(i).REGISTER_SINGLE_INST.REG_BASE_INST.MY_BRAM_INST.r_ram : t_ram >>;
			end if;
		end process;

	end generate;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(r_cnt_valid > 16 and s_probe_wr_en = '1') then
				r_cnt_valid <= 0;
			elsif(s00_ctrl_axis_tvalid = '0' and pi_rst = '0' and s_probe_reg_busy = (s_probe_reg_busy'length-1 downto 0 => '0')) then
				r_cnt_valid <= r_cnt_valid + 1;
			else
				r_cnt_valid <= 0;
			end if;

			if(pi_rst = '1') then
				r_end_of_prog_file_flag <= '0';
			else
				if(r_cnt_valid > 16 and s_probe_wr_en = '1') then
					r_end_of_prog_file_flag <= '1';
				end if;
			end if;

			if((r_cnt_valid > 16 and r_end_of_prog_file_flag = '1') or pi_force_stop = '1') then
				r_end_of_prog_file <= '1';
			else
				r_end_of_prog_file <= '0';
			end if;

			r_end_of_sim <= r_end_of_prog_file;
		end if;
	end process;

	po_end_of_prog_file <= r_end_of_prog_file;
	po_end_of_sim <= r_end_of_sim;


	-----------------------------
	-----                   -----
	-----   ERROR CHECKER   -----
	-----                   -----
	-----------------------------

	ERROR_CHECKER_INST: entity work.error_checker generic map (
		g_num_of_phys_registers		=> g_num_of_phys_registers,			--: natural := 18;
		g_reg_logic_addr_width		=> g_reg_logic_addr_width,				--: natural := 4;
		g_reg_phys_addr_width		=> g_reg_phys_addr_width,				--: natural := 5;
		g_data_width					=> g_data_width,							--: natural := 64;
		g_addr_width					=> g_addr_width,							--: natural := 9;
		g_ctrl_width					=> g_ctrl_width,							--: natural := 8;
		g_opcode_width					=> g_opcode_width							--: natural := 4
	)
	port map (
		pi_clk							=> pi_clk,									--: in std_logic;
		pi_rst							=> pi_rst,									--: in std_logic;

		pi_probe_instr					=> s_probe_instr_dly,					--: in std_logic_vector(g_opcode_width-1 downto 0);
		pi_probe_reg_1					=> s_probe_logic_1_dly,					--: in std_logic_vector(g_opcode_width-1 downto 0);		-- TMP FIX
		pi_probe_reg_2					=> s_probe_logic_2_dly,					--: in std_logic_vector(g_opcode_width-1 downto 0);		-- TMP FIX
		pi_probe_reg_3					=> s_probe_logic_3_dly,					--: in std_logic_vector(g_opcode_width-1 downto 0);		-- TMP FIX
		pi_probe_wr_en					=> s_probe_wr_en_dly,					--: in std_logic;

		pi_srup_reg_busy				=> s_probe_reg_busy,						--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_srup_data					=> r_probe_data,							--: in t_mm;
		pi_srup_data_sign				=> s_probe_data_sign,					--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		pi_srup_data_size				=> s_probe_data_size,					--: in t_size;
		pi_srup_data_phys				=> s_probe_data_phys,					--: in t_phys;

		pi_dpi_instr					=> pi_dpi_instr,							--: in std_logic_vector(g_opcode_width-1 downto 0);
		pi_dpi_data_1					=> s_dpi_data_1,							--: in t_ram;
		pi_dpi_data_2					=> s_dpi_data_2,							--: in t_ram;
		pi_dpi_data_3					=> s_dpi_data_3,							--: in t_ram;
		pi_dpi_data_sign_1			=> pi_dpi_data_sign_1,					--: in std_logic;
		pi_dpi_data_sign_2			=> pi_dpi_data_sign_2,					--: in std_logic;
		pi_dpi_data_sign_3			=> pi_dpi_data_sign_3,					--: in std_logic;
		pi_dpi_data_size_1			=> pi_dpi_data_size_1,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_dpi_data_size_2			=> pi_dpi_data_size_2,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_dpi_data_size_3			=> pi_dpi_data_size_3,					--: in std_logic_vector(g_addr_width-1 downto 0);
		pi_dpi_data_phys_1			=> pi_dpi_data_phys_1,					--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_dpi_data_phys_2			=> pi_dpi_data_phys_2,					--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_dpi_data_phys_3			=> pi_dpi_data_phys_3,					--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		po_error_opcode				=> po_error_opcode,						--: out std_logic;
		po_error_read					=> po_error_read,							--: out std_logic;
		po_error_write					=> po_error_write,						--: out std_logic;
		po_error_data					=> po_error_data,							--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_error_sign					=> po_error_sign,							--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_error_size					=> po_error_size,							--: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_error_phys					=> po_error_phys							--: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
	);

end architecture;
