-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    10/11/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    test_pack
-------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

--use work.pro_pack.all;
--use work.my_pack.all;

package test_pack is

	-- TMP TEST
	--type t_ram is array (0 to 2**9-1) of std_logic_vector(64-1 downto 0);
	--type t_mm is array (0 to 17-1) of t_ram;
	type t_mm_flat is array (0 to 17-1) of std_logic_vector(2**9 * 64-1 downto 0);

--	type t_ram is array (0 to 2**C_STD_ADDR_WIDTH-1) of std_logic_vector(C_STD_DATA_WIDTH-1 downto 0);
--	type t_mm is array (0 to C_NUM_OF_ALL_REGISTERS-1) of t_ram;
--	type t_mm_flat is array (0 to C_NUM_OF_ALL_REGISTERS-1) of std_logic_vector(2**C_STD_ADDR_WIDTH * C_STD_DATA_WIDTH-1 downto 0);
--	type t_all_phys is array (0 to C_NUM_OF_ALL_REGISTERS-1) of (addr_width(C_NUM_OF_ALL_REGISTERS)-1 downto 0);

end test_pack;

package body test_pack is

end package body test_pack;
