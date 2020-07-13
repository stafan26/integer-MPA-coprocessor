-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    10/11/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    pro_pack
-------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package pro_pack is

	---------
	-- PLL --
	---------

--	-- CLK0: 500 MHz				2.000 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 10;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 1;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

--	-- CLK0: 466.6(6) MHz		2.142 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 14;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 1;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 3;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 6;

--	-- CLK0: 460 MHz				2.173 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 46;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 5;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

--	-- CLK0: 450 MHz				2,222 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 9;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 1;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

--	-- CLK0: 440 MHz				2.272 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 44;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 5;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

--	-- CLK0: 430 MHz				2.325 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 43;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 5;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

--	-- CLK0: 425 MHz				2.352 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 17;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 2;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

--	-- CLK0: 420 MHz				2.381 ns
--	constant PLL_CLKFBOUT_MULT					: natural := 42;					-- Multiply value for all CLKOUT; (2-64)
--	constant PLL_DIVCLK_DIVIDE					: natural := 5;					-- Master division value; (1-56)
--	constant PLL_CLKOUT0_DIVIDE				: natural := 2;
--	constant PLL_CLKOUT1_DIVIDE				: natural := 4;

	-- CLK0: 400 MHz				2.500 ns
	constant PLL_CLKFBOUT_MULT					: natural := 12;					-- Multiply value for all CLKOUT; (2-64)
	constant PLL_DIVCLK_DIVIDE					: natural := 1;					-- Master division value; (1-56)
	constant PLL_CLKOUT0_DIVIDE				: natural := 3;
	constant PLL_CLKOUT1_DIVIDE				: natural := 6;

	constant PLL_SIM_FREQ						: real := real(100000000*PLL_CLKFBOUT_MULT)/real(PLL_CLKOUT0_DIVIDE);
	constant PLL_SIM_PERIOD						: real := real(1)/PLL_SIM_FREQ;
	constant PLL_SIM_HALF_PERIOD				: real := PLL_SIM_PERIOD/real(2);
	constant PLL_SIM_HALF_PERIOD_TIME		: time := PLL_SIM_HALF_PERIOD*1sec;


	--------------
	-- HARDWARE --
	--------------

	constant C_MAX_NUM_OF_IN_PER_MUX					: natural := 6;
	constant C_SIZE_OF_SINGLE_BRAM					: natural := 32 * 1024;
	constant C_DSP_DATA_WIDTH							: natural := 48;

	------------
	-- GLOBAL --
	------------

	constant C_NUM_OF_REGISTERS						: natural := 16;
	constant C_NUM_OF_SHADOW_REGISTERS				: natural := 1;
	constant C_NUM_OF_ALL_REGISTERS					: natural := C_NUM_OF_REGISTERS+C_NUM_OF_SHADOW_REGISTERS;
	constant C_NUM_OF_BRAM_IN_REG						: natural := 1;
	constant C_NUM_OF_MODULES							: natural := C_NUM_OF_REGISTERS+C_NUM_OF_SHADOW_REGISTERS+4-1;			--(LOADER_A, LOADER_B, ADDER/SUB, MULT = 4)

	constant C_REG_PHYS_ADDR_WIDTH					: natural := 5;

	constant C_STD_DATA_WIDTH							: natural := 64;
	constant C_STD_ADDR_WIDTH							: natural := 9;
	constant C_STD_CTRL_WIDTH							: natural := 8;

	--constant C_IP_NUM_OF_INPUTS						: natural := 16;

	constant C_ADD_64_DELAY								: natural := 5;
	constant C_SUB_64_DELAY								: natural := 5;
	constant C_MULT_64_DELAY							: natural := 12;
	constant C_MULT_64_ACC_DELAY						: natural := 4;
	constant C_BRAM_DELAY								: natural := 3;


	-------------
	-- MODULES --
	-------------
	constant C_REG_ADD_SUB_OPERATION_DELAY			: natural := 27;
	constant C_REG_MULT_OPERATION_DELAY				: natural := 54;


	----------
	-- CTRL --
	----------

	-- FRAME --
	constant C_STD_ID_SIZE								: natural := 6;
	constant C_STD_ID_ADDR_LO							: natural := 0;

	-- REG_I
	constant C_STD_REG_WRITE							: natural := 7;
	constant C_STD_REG_CMC_CHANNEL_ADDR				: natural := 6;
	constant C_STD_ID_ADDR_HI							: natural := C_STD_ID_ADDR_LO + C_STD_ID_SIZE - 1;

	-- REG_II
	constant C_STD_REG_ADDR_UP_DOWN					: natural := 0;
	constant C_STD_REG_HI_LO							: natural := 7;
	constant C_STD_REG_SET_ZERO						: natural := 6;
	constant C_STD_REG_SET_ONE							: natural := 5;
	constant C_STD_REG_SELECT_ADDR					: natural := 0;	-- SIZE 4-5


	constant C_STD_ADD_SUB_ADDR						: natural := 6;
	constant C_STD_UNL_SELECT_ADDR					: natural := 0;
	constant C_STD_UNL_SIGN_ADDR						: natural := 4;
	constant C_STD_UNL_SIZE_ADDR						: natural := 5;

	-- FRAME --
	constant C_STD_OPCODE_SIZE							: natural := 4;
	constant C_STD_OPCODE_ADDR_LO						: natural := 4;
	constant C_STD_OPCODE_ADDR_HI						: natural := C_STD_OPCODE_SIZE + C_STD_OPCODE_ADDR_LO - 1;
	constant C_STD_SIGN_SIZE							: natural := 2;
	constant C_STD_SIGN_ADDR_LO						: natural := C_STD_OPCODE_SIZE + C_STD_OPCODE_ADDR_LO;
	constant C_STD_SIGN_ADDR_HI						: natural := C_STD_SIGN_SIZE + C_STD_SIGN_ADDR_LO - 1;


	constant C_STD_OPCODE_LOAD_A						: natural := 1;
	constant C_STD_OPCODE_LOAD_B						: natural := 2;
	constant C_STD_OPCODE_LOAD_AB						: natural := 3;
	constant C_STD_OPCODE_UNLOAD						: natural := 4;
	constant C_STD_OPCODE_SET_ZERO					: natural := 5;
	constant C_STD_OPCODE_SET_ONE						: natural := 6;
	constant C_STD_OPCODE_SIGN_TO_STEP				: natural := 7;
	constant C_STD_OPCODE_MULT							: natural := 8;
	constant C_STD_OPCODE_ADD							: natural := 9;
	constant C_STD_OPCODE_SUB							: natural := 10;


-- REGISTERS ARE LOCATED AT i, WHERE i IS THE NUMBER OF THE ADDRESS
	constant C_STD_ID_ADDER								: natural := 20;
	constant C_STD_ID_MULT								: natural := 21;
	constant C_STD_ID_COMMON							: natural := 22;

	-- arrays
	type t_ram is array (0 to 2**C_STD_ADDR_WIDTH-1) of std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	type t_mm is array (0 to C_NUM_OF_ALL_REGISTERS-1) of t_ram;

	type t_phys is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(C_REG_PHYS_ADDR_WIDTH-1 downto 0);
	type t_phys_oh is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(C_NUM_OF_ALL_REGISTERS-1 downto 0);

	--type t_logic is array (0 to C_NUM_OF_REGISTERS-1) of std_logic_vector(C_REG_PHYS_ADDR_WIDTH-1 downto 0);
	type t_logic_inv is array (0 to C_REG_PHYS_ADDR_WIDTH-1) of std_logic_vector(C_NUM_OF_REGISTERS-1 downto 0);

	--type t_logic_oh is array (0 to C_NUM_OF_REGISTERS-1) of std_logic_vector(C_NUM_OF_ALL_REGISTERS-1 downto 0);
	type t_logic_oh_inv is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(C_NUM_OF_REGISTERS-1 downto 0);

	type t_data_x1 is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	type t_rest_x1 is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic;
	type t_size is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(C_STD_ADDR_WIDTH-1 downto 0);

	type t_phys_reg_busy_mode is  array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(2 downto 0);

end pro_pack;

package body pro_pack is

end package body pro_pack;
