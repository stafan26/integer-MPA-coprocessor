-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_follower_data_last_switchbox
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity cpu_follower_data_last_switchbox is
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_reg_mode_start					: in std_logic;
	pi_reg_mode_B						: in std_logic;
	pi_reg_mode_aux					: in std_logic;
	pi_reg_mode							: in std_logic_vector(2 downto 0);

	pi_loader_A_wr_en					: in std_logic;
	pi_loader_A_data_last			: in std_logic;
	pi_loader_A_sign					: in std_logic;

	pi_loader_B_wr_en					: in std_logic;
	pi_loader_B_data_last			: in std_logic;
	pi_loader_B_sign					: in std_logic;

	pi_adder_wr_en						: in std_logic;
	pi_adder_data_last				: in std_logic;
	pi_adder_zero						: in std_logic_vector(1 downto 0);
	pi_adder_all_ones					: in std_logic;

	pi_mult_wr_en						: in std_logic;
	pi_mult_data_last					: in std_logic;
	pi_mult_zero						: in std_logic;

	pi_set_zero							: in std_logic;
	pi_set_one							: in std_logic;
	pi_set_zero_or_one				: in std_logic;

	po_wr_en								: out std_logic;
	po_data_last						: out std_logic;
	po_sign								: out std_logic;
	po_zero								: out std_logic
);
end cpu_follower_data_last_switchbox;

architecture cpu_follower_data_last_switchbox of cpu_follower_data_last_switchbox is

	signal r_reg_mode							: std_logic_vector(2 downto 0);

	signal r_wr_en								: std_logic;
	signal r_loader_wr_en					: std_logic;

	signal r_data_last						: std_logic;
	signal r_loader_data_last				: std_logic;
	signal r_sign								: std_logic;
	signal r_loader_sign						: std_logic;

	signal r_zero								: std_logic;

begin

	po_wr_en <= r_wr_en;									--: out std_logic;
	po_data_last <= r_data_last;						--: out std_logic;
	po_sign <= r_sign;									--: out std_logic;
	po_zero <= r_zero;									--: out std_logic;


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			----------------
			-- R_REG_MODE --
			----------------
			if(pi_rst = '1') then
				r_reg_mode <= (others=>'0');
			else

				if(pi_reg_mode_start = '1' and pi_reg_mode_aux = '1') then
					r_reg_mode <= "111";
				elsif(pi_reg_mode_start = '1' and pi_reg_mode_B = '1') then
					r_reg_mode <= "011";
				elsif(pi_reg_mode_start = '1' and pi_reg_mode_B = '0') then
					r_reg_mode <= pi_reg_mode;
				elsif(r_data_last = '1') then
					r_reg_mode <= (others=>'0');
				end if;

			end if;


			--------------------
			-- R_LOADER_WR_EN --
			--------------------
			if(pi_rst = '1') then
				r_loader_wr_en <= '0';
			else

				case r_reg_mode(0) is
					when '0' => 		r_loader_wr_en <= pi_loader_A_wr_en;
					when '1' => 		r_loader_wr_en <= pi_loader_B_wr_en;
					when others =>		r_loader_wr_en <= '0';
				end case;

			end if;


			-------------
			-- R_WR_EN --
			-------------
			if(pi_rst = '1') then
				r_wr_en <= '0';
			else

				if(pi_set_zero_or_one = '1') then
					r_wr_en <= '1';
				else
					case r_reg_mode(2 downto 1) is
						when "01" => 		r_wr_en <= r_loader_wr_en;
						when "10" => 		r_wr_en <= pi_mult_wr_en;
						when "11" => 		r_wr_en <= pi_adder_wr_en;
						when others =>		r_wr_en <= '0';
					end case;
				end if;

			end if;

			------------------------
			-- R_LOADER_DATA_LAST --
			------------------------
			if(pi_rst = '1') then
				r_loader_data_last <= '0';
			else

				case r_reg_mode(0) is
					when '0' => 		r_loader_data_last <= pi_loader_A_data_last;
					when '1' => 		r_loader_data_last <= pi_loader_B_data_last;
					when others => 	r_loader_data_last <= '0';
				end case;

			end if;

			-----------------
			-- R_DATA_LAST --
			-----------------
			if(pi_rst = '1') then
				r_data_last <= '0';
			else

				if(pi_set_zero_or_one = '1') then
					r_data_last <= '1';
				else
					case r_reg_mode(2 downto 1) is
						when "01" => 		r_data_last <= r_loader_data_last;
						when "10" => 		r_data_last <= pi_mult_data_last;
						when "11" => 		r_data_last <= pi_adder_data_last;
						when others =>		r_data_last <= '0';
					end case;
				end if;

			end if;


			-------------------
			-- R_LOADER_SIGN --
			-------------------
			case r_reg_mode(0) is
				when '0' => 			r_loader_sign <= pi_loader_A_sign;
				when '1' => 			r_loader_sign <= pi_loader_B_sign;
				when others => 		r_loader_sign <= '0';
			end case;


			------------
			-- R_SIGN --
			------------
			if(pi_set_zero_or_one = '1') then
				r_sign <= '0';
			else
				case r_reg_mode(2 downto 1) is
					when "01" => 			r_sign <= r_loader_sign;
					when "11" => 			r_sign <= pi_adder_all_ones;
					when others => 		r_sign <= '0';
				end case;
			end if;

			------------
			-- R_ZERO --
			------------
			if(pi_rst = '1') then
				r_zero <= '0';
			else

				if(pi_set_zero = '1') then
					r_zero <= '1';
				else
					case r_reg_mode is
						when "100" => 		r_zero <= pi_mult_zero;
						when "110" => 		r_zero <= pi_adder_zero(0);
						when "111" => 		r_zero <= pi_adder_zero(1);
						when others =>		r_zero <= '0';
					end case;
				end if;

			end if;

		end if;
	end process;

end architecture;
