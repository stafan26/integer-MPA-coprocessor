-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    01/12/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    my_bram
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

Library UNISIM;
use UNISIM.vcomponents.all;

Library UNIMACRO;
use UNIMACRO.vcomponents.all;

use work.my_pack.all;
use work.pro_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
--
-------------------------------------------
-------------------------------------------

entity my_bram is
generic (
	g_sim							: boolean := false;
	g_data_width				: natural := 64;
	g_addr_width				: natural := 8
);
port (
	pi_clk			: in std_logic;
	pi_we_A			: in std_logic;
	pi_addr_A		: in std_logic_vector(g_addr_width-1 downto 0);
	pi_data_A		: in std_logic_vector(g_data_width-1 downto 0);
	pi_addr_B		: in std_logic_vector(g_addr_width-1 downto 0);
	po_data_B		: out std_logic_vector(g_data_width-1 downto 0)
);
end my_bram;

architecture my_bram of my_bram is

	signal r_ram		: t_ram := (others=>(others=>'0'));
	signal r_data_A	: std_logic_vector(g_data_width-1 downto 0);
	signal r_data_B	: std_logic_vector(g_data_width-1 downto 0);
	signal r_addr_A	: std_logic_vector(g_addr_width-1 downto 0);
	signal r_wea		: std_logic;

	constant c_result_mem_width		: natural := 64*3;
	constant c_result_mem_portions	: natural := natural(ceil(real(c_result_mem_width)/real(g_data_width)));
	signal s_memory_result_vector		: std_logic_vector(c_result_mem_width-1 downto 0);

begin

	STORAGE_SIM_GEN: if(g_sim = true) generate
		process(pi_clk)
		begin

			if(rising_edge(pi_clk)) then

				r_wea <= pi_we_A;
				r_data_A <= pi_data_A;
				r_addr_A <= pi_addr_A;

				if(r_wea = '1') then
					r_ram(to_natural(r_addr_A)) <= r_data_A;
				end if;


				po_data_B <= r_data_B;
				r_data_B <= r_ram(to_natural(pi_addr_B));

			end if;

		end process;

		SIM_RESULT_GEN: for i in 0 to c_result_mem_portions-1 generate
			s_memory_result_vector((g_data_width*i)+g_data_width-1 downto g_data_width*i) <= r_ram(i);
		end generate;
	end generate;

	STORAGE_IP_GEN: if(g_sim = false) generate

		BRAM_SDP_MACRO_inst: BRAM_SDP_MACRO generic map (
			BRAM_SIZE				=> "36Kb",								-- Target BRAM, "18Kb" or "36Kb"
			DEVICE					=> "7SERIES",							-- Target device: "VIRTEX5", "VIRTEX6", "7SERIES", "SPARTAN6"
			WRITE_WIDTH				=> g_data_width,						-- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
			READ_WIDTH				=> g_data_width,						-- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
			DO_REG					=> 1,										-- Optional output register (0 or 1)
			INIT_FILE				=> "NONE",
			SIM_COLLISION_CHECK	=> "NONE",								-- Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
			SRVAL						=> X"000000000000000000",			-- Set/Reset value for port output
			WRITE_MODE				=> "WRITE_FIRST",						-- Specify "READ_FIRST" for same clock or synchronous clocks / Specify "WRITE_FIRST for asynchrononous clocks on ports
			INIT						=> X"000000000000000000"			-- Initial values on output port
		)
		port map (
			RST		=> '0',									-- 1-bit input reset

			WRCLK		=> pi_clk,								-- 1-bit input write clock
			WREN		=> pi_we_A,								-- 1-bit input write port enable
			WE			=> (7 downto 0 => '1'),				-- Input write enable, width defined by write port depth
			WRADDR	=> pi_addr_A,							-- Input write address, width defined by write port depth
			DI			=> pi_data_A,							-- Input write data port, width defined by WRITE_WIDTH parameter

			RDCLK		=> pi_clk,								-- 1-bit input read clock
			RDADDR	=> pi_addr_B,							-- Input read address, width defined by read port depth
			DO			=> po_data_B,							-- Output read data port, width defined by READ_WIDTH parameter
			RDEN		=> '1',									-- 1-bit input read port enable
			REGCE		=> '1'									-- 1-bit input read output register enable

		);

	end generate;

end architecture;
