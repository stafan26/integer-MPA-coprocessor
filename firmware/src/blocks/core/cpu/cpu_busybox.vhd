-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_busybox
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--library UNISIM;
--use UNISIM.vcomponents.all;

use work.pro_pack.all;
use work.my_pack.all;
use work.common_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--		- protection agains reading and writing the same register or MFPGA130
--
-------------------------------------------
-------------------------------------------

entity cpu_busybox is
generic (
	g_lfsr								: boolean := true;
	g_num_of_phys_registers			: natural := 18
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_phys_reg_active_all			: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_phys_reg_1_oh					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_phys_reg_2_oh					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_phys_reg_3_oh					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_reg_1_busy_mode				: in std_logic_vector(2 downto 0);
	pi_reg_2_busy_mode				: in std_logic_vector(2 downto 0);
	pi_reg_3_busy_mode				: in std_logic_vector(2 downto 0);
	pi_reg_3_aux_busy_mode			: in std_logic_vector(2 downto 0);

	pi_cmd_add_sub						: in std_logic;
	pi_cmd_mult							: in std_logic;
	pi_cmd_taken						: in std_logic;

	pi_cmc_add_sub_last				: in std_logic;
	pi_cmc_mult_last					: in std_logic;

	pi_loader_A_data_last			: in std_logic;
	pi_loader_B_data_last			: in std_logic;
	pi_unloader_data_last			: in std_logic;

	po_add_sub_busy					: out std_logic;
	po_mult_busy						: out std_logic;
	po_reg_busy							: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
);
end cpu_busybox;

architecture cpu_busybox of cpu_busybox is

	constant c_mult_delay_width						: natural := addr_width(C_REG_MULT_OPERATION_DELAY+1);
	signal s_mult_delay									: std_logic_vector(c_mult_delay_width-1 downto 0);

	constant c_add_sub_delay_width					: natural := addr_width(C_REG_ADD_SUB_OPERATION_DELAY+1);
	signal s_add_sub_delay								: std_logic_vector(c_add_sub_delay_width-1 downto 0);

	signal r_cmc_add_sub_last							: std_logic;

	signal r_mult_busy									: std_logic;
	signal r_add_sub_busy								: std_logic;

	signal r_reg_busy										: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_reg_off_read								: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_reg_off_write								: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_reg_busy_mode								: t_phys_reg_busy_mode;
	signal r_reg_busy_mode_pre							: t_phys_reg_busy_mode;
	signal r_reg_busy_mode_hi							: t_phys_reg_busy_mode;
	signal r_reg_busy_mode_low							: t_phys_reg_busy_mode;
	signal r_reg_low_active								: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_phys_reg_active_all						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_phys_reg_active_all_dly					: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_cnt_add_sub_load							: std_logic;
	signal r_cnt_add_sub_start							: std_logic;
	signal s_cnt_add_sub_last							: std_logic;

	signal r_cnt_mult_load								: std_logic;
	signal r_cnt_mult_start								: std_logic;
	signal s_cnt_mult_last								: std_logic;

begin

	po_reg_busy <= r_reg_busy;
	po_add_sub_busy <= r_add_sub_busy;
	po_mult_busy <= r_mult_busy;


	LFSR_CNT_GEN: if(g_lfsr = true) generate
		s_mult_delay <= to_lfsr(C_REG_MULT_OPERATION_DELAY, c_mult_delay_width);
		s_add_sub_delay <= to_lfsr(C_REG_ADD_SUB_OPERATION_DELAY, c_add_sub_delay_width);
	end generate;

	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		s_mult_delay <= to_std_logic_vector(C_REG_MULT_OPERATION_DELAY, c_mult_delay_width);
		s_add_sub_delay <= to_std_logic_vector(C_REG_ADD_SUB_OPERATION_DELAY, c_add_sub_delay_width);
	end generate;


	-----------------
	-- ADDER DELAY --
	-----------------
	CPU_CNT_ADD_SUB_LAST_INST: entity work.cpu_cnt_last generic map (
		g_lfsr					=> g_lfsr,									--: boolean := true;
		g_n						=> c_add_sub_delay_width				--: natural := 60
	)
	port map (
		pi_clk					=> pi_clk,									--: in std_logic;
		pi_rst					=> pi_rst,									--: in std_logic;
		pi_load					=> r_cnt_add_sub_load,					--: in std_logic;
		pi_data					=> s_add_sub_delay,						--: in std_logic_vector(g_n-1 downto 0);
		pi_start					=> r_cnt_add_sub_start,					--: in std_logic;
		po_last					=> s_cnt_add_sub_last					--: out std_logic
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------------------
			-- R_CNT_ADD_SUB_LOAD --
			------------------------
			if(pi_rst = '1') then
				r_cnt_add_sub_load <= '0';
			else
				if(pi_cmd_taken = '1' and pi_cmd_add_sub = '1') then
					r_cnt_add_sub_load <= '1';
				else
					r_cnt_add_sub_load <= '0';
				end if;
			end if;


			-------------
			-- R_START --
			-------------
			if(pi_rst = '1') then
				r_cnt_add_sub_start <= '0';
			else
				if(r_add_sub_busy = '1' and pi_cmc_add_sub_last = '1') then
					r_cnt_add_sub_start <= '1';
				else
					r_cnt_add_sub_start <= '0';
				end if;
			end if;

		end if;

	end process;


	----------------
	-- MULT DELAY --
	----------------
	CPU_CNT_MULT_LAST_INST: entity work.cpu_cnt_last generic map (
		g_lfsr					=> g_lfsr,									--: boolean := true;
		g_n						=> c_mult_delay_width					--: natural := 60
	)
	port map (
		pi_clk					=> pi_clk,									--: in std_logic;
		pi_rst					=> pi_rst,									--: in std_logic;
		pi_load					=> r_cnt_mult_load,						--: in std_logic;
		pi_data					=> s_mult_delay,							--: in std_logic_vector(g_n-1 downto 0);
		pi_start					=> r_cnt_mult_start,						--: in std_logic;
		po_last					=> s_cnt_mult_last						--: out std_logic
	);

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			---------------------
			-- R_CNT_MULT_LOAD --
			---------------------
			if(pi_rst = '1') then
				r_cnt_mult_load <= '0';
			else
				if(pi_cmd_taken = '1' and pi_cmd_mult = '1') then
					r_cnt_mult_load <= '1';
				else
					r_cnt_mult_load <= '0';
				end if;
			end if;


			----------------------
			-- R_CNT_MULT_START --
			----------------------
			if(pi_rst = '1') then
				r_cnt_mult_start <= '0';
			else
				if(r_mult_busy = '1' and pi_cmc_mult_last = '1') then
					r_cnt_mult_start <= '1';
				else
					r_cnt_mult_start <= '0';
				end if;
			end if;

		end if;

	end process;



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------------
			-- R_MULT_BUSY --
			-----------------
			if(pi_rst = '1') then
				r_mult_busy <= '0';
			else

				if(pi_cmd_mult = '1' and pi_cmd_taken = '1') then
					r_mult_busy <= '1';
				--elsif(pi_cmc_mult_last = '1') then		-- MFPGA-118
				elsif(s_cnt_mult_last = '1') then
					r_mult_busy <= '0';
				end if;

			end if;


			----------------
			-- R_ADD_BUSY --
			----------------
			if(pi_rst = '1') then
				r_add_sub_busy <= '0';
			else

				if(pi_cmd_add_sub = '1' and pi_cmd_taken = '1') then
					r_add_sub_busy <= '1';
				--elsif(pi_cmc_add_sub_last = '1') then		-- MFPGA-118
				elsif(s_cnt_add_sub_last = '1') then
					r_add_sub_busy <= '0';
				end if;

			end if;


			------------
			-- STREAM --
			------------
			r_cmc_add_sub_last <= pi_cmc_add_sub_last;		-- workaround for 1 limb addidition


			if(pi_cmd_taken = '1') then
				r_phys_reg_active_all <= pi_phys_reg_active_all;
			else
				r_phys_reg_active_all <= (others=>'0');
			end if;
			r_phys_reg_active_all_dly <= r_phys_reg_active_all;

		end if;
	end process;



	REG_BUSY_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		process(pi_clk)
		begin
			if(rising_edge(pi_clk)) then


				---------------------
				-- R_REG_BUSY_MODE --
				---------------------
				if(r_phys_reg_active_all_dly(i) = '1') then
					r_reg_busy_mode(i) <= r_reg_busy_mode_pre(i);
				end if;



				---------------------
				-- R_REG_BUSY_MODE_LOW --
				---------------------
				if(pi_phys_reg_1_oh(i) = '1') then
					r_reg_busy_mode_low(i) <= pi_reg_1_busy_mode;
				else
					r_reg_busy_mode_low(i) <= pi_reg_2_busy_mode;
				end if;

				--------------------
				-- R_REG_BUSY_MODE_HI --
				--------------------
				if(pi_phys_reg_3_oh(i) = '1') then
					r_reg_busy_mode_hi(i) <= pi_reg_3_busy_mode;
				else
					r_reg_busy_mode_hi(i) <= pi_reg_3_aux_busy_mode;
				end if;


				------------------
				-- R_REG_LOW_ACTIVE --
				------------------
				if(pi_phys_reg_1_oh(i) = '1' or pi_phys_reg_2_oh(i) = '1') then
					r_reg_low_active(i) <= '1';
				else
					r_reg_low_active(i) <= '0';
				end if;


				---------------------
				-- R_REG_BUSY_MODE_PRE --
				---------------------
				if(r_reg_low_active(i) = '1') then
					r_reg_busy_mode_pre(i) <= r_reg_busy_mode_low(i);
				else
					r_reg_busy_mode_pre(i) <= r_reg_busy_mode_hi(i);
				end if;


				----------------
				-- R_REG_BUSY --
				----------------
				if(pi_rst = '1') then
					r_reg_busy(i) <= '0';
				else

					if(pi_phys_reg_active_all(i) = '1' and pi_cmd_taken = '1') then
						r_reg_busy(i) <= '1';
					elsif((r_reg_busy_mode(i)(2) = '0' and r_reg_off_read(i) = '1') or		-- READ
							(r_reg_busy_mode(i)(2) = '1' and r_reg_off_write(i) = '1')			-- WRITE
					) then
						r_reg_busy(i) <= '0';
					end if;

				end if;


				--------------------
				-- R_REG_OFF_READ --
				--------------------
				if(pi_rst = '1') then
					r_reg_off_read(i) <= '0';
				else

					if( (r_reg_busy_mode(i)(1 downto 0) = "00" and r_cmc_add_sub_last = '1') or
						(r_reg_busy_mode(i)(1 downto 0) = "01" and pi_cmc_mult_last = '1') or
						(r_reg_busy_mode(i)(1 downto 0) = "10" and pi_unloader_data_last = '1')
					) then
						r_reg_off_read(i) <= '1';
					else
						r_reg_off_read(i) <= '0';
					end if;

				end if;


				---------------------
				-- R_REG_OFF_WRITE --
				---------------------
				if(pi_rst = '1') then
					r_reg_off_write(i) <= '0';
				else

					if( (r_reg_busy_mode(i)(1 downto 0) = "00" and s_cnt_add_sub_last = '1') or
						(r_reg_busy_mode(i)(1 downto 0) = "01" and s_cnt_mult_last = '1') or
						(r_reg_busy_mode(i)(1 downto 0) = "10" and pi_loader_A_data_last = '1') or
						(r_reg_busy_mode(i)(1 downto 0) = "11" and pi_loader_B_data_last = '1')
					) then
						r_reg_off_write(i) <= '1';
					else
						r_reg_off_write(i) <= '0';
					end if;

				end if;

			end if;
		end process;

	end generate;



-- BLAD MAPOWANIA  LOAD_AB dla kanalu A
--		---------------------
--		-- R_REG_BUSY_MODE --
--		---------------------
--		R_REG_BUSY_MODE_0_INST: LUT6_L generic map (
--			INIT => X"0100010801040000"
--		) -- Specify LUT Contents
--		port map (
--			LO => s_reg_busy_mode(i)(0), -- LUT general output
--			I0 => r_cmd_opcode(0), -- LUT input
--			I1 => r_cmd_opcode(1), -- LUT input
--			I2 => r_cmd_opcode(2), -- LUT input
--			I3 => r_cmd_opcode(3), -- LUT input
--			I4 => r_cmd_reg_index(i)(0), -- LUT input
--			I5 => r_cmd_reg_index(i)(1) -- LUT input
--		);
--
--		R_REG_BUSY_MODE_1_INST: LUT6_L generic map (
--			INIT => X"0000000800160000"
--		) -- Specify LUT Contents
--		port map (
--			LO => s_reg_busy_mode(i)(1), -- LUT general output
--			I0 => r_cmd_opcode(0), -- LUT input
--			I1 => r_cmd_opcode(1), -- LUT input
--			I2 => r_cmd_opcode(2), -- LUT input
--			I3 => r_cmd_opcode(3), -- LUT input
--			I4 => r_cmd_reg_index(i)(0), -- LUT input
--			I5 => r_cmd_reg_index(i)(1) -- LUT input
--		);
--
--		R_REG_BUSY_MODE_2_INST: LUT6_L generic map (
--			INIT => X"0700000800060000"
--		) -- Specify LUT Contents
--		port map (
--			LO => s_reg_busy_mode(i)(2), -- LUT general output
--			I0 => r_cmd_opcode(0), -- LUT input
--			I1 => r_cmd_opcode(1), -- LUT input
--			I2 => r_cmd_opcode(2), -- LUT input
--			I3 => r_cmd_opcode(3), -- LUT input
--			I4 => r_cmd_reg_index(i)(0), -- LUT input
--			I5 => r_cmd_reg_index(i)(1) -- LUT input
--		);
--
--		REG_BUSY_GEN: for j in 0 to 2 generate
--
--			REG_BUSY_FDRE_INST: FDRE generic map (
--				INIT	=> '0'
--			)
--			port map (
--				Q		=> r_reg_busy_mode(i)(j),
--				C		=> pi_clk,
--				CE		=> r_cmd_taken,
--				R		=> '0',
--				D		=> s_reg_busy_mode(i)(j)
--			);
--		end generate;

end architecture;
