-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    reg_ctrl
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library UNISIM;
use UNISIM.vcomponents.all;

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

entity reg_ctrl is
generic (
	g_id									: natural := 10;
	g_addr_width						: natural := 11;
	g_ctrl_width						: natural := 8
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_ctrl_ch_1						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_ch_1_valid_n				: in std_logic;
	pi_ctrl_ch_2						: in std_logic_vector(g_ctrl_width-1 downto 0);
	pi_ctrl_ch_2_valid_n				: in std_logic;

	po_cmc_channel						: out std_logic;
	po_operand_B						: out std_logic;
	po_addr_up_down					: out std_logic;
	po_select							: out std_logic_vector(2 downto 0);
	po_start_rd							: out std_logic;
	po_start_wr							: out std_logic;
	po_select_hi_lo					: out std_logic;
	po_set_zero							: out std_logic;
	po_set_one							: out std_logic
);
end reg_ctrl;

architecture reg_ctrl of reg_ctrl is

	signal r_id_ch_1_recognized						: std_logic;
	signal r_id_ch_2_recognized						: std_logic;

	signal r_write_ch_1_stream							: std_logic;
	signal r_write_ch_2_stream							: std_logic;

	signal s_hi_lo_ch_1									: std_logic;
	signal s_hi_lo_ch_2									: std_logic;
	signal s_set_one_ch_1								: std_logic;
	signal s_set_one_ch_2								: std_logic;
	signal s_set_zero_ch_1								: std_logic;
	signal s_set_zero_ch_2								: std_logic;

	signal r_set_active_ch_1_stream					: std_logic;
	signal r_set_active_ch_2_stream					: std_logic;
	signal r_write_set_not_active_ch_1_stream		: std_logic;
	signal r_write_set_not_active_ch_2_stream		: std_logic;
	signal r_cmc_channel									: std_logic;
	signal r_operand_B									: std_logic;
	signal r_addr_up_down								: std_logic;
	signal r_read_cmc_on									: std_logic;
	signal r_read_cmc_ch_1								: std_logic;
	signal r_read_cmc_ch_2								: std_logic;

	signal r_select_ch_1									: std_logic;
	signal r_select_ch_2									: std_logic;
	signal r_select										: std_logic_vector(2 downto 0);
	signal r_select_ch_1_stream						: std_logic_vector(2 downto 0);
	signal r_select_ch_2_stream						: std_logic_vector(2 downto 0);
	signal r_start_rd										: std_logic;
	signal r_start_wr										: std_logic;

	signal s_addr_up_down_ch_1							: std_logic;
	signal s_addr_up_down_ch_2							: std_logic;

begin

	po_cmc_channel	<= r_cmc_channel;
	po_operand_B <= r_operand_B;
	po_addr_up_down <= r_addr_up_down;
	po_select <= r_select;
	po_start_rd <= r_start_rd;
	po_start_wr <= r_start_wr;

	s_hi_lo_ch_1 <= pi_ctrl_ch_1(C_STD_REG_HI_LO);
	s_hi_lo_ch_2 <= pi_ctrl_ch_2(C_STD_REG_HI_LO);
	s_set_one_ch_1 <= pi_ctrl_ch_1(C_STD_REG_SET_ONE);
	s_set_one_ch_2 <= pi_ctrl_ch_2(C_STD_REG_SET_ONE);
	s_set_zero_ch_1 <= pi_ctrl_ch_1(C_STD_REG_SET_ZERO);
	s_set_zero_ch_2 <= pi_ctrl_ch_2(C_STD_REG_SET_ZERO);


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			--------------------------
			-- R_ID_CH_1_RECOGNIZED --
			--------------------------
			if(pi_ctrl_ch_1_valid_n = '1') then
				r_id_ch_1_recognized <= '0';
			else
				if(pi_ctrl_ch_1(C_STD_ID_ADDR_HI downto C_STD_ID_ADDR_LO) = to_std_logic_vector(g_id, C_STD_ID_SIZE)) then
					r_id_ch_1_recognized <= '1';
				else
					r_id_ch_1_recognized <= '0';
				end if;
			end if;


			--------------------------
			-- R_ID_CH_2_RECOGNIZED --
			--------------------------
			if(pi_ctrl_ch_2_valid_n = '1') then
				r_id_ch_2_recognized <= '0';
			else
				if(pi_ctrl_ch_2(C_STD_ID_ADDR_HI downto C_STD_ID_ADDR_LO) = to_std_logic_vector(g_id, C_STD_ID_SIZE)) then
					r_id_ch_2_recognized <= '1';
				else
					r_id_ch_2_recognized <= '0';
				end if;
			end if;


			------------
			-- STREAM --
			------------
			r_write_ch_1_stream <= pi_ctrl_ch_1(C_STD_REG_WRITE);
			r_write_ch_2_stream <= pi_ctrl_ch_2(C_STD_REG_WRITE);
			r_set_active_ch_1_stream <= pi_ctrl_ch_1(C_STD_REG_WRITE) and pi_ctrl_ch_1(C_STD_REG_CMC_CHANNEL_ADDR);
			r_set_active_ch_2_stream <= pi_ctrl_ch_2(C_STD_REG_WRITE) and pi_ctrl_ch_2(C_STD_REG_CMC_CHANNEL_ADDR);
			r_write_set_not_active_ch_1_stream <= pi_ctrl_ch_1(C_STD_REG_WRITE) and not pi_ctrl_ch_1(C_STD_REG_CMC_CHANNEL_ADDR);
			r_write_set_not_active_ch_2_stream <= pi_ctrl_ch_2(C_STD_REG_WRITE) and not pi_ctrl_ch_2(C_STD_REG_CMC_CHANNEL_ADDR);
			r_select_ch_1_stream <= pi_ctrl_ch_1(C_STD_REG_SELECT_ADDR+3-1 downto C_STD_REG_SELECT_ADDR);
			r_select_ch_2_stream <= pi_ctrl_ch_2(C_STD_REG_SELECT_ADDR+3-1 downto C_STD_REG_SELECT_ADDR);


			---------------------
			-- R_READ_CMC_CH_1 --
			---------------------
			r_read_cmc_ch_1 <= pi_ctrl_ch_1(C_STD_REG_CMC_CHANNEL_ADDR);


			---------------------
			-- R_READ_CMC_CH_1 --
			---------------------
			r_read_cmc_ch_2 <= pi_ctrl_ch_2(C_STD_REG_CMC_CHANNEL_ADDR);


			-------------------
			-- R_READ_CMC_ON --
			-------------------
			if(pi_ctrl_ch_1(C_STD_REG_WRITE) = '0' or pi_ctrl_ch_2(C_STD_REG_WRITE) = '0') then
				r_read_cmc_on <= '1';
			else
				r_read_cmc_on <= '0';
			end if;

		end if;
	end process;


	-----------
	-- WRITE --
	-----------
	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			---------------------
			-- PO_SELECT_HI_LO --
			---------------------
			if((r_id_ch_1_recognized = '1' and r_write_set_not_active_ch_1_stream = '1' and s_hi_lo_ch_1 = '1') or (r_id_ch_2_recognized = '1' and r_write_set_not_active_ch_2_stream = '1' and s_hi_lo_ch_2 = '1')) then
				po_select_hi_lo <= '1';
			else
				po_select_hi_lo <= '0';
			end if;


			-----------------
			-- PO_SET_ZERO --
			-----------------
			if((r_id_ch_1_recognized = '1' and r_set_active_ch_1_stream = '1' and s_set_zero_ch_1 = '1') or (r_id_ch_2_recognized = '1' and r_set_active_ch_2_stream = '1' and s_set_zero_ch_2 = '1')) then
				po_set_zero <= '1';
			else
				po_set_zero <= '0';
			end if;


			----------------
			-- PO_SET_ONE --
			----------------
			if((r_id_ch_1_recognized = '1' and r_set_active_ch_1_stream = '1' and s_set_one_ch_1 = '1') or (r_id_ch_2_recognized = '1' and r_set_active_ch_2_stream = '1' and s_set_one_ch_2 = '1')) then
				po_set_one <= '1';
			else
				po_set_one <= '0';
			end if;


			----------------
			-- R_START_WR --			4
			----------------
			if((r_id_ch_1_recognized = '1' and r_write_set_not_active_ch_1_stream = '1') or (r_id_ch_2_recognized = '1' and r_write_set_not_active_ch_2_stream = '1')) then
				r_start_wr <= '1';
			else
				r_start_wr <= '0';
			end if;


			-------------------
			-- R_SELECT_CH_1 --		4
			-------------------
			if(r_id_ch_1_recognized = '1' and r_write_set_not_active_ch_1_stream = '1') then
				r_select_ch_1 <= '1';
			else
				r_select_ch_1 <= '0';
			end if;


			-------------------
			-- R_SELECT_CH_2 --		4
			-------------------
			if(r_id_ch_2_recognized = '1' and r_write_set_not_active_ch_2_stream = '1') then
				r_select_ch_2 <= '1';
			else
				r_select_ch_2 <= '0';
			end if;


			--------------
			-- R_SELECT --			4+1
			--------------
			-- one extra clk cycle delay added by r_select_ch_x in order to reduce logic levels
			if(pi_rst = '1') then
				r_select <= (others=>'0');
			else
				if(r_select_ch_1 = '1') then
					r_select <= r_select_ch_1_stream;
				elsif(r_select_ch_2 = '1') then
					r_select <= r_select_ch_2_stream;
				end if;
			end if;

		end if;
	end process;


	s_addr_up_down_ch_1 <= pi_ctrl_ch_1(C_STD_REG_ADDR_UP_DOWN);
	s_addr_up_down_ch_2 <= pi_ctrl_ch_2(C_STD_REG_ADDR_UP_DOWN);


	----------
	-- READ --
	----------
	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			----------------
			-- R_START_RD --			4
			----------------
			if(r_id_ch_1_recognized = '1' and r_write_ch_1_stream = '0') then
				r_start_rd <= '1';
			elsif(r_id_ch_2_recognized = '1' and r_write_ch_2_stream = '0') then
				r_start_rd <= '1';
			else
				r_start_rd <= '0';
			end if;


			-------------------
			-- R_CMC_CHANNEL --			5+1
			-------------------
			if((r_id_ch_1_recognized = '1' and r_read_cmc_on = '1' and r_read_cmc_ch_1 = '0') or (r_id_ch_2_recognized = '1' and r_read_cmc_on = '1' and r_read_cmc_ch_2 = '0')) then
				r_cmc_channel <= '0';
			elsif((r_id_ch_1_recognized = '1' and r_read_cmc_on = '1' and r_read_cmc_ch_1 = '1') or (r_id_ch_2_recognized = '1' and r_read_cmc_on = '1' and r_read_cmc_ch_2 = '1')) then
				r_cmc_channel <= '1';
			end if;


			-----------------
			-- R_OPERAND_B --			4+1
			-----------------
			if(r_id_ch_1_recognized = '1' and r_write_ch_1_stream = '0') then
				r_operand_B <= '0';
			elsif(r_id_ch_2_recognized = '1' and r_write_ch_2_stream = '0') then
				r_operand_B <= '1';
			end if;


			--------------------
			-- R_ADDR_UP_DOWN --			6+1
			--------------------
			if(r_id_ch_1_recognized = '1' and r_write_ch_1_stream = '0') then
				r_addr_up_down <= s_addr_up_down_ch_1;
			elsif(r_id_ch_2_recognized = '1' and r_write_ch_2_stream = '0') then
				r_addr_up_down <= s_addr_up_down_ch_2;
			end if;

		end if;
	end process;

end architecture;
