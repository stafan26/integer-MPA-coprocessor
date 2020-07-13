-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    20/7/2019
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_peripheral_delayer
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
-------------------------------------------
-------------------------------------------


entity cpu_peripheral_delayer is

port(
	pi_clk						: in std_logic;
	pi_unloader_wr_en			: in std_logic;
	po_unloader_wr_en			: out std_logic;
	pi_unloader_last			: in std_logic;
	po_unloader_last			: out std_logic;

	pi_adder_data_wr_en		: in std_logic;
	po_adder_data_wr_en		: out std_logic;
	pi_adder_data_last		: in std_logic;
	po_adder_data_last		: out std_logic;

	pi_mult_data_wr_en		: in std_logic;
	po_mult_data_wr_en		: out std_logic;
	pi_mult_data_cycle		: in std_logic;
	po_mult_data_cycle		: out std_logic;
	pi_mult_data_last			: in std_logic;
	po_mult_data_last			: out std_logic
);
end cpu_peripheral_delayer;

architecture cpu_peripheral_delayer of cpu_peripheral_delayer is

begin

	----------------
	--   UNLOAD   --
	----------------

	UNLOADER_DATA_VALID_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 6									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_unloader_wr_en,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_unloader_wr_en				--: out std_logic_vector(g_data_width-1 downto 0)
	);

	UNLOADER_DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 6									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_unloader_last,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_unloader_last				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	---------------
	--   ADDER   --
	---------------

	CMC_ADDER_DATA_WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 5									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_adder_data_wr_en,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_adder_data_wr_en			--: out std_logic_vector(g_data_width-1 downto 0)
	);

	CMC_ADDER_DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 5									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_adder_data_last,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_adder_data_last			--: out std_logic_vector(g_data_width-1 downto 0)
	);


	--------------
	--   MULT   --
	--------------

	CMC_MULT_DATA_WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 5									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_mult_data_wr_en,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_mult_data_wr_en			--: out std_logic_vector(g_data_width-1 downto 0)
	);

	CMC_MULT_DATA_CYCLE_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 5									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_mult_data_cycle,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_mult_data_cycle			--: out std_logic_vector(g_data_width-1 downto 0)
	);

	CMC_MULT_DATA_LAST_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 5									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_mult_data_last,			--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_mult_data_last				--: out std_logic_vector(g_data_width-1 downto 0)
	);

end architecture;
