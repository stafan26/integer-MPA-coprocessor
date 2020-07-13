-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_64
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use work.pro_pack.all;
--use work.common_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity mult_64 is
generic (
	g_data_width					: natural := 64
);
port(
	CLK								: in std_logic;
	A									: in std_logic_vector(g_data_width-1 downto 0);
	B									: in std_logic_vector(g_data_width-1 downto 0);
	S									: out std_logic_vector(2*g_data_width-1 downto 0)
);
end mult_64;

architecture mult_64 of mult_64 is

	signal r_A0_0											: std_logic_vector(16 downto 0);
	signal r_A0_1											: std_logic_vector(16 downto 0);
	signal r_A0_2											: std_logic_vector(16 downto 0);
	signal r_A0_3											: std_logic_vector(16 downto 0);
	signal r_A0_4											: std_logic_vector(16 downto 0);

	signal r_A1_0											: std_logic_vector(16 downto 0);
	signal r_A1_1											: std_logic_vector(16 downto 0);
	signal r_A1_2											: std_logic_vector(16 downto 0);
	signal r_A1_3											: std_logic_vector(16 downto 0);

	signal r_A2_0											: std_logic_vector(16 downto 0);
	signal r_A2_1											: std_logic_vector(16 downto 0);
	signal r_A2_2											: std_logic_vector(16 downto 0);
	signal r_A2_3											: std_logic_vector(16 downto 0);

	signal r_A3_0											: std_logic_vector(12 downto 0);
	signal r_A3_1											: std_logic_vector(12 downto 0);
	signal r_A3_2											: std_logic_vector(12 downto 0);
	signal r_A3_3											: std_logic_vector(12 downto 0);
	signal r_A3_4											: std_logic_vector(12 downto 0);

	signal r_B0_0											: std_logic_vector(16 downto 0);
	signal r_B0_1											: std_logic_vector(16 downto 0);
	signal r_B0_2											: std_logic_vector(16 downto 0);

	signal r_B1_0											: std_logic_vector(16 downto 0);
	signal r_B1_1											: std_logic_vector(16 downto 0);
	signal r_B1_2											: std_logic_vector(16 downto 0);
	signal r_B1_3											: std_logic_vector(16 downto 0);

	signal r_B2_0											: std_logic_vector(16 downto 0);
	signal r_B2_1											: std_logic_vector(16 downto 0);
	signal r_B2_2											: std_logic_vector(16 downto 0);
	signal r_B2_3											: std_logic_vector(16 downto 0);
	signal r_B2_4											: std_logic_vector(16 downto 0);

	signal r_B3_0											: std_logic_vector(12 downto 0);
	signal r_B3_1											: std_logic_vector(12 downto 0);
	signal r_B3_2											: std_logic_vector(12 downto 0);
	signal r_B3_3											: std_logic_vector(12 downto 0);
	signal r_B3_4											: std_logic_vector(12 downto 0);


	-- PART II
	signal s_data_A0_B0									: std_logic_vector(47 downto 0);
	signal s_data_A0_B0_open							: std_logic_vector(30 downto 0);
	signal s_data_A0_B0_ready							: std_logic_vector(16 downto 0);
	signal s_data_A0_B0_ready_dly						: std_logic_vector(16 downto 0);

	signal s_data_A1_B0									: std_logic_vector(47 downto 0);
	signal s_data_A1_B0_open							: std_logic_vector(47 downto 0);

	signal s_data_A0_B1									: std_logic_vector(47 downto 0);
	signal s_data_A0_B1_open							: std_logic_vector(30 downto 0);
	signal s_data_A0_B1_ready							: std_logic_vector(16 downto 0);
	signal s_data_A0_B1_ready_dly						: std_logic_vector(16 downto 0);

	signal s_data_A2_B0									: std_logic_vector(47 downto 0);
	signal s_data_A2_B0_open							: std_logic_vector(47 downto 0);

	signal s_data_A1_B1									: std_logic_vector(47 downto 0);
	signal s_data_A1_B1_open							: std_logic_vector(47 downto 0);

	signal s_data_A0_B2_open							: std_logic_vector(30 downto 0);
	signal s_data_A0_B2_ready							: std_logic_vector(16 downto 0);
	signal s_data_A0_B2_ready_dly						: std_logic_vector(16 downto 0);
	signal s_data_II_result								: std_logic_vector(47 downto 0);


	-- PART I
	signal s_data_A3_B0									: std_logic_vector(47 downto 0);
	signal s_data_A3_B0_open							: std_logic_vector(47 downto 0);

	signal s_data_A2_B1									: std_logic_vector(47 downto 0);
	signal s_data_A2_B1_open							: std_logic_vector(47 downto 0);

	signal s_data_A1_B2									: std_logic_vector(47 downto 0);
	signal s_data_A1_B2_open							: std_logic_vector(47 downto 0);

	signal s_data_A0_B3_open							: std_logic_vector(11 downto 0);
	signal s_data_I_result								: std_logic_vector(35 downto 0);


	-- PART III
	signal s_data_A3_B1									: std_logic_vector(47 downto 0);
	signal s_data_A3_B1_open							: std_logic_vector(47 downto 0);

	signal s_data_A2_B2									: std_logic_vector(47 downto 0);
	signal s_data_A2_B2_open							: std_logic_vector(47 downto 0);

	signal s_data_A1_B3									: std_logic_vector(47 downto 0);
	signal s_data_A1_B3_open							: std_logic_vector(30 downto 0);
	signal s_data_A1_B3_ready							: std_logic_vector(16 downto 0);
	signal s_data_A1_B3_ready_dly						: std_logic_vector(16 downto 0);


	signal s_data_A3_B2									: std_logic_vector(47 downto 0);
	signal s_data_A3_B2_open							: std_logic_vector(47 downto 0);

	signal s_data_A2_B3									: std_logic_vector(47 downto 0);
	signal s_data_A2_B3_open							: std_logic_vector(30 downto 0);
	signal s_data_A2_B3_ready							: std_logic_vector(16 downto 0);
	signal s_data_A2_B3_ready_dly						: std_logic_vector(16 downto 0);

	signal s_data_A3_B3									: std_logic_vector(47 downto 0);
	signal s_data_A3_B3_ready							: std_logic_vector(47 downto 0);
	signal s_data_A3_B3_ready_dly						: std_logic_vector(11 downto 0);

	signal s_data_III_result							: std_logic_vector(47 downto 0);

	signal s_data_lo										: std_logic_vector(47 downto 0);
	signal s_data_lo_open								: std_logic_vector(30 downto 0);
	signal s_data_lo_ready								: std_logic_vector(16 downto 0);
	signal s_data_lo_ready_dly							: std_logic_vector(16 downto 0);
	signal s_data_hi_ready								: std_logic_vector(47 downto 0);
	signal s_data_hi_ready_dly							: std_logic_vector(47 downto 0);

begin

	---------------------
	-- START OF PART II --
	---------------------

	-- LEVEL 0

	-- A0_B0
	MULT_17_A0_B0_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 1,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 1,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 1,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 1,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A0_B0,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 17)			=> s_data_A0_B0_open,							-- 48-bit output: Primary data output
		P(16 downto 0)				=> s_data_A0_B0_ready,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> (others=>'0'),									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0000101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A0_0,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B0_0,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '0',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '0',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- LEVEL 1

	-- A1_B0
	MULT_17_A1_B0_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A1_B0,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A1_B0_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A0_B0,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "1010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A1_0,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B0_0,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A0_B1
	MULT_17_A0_B1_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A0_B1,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 17)			=> s_data_A0_B1_open,							-- 48-bit output: Primary data output
		P(16 downto 0)				=> s_data_A0_B1_ready,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A1_B0,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A0_1,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B1_1,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);

	-- LEVEL 2

		-- A2_B0
	MULT_17_A2_B0_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A2_B0,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A2_B0_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A0_B1,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "1010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A2_2,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B0_2,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A1_B1
	MULT_17_A1_B1_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A1_B1,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A1_B1_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A2_B0,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A1_3,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B1_3,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A0_B2
	MULT_17_A0_B2_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_II_result,								-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 17)			=> s_data_A0_B2_open,							-- 48-bit output: Primary data output
		P(16 downto 0)				=> s_data_A0_B2_ready,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A1_B1,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A0_4,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B2_4,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-------------------
	-- END OF PART II --
	-------------------


	----------------------
	-- START OF PART I --
	----------------------

		-- A3_B0
	MULT_17_A3_B0_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A3_B0,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A3_B0_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> (others=>'0'),									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0000101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 13)			=> (others=>'0'),									-- 30-bit input: A data input
		A(12 downto 0)				=> r_A3_0,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B0_0,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A2_B1
	MULT_17_A2_B1_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A2_B1,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A2_B1_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A3_B0,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A2_1,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B1_1,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A1_B2
	MULT_17_A1_B2_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A1_B2,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A1_B2_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A2_B1,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A1_2,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B2_2,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);

	-- A0_B3
	MULT_17_A0_B3_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> open,												-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 36)			=> s_data_A0_B3_open,							-- 48-bit output: Primary data output
		P(35 downto 0)				=> s_data_I_result,								-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A1_B2,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A0_3,											-- 30-bit input: A data input
		B(17 downto 13)			=> (others=>'0'),									-- 18-bit input: B data input
		B(12 downto 0)				=> r_B3_3,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);

	-------------------
	-- END OF PART I --
	-------------------




	-----------------------
	-- START OF PART III --
	-----------------------

	-- A3_B1
	MULT_17_A3_B1_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 1,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 1,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 1,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 1,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A3_B1,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A3_B1_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> (others=>'0'),									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0000101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 13)			=> (others=>'0'),									-- 30-bit input: A data input
		A(12 downto 0)				=> r_A3_0,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B1_0,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '0',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '0',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A2_B2
	MULT_17_A2_B2_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A2_B2,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A2_B2_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A3_B1,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A2_0,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B2_0,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A1_B3
	MULT_17_A1_B3_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A1_B3,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 17)			=> s_data_A1_B3_open,							-- 48-bit output: Primary data output
		P(16 downto 0)				=> s_data_A1_B3_ready,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A2_B2,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A1_1,											-- 30-bit input: A data input
		B(17 downto 13)			=> (others=>'0'),									-- 18-bit input: B data input
		B(12 downto 0)				=> r_B3_1,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A3_B2
	MULT_17_A3_B2_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A3_B2,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A3_B2_open,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A1_B3,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "1010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 13)			=> (others=>'0'),									-- 30-bit input: A data input
		A(12 downto 0)				=> r_A3_2,											-- 30-bit input: A data input
		B(17)							=> '0',												-- 18-bit input: B data input
		B(16 downto 0)				=> r_B2_2,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A2_B3
	MULT_17_A2_B3_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_A2_B3,									-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 17)			=> s_data_A2_B3_open,							-- 48-bit output: Primary data output
		P(16 downto 0)				=> s_data_A2_B3_ready,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A3_B2,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "0010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 17)			=> (others=>'0'),									-- 30-bit input: A data input
		A(16 downto 0)				=> r_A2_3,											-- 30-bit input: A data input
		B(17 downto 13)			=> (others=>'0'),									-- 18-bit input: B data input
		B(12 downto 0)				=> r_B3_3,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	-- A3_B3
	MULT_17_A3_B3_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "MULTIPLY",							-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 2,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 2,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 2,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 2,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 0,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 1,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> open,												-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_A3_B3_ready,							-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_A2_B3,									-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "1010101",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A(29 downto 13)			=> (others=>'0'),									-- 30-bit input: A data input
		A(12 downto 0)				=> r_A3_4,											-- 30-bit input: A data input
		B(17 downto 13)			=> (others=>'0'),									-- 18-bit input: B data input
		B(12 downto 0)				=> r_B3_4,											-- 18-bit input: B data input
		C								=> (others=>'0'),									-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '1',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '1',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '1',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '0',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '1',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	---------------------
	-- END OF PART III --
	---------------------


	-- 	48				=		14						+			17			+	17
	s_data_III_result <= s_data_A3_B3_ready(13 downto 0) & s_data_A2_B3_ready_dly & s_data_A1_B3_ready_dly;


	-------------
	-- ADDER I --
	-------------

	ADD_48_LO_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "NONE",								-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 0,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 0,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 0,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 0,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 1,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 0,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> s_data_lo,										-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P(47 downto 17)			=> s_data_lo_open,								-- 48-bit output: Primary data output
		P(16 downto 0)				=> s_data_lo_ready,								-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_II_result,								-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "1011100",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A								=> (others=>'0'),									-- 30-bit input: A data input
		B								=> (others=>'0'),									-- 18-bit input: B data input
		C(47 downto 36)			=> (others=>'0'),									-- 48-bit input: C data input
		C(35 downto 0)				=> s_data_I_result,								-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '0',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '0',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '0',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '0',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '1',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '0',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);


	--------------
	-- ADDER II --
	--------------

	ADD_48_HI_INST: DSP48E1 generic map (
		-- Feature Control Attributes: Data Path Selection
		A_INPUT					=> "DIRECT",							-- Selects A input source, "DIRECT" (A port) or "CASCADE" (ACIN port)
		B_INPUT					=> "DIRECT",							-- Selects B input source, "DIRECT" (B port) or "CASCADE" (BCIN port)
		USE_DPORT				=> FALSE,								-- Select D port usage (TRUE or FALSE)
		USE_MULT					=> "NONE",								-- Select multiplier usage ("MULTIPLY", "DYNAMIC", or "NONE")
		USE_SIMD					=> "ONE48",								-- SIMD selection ("ONE48", "TWO24", "FOUR12")
																				-- Pattern Detector Attributes: Pattern Detection Configuration
		AUTORESET_PATDET		=> "NO_RESET",							-- "NO_RESET", "RESET_MATCH", "RESET_NOT_MATCH"
		MASK						=> X"3fffffffffff",					-- 48-bit mask value for pattern detect (1=ignore)
		PATTERN					=> X"000000000000",					-- 48-bit pattern match for pattern detect
		SEL_MASK					=> "MASK",								-- "C", "MASK", "ROUNDING_MODE1", "ROUNDING_MODE2"
		SEL_PATTERN				=> "PATTERN",							-- Select pattern value ("PATTERN" or "C")
		USE_PATTERN_DETECT	=> "NO_PATDET",						-- Enable pattern detect ("PATDET" or "NO_PATDET")
																				-- Register Control Attributes: Pipeline Register Configuration
		ACASCREG					=> 0,										-- Number of pipeline stages between A/ACIN and ACOUT (0, 1 or 2)
		ADREG						=> 0,										-- Number of pipeline stages for pre-adder (0 or 1)
		ALUMODEREG				=> 0,										-- Number of pipeline stages for ALUMODE (0 or 1)
		AREG						=> 0,										-- Number of pipeline stages for A (0, 1 or 2)
		BCASCREG					=> 0,										-- Number of pipeline stages between B/BCIN and BCOUT (0, 1 or 2)
		BREG						=> 0,										-- Number of pipeline stages for B (0, 1 or 2)
		CARRYINREG				=> 0,										-- Number of pipeline stages for CARRYIN (0 or 1)
		CARRYINSELREG			=> 0,										-- Number of pipeline stages for CARRYINSEL (0 or 1)
		CREG						=> 1,										-- Number of pipeline stages for C (0 or 1)
		DREG						=> 0,										-- Number of pipeline stages for D (0 or 1)
		INMODEREG				=> 0,										-- Number of pipeline stages for INMODE (0 or 1)
		MREG						=> 0,										-- Number of multiplier pipeline stages (0 or 1)
		OPMODEREG				=> 0,										-- Number of pipeline stages for OPMODE (0 or 1)
		PREG						=> 1										-- Number of pipeline stages for P (0 or 1)
	)
	port map (
		-- Cascade: 30-bit (each) output: Cascade Ports
		ACOUT							=> open,												-- 30-bit output: A port cascade output
		BCOUT							=> open,												-- 18-bit output: B port cascade output
		CARRYCASCOUT				=> open,												-- 1-bit output: Cascade carry output
		MULTSIGNOUT					=> open,												-- 1-bit output: Multiplier sign cascade output
		PCOUT							=> open,												-- 48-bit output: Cascade output
																								-- Control: 1-bit (each) output: Control Inputs/Status Bits
		OVERFLOW						=> open,												-- 1-bit output: Overflow in add/acc output
		PATTERNBDETECT 			=> open,												-- 1-bit output: Pattern bar detect output
		PATTERNDETECT				=> open,												-- 1-bit output: Pattern detect output
		UNDERFLOW					=> open,												-- 1-bit output: Underflow in add/acc output
																								-- Data: 4-bit (each) output: Data Ports
		CARRYOUT						=> open,												-- 4-bit output: Carry output
		P								=> s_data_hi_ready,								-- 48-bit output: Primary data output
																								-- Cascade: 30-bit (each) input: Cascade Ports
		ACIN							=> (others=>'0'),									-- 30-bit input: A cascade data input
		BCIN							=> (others=>'0'),									-- 18-bit input: B cascade input
		CARRYCASCIN					=> '0',												-- 1-bit input: Cascade carry input
		MULTSIGNIN					=> '0',												-- 1-bit input: Multiplier sign input
		PCIN							=> s_data_lo,										-- 48-bit input: P cascade input
																								-- Control: 4-bit (each) input: Control Inputs/Status Bits
		ALUMODE						=> "0000",											-- 4-bit input: ALU control input
		CARRYINSEL					=> (others=>'0'),									-- 3-bit input: Carry select input
		CLK							=> CLK,												-- 1-bit input: Clock input
		INMODE						=> (others=>'0'),									-- 5-bit input: INMODE control input
		OPMODE						=> "1011100",										-- 7-bit input: Operation mode input
																								-- Data: 30-bit (each) input: Data Ports
		A								=> (others=>'0'),									-- 30-bit input: A data input
		B								=> (others=>'0'),									-- 18-bit input: B data input
		C								=> s_data_III_result,							-- 48-bit input: C data input
		CARRYIN						=> '0',												-- 1-bit input: Carry input signal

		D								=> (others=>'0'),									-- 25-bit input: D data input
																								-- Reset/Clock Enable: 1-bit (each) input: Reset/Clock Enable Inputs
		CEA1							=> '0',								-- 1-bit input: Clock enable input for 1st stage AREG
		CEA2							=> '0',								-- 1-bit input: Clock enable input for 2nd stage AREG
		CEAD							=> '0',								-- 1-bit input: Clock enable input for ADREG
		CEALUMODE					=> '0',								-- 1-bit input: Clock enable input for ALUMODE
		CEB1							=> '0',								-- 1-bit input: Clock enable input for 1st stage BREG
		CEB2							=> '0',								-- 1-bit input: Clock enable input for 2nd stage BREG
		CEC							=> '1',								-- 1-bit input: Clock enable input for CREG
		CECARRYIN					=> '0',								-- 1-bit input: Clock enable input for CARRYINREG
		CECTRL						=> '0',								-- 1-bit input: Clock enable input for OPMODEREG and CARRYINSELREG
		CED							=> '0',								-- 1-bit input: Clock enable input for DREG
		CEINMODE						=> '0',								-- 1-bit input: Clock enable input for INMODEREG
		CEM							=> '0',								-- 1-bit input: Clock enable input for MREG
		CEP							=> '1',								-- 1-bit input: Clock enable input for PREG
		RSTA							=> '0',								-- 1-bit input: Reset input for AREG
		RSTALLCARRYIN				=> '0',								-- 1-bit input: Reset input for CARRYINREG
		RSTALUMODE					=> '0',								-- 1-bit input: Reset input for ALUMODEREG
		RSTB							=> '0',								-- 1-bit input: Reset input for BREG
		RSTC							=> '0',								-- 1-bit input: Reset input for CREG
		RSTCTRL						=> '0',								-- 1-bit input: Reset input for OPMODEREG and CARRYINSELREG
		RSTD							=> '0',								-- 1-bit input: Reset input for DREG and ADREG
		RSTINMODE					=> '0',								-- 1-bit input: Reset input for INMODEREG
		RSTM							=> '0',								-- 1-bit input: Reset input for MREG
		RSTP							=> '0'								-- 1-bit input: Reset input for PREG
	);





	process(CLK)
	begin
		if(rising_edge(CLK)) then

			r_A0_0 <= A(16 downto 0);
			r_A0_1 <= r_A0_0;
			r_A0_2 <= r_A0_1;
			r_A0_3 <= r_A0_2;
			r_A0_4 <= r_A0_3;

			r_A1_0 <= A(33 downto 17);
			r_A1_1 <= r_A1_0;
			r_A1_2 <= r_A1_1;
			r_A1_3 <= r_A1_2;

			r_A2_0 <= A(50 downto 34);
			r_A2_1 <= r_A2_0;
			r_A2_2 <= r_A2_1;
			r_A2_3 <= r_A2_2;

			r_A3_0 <= A(63 downto 51);
			r_A3_1 <= r_A3_0;
			r_A3_2 <= r_A3_1;
			r_A3_3 <= r_A3_2;
			r_A3_4 <= r_A3_3;

			r_B0_0 <= B(16 downto 0);
			r_B0_1 <= r_B0_0;
			r_B0_2 <= r_B0_1;

			r_B1_0 <= B(33 downto 17);
			r_B1_1 <= r_B1_0;
			r_B1_2 <= r_B1_1;
			r_B1_3 <= r_B1_2;

			r_B2_0 <= B(50 downto 34);
			r_B2_1 <= r_B2_0;
			r_B2_2 <= r_B2_1;
			r_B2_3 <= r_B2_2;
			r_B2_4 <= r_B2_3;

			r_B3_0 <= B(63 downto 51);
			r_B3_1 <= r_B3_0;
			r_B3_2 <= r_B3_1;
			r_B3_3 <= r_B3_2;
			r_B3_4 <= r_B3_3;

		end if;
	end process;


	A0_B0_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 17,							--: natural := 1;
		g_delay					=> 8								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_A0_B0_ready,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_A0_B0_ready_dly	--: out std_logic_vector(g_data_width-1 downto 0)
	);


	A0_B1_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 17,							--: natural := 1;
		g_delay					=> 6								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_A0_B1_ready,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_A0_B1_ready_dly	--: out std_logic_vector(g_data_width-1 downto 0)
	);


	A0_B2_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 17,							--: natural := 1;
		g_delay					=> 3								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_A0_B2_ready,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_A0_B2_ready_dly	--: out std_logic_vector(g_data_width-1 downto 0)
	);


	-- PART III
	A1_B3_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 17,							--: natural := 1;
		g_delay					=> 3								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_A1_B3_ready,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_A1_B3_ready_dly	--: out std_logic_vector(g_data_width-1 downto 0)
	);


	A2_B3_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 17,							--: natural := 1;
		g_delay					=> 1								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_A2_B3_ready,		--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_A2_B3_ready_dly	--: out std_logic_vector(g_data_width-1 downto 0)
	);



	-- ADDERS

	LO_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 17,							--: natural := 1;
		g_delay					=> 2								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_lo_ready,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_lo_ready_dly		--: out std_logic_vector(g_data_width-1 downto 0)
	);


	HI_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 48,							--: natural := 1;
		g_delay					=> 1								--: natural := 15
	)
	port map (
		pi_clk					=> CLK,							--: in std_logic;
		pi_data					=> s_data_hi_ready,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_hi_ready_dly		--: out std_logic_vector(g_data_width-1 downto 0)
	);


	A3_B3_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 12,											--: natural := 1;
		g_delay					=> 3												--: natural := 15
	)
	port map (
		pi_clk					=> CLK,											--: in std_logic;
		pi_data					=> s_data_A3_B3_ready(25 downto 14),	--: in std_logic_vector(g_data_width-1 downto 0);
		po_data					=> s_data_A3_B3_ready_dly					--: out std_logic_vector(g_data_width-1 downto 0)
	);


--128	=			12 						48								17							17									17								17
	S <= s_data_A3_B3_ready_dly & s_data_hi_ready_dly & s_data_lo_ready_dly & s_data_A0_B2_ready_dly & s_data_A0_B1_ready_dly & s_data_A0_B0_ready_dly;

end architecture;
