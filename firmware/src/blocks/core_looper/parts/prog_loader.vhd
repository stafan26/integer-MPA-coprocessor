	-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    prog_loader
-- Module Name:    prog_loader
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;


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

entity prog_loader is
generic (
	g_ctrl_width						: natural := 8
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;
	s00_ctrl_axis_tdata				: out std_logic_vector(g_ctrl_width-1 downto 0);
	s00_ctrl_axis_tlast				: out std_logic;
	s00_ctrl_axis_tvalid				: out std_logic;
	s00_ctrl_axis_tready				: in std_logic
);
end prog_loader;

architecture prog_loader of prog_loader is

	constant c_num_of_instr_in_rom					: natural := 10;

	signal r_rst						: std_logic_vector(2 downto 0);

	signal r_cnt_zero					: std_logic_vector(c_num_of_instr_in_rom-1 downto 0);
	signal r_valid						: std_logic;
	signal r_valid_shreg				: std_logic_vector(2 downto 0);
	signal r_cnt						: std_logic_vector(10 downto 0);
	signal s_data						: std_logic_vector(8 downto 0);
	signal r_data						: std_logic_vector(8 downto 0);

begin

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(pi_rst = '1') then
				r_rst <= (0=>'1',others=>'0');
			else
				r_rst <= r_rst(r_rst'length-2 downto 0) & pi_rst;
			end if;

			-------------
			-- R_VALID --
			-------------
			if(pi_rst = '1') then
				r_valid <= '0';
			else

				if(r_rst(r_rst'length-1) = '1') then
					r_valid <= '1';
				elsif(r_valid_shreg(r_valid_shreg'length-1) = '1') then
					r_valid <= '1';
				elsif(s00_ctrl_axis_tready = '1') then
					r_valid <= '0';
				end if;
			end if;

			-------------------
			-- R_VALID_SHREG --
			-------------------
			if(r_valid = '1' and s00_ctrl_axis_tready = '1') then
				r_valid_shreg <= (0=>'1',others=>'0');
			else
				r_valid_shreg <= r_valid_shreg(r_valid_shreg'length-2 downto 0) & '0';
			end if;


			if(pi_rst = '1') then
				r_cnt_zero <= (0=>'1',others=>'0');
			else

				if(r_valid = '1' and s00_ctrl_axis_tready = '1') then
					r_cnt_zero <= r_cnt_zero(r_cnt_zero'length-2 downto 0) & r_cnt_zero(r_cnt_zero'length-1);
				end if;

			end if;


			-----------
			-- R_CNT --
			-----------
			if(pi_rst = '1') then
				r_cnt <= (others=>'0');
			else

				if(r_valid = '1' and s00_ctrl_axis_tready = '1') then

					if(r_cnt_zero(r_cnt_zero'length-1) = '1') then
						r_cnt <= (others=>'0');
					else
						r_cnt <= r_cnt + 1;
					end if;
				end if;

			end if;

			r_data <= s_data;

		end if;
	end process;


	s00_ctrl_axis_tvalid <= r_valid;
	s00_ctrl_axis_tdata <= r_data(7 downto 0);
	s00_ctrl_axis_tlast <= r_data(8);

--	PROG_ROM_INST: entity work.prog_rom port map (
--		clka				=> pi_clk,			--: in std_logic;
--		addra				=> r_cnt,			--: in std_logic_vector(3 downto 0);
--		douta				=> s_data			--: out std_logic_vector(8 downto 0);
--	);


	BRAM_SINGLE_MACRO_INST: BRAM_SINGLE_MACRO generic map (
		BRAM_SIZE		=> "18Kb",							-- Target BRAM, "18Kb" or "36Kb"
		DEVICE			=> "7SERIES",						-- Target Device: "VIRTEX5", "7SERIES", "VIRTEX6, "SPARTAN6"
		DO_REG			=> 1,									-- Optional output register (0 or 1)
		INIT_FILE		=> "./core_looper.mem",
		WRITE_WIDTH		=> 9,									-- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
		READ_WIDTH		=> 9,									-- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
		WRITE_MODE		=> "WRITE_FIRST"					-- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
	)
	port map (
		DO					=> s_data,							-- Output data, width defined by READ_WIDTH parameter
		ADDR				=> r_cnt,							-- Input address, width defined by read/write port depth
		CLK				=> pi_clk,							-- 1-bit input clock
		DI					=> (others=>'0'),					-- Input data port, width defined by WRITE_WIDTH parameter
		EN					=> '1',								-- 1-bit input RAM enable
		REGCE 			=> '1',								-- 1-bit input output register enable
		RST				=> '0',								-- 1-bit input reset
		WE					=> (0 downto 0=>'0')				-- Input write enable, width defined by write port depth
	);



end architecture;
