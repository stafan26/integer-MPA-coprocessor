-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    29/12/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    core_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;
use work.common_pack.all;

entity core_TB is
generic(
	g_store_output_file									: boolean := false;
	g_data_dir_path										: string := "./";
	g_lfsr													: boolean := false
);
end core_TB;

architecture core_TB of core_TB is

	constant c_sim											: boolean := true;
	constant c_num_of_bram								: natural := 1;
	constant c_num_of_logic_registers				: natural := C_NUM_OF_REGISTERS;
	constant c_num_of_phys_registers					: natural := C_NUM_OF_ALL_REGISTERS;
	constant c_data_width								: natural := C_STD_DATA_WIDTH;
	constant c_addr_width								: natural := C_STD_ADDR_WIDTH;
	constant c_ctrl_width								: natural := C_STD_CTRL_WIDTH;
	constant c_opcode_unload							: std_logic_vector(3 downto 0) := to_std_logic_vector(C_STD_OPCODE_UNLOAD, 4);
	constant c_delay_last_and_close					: natural := 24;

	constant c_prog_filename							: string := "prog.bin";
	constant c_bus_A_filename							: string := "busA.bin";
	constant c_bus_B_filename							: string := "busB.bin";
	constant c_bus_Z_filename							: string := "busZ.bin";

	constant c_prog_filepath							: string := g_data_dir_path & "/" & c_prog_filename;
	constant c_bus_A_filepath							: string := g_data_dir_path & "/" & c_bus_A_filename;
	constant c_bus_B_filepath							: string := g_data_dir_path & "/" & c_bus_B_filename;
	constant c_bus_Z_filepath							: string := g_data_dir_path & "/" & c_bus_Z_filename;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;
	signal r_rst_shreg									: std_logic_vector(9 downto 0);
	signal r_rst_shreg_dly								: std_logic;

	signal s00a_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal s00a_axis_tvalid								: std_logic;
	signal s00a_axis_tready								: std_logic;
	signal s00b_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal s00b_axis_tvalid								: std_logic;
	signal s00b_axis_tready								: std_logic;
	signal s00_ctrl_axis_tdata							: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s00_ctrl_axis_tlast							: std_logic;
	signal s00_ctrl_axis_tvalid						: std_logic;
	signal s00_ctrl_axis_tready						: std_logic;
	signal m00_axis_tdata								: std_logic_vector(c_data_width-1 downto 0);
	signal m00_axis_tvalid								: std_logic;
	signal m00_axis_tlast								: std_logic;
	signal m00_axis_tready								: std_logic;

	signal s_opcode										: std_logic_vector(3 downto 0);
	signal r_cnt_cmd										: natural;
	signal r_cnt_out										: natural;
	signal r_close											: std_logic;
	signal r_close_dly									: std_logic;
	signal r_delay											: std_logic_vector(c_delay_last_and_close-1 downto 0);

begin

	process
	begin
		r_clk <= '1';
		wait for PLL_SIM_HALF_PERIOD_TIME;
		r_clk <= '0';
		wait for PLL_SIM_HALF_PERIOD_TIME;
	end process;

	process
	begin
		r_rst <= '1';
		wait for 200ns;
		r_rst <= '0';
		wait;
	end process;

	process(r_clk)
	begin
		if(rising_edge(r_clk)) then
			if(r_rst = '1') then
				r_rst_shreg <= (others=>'1');
			else
				r_rst_shreg <= '0' & r_rst_shreg(r_rst_shreg'length-1 downto 1);
			end if;
		end if;

	end process;


	PROG_FORCER_INST: entity work.forcer_prog generic map (
		g_filepath						=> c_prog_filepath,				--: string := "i.txt";
		g_data_width					=> c_ctrl_width					--: natural := 64
	)
	port map (
		pi_clk							=> r_clk,							--: in std_logic;
		pi_rst							=> r_rst_shreg(0),				--: in std_logic;
		po_m00_tdata					=> s00_ctrl_axis_tdata,			--: out std_logic_vector(g_data_width-1 downto 0);
		po_m00_tlast					=> s00_ctrl_axis_tlast,			--: out std_logic;
		po_m00_tvalid					=> s00_ctrl_axis_tvalid,		--: out std_logic;
		pi_m00_tready					=> s00_ctrl_axis_tready			--: in std_logic
	);


	BUS_A_FORCER_INST: entity work.forcer_data generic map (
		g_filepath						=> c_bus_A_filepath,				--: string := "i.txt";
		g_data_width					=> c_data_width					--: natural := 64
	)
	port map (
		pi_clk							=> r_clk,							--: in std_logic;
		pi_rst							=> r_rst_shreg(0),				--: in std_logic;
		po_m00_tdata					=> s00a_axis_tdata,				--: out std_logic_vector(g_data_width-1 downto 0);
		po_m00_tvalid					=> s00a_axis_tvalid,				--: out std_logic;
		pi_m00_tready					=> s00a_axis_tready				--: in std_logic
	);


	BUS_B_FORCER_INST: entity work.forcer_data generic map (
		g_filepath						=> c_bus_B_filepath,				--: string := "i.txt";
		g_data_width					=> c_data_width					--: natural := 64
	)
	port map (
		pi_clk							=> r_clk,							--: in std_logic;
		pi_rst							=> r_rst_shreg(0),				--: in std_logic;
		po_m00_tdata					=> s00b_axis_tdata,				--: out std_logic_vector(g_data_width-1 downto 0);
		po_m00_tvalid					=> s00b_axis_tvalid,				--: out std_logic;
		pi_m00_tready					=> s00b_axis_tready				--: in std_logic
	);


	CORE_INST: entity work.core generic map (
		g_sim								=> c_sim,								--: boolean := false;
		g_num_of_bram					=> c_num_of_bram,						--: natural := 1;
		g_lfsr							=> g_lfsr,								--: boolean := true;
		g_num_of_logic_registers	=> c_num_of_logic_registers,		--: natural := C_NUM_OF_REGISTERS;
		g_num_of_phys_registers		=> c_num_of_phys_registers,		--: natural := C_NUM_OF_ALL_REGISTERS;
		g_data_width					=> c_data_width,						--: natural := C_STD_DATA_WIDTH;
		g_addr_width					=> c_addr_width,						--: natural := C_STD_ADDR_WIDTH;
		g_ctrl_width					=> c_ctrl_width						--: natural := C_STD_CTRL_WIDTH
	)
	port map (
		pi_clk							=> r_clk,								--: in std_logic;
		pi_rst							=> r_rst,								--: in std_logic;
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
		m00_axis_tready				=> m00_axis_tready					--: in std_logic;
	);

	DO_NOT_STORE_OUTPUT_FILES_GEN: if(g_store_output_file = false) generate
		m00_axis_tready <= '1';
	end generate;


	STORE_OUTPUT_FILES_GEN: if(g_store_output_file = true) generate

		FORCER_RESULT_INST: entity work.forcer_result generic map (
			g_filepath						=> c_bus_Z_filepath,					--: string := "i.txt";
			g_data_width					=> c_data_width						--: natural := 64
		)
		port map (
			pi_clk							=> r_clk,								--: in std_logic;
			pi_rst							=> r_rst,								--: in std_logic;
			pi_close							=> r_close,								--: in std_logic;
			pi_m00_tdata					=> m00_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
			pi_m00_tvalid					=> m00_axis_tvalid,					--: in std_logic;
			po_m00_tready					=> m00_axis_tready					--: out std_logic
		);

	end generate;


	s_opcode <= s00_ctrl_axis_tdata(3 downto 0);

	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			if(r_rst = '1') then
				r_cnt_cmd <= 0;
			else

				if(s00_ctrl_axis_tvalid = '1' and s00_ctrl_axis_tready = '1' and s00_ctrl_axis_tlast = '1' and s_opcode = c_opcode_unload) then
					r_cnt_cmd <= r_cnt_cmd + 1;
				end if;

			end if;



			if(r_rst = '1') then
				r_cnt_out <= 0;
			else

				if(m00_axis_tvalid = '1' and m00_axis_tlast = '1') then
					r_cnt_out <= r_cnt_out + 1;
				end if;

			end if;


			r_rst_shreg_dly <= r_rst_shreg(0);

			if(r_rst = '1' or r_rst_shreg(0) = '1' or r_rst_shreg_dly = '1') then
				r_delay <= (others=>'0');
			else
				if(s00_ctrl_axis_tvalid = '0' and r_cnt_cmd = r_cnt_out) then
					r_delay <= '1' & r_delay(r_delay'length-1 downto 1);
				else
					r_delay <= '0' & r_delay(r_delay'length-1 downto 1);
				end if;
			end if;


			if(r_rst = '1') then
				r_close <= '0';
			else
				if(r_delay(1) = '1' and r_delay(0) = '0') then
					r_close <= '1';
				else
					r_close <= '0';
				end if;
			end if;

			r_close_dly <= r_close;

			if(r_close_dly = '1') then
				report "Simulation ended." severity failure;
			end if;

		end if;
	end process;



end architecture;
