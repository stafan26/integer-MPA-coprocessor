-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    mult_part_adder
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

entity mult_part_adder is
generic (
	g_data_width						: natural := 64;
	g_addr_width						: natural := 9
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_data								: in std_logic_vector(g_data_width+g_addr_width-1 downto 0);
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_cout						: out std_logic;
	po_data_zero						: out std_logic;
	po_data_all_ones					: out std_logic;
	po_data_last						: out std_logic;
	po_data_wr_en						: out std_logic
);
end mult_part_adder;

architecture mult_part_adder of mult_part_adder is

	constant c_large_carry								: std_logic_vector(g_data_width-g_addr_width-1 downto 0) := (others=>'0');
	signal r_large_carry									: std_logic_vector(g_data_width-1 downto 0);
	signal r_large_carry_part							: std_logic_vector(g_addr_width-1 downto 0);

	signal s_data											: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_cout									: std_logic;
	signal s_data_zero									: std_logic;
	signal s_data_all_ones								: std_logic;
	signal r_data_last									: std_logic;

begin

	r_large_carry <= c_large_carry & r_large_carry_part;


	ADD_64_INST: entity work.add_64 generic map (
		g_data_width				=> g_data_width								--: natural := 64
	)
	port map (
		CLK							=> pi_clk,										--: in std_logic;
		A								=> pi_data(g_data_width-1 downto 0),	--: in std_logic_vector(g_data_width-1 downto 0);
		B								=> r_large_carry,								--: in std_logic_vector(g_data_width-1 downto 0);
		S								=> s_data,										--: out std_logic_vector(g_data_width-1 downto 0);
		C_OUT							=> s_data_cout,								--: out std_logic;
		ZERO							=> s_data_zero,								--: out std_logic;
		ALL_ONES						=> s_data_all_ones							--: out std_logic;
	);


	DATA_LAST_OUT_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY+1			--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_last,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_data_last				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,								--: natural := 1;
		g_delay					=> C_ADD_64_DELAY+1			--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,						--: in std_logic;
		pi_data(0)				=> pi_data_wr_en,				--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> po_data_wr_en				--: out std_logic_vector(g_data_width-1 downto 0)
	);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			po_data <= s_data;
			po_data_cout <= s_data_cout;
			po_data_zero <= s_data_zero;
			po_data_all_ones <= s_data_all_ones;

			r_data_last <= pi_data_last;

			------------------------
			-- R_LARGE_CARRY_PART --
			------------------------
			if(pi_rst = '1') then
				r_large_carry_part <= (others=>'0');
			else

				if(r_data_last = '1') then
					r_large_carry_part <= (others=>'0');
				elsif(pi_data_wr_en = '1') then
					r_large_carry_part <= pi_data(g_data_width+g_addr_width-1 downto g_data_width);
				end if;

			end if;

		end if;
	end process;

end architecture;
