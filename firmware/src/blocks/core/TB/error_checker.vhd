-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    error_checker
-- Module Name:    error_checker
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.test_pack.all;
use work.pro_pack.all;
use work.my_pack.all;
--use work.dpi_test_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity error_checker is
generic (
	g_num_of_phys_registers			: natural := 18;
	g_reg_logic_addr_width			: natural := 4;
	g_reg_phys_addr_width			: natural := 5;
	g_data_width						: natural := 64;
	g_addr_width						: natural := 9;
	g_ctrl_width						: natural := 8;
	g_opcode_width						: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	-- PROBE
	pi_probe_instr						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_probe_reg_1						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_probe_reg_2						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_probe_reg_3						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_probe_wr_en						: in std_logic;

	-- SRUP
	pi_srup_reg_busy					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_srup_data						: in t_mm;
	pi_srup_data_sign					: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
	pi_srup_data_size					: in t_size;
	pi_srup_data_phys					: in t_phys;

	-- EMULATOR
	pi_dpi_instr						: in std_logic_vector(g_opcode_width-1 downto 0);
	pi_dpi_data_1						: in t_ram;
	pi_dpi_data_2						: in t_ram;
	pi_dpi_data_3						: in t_ram;
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
	po_error_phys						: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
);
end error_checker;

architecture error_checker of error_checker is

	signal r_error_read					: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_error_write					: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_srup_reg_busy				: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_srup_reg_busy_prev_1		: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_srup_reg_busy_prev_2		: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_srup_reg_busy_prev_3		: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_srup_reg_busy_prev_4		: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal r_schedule						: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_scheduled_sign				: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal r_scheduled_size				: t_size;
	signal r_scheduled_phys				: t_phys;
	signal r_scheduled_data				: t_mm;

	type t_error_limb_location is array (0 to div_up(2**C_STD_ADDR_WIDTH,64)-1) of std_logic_vector(63 downto 0);
	type t_error_data_location is array (0 to g_num_of_phys_registers-1) of t_error_limb_location;
	signal s_error_data_location		: t_error_data_location;

	signal r_cnt_instr					: integer;

	type t_error is (
							OK,
							RESULT_SIGN,
							RESULT_SIZE,
							RESULT_PHYS_REG,
							RESULT_DATA,
							A_SIGN,
							A_SIZE,
							A_PHYS_REG,
							A_DATA,
							B_SIGN,
							B_SIZE,
							B_PHYS_REG,
							B_DATA
	);


	type t_error_read_code is array (0 to g_num_of_phys_registers-1) of t_error;
	signal r_error_code			: t_error_read_code;


	type t_limb_failed is array (0 to g_num_of_phys_registers-1) of std_logic_vector(2**g_addr_width-1 downto 0);
	signal r_limb_failed					: t_limb_failed;

begin

	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			r_srup_reg_busy <= pi_srup_reg_busy;
			r_srup_reg_busy_prev_1 <= r_srup_reg_busy;
			r_srup_reg_busy_prev_2 <= r_srup_reg_busy_prev_1;
			r_srup_reg_busy_prev_3 <= r_srup_reg_busy_prev_2;
			r_srup_reg_busy_prev_4 <= r_srup_reg_busy_prev_3;

			if(pi_rst = '1') then
				po_error_read <= '0';
				po_error_write <= '0';
				r_cnt_instr <= -1;
			else

				if(r_error_read /= (r_error_read'length-1 downto 0 =>'0')) then
					po_error_read <= '1';
				end if;

				if(r_error_write /= (r_error_write'length-1 downto 0 =>'0')) then
					po_error_write <= '1';
				end if;

				if(pi_probe_wr_en = '1') then
					r_cnt_instr <= r_cnt_instr + 1;
				end if;

			end if;

		end if;
	end process;



	-----------------
	--   OPCODE   ---
	-----------------

	process(pi_clk)
	begin

		if(rising_edge(pi_clk)) then
			if(pi_rst = '1') then
				po_error_opcode <= '0';
			else

				if(pi_probe_wr_en = '1') then
					if(pi_probe_instr /= pi_dpi_instr) then
						po_error_opcode <= '1';
					end if;

				end if;

			end if;
		end if;

	end process;


	-----------------------
	--   DPI vs PROBES   --
	-----------------------

	DPI_VS_PROBES_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		CHECK_ERROR_LOCATION_GEN: for j in 0 to 2**g_addr_width-1 generate
			s_error_data_location(i)(div_down(j, 64))(j mod 64) <= '1' when r_schedule(i) = '1' and r_srup_reg_busy_prev_4(i) = '1' and r_srup_reg_busy_prev_3(i) = '0' and r_scheduled_data(i)(j) /=  pi_srup_data(i)(j) else '0';
			--s_error_data_location_short(i)(div(down(j, 64)) <= '1' when r_schedule(i) = '1' and r_srup_reg_busy_prev(i) = '1' and r_srup_reg_busy(i) = '0' and r_scheduled_data(i)(j) /= pi_srup_data(i)(j) else '0';
		end generate;

		WHICH_LIMB_FAILED_GEN: for j in 0 to 2**g_addr_width-1 generate

			process(pi_clk)
			begin
				if(rising_edge(pi_clk)) then
					--if(r_scheduled_phys(i)(j) /=  pi_srup_data_phys(i)(j)) then
					if(r_scheduled_data(i)(j) /=  pi_srup_data(i)(j)) then
						r_limb_failed(i)(j) <= '1';
					else
						r_limb_failed(i)(j) <= '0';
					end if;
				end if;
			end process;

		end generate;


		process(pi_clk)
		begin

			if(rising_edge(pi_clk)) then

				if(pi_rst = '1') then
					r_error_read(i) <= '0';
					r_error_write(i) <= '0';
					po_error_sign(i) <= '0';
					po_error_size(i) <= '0';
					po_error_phys(i) <= '0';
					po_error_data(i) <= '0';
					r_schedule(i) <= '0';
					r_error_code(i) <= OK;
				else

					if(r_schedule(i) = '1' and r_srup_reg_busy_prev_4(i) = '1' and r_srup_reg_busy_prev_3(i) = '0') then

						-- READ AFTER WRITE COMPLETED
						r_schedule(i) <= '0';

						-- SIGN
						if(r_scheduled_sign(i) /=  pi_srup_data_sign(i)) then
							po_error_sign(i) <= '1';
							r_error_write(i) <= '1';
							r_error_code(i) <= RESULT_SIGN;
						end if;

						-- SIZE
						if(r_scheduled_size(i) /=  pi_srup_data_size(i)) then
							po_error_size(i) <= '1';
							r_error_write(i) <= '1';
							r_error_code(i) <= RESULT_SIZE;
						end if;

						-- PHYS REGISTER
						if(to_natural(r_scheduled_phys(i)) /=  i) then
							po_error_phys(i) <= '1';
							r_error_write(i) <= '1';
							r_error_code(i) <= RESULT_PHYS_REG;
						end if;

						-- DATA
						if(r_scheduled_data(i) /=  pi_srup_data(i)) then
							po_error_data(i) <= '1';
							r_error_write(i) <= '1';
							r_error_code(i) <= RESULT_DATA;
						end if;

					elsif(pi_probe_wr_en = '1') then

						-- 1ST ARGUMENT
						if(i = to_natural(pi_dpi_data_phys_1)) then
							case pi_probe_instr is

								-- READ IMMEDIATELY
								when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_UNLOAD, g_opcode_width) =>

									-- SIGN
									if(pi_srup_data_sign(to_natural(pi_dpi_data_phys_1)) /= pi_dpi_data_sign_1) then
										po_error_sign(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= A_SIGN;
									end if;

									-- SIZE
									if(pi_srup_data_size(to_natural(pi_dpi_data_phys_1)) /= pi_dpi_data_size_1) then
										po_error_size(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= A_SIZE;
									end if;

									-- PHYS REGISTER
									if(pi_srup_data_phys(to_natural(pi_probe_reg_1)) /=  pi_dpi_data_phys_1) then
										po_error_phys(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= A_PHYS_REG;
									end if;

									-- DATA
									if(pi_srup_data(to_natural(pi_dpi_data_phys_1)) /=  pi_dpi_data_1) then
										po_error_data(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= A_DATA;
									end if;

								-- SCHEDULE READING AFTER WRITE COMPLETED
								when to_std_logic_vector(C_STD_OPCODE_LOAD_A, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_LOAD_B, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_SET_ZERO, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_SET_ONE, g_opcode_width) =>
									r_schedule(i) <= '1';

									-- SIGN
									r_scheduled_sign(i) <= pi_dpi_data_sign_1;

									-- SIZE
									r_scheduled_size(i) <= pi_dpi_data_size_1;

									-- PHYS REGISTER
									r_scheduled_phys(i) <= pi_dpi_data_phys_1;

									-- DATA
									r_scheduled_data(i) <= pi_dpi_data_1;

								when others =>
							end case;
						end if;


						-- 2ND ARGUMENT
						if(i = to_natural(pi_dpi_data_phys_2)) then
							case pi_probe_instr is

								-- READ IMMEDIATELY
								when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>

									-- SIGN
									if(pi_srup_data_sign(to_natural(pi_dpi_data_phys_2)) /= pi_dpi_data_sign_2) then
										po_error_sign(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= B_SIGN;
									end if;

									-- SIZE
									if(pi_srup_data_size(to_natural(pi_dpi_data_phys_2)) /= pi_dpi_data_size_2) then
										po_error_size(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= B_SIZE;
									end if;

									-- PHYS REGISTER
									if(pi_srup_data_phys(to_natural(pi_probe_reg_2)) /=  pi_dpi_data_phys_2) then
										po_error_phys(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= B_PHYS_REG;
									end if;

									-- DATA
									if(pi_srup_data(to_natural(pi_dpi_data_phys_2)) /=  pi_dpi_data_2) then
										po_error_data(i) <= '1';
										r_error_read(i) <= '1';
										r_error_code(i) <= B_DATA;
									end if;

								-- SCHEDULE READING AFTER WRITE COMPLETED
								when to_std_logic_vector(C_STD_OPCODE_LOAD_AB, g_opcode_width) =>
									r_schedule(i) <= '1';

									-- SIGN
									r_scheduled_sign(i) <= pi_dpi_data_sign_2;

									-- SIZE
									r_scheduled_size(i) <= pi_dpi_data_size_2;

									-- PHYS REGISTER
									r_scheduled_phys(i) <=  pi_dpi_data_phys_2;

									-- DATA
									r_scheduled_data(i) <=  pi_dpi_data_2;

								when others =>
							end case;
						end if;


						-- 3RD ARGUMENT
						if(i = to_natural(pi_dpi_data_phys_3)) then
							case pi_probe_instr is

								-- SCHEDULE READING AFTER WRITE COMPLETED
								when to_std_logic_vector(C_STD_OPCODE_ADD, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_SUB, g_opcode_width) |
								to_std_logic_vector(C_STD_OPCODE_MULT, g_opcode_width) =>
									r_schedule(i) <= '1';

									-- SIGN
									r_scheduled_sign(i) <= pi_dpi_data_sign_3;

									-- SIZE
									r_scheduled_size(i) <= pi_dpi_data_size_3;

									-- PHYS REGISTER
									r_scheduled_phys(i) <=  pi_dpi_data_phys_3;

									-- DATA
									r_scheduled_data(i) <=  pi_dpi_data_3;

								when others =>
							end case;
						end if;

					end if;
				end if;

			end if;

		end process;

	end generate;

end architecture;
