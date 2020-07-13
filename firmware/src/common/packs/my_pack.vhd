-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    10/11/2016
-- Project Name:   MPALU
-- Design Name:    common
-- Module Name:    my_pack
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package my_pack is

	function to_std_logic_vector(word: integer; num_of_bits: natural) return std_logic_vector;
	function to_std_logic_vector_signed(word: integer; num_of_bits: natural) return std_logic_vector;
	function to_std_logic(word: integer) return std_logic;
	function to_natural(word: std_logic_vector) return natural;
	function to_natural(word: std_logic) return natural;
	function to_natural(word: boolean) return natural;
	function to_integer(word: std_logic_vector) return integer;
	function greater_num(a: natural; b: natural) return natural;
	function lesser_num(a: natural; b: natural) return natural;
	function addr_width(depth: natural) return natural;
	function is_one_hot(data: std_logic_vector) return boolean;
	function is_one_cold(data: std_logic_vector) return boolean;
	function is_num_of_ones_gte_x(data: std_logic_vector; num: natural) return boolean;
	function sub_ge_zero(a: natural; b: natural) return natural;
	function one_hot_2_bin(a: std_logic_vector) return std_logic_vector;
	function "=" (a : std_logic_vector; b : natural) return boolean;
	--function "=" (a : std_logic_vector; b : integer) return boolean;
	function "/=" (a : std_logic_vector; b : integer) return boolean;
	function ">" (a : std_logic_vector; b : natural) return boolean;
	function "<" (a : std_logic_vector; b : natural) return boolean;
	function ">=" (a : std_logic_vector; b : natural) return boolean;
	function "<=" (a : std_logic_vector; b : natural) return boolean;
	function "+" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector;
	function "+" (a : std_logic_vector; b : std_logic) return std_logic_vector;
	function "+" (a : std_logic_vector; b : integer) return std_logic_vector;
	function "-" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector;
	function "-" (a : std_logic_vector; b : std_logic) return std_logic_vector;
	function "-" (a : std_logic_vector; b : integer) return std_logic_vector;
	function "/" (a : natural; b : natural) return natural;
	function div_down(a : natural; b : natural) return natural;
	function div_up(a : natural; b : natural) return natural;
	function more_than_one_set_bit(v : std_logic_vector) return std_logic;
	function or_reduce(v : std_logic_vector) return std_logic;
	function and_reduce(v : std_logic_vector) return std_logic;

end my_pack;

package body my_pack is

	function to_std_logic_vector(word: integer; num_of_bits: natural) return std_logic_vector is
	begin
		return std_logic_vector(IEEE.numeric_std.to_unsigned(word, num_of_bits));
	end function;

	function to_std_logic_vector_signed(word: integer; num_of_bits: natural) return std_logic_vector is
	begin
		return std_logic_vector(IEEE.numeric_std.to_signed(word, num_of_bits));
	end function;


	function to_std_logic(word: integer) return std_logic is
		variable v_ret			: std_logic_vector(0 downto 0) := std_logic_vector(IEEE.numeric_std.to_signed(word, 1));
	begin
		return v_ret(0);
	end function;


	function to_natural(word: std_logic_vector) return natural is
	begin
		return IEEE.numeric_std.to_integer(IEEE.numeric_std.unsigned(word));
	end function;

	function to_natural(word: std_logic) return natural is
		variable ret		: natural;
	begin
		if(word = '1') then
			ret := 1;
		else
			ret := 0;
		end if;
		return ret;
	end function to_natural;

	function to_natural(word: boolean) return natural is
		variable ret	: natural;
	begin
		if(word = false) then
			ret := 0;
		else
			ret := 1;
		end if;
		return ret;
	end function to_natural;

	function to_integer(word: std_logic_vector) return integer is
	begin
		return IEEE.numeric_std.to_integer(IEEE.numeric_std.signed(word));
	end function;

	function greater_num(a: natural; b: natural) return natural is
		variable ret	: natural;
	begin
		if(a > b) then
			ret := a;
		else
			ret := b;
		end if;
		return ret;
	end function;

	function lesser_num(a: natural; b: natural) return natural is
		variable ret	: natural;
	begin
		if(a < b) then
			ret := a;
		else
			ret := b;
		end if;
		return ret;
	end function;

	function addr_width(depth: natural) return natural is
		variable width: natural := 1;
	begin
		while(2**width < depth) loop
			width := width + 1;
		end loop;
		return width;
	end function;

	function is_one_hot(data: std_logic_vector) return boolean is
		variable v_num_of_ones	: natural := 0;
		variable ret 				: boolean;
	begin
		for i in 0 to data'length-1 loop
			if(data(i) = '1') then
				v_num_of_ones := v_num_of_ones + 1;
			end if;
		end loop;
		if(v_num_of_ones = 1) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end function is_one_hot;

	function is_one_cold(data: std_logic_vector) return boolean is
		variable v_num_of_ones	: natural := 0;
		variable ret				: boolean;
	begin
		for i in 0 to data'length-1 loop
			if(data(i) = '1') then
				v_num_of_ones := v_num_of_ones + 1;
			end if;
		end loop;
		if(v_num_of_ones = data'length-1) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end function is_one_cold;

	function is_num_of_ones_gte_x(data: std_logic_vector; num : natural) return boolean is
		variable v_num_of_ones	: natural := 0;
		variable ret				: boolean;
	begin
		for i in 0 to data'length-1 loop
			if(data(i) = '1') then
				v_num_of_ones := v_num_of_ones + 1;
			end if;
		end loop;
		if(v_num_of_ones >= num) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end function is_num_of_ones_gte_x;

	function sub_ge_zero(a: natural; b: natural) return natural is
		variable ret						: natural;
	begin
		if(a >= b) then
			ret := a-b;
		else
			ret := 0;
		end if;
		return ret;
	end function sub_ge_zero;

	function one_hot_2_bin(a: std_logic_vector) return std_logic_vector is
		constant ret_width				: natural := addr_width(a'length);
		variable ret						: std_logic_vector(ret_width-1 downto 0);
	begin
		--ret := to_std_logic_vector(1 + to_natural(log(real(to_natural(a)))/log(real(2))), ret_width);
		ret := to_std_logic_vector(1, ret_width);
		return ret;
	end function one_hot_2_bin;

	function "=" (a : std_logic_vector; b : natural) return boolean is
		variable ret						: boolean;
	begin
		if(to_natural(a) = b) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end "=";

--	function "=" (a : std_logic_vector; b : integer) return boolean is
--		variable ret						: boolean;
--	begin
--		if(to_integer(a) = b) then
--			ret := true;
--		else
--			ret := false;
--		end if;
--		return ret;
--	end "=";

	function "/=" (a : std_logic_vector; b : integer) return boolean is
		variable ret						: boolean;
	begin
		if(to_integer(a) /= b) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end "/=";

	function ">" (a : std_logic_vector; b : natural) return boolean is
		variable ret						: boolean;
	begin
		if(to_natural(a) > b) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end ">";

	function "<" (a : std_logic_vector; b : natural) return boolean is
		variable ret						: boolean;
	begin
		if(to_natural(a) < b) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end "<";

	function ">=" (a : std_logic_vector; b : natural) return boolean is
		variable ret						: boolean;
	begin
		if(to_natural(a) >= b) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end ">=";

	function "<=" (a : std_logic_vector; b : natural) return boolean is
		variable ret						: boolean;
	begin
		if(to_natural(a) <= b) then
			ret := true;
		else
			ret := false;
		end if;
		return ret;
	end "<=";

	function "+" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
		constant c_integer_size					: natural := 8;
		constant c_num_of_full_adds			: natural := div_down(a'length, c_integer_size);
		variable c_last_width					: integer;

		variable r_operand						: natural;
		variable r_operand_slv					: std_logic_vector(c_integer_size+1-1 downto 0);
		variable r_tmp_res						: natural;
		variable r_tmp_res_slv					: std_logic_vector(c_integer_size+1-1 downto 0);

		variable r_result 						: std_logic_vector(a'length-1 downto 0);
		variable r_cout	 						: std_logic;

	begin

		c_last_width := a'length - c_num_of_full_adds*c_integer_size;
		if(c_last_width < 0) then
			c_last_width := 0;
		end if;

		for i in 0 to c_num_of_full_adds-1 loop
			r_tmp_res := to_integer('0' & r_cout);

			--r_operand_slv(c_integer_size-1 downto 0) := a((i+1)*c_integer_size-1 downto i*c_integer_size);
			r_operand_slv(c_integer_size) := '0';
			for x in 0 to c_integer_size-1 loop
				r_operand_slv(x) := a(i*c_integer_size+x);
			end loop;

			r_operand := to_integer('0' & r_operand_slv);
			r_tmp_res := r_tmp_res + r_operand;

			--r_operand_slv := '0' & b((i+1)*c_integer_size-1 downto i*c_integer_size);
			r_operand_slv(c_integer_size) := '0';
			for x in 0 to c_integer_size-1 loop
				r_operand_slv(x) := b(i*c_integer_size+x);
			end loop;
			r_operand := to_integer('0' & r_operand_slv);
			r_tmp_res := r_tmp_res + r_operand;

			r_tmp_res_slv := to_std_logic_vector(r_tmp_res, c_integer_size+1);

			r_result((i+1)*c_integer_size+1-1 downto i*c_integer_size) := r_tmp_res_slv;
			r_cout := r_tmp_res_slv(c_integer_size);
		end loop;

		if(c_num_of_full_adds*c_integer_size < a'length) then
			r_tmp_res := to_integer('0' & r_cout);

			--r_tmp_res := r_tmp_res + to_integer(a(a'length-1 downto c_num_of_full_adds*c_integer_size));
			for x in 0 to c_integer_size+1-1 loop
				r_operand_slv(x) := '0';
			end loop;

			for x in 0 to a'length-(c_num_of_full_adds*c_integer_size)-1 loop
				r_operand_slv(x) := a(c_num_of_full_adds*c_integer_size+x);
			end loop;
			r_operand := to_integer('0' & r_operand_slv);
			r_tmp_res := r_tmp_res + r_operand;

			--r_tmp_res := r_tmp_res + to_integer(b(b'length-1 downto c_num_of_full_adds*c_integer_size));
			for x in 0 to c_integer_size+1-1 loop
				r_operand_slv(x) := '0';
			end loop;

			for x in 0 to a'length-(c_num_of_full_adds*c_integer_size)-1 loop
				r_operand_slv(x) := a(c_num_of_full_adds*c_integer_size+x);
			end loop;
			r_operand := to_integer('0' & r_operand_slv);
			r_tmp_res := r_tmp_res + r_operand;

			r_tmp_res_slv := to_std_logic_vector(r_tmp_res, c_integer_size+1);

			r_result(r_result'length-1 downto r_result'length-c_last_width) := r_tmp_res_slv(c_last_width-1 downto 0);
		end if;

		return r_result;
	end "+";

	function "+" (a : std_logic_vector; b : std_logic) return std_logic_vector is
		variable ret						: std_logic_vector(a'length-1 downto 0);
	begin
		if(b = '1') then
			ret := to_std_logic_vector(to_natural(a) + 1, a'length);
		else
			ret := a;
		end if;
		return ret;
	end "+";

	function "+" (a : std_logic_vector; b : integer) return std_logic_vector is
	begin
		return to_std_logic_vector(to_integer(a) + b, a'length);
	end "+";

	function "-" (a : std_logic_vector; b : std_logic_vector) return std_logic_vector is
	begin
		return to_std_logic_vector(to_integer(a) - to_integer(b), a'length);
	end "-";

	function "-" (a : std_logic_vector; b : std_logic) return std_logic_vector is
		variable ret						: std_logic_vector(a'length-1 downto 0);
	begin
		if(b = '1') then
			ret := to_std_logic_vector(to_natural(a) - 1, a'length);
		else
			ret := a;
		end if;
		return ret;
	end "-";

	function "-" (a : std_logic_vector; b : integer) return std_logic_vector is
	begin
		return to_std_logic_vector(to_integer(a) - b, a'length);
	end "-";

	function "/" (a : natural; b : natural) return natural is
	begin
		return natural(ceil(real(a)/real(b)));
	end "/";

	function div_down(a : natural; b : natural) return natural is
	begin
		return natural(floor(real(a)/real(b)));
	end div_down;

	function div_up(a : natural; b : natural) return natural is
	begin
		return natural(ceil(real(a)/real(b)));
	end div_up;

	function more_than_one_set_bit(v : std_logic_vector) return std_logic is
		variable n			: natural := 0;
		variable r			: std_logic;
	begin
		for i in v'range loop
			if v(i) = '1' then
				n := n + 1;
			end if;
		end loop;
		if(n = 0 or n = 1) then
			r := '0';
		else
			r := '1';
		end if;
		return r;
	end function more_than_one_set_bit;


	function or_reduce(v : std_logic_vector) return std_logic is
		variable v_ret						: std_logic := ieee.std_logic_misc.or_reduce(v);
	begin
		return v_ret;
	end function;


	function and_reduce(v : std_logic_vector) return std_logic is
		variable v_ret						: std_logic := ieee.std_logic_misc.and_reduce(v);
	begin
		return v_ret;
	end function;

end package body my_pack;
