-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    10/11/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    common_pack
-------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

package common_pack is

	type tap_vector is array(4 downto 0) of natural range 0 to 64;

	function select_tap(n : natural) return tap_vector;
	function reverse_tap(tap : tap_vector) return tap_vector;
	function reverse_tap_2(tap : tap_vector) return tap_vector;
	function to_lfsr(g_value : natural; g_width : natural) return std_logic_vector;
	function to_lfsr(g_value : natural; g_width : natural) return natural;

end common_pack;

package body common_pack is

	function select_tap(n : natural) return tap_vector is
		variable ret	: tap_vector;
	begin

		case n is
			when 2 => ret := (2, 2, 1, 0, 0);
			when 3 => ret := (2, 3, 2, 0, 0);
			when 4 => ret := (2, 4, 3, 0, 0);
			when 5 => ret := (2, 5, 3, 0, 0);
			when 6 => ret := (2, 6, 5, 0, 0);
			when 7 => ret := (2, 7, 6, 0, 0);
			when 8 => ret := (4, 8, 6, 5, 4);
			when 9 => ret := (2, 9, 5, 0, 0);
			when 10 => ret := (2, 10, 7, 0, 0);
			when 11 => ret := (2, 11, 9, 0, 0);
			when 12 => ret := (4, 12, 11, 8, 6);
			when 13 => ret := (4, 13, 12, 10, 9);
			when 14 => ret := (4, 14, 13, 11, 9);
			when 15 => ret := (2, 15, 14, 0, 0);
			when 16 => ret := (4, 16, 14, 13, 11);
			when 17 => ret := (2, 17, 14, 0, 0);
			when 18 => ret := (2, 18, 11, 0, 0);
			when 19 => ret := (4, 19, 18, 17, 14);
			when 20 => ret := (2, 20, 17, 0, 0);
			when 21 => ret := (2, 21, 19, 0, 0);
			when 22 => ret := (2, 22, 21, 0, 0);
			when 23 => ret := (2, 23, 18, 0, 0);
			when 24 => ret := (4, 24, 23, 21, 20);
			when 25 => ret := (2, 25, 22, 0, 0);
			when 26 => ret := (4, 26, 25, 24, 20);
			when 27 => ret := (4, 27, 26, 25, 22);
			when 28 => ret := (2, 28, 25, 0, 0);
			when 29 => ret := (2, 29, 27, 0, 0);
			when 30 => ret := (4, 30, 29, 26, 24);
			when 31 => ret := (2, 31, 28, 0, 0);
			when 32 => ret := (4, 32, 30, 26, 25);
			when 33 => ret := (2, 33, 20, 0, 0);
			when 34 => ret := (4, 34, 31, 30, 26);
			when 35 => ret := (2, 35, 33, 0, 0);
			when 36 => ret := (2, 36, 25, 0, 0);
			when 37 => ret := (4, 37, 36, 33, 31);
			when 38 => ret := (4, 38, 37, 33, 32);
			when 39 => ret := (2, 39, 35, 0, 0);
			when 40 => ret := (4, 40, 37, 36, 35);
			when 41 => ret := (2, 41, 38, 0, 0);
			when 42 => ret := (4, 42, 40, 37, 35);
			when 43 => ret := (4, 43, 42, 38, 37);
			when 44 => ret := (4, 44, 42, 39, 38);
			when 45 => ret := (4, 45, 44, 42, 41);
			when 46 => ret := (4, 46, 40, 39, 38);
			when 47 => ret := (2, 47, 42, 0, 0);
			when 48 => ret := (4, 48, 44, 41, 39);
			when 49 => ret := (2, 49, 40, 0, 0);
			when 50 => ret := (4, 50, 48, 47, 46);
			when 51 => ret := (4, 51, 50, 48, 45);
			when 52 => ret := (2, 52, 49, 0, 0);
			when 53 => ret := (4, 53, 52, 51, 47);
			when 54 => ret := (4, 54, 51, 48, 46);
			when 55 => ret := (2, 55, 31, 0, 0);
			when 56 => ret := (4, 56, 54, 52, 49);
			when 57 => ret := (2, 57, 50, 0, 0);
			when 58 => ret := (2, 58, 39, 0, 0);
			when 59 => ret := (4, 59, 57, 55, 52);
			when 60 => ret := (2, 60, 59, 0, 0);
			when 61 => ret := (4, 61, 60, 59, 56);
			when 62 => ret := (4, 62, 59, 57, 56);
			when 63 => ret := (2, 63, 62, 0, 0);
			when 64 => ret := (4, 64, 63, 61, 60);
			when others => ret := (0, 0, 0, 0, 0);
		end case;

		return ret;

	end function;


	function reverse_tap(tap : tap_vector) return tap_vector is
		variable ret	: tap_vector;
	begin

		ret := tap;
		if(ret(4) = 2) then
			ret(3) := 1;
			ret(2) := ret(2) + 1;
		elsif(ret(4) = 4) then
			ret(3) := 1;
			ret(2) := ret(2) + 1;
			ret(1) := ret(1) + 1;
			ret(0) := ret(0) + 1;
		end if;

		return ret;

	end function;


	function reverse_tap_2(tap : tap_vector) return tap_vector is
		variable ret	: tap_vector;
	begin

		ret := tap;
		if(ret(4) = 2) then
			ret(3) := 2;
			ret(2) := ret(2) + 1;
		elsif(ret(4) = 4) then
			ret(3) := 2;
			ret(2) := ret(2) + 1;
			ret(1) := ret(1) + 1;
			ret(0) := ret(0) + 1;
		end if;

		return ret;

	end function;


	function to_lfsr(g_value : natural; g_width : natural) return std_logic_vector is
		variable c_tap					: tap_vector := select_tap(g_width);
		variable ret					: std_logic_vector(g_width-1 downto 0) := (0=>'1',others=>'0');
		variable s_feedback			: std_logic;
	begin

		--report "to_lfsr(" & integer'image(g_value) & ", " & integer'image(g_width) & ") " & integer'image(c_tap(4)) & " " & integer'image(c_tap(3)) & " " & integer'image(c_tap(2)) & " " & integer'image(c_tap(1)) & " " & integer'image(c_tap(0));

		for i in 0 to g_value-1 loop
			if(c_tap(4) = 4) then
				s_feedback := ret(c_tap(0)-1) xor ret(c_tap(1)-1) xor ret(c_tap(2)-1) xor ret(c_tap(3)-1);
			elsif(c_tap(4) = 2) then
				s_feedback := ret(c_tap(2)-1) xor ret(c_tap(3)-1);
			else
				s_feedback := '0';
			end if;

			ret := ret(g_width-2 downto 0) & s_feedback;
		end loop;

		return ret;

	end function;


	function to_lfsr(g_value : natural; g_width : natural) return natural is
		variable c_tap					: tap_vector := select_tap(g_width);
		variable ret					: std_logic_vector(g_width-1 downto 0) := (0=>'1',others=>'0');
		variable s_feedback			: std_logic;
	begin

		--report "to_lfsr(" & integer'image(g_value) & ", " & integer'image(g_width) & ") " & integer'image(c_tap(4)) & " " & integer'image(c_tap(3)) & " " & integer'image(c_tap(2)) & " " & integer'image(c_tap(1)) & " " & integer'image(c_tap(0));

		for i in 0 to g_value-1 loop
			if(c_tap(4) = 4) then
				s_feedback := ret(c_tap(0)-1) xor ret(c_tap(1)-1) xor ret(c_tap(2)-1) xor ret(c_tap(3)-1);
			elsif(c_tap(4) = 2) then
				s_feedback := ret(c_tap(2)-1) xor ret(c_tap(3)-1);
			else
				s_feedback := '0';
			end if;

			ret := ret(g_width-2 downto 0) & s_feedback;
		end loop;

		return IEEE.numeric_std.to_integer(IEEE.numeric_std.unsigned(ret));

	end function;

end package body common_pack;
