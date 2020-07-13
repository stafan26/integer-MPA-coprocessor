	-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    10/11/2016
-- Project Name:   MPALU
-- Design Name:    multiplier
-- Module Name:    my_pll
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

use work.pro_pack.all;

entity my_pll is
	port (
		pi_clk_ext						: in std_logic;
		pi_rst_ext						: in std_logic;
		po_clk							: out std_logic;
		po_rst							: out std_logic
	);
end my_pll;

architecture my_pll of my_pll is

	constant c_release_reset_after_x_clk	: natural := 8;

	signal s_clk_ext								: std_logic;
	signal s_clk									: std_logic;
	signal s_clk_buf								: std_logic;
	signal s_clk_div								: std_logic;
	signal s_clk_div_buf							: std_logic;

	signal s_clk_fb								: std_logic;
	signal s_clk_fb_buf							: std_logic;

	signal r_rst									: std_logic;
	signal r_rst_main								: std_logic;
	signal r_rst_shreg							: std_logic_vector(c_release_reset_after_x_clk-1 downto 0);

	signal s_locked								: std_logic;

begin

	EXT_CLK_IBUF:			IBUFG port map (I => pi_clk_ext, O => s_clk_ext);

	MAIN_CLK_BUF:			BUFG port map (I => s_clk,			O => s_clk_buf			);
	MAIN_DIV_CLK_BUF:		BUFG port map (I => s_clk_div,	O => s_clk_div_buf	);
	DELAY_CLK_BUF:			BUFG port map (I => s_clk_fb,		O => s_clk_fb_buf		);

	po_clk <= s_clk_buf;
	po_rst <= r_rst_main;


	PLLE2_BASE_inst : PLLE2_BASE
	generic map (
		BANDWIDTH						=> "OPTIMIZED",				-- OPTIMIZED, HIGH, LOW

		CLKFBOUT_MULT					=> PLL_CLKFBOUT_MULT,		-- Multiply value for all CLKOUT, (2-64)
		DIVCLK_DIVIDE					=> PLL_DIVCLK_DIVIDE,		-- Master division value, (1-56)
		CLKOUT0_DIVIDE					=> PLL_CLKOUT0_DIVIDE,
		CLKOUT1_DIVIDE					=> PLL_CLKOUT1_DIVIDE,


		CLKFBOUT_PHASE					=> 0.0,							-- Phase offset in degrees of CLKFB, (-360.000-360.000).
		CLKIN1_PERIOD					=> 10.0,							-- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
																				-- CLKOUT0_DIVIDE - CLKOUT5_DIVIDE: Divide amount for each CLKOUT (1-128)

		CLKOUT2_DIVIDE					=> 10,
		CLKOUT3_DIVIDE					=> 10,
		CLKOUT4_DIVIDE					=> 10,
		CLKOUT5_DIVIDE					=> 10,
																				-- CLKOUT0_DUTY_CYCLE - CLKOUT5_DUTY_CYCLE: Duty cycle for each CLKOUT (0.001-0.999).
		CLKOUT0_DUTY_CYCLE			=> 0.5,
		CLKOUT1_DUTY_CYCLE			=> 0.5,
		CLKOUT2_DUTY_CYCLE			=> 0.5,
		CLKOUT3_DUTY_CYCLE			=> 0.5,
		CLKOUT4_DUTY_CYCLE			=> 0.5,
		CLKOUT5_DUTY_CYCLE			=> 0.5,
																				-- CLKOUT0_PHASE - CLKOUT5_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
		CLKOUT0_PHASE					=> 0.0,
		CLKOUT1_PHASE					=> 0.0,
		CLKOUT2_PHASE					=> 0.0,
		CLKOUT3_PHASE					=> 0.0,
		CLKOUT4_PHASE					=> 0.0,
		CLKOUT5_PHASE					=> 0.0,

		REF_JITTER1						=> 0.0,							-- Reference input jitter in UI, (0.000-0.999).
		STARTUP_WAIT					=> "TRUE"						-- Delay DONE until PLL Locks, ("TRUE"/"FALSE")
	)
	port map (
																				-- Clock Outputs: 1-bit (each) output: User configurable clock outputs
		CLKOUT0							=> s_clk,						-- 1-bit output: CLKOUT0
		CLKOUT1							=> s_clk_div,					-- 1-bit output: CLKOUT1
		CLKOUT2							=> open,							-- 1-bit output: CLKOUT2
		CLKOUT3							=> open,							-- 1-bit output: CLKOUT3
		CLKOUT4							=> open,							-- 1-bit output: CLKOUT4
		CLKOUT5							=> open,							-- 1-bit output: CLKOUT5
																				-- Feedback Clocks: 1-bit (each) output: Clock feedback ports
		CLKFBOUT							=> s_clk_fb,					-- 1-bit output: Feedback clock
		LOCKED							=> s_locked,					-- 1-bit output: LOCK
		CLKIN1							=> s_clk_ext,					-- 1-bit input: Input clock
																				-- Control Ports: 1-bit (each) input: PLL control ports
		PWRDWN							=> '0',							-- 1-bit input: Power-down
		RST								=> '0',							-- 1-bit input: Reset
																				-- Feedback Clocks: 1-bit (each) input: Clock feedback ports
		CLKFBIN							=> s_clk_fb_buf				-- 1-bit input: Feedback clock
	);

	-- End of PLLE2_BASE_inst instantiation



	process(s_clk_buf)
	begin
		if(rising_edge(s_clk_buf)) then

			r_rst_main <= r_rst;

		end if;
	end process;



	process(s_clk_buf)
	begin
		if(rising_edge(s_clk_buf)) then

			if(s_locked = '0' or pi_rst_ext = '1') then
				r_rst_shreg <= (others=>'1');
			else
				r_rst_shreg <= '0' & r_rst_shreg(r_rst_shreg'length-1 downto 1);
			end if;

			if(s_locked = '0' or pi_rst_ext = '1' or r_rst_shreg(0) = '1') then
				r_rst <= '1';
			else
				r_rst <= '0';
			end if;

		end if;
	end process;

end architecture;
