-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    30/4/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    multiplier_TB
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

entity multiplier_TB is
end multiplier_TB;

architecture multiplier_TB of multiplier_TB is

	constant c_data_width								: natural := 64;
	constant c_addr_width								: natural := 9;
	constant c_ctrl_width								: natural := 8;
	constant c_select_width								: natural := 5;
	constant c_id											: natural := 2;

	signal r_clk											: std_logic;
	signal r_rst											: std_logic;

	signal s_ctrl_A										: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s_ctrl_B										: std_logic_vector(c_ctrl_width-1 downto 0);
	signal s_ctrl_valid									: std_logic;

	signal s_data_A										: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_B										: std_logic_vector(c_data_width-1 downto 0);

	signal s_data_A_ref									: std_logic_vector(c_data_width-1 downto 0);
	signal s_data_B_ref									: std_logic_vector(c_data_width-1 downto 0);

	signal s_data_A_and_B_last							: std_logic;

	signal s_data_A_wr_en								: std_logic;
	signal r_data_A_wr_en								: std_logic;
	signal s_data_A_cycle								: std_logic;
	signal r_data_A_cycle								: std_logic;
	signal r_data_A_cycle_prev							: std_logic;

	signal r_cycle_up_done								: std_logic;
	signal r_cycle_flat_done							: std_logic;
	signal r_cycle_down_done							: std_logic;
	signal r_cnt_cycle_up								: natural;
	signal r_cnt_cycle_up_border						: natural;
	signal r_cnt_cycle_flat								: natural;
	signal r_cnt_cycle_down								: natural;
	signal r_cnt_cycle_down_border					: natural;
	signal r_cnt_total_gr								: natural;
	signal r_cnt_total_all								: natural;

	signal r_data_last									: std_logic;

	signal s_out_data										: std_logic_vector(c_data_width-1 downto 0);
	signal s_out_data_last								: std_logic;
	signal s_out_data_wr_en								: std_logic;
	signal s_out_data_zero								: std_logic;

	signal r_cnt											: natural;
	signal r_cnt_index_A									: natural;
	signal r_cnt_index_A_init							: natural;
	signal r_cnt_index_B									: natural;
	signal r_cnt_index_B_init							: natural;

	constant c_data_A_width								: natural := 1;
	constant c_data_B_width								: natural := 1;

	constant c_data_A_max_width								: natural := 511;
	constant c_data_B_max_width								: natural := 511;

	constant c_data_sm									: natural := lesser_num(c_data_A_width, c_data_B_width);
	constant c_data_gt									: natural := greater_num(c_data_A_width, c_data_B_width);

	type t_data_A is array (0 to c_data_A_max_width-1) of std_logic_vector(c_data_width-1 downto 0);
	type t_data_B is array (0 to c_data_B_max_width-1) of std_logic_vector(c_data_width-1 downto 0);


	constant c_data_A										: t_data_A := (0=>x"0000000000000002",
																					others=>(others=>'0'));

	constant c_data_B										: t_data_B := (0=>x"0000000000000003",
																					others=>(others=>'0'));


--	constant c_data_A										: t_data_A := (0=>x"9856985623975829",
--																				1=>x"1409321583325438",
--																				2=>x"1342564367543543");
--
--	constant c_data_B										: t_data_B := (0=>x"4389856985623975",
--																				1=>x"5431409321583325");

--data_A = x"1342564367543543" & x"1409321583325438" & x"9856985623975829";
--data_B = x"5431409321583325" & x"4389856985623975";

--res_AB = x"065578DC47F8FAE6" & x"F36D2EF952907C97" & x"20BFC1376C3148CE" &
--         x"BC28FB1B3C2B32E4" & x"1BC783D9037E6BBD";


	signal s_data					: t_data_x1;

begin

	process
	begin
		r_clk <= '1';
		wait for 5ns;
		r_clk <= '0';
		wait for 5ns;
	end process;

	process
	begin
		r_rst <= '1';
		wait for 500ns;
		r_rst <= '0';
		wait;
	end process;


	MULTIPLIER_INST: entity work.multiplier generic map (
		g_data_width				=> c_data_width,					--: natural := 64;
		g_addr_width				=> c_addr_width,					--: natural := 9;
		g_ctrl_width				=> c_ctrl_width,					--: natural := 8;
		g_select_width				=> c_select_width,				--: natural := 4;
		g_id							=> c_id								--: natural := 2
	)
	port map (
		pi_clk						=> r_clk,							--: in std_logic;
		pi_rst						=> r_rst,							--: in std_logic;
		pi_ctrl_ch_A				=> s_ctrl_A,						--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_ch_B				=> s_ctrl_B,						--: in std_logic_vector(g_ctrl_width-1 downto 0);
		pi_ctrl_valid_n			=> s_ctrl_valid,					--: in std_logic_vector(g_ctrl_width-1 downto 0);

		pi_data						=> s_data,							--: in t_data_x1;
		pi_data_last				=> s_data_A_and_B_last,			--: in std_logic;
		pi_data_wr_en				=> s_data_A_wr_en,				--: in std_logic;
		pi_data_cycle				=> s_data_A_cycle,				--: in std_logic;

		po_data						=> s_out_data						--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> s_out_data_last,				--: out std_logic;
		po_data_wr_en				=> s_out_data_wr_en,				--: out std_logic;
		po_data_zero				=> s_out_data_zero				--: out std_logic
	);


	s_data(0)			<= s_data_B;
	s_data(4)			<= s_data_A;



	process(r_clk)
	begin
		if(rising_edge(r_clk)) then
			if(r_rst = '1') then
				r_cnt <= 0;
			else
				if(r_cnt < 10) then
					r_cnt <= r_cnt + 1;
				end if;
			end if;
		end if;
	end process;


	s_ctrl_A <= to_std_logic_vector(c_id, 8) when r_cnt = 2 else
					x"04" when r_cnt = 3 else
					(others=>'0');

	s_ctrl_B <= to_std_logic_vector(c_id, 8) when r_cnt = 2 else
					x"00" when r_cnt = 3 else
					(others=>'0');

	s_ctrl_valid <= '0' when r_cnt = 2 else
					'1';


	s_data_A_ref <= c_data_A(0) when r_cnt = 4 else
					(others=>'0');

	s_data_B_ref <= c_data_B(0) when r_cnt = 4 else
					(others=>'0');


--	s_data_A_ref <= c_data_A(0) when r_cnt = 4 else
--					c_data_A(0) when r_cnt = 5 else
--					c_data_A(1) when r_cnt = 6 else
--					c_data_A(1) when r_cnt = 7 else
--					c_data_A(2) when r_cnt = 8 else
--					c_data_A(2) when r_cnt = 9 else
--					(others=>'0');
--
--	s_data_B_ref <= c_data_B(0) when r_cnt = 4 else
--					c_data_B(1) when r_cnt = 5 else
--					c_data_B(0) when r_cnt = 6 else
--					c_data_B(1) when r_cnt = 7 else
--					c_data_B(0) when r_cnt = 8 else
--					c_data_B(1) when r_cnt = 9 else
--					(others=>'0');

--	s_data_A_and_B_last <= '1' when r_cnt = 9 else '0';
--
--	s_data_A_wr_en <= '1' when r_cnt = 4 else
--							'1' when r_cnt = 5 else
--							'1' when r_cnt = 6 else
--							'1' when r_cnt = 7 else
--							'1' when r_cnt = 8 else
--							'1' when r_cnt = 9 else
--							'0';
--
--	s_data_A_cycle <= '1' when r_cnt = 4 else
--							'1' when r_cnt = 5 else
--							'0' when r_cnt = 6 else
--							'1' when r_cnt = 7 else
--							'0' when r_cnt = 8 else
--							'1' when r_cnt = 9 else
--							'0';

--	s_data_A <= c_data_A(0);
--	s_data_B <= c_data_B(0);

--	s_data_A <= c_data_A(r_cnt_index_A) when r_data_A_wr_en = '1' else (others=>'0');
--	s_data_B <= c_data_B(r_cnt_index_B) when r_data_A_wr_en = '1' else (others=>'0');
	s_data_A <= c_data_A(r_cnt_index_A);
	s_data_B <= c_data_B(r_cnt_index_B);
	s_data_A_and_B_last <= r_data_last;
	s_data_A_wr_en <= r_data_A_wr_en;
	s_data_A_cycle <= r_data_A_cycle_prev;

	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			r_data_last <= '0';
			if(r_data_last = '1') then
				r_data_A_cycle_prev <= '0';
			else
				r_data_A_cycle_prev <= r_data_A_cycle;
			end if;

			if(r_rst = '1' or r_data_last = '1') then
				r_data_A_wr_en <= '0';
			elsif(r_cnt > 2 and (r_cycle_up_done = '0' or r_cycle_flat_done = '0' or r_cycle_down_done = '0')) then
				r_data_A_wr_en <= '1';
			end if;

			if(r_rst = '1') then
				r_data_A_cycle <= '0';
				r_cycle_up_done <= '0';
				r_cnt_cycle_up <= 0;
				r_cnt_cycle_up_border <= 0;
				r_cnt_total_gr <= 1;
				r_cnt_total_all <= 1;

				r_cnt_cycle_flat <= 0;

				r_cnt_cycle_down <= 0;
				r_cnt_cycle_down_border <= c_data_sm - 1;

				if(c_data_sm = c_data_gt) then
					r_cycle_flat_done <= '0';
				else
					r_cycle_flat_done <= '1';
				end if;

				if(c_data_sm > 1) then
					r_cycle_down_done <= '0';
				else
					r_cycle_down_done <= '1';
				end if;

			else

				r_data_A_cycle <= '0';

				if(r_cnt = 2) then			-- zamienic na r_start_1 i r_start_2
					r_data_A_cycle <= '1';
				elsif(r_cnt > 2) then

					r_cnt_total_all <= r_cnt_total_all + 1;

					--------
					-- UP --
					--------
					if(r_cycle_up_done = '0') then
						if(r_cnt_cycle_up = r_cnt_cycle_up_border) then
							r_data_A_cycle <= '1';
							r_cnt_total_gr <= r_cnt_total_gr + 1;
							r_cnt_cycle_up <= 0;
							r_cnt_cycle_up_border <= r_cnt_cycle_up_border + 1;
							if(c_data_sm-1 = r_cnt_cycle_up_border) then
								r_cycle_up_done <= '1';
							end if;
						else
							r_cnt_cycle_up <= r_cnt_cycle_up + 1;
						end if;
					end if;

					----------
					-- FLAT --
					----------
					if(r_cycle_up_done = '1' and r_cycle_flat_done = '0') then
						if(r_cnt_cycle_flat = c_data_sm) then
							r_cnt_total_gr <= r_cnt_total_gr + 1;
							r_data_A_cycle <= '1';
							r_cnt_cycle_flat <= 0;
							if(r_cnt_total_gr = c_data_gt) then
								r_cycle_flat_done <= '1';
							end if;
						else
							r_cnt_cycle_flat <= r_cnt_cycle_flat + 1;
						end if;
					end if;


					----------
					-- DOWN --
					----------
					if(r_cycle_up_done = '1' and r_cycle_flat_done = '1' and r_cycle_down_done = '0') then
						if(r_cnt_cycle_down = r_cnt_cycle_down_border) then
							r_cnt_total_gr <= r_cnt_total_gr + 1;
							r_data_A_cycle <= '1';
							r_cnt_cycle_down <= 0;
							r_cnt_cycle_down_border <= r_cnt_cycle_down_border - 1;
							if(r_cnt_total_all = c_data_A_width * c_data_B_width) then
								r_data_last <= '1';
							end if;
							if(r_cnt_cycle_down_border = 0) then
								r_cycle_down_done <= '1';
							end if;
						else
							r_cnt_cycle_down <= r_cnt_cycle_down + 1;
						end if;
					end if;

				end if;
			end if;

		end if;
	end process;


	process(r_clk)
	begin
		if(rising_edge(r_clk)) then

			-------------------
			-- R_CNT_INDEX_A --
			-------------------
			if(r_rst = '1') then
				r_cnt_index_A <= 0;
				r_cnt_index_A_init <= 0;
			else

				if(r_data_A_wr_en = '1') then
					if(r_data_A_cycle = '1') then
						r_cnt_index_A <= r_cnt_index_A_init;
						if(r_cnt_index_A_init < c_data_A_width-1) then
							r_cnt_index_A_init <= r_cnt_index_A_init + 1;
						end if;
					elsif(r_cnt_index_A < c_data_A_width) then
						r_cnt_index_A <= r_cnt_index_A + 1;
					end if;
				end if;

			end if;


			-------------------
			-- R_CNT_INDEX_B --
			-------------------
			if(r_rst = '1') then
				r_cnt_index_B <= 0;
				r_cnt_index_B_init <= 1;
			else

				if(r_data_A_wr_en = '1') then
					if(r_data_A_cycle = '1' and r_cnt_index_B_init < c_data_B_width-1) then
						r_cnt_index_B_init <= r_cnt_index_B_init + 1;
					end if;

					if(r_data_A_cycle = '1') then
						r_cnt_index_B <= r_cnt_index_B_init;
					else
						r_cnt_index_B <= r_cnt_index_B - 1;
					end if;

				end if;
			end if;

		end if;
	end process;

end architecture;
