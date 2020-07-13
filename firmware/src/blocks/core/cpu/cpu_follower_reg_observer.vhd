-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    cpu
-- Module Name:    cpu_follower_reg_observer
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.common_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--
--
-------------------------------------------
-------------------------------------------

entity cpu_follower_reg_observer is
generic (
	g_lfsr								: boolean := true;
	g_addr_width						: natural := 9
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_data_last						: in std_logic;
	pi_sign								: in std_logic;
	pi_wr_en								: in std_logic;
	pi_zero								: in std_logic;

	pi_cpu_sign							: in std_logic;
	pi_cpu_update						: in std_logic;
	pi_adder_sign_inverted			: in std_logic;

	po_size								: out std_logic_vector(g_addr_width-1 downto 0);
	po_last								: out std_logic_vector(4 downto 0);
	po_sign								: out std_logic;
	po_zero								: out std_logic;
	po_one								: out std_logic
);
end cpu_follower_reg_observer;

architecture cpu_follower_reg_observer of cpu_follower_reg_observer is

	constant c_tap										: tap_vector := select_tap(g_addr_width);

	signal c_size_one									: std_logic_vector(g_addr_width-1 downto 0);
	signal s_size_all									: std_logic_vector(g_addr_width-1 downto 0);
	signal r_size_all									: std_logic_vector(g_addr_width-1 downto 0);
	signal r_size										: std_logic_vector(g_addr_width-1 downto 0);
	signal s_size_feedback							: std_logic;

	signal r_data_last								: std_logic;

	signal r_last_all									: std_logic_vector(4 downto 0);
	signal r_last										: std_logic_vector(4 downto 0);
	signal r_zero										: std_logic;
	signal r_one										: std_logic;
	signal r_sign										: std_logic;
	signal r_sign_en									: std_logic;

	signal r_adder_sign_inverted						: std_logic;
	signal r_adder_sign_inverted_en					: std_logic;


begin

	po_size <= r_size;
	po_sign <= r_sign;
	po_last <= r_last;
	po_zero <= r_zero;
	po_one <= r_one;



	REGULAR_CNT_GEN: if(g_lfsr = false) generate
		c_size_one <= (others=>'0');
		s_size_all <= r_size_all + 1;
	end generate;

	LFSR_CNT_GEN: if(g_lfsr = true) generate
		c_size_one <= (0=>'1',others=>'0');

		-- REPHRASING: s_up_fifo_plus <= r_cnt_fifo + 1;
		s_size_all <= r_size_all(g_addr_width-2 downto 0) & s_size_feedback;

		MY_SIZE_PLUS_FOUR_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 4) generate
			s_size_feedback <= r_size_all(c_tap(0)-1) xor r_size_all(c_tap(1)-1) xor r_size_all(c_tap(2)-1) xor r_size_all(c_tap(3)-1);
		end generate;

		MY_SIZE_PLUS_TWO_TAP_LFSR_FEEDBACK_GEN: if(c_tap(4) = 2) generate
			s_size_feedback <= r_size_all(c_tap(2)-1) xor r_size_all(c_tap(3)-1);
		end generate;

	end generate;



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------------
			-- R_DATA_LAST --
			-----------------
			if(pi_rst = '1') then
				r_data_last <= '1';
			else

				if(pi_wr_en = '1') then
					r_data_last <= pi_data_last;
				end if;

			end if;


			----------------
			-- R_SIZE_ALL --
			----------------
			if(pi_rst = '1') then
				r_size_all <= c_size_one;
				r_last_all <= (0=>'1',others=>'0');
			else
				if(pi_wr_en = '1' and pi_data_last = '1') then
					r_size_all <= c_size_one;
					r_last_all <= (0=>'1',others=>'0');
				elsif(pi_wr_en = '1') then
					r_size_all <= s_size_all;
					r_last_all <= r_last_all(r_last_all'length-2 downto 0) & '0';
				end if;
			end if;


			------------
			-- R_SIZE --
			------------
			if(pi_rst = '1') then
				r_size <= c_size_one;
				r_last <= (0=>'1',others=>'0');
			else
				if((pi_wr_en = '1' and r_data_last = '1') or 		-- first value
					(pi_wr_en = '1' and pi_zero = '0')) then			-- proper value
					r_size <= r_size_all;
					r_last <= r_last_all;
				end if;
			end if;


			------------
			-- R_ZERO --
			------------
			if(pi_rst = '1') then
				r_zero <= '1';
			else

				if(pi_wr_en = '1' and r_data_last = '1' and pi_zero = '1') then 		-- first value
					r_zero <= '1';
				elsif(pi_wr_en = '1' and pi_zero = '0') then
					r_zero <= '0';
				end if;

			end if;


--			------------
--			-- R_SIGN --
--			------------
--			if(pi_rst = '1') then
--				r_sign <= '0';
--			else
--
--				if(r_sign_update_en = '1') then
--
--					if(pi_cpu_update = '1') then
--						r_sign <= pi_cpu_sign;
--					elsif(pi_data_last = '1') then			-- LOADER/ADD/SUB/MULT
--						r_sign <= pi_sign;
--					end if;
--
--				end if;
--
--			end if;
--
--
--			----------------------
--			-- R_SIGN_UPDATE_EN --
--			----------------------
--			if(pi_rst = '1') then
--				r_sign_update_en <= '1';
--			else
--
--				if(pi_data_last = '1') then
--					r_sign_update_en <= '1';
--				elsif(pi_cpu_update = '1') then
--					r_sign_update_en <= '0';
--				end if;
--
--			end if;


			------------
			-- R_SIGN --
			------------
			if(pi_rst = '1') then
				r_sign <= '0';
			else

				if(r_sign_en = '1') then

					if(pi_cpu_update = '1') then
						r_sign <= pi_cpu_sign;
					elsif(r_adder_sign_inverted = '0' and pi_data_last = '1') then			-- LOADER/ADD(regular)/SUB(regular)/MULT
						r_sign <= pi_sign;
					elsif(r_adder_sign_inverted = '1' and pi_data_last = '1') then			-- ADD(inverted)/SUB(inverted)
						r_sign <= not pi_sign;
					end if;

				end if;

			end if;


			---------------
			-- R_SIGN_EN --
			---------------
			if(pi_rst = '1') then
				r_sign_en <= '1';
			else
				if(pi_data_last = '1') then
					r_sign_en <= '1';
				elsif(pi_cpu_update = '1') then
					r_sign_en <= '0';
				end if;

			end if;


			---------------------------
			-- R_ADDER_SIGN_INVERTED --
			---------------------------
			if(pi_rst = '1') then
				r_adder_sign_inverted <= '0';
			else

				if(r_adder_sign_inverted_en = '1') then
					if(pi_adder_sign_inverted = '1') then
						r_adder_sign_inverted <= '1';
					elsif(pi_wr_en = '1') then
						r_adder_sign_inverted <= '0';
					end if;
				end if;
			end if;


			------------------------------
			-- R_ADDER_SIGN_INVERTED_EN --
			------------------------------
			if(pi_rst = '1') then
				r_adder_sign_inverted_en <= '1';
			else

				if(pi_adder_sign_inverted = '1' or (pi_wr_en = '1' and pi_data_last = '0')) then
					r_adder_sign_inverted_en <= '0';
				elsif(pi_data_last = '1') then
					r_adder_sign_inverted_en <= '1';
				end if;

			end if;

		end if;
	end process;

end architecture;
