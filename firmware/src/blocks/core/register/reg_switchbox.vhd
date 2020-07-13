-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_switchbox
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity reg_switchbox is
generic (
	g_id									: natural := 36;
	g_data_width						: natural := 64
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_select							: in std_logic_vector(2 downto 0);
	pi_start								: in std_logic;

	-- LOADER
	pi_loader_A_data					: in std_logic_vector(g_data_width-1 downto 0);
	pi_loader_A_data_last			: in std_logic;
	pi_loader_A_data_wr_en			: in std_logic;

	pi_loader_B_data					: in std_logic_vector(g_data_width-1 downto 0);
	pi_loader_B_data_last			: in std_logic;
	pi_loader_B_data_wr_en			: in std_logic;

	-- REG COPY
	pi_reg_data							: in std_logic_vector(g_data_width-1 downto 0);
	pi_reg_data_last					: in std_logic;
	pi_reg_data_wr_en					: in std_logic;

	-- ADDER
	pi_adder_data_lo					: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	pi_adder_data_last				: in std_logic;
	pi_adder_data_wr_en				: in std_logic;

	-- MULT
	pi_mult_data						: in std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
	pi_mult_data_last					: in std_logic;
	pi_mult_data_wr_en				: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic
);
end reg_switchbox;

architecture reg_switchbox of reg_switchbox is

	signal s_loader_data							: std_logic_vector(g_data_width-1 downto 0);
	signal s_loader_data_last					: std_logic;
	signal s_loader_data_wr_en					: std_logic;

begin

	LOADER_SWITCHBOX_X2_INST: entity work.switchbox_x2_extra generic map (
		--g_output_data_last		=> "YES",								--: string := "YES";
		g_data_width				=> g_data_width,						--: natural := 64;
		g_extra_width				=> 1										--: natural := 4
	)
	port map (
		pi_clk						=> pi_clk,								--: in std_logic;
		pi_rst						=> pi_rst,								--: in std_logic;
		pi_select					=> pi_select(2),						--: in std_logic_vector(1 downto 0);
		pi_start						=> pi_start,							--: in std_logic;
		pi_data_ch_1				=> pi_loader_A_data,					--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_2				=> pi_loader_B_data,					--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_last_ch_1			=> pi_loader_A_data_last,			--: in std_logic;
		pi_data_last_ch_2			=> pi_loader_B_data_last,			--: in std_logic;
		pi_data_extra_ch_1(0)	=> pi_loader_A_data_wr_en,			--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_2(0)	=> pi_loader_B_data_wr_en,			--: in std_logic_vector(g_extra_width-1 downto 0);
		po_data						=> s_loader_data,						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> s_loader_data_last,				--: out std_logic;
		po_data_extra(0)			=> s_loader_data_wr_en				--: out std_logic_vector(g_extra_width-1 downto 0)
	);



	MAIN_SWITCHBOX_X4_INST: entity work.switchbox_x4_extra generic map (
		g_output_data_last		=> "YES",								--: string := "YES";
		g_data_width				=> g_data_width,						--: natural := 64;
		g_extra_width				=> 1										--: natural := 4
	)
	port map (
		pi_clk						=> pi_clk,								--: in std_logic;
		pi_rst						=> pi_rst,								--: in std_logic;
		pi_select					=> pi_select(1 downto 0),			--: in std_logic_vector(1 downto 0);
		pi_start						=> pi_start,							--: in std_logic;
		pi_data_ch_1				=> pi_reg_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_2				=> s_loader_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_3				=> pi_adder_data_lo,					--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_ch_4				=> pi_mult_data,						--: in std_logic_vector(g_data_width-1 downto 0);
		pi_data_last_ch_1			=> pi_reg_data_last,					--: in std_logic;
		pi_data_last_ch_2			=> s_loader_data_last,				--: in std_logic;
		pi_data_last_ch_3			=> pi_adder_data_last,				--: in std_logic;
		pi_data_last_ch_4			=> pi_mult_data_last,				--: in std_logic;
		pi_data_extra_ch_1(0)	=> pi_reg_data_wr_en,				--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_2(0)	=> s_loader_data_wr_en,				--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_3(0)	=> pi_adder_data_wr_en,				--: in std_logic_vector(g_extra_width-1 downto 0);
		pi_data_extra_ch_4(0)	=> pi_mult_data_wr_en,				--: in std_logic_vector(g_extra_width-1 downto 0);

		po_data						=> po_data,								--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> po_data_last,						--: out std_logic;
		po_data_extra(0)			=> po_data_wr_en						--: out std_logic_vector(g_extra_width-1 downto 0)
	);

end architecture;
