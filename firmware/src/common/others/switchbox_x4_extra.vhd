-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    switchbox_x4_extra
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
-------------------------------------------
-------------------------------------------

entity switchbox_x4_extra is
generic (
	g_output_data_last				: string := "YES";
	g_data_width						: natural := 64;
	g_extra_width						: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_select							: in std_logic_vector(1 downto 0);
	pi_start								: in std_logic;

	pi_data_ch_1						: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_ch_2						: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_ch_3						: in std_logic_vector(g_data_width-1 downto 0);
	pi_data_ch_4						: in std_logic_vector(g_data_width-1 downto 0);

	pi_data_last_ch_1					: in std_logic;
	pi_data_last_ch_2					: in std_logic;
	pi_data_last_ch_3					: in std_logic;
	pi_data_last_ch_4					: in std_logic;

	pi_data_extra_ch_1				: in std_logic_vector(g_extra_width-1 downto 0);
	pi_data_extra_ch_2				: in std_logic_vector(g_extra_width-1 downto 0);
	pi_data_extra_ch_3				: in std_logic_vector(g_extra_width-1 downto 0);
	pi_data_extra_ch_4				: in std_logic_vector(g_extra_width-1 downto 0);

	po_data								: out std_logic_vector(g_data_width-1 downto 0);
	po_data_last						: out std_logic;
	po_data_extra						: out std_logic_vector(g_extra_width-1 downto 0)
);
end switchbox_x4_extra;

architecture switchbox_x4_extra of switchbox_x4_extra is

	signal r_rst											: std_logic;

	signal r_ctrl_on										: std_logic;
	signal s_data											: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_last									: std_logic;
	signal s_data_extra									: std_logic_vector(g_extra_width-1 downto 0);

begin


	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------
			-- R_RST --
			-----------
			if(pi_rst = '1') then
				r_rst <= '1';
			else

				if((pi_data_last_ch_1 = '1' and pi_select = "00") or
				(pi_data_last_ch_2 = '1' and pi_select = "01") or
				(pi_data_last_ch_3 = '1' and pi_select = "10") or
				(pi_data_last_ch_4 = '1' and pi_select = "11") ) then
					r_rst <= '1';
				else
					r_rst <= '0';
				end if;

			end if;


			---------------
			-- R_CTRL_ON --
			---------------
			if(r_rst = '1') then
				r_ctrl_on <= '1';
			else

				if(pi_start = '1') then
					r_ctrl_on <= '0';
				end if;

			end if;

		end if;
	end process;



							-------------
							-- OUTPUTS --
							-------------
	PI_DATA_GEN: for i in 0 to g_data_width-1 generate

		DATA_LUT6_L_INST : LUT6_L generic map (
			INIT => X"FF00F0F0CCCCAAAA"
		) -- Specify LUT contents
		port map (
			LO		=> s_data(i),				-- LUT local output
			I0		=> pi_data_ch_1(i),		-- LUT input
			I1		=> pi_data_ch_2(i),		-- LUT input
			I2		=> pi_data_ch_3(i),		-- LUT input
			I3		=> pi_data_ch_4(i),		-- LUT input
			I4		=> pi_select(0),			-- LUT input
			I5		=> pi_select(1)			-- LUT input
		);

		DATA_FDRE_INST: FDRE generic map (
			INIT	=> '0'
		)
		port map (
			Q		=> po_data(i),
			C		=> pi_clk,
			CE		=> '1',
			R		=> '0',
			D		=> s_data(i)
		);

	end generate;


	PI_DATA_EXTRA_GEN: for i in 0 to g_extra_width-1 generate

		DATA_EXTRA_LUT6_L_INST : LUT6_L generic map (
			INIT => X"FF00F0F0CCCCAAAA"
		) -- Specify LUT contents
		port map (
			LO		=> s_data_extra(i),				-- LUT local output
			I0		=> pi_data_extra_ch_1(i),		-- LUT input
			I1		=> pi_data_extra_ch_2(i),		-- LUT input
			I2		=> pi_data_extra_ch_3(i),		-- LUT input
			I3		=> pi_data_extra_ch_4(i),		-- LUT input
			I4		=> pi_select(0),					-- LUT input
			I5		=> pi_select(1)					-- LUT input
		);

		DATA_EXTRA_FDRE_INST: FDRE generic map (
			INIT	=> '0'
		)
		port map (
			Q		=> po_data_extra(i),
			C		=> pi_clk,
			CE		=> '1',
			R		=> r_ctrl_on,
			D		=> s_data_extra(i)
		);

	end generate;



	DATA_LAST_ONE_OUTPUT_REG: if(g_output_data_last = "YES") generate

		DATA_LAST_LUT6_L_INST : LUT6_L generic map (
			INIT => X"FF00F0F0CCCCAAAA"
		) -- Specify LUT contents
		port map (
			LO		=> s_data_last,					-- LUT local output
			I0		=> pi_data_last_ch_1,			-- LUT input
			I1		=> pi_data_last_ch_2,			-- LUT input
			I2		=> pi_data_last_ch_3,			-- LUT input
			I3		=> pi_data_last_ch_4,			-- LUT input
			I4		=> pi_select(0),					-- LUT input
			I5		=> pi_select(1)					-- LUT input
		);

		DATA_LAST_FDRE_INST: FDRE generic map (
			INIT	=> '0'
		)
		port map (
			Q		=> po_data_last,
			C		=> pi_clk,
			CE		=> '1',
			R		=> r_ctrl_on,
			D		=> s_data_last
		);

	end generate;


--	process(pi_clk)
--	begin
--		if(rising_edge(pi_clk)) then
--
--			-------------
--			-- PO_DATA --		6
--			-------------
--			po_data <= s_data;
--
--			-------------------
--			-- PO_DATA_EXTRA --		6
--			-------------------
--			if(r_ctrl_on = '1') then
--				po_data_extra <= (others=>'0');
--			else
--				po_data_extra <= s_data_extra;
--			end if;
--
--			------------------
--			-- PO_DATA_LAST --	6
--			------------------
--			if(r_ctrl_on = '1') then
--				po_data_last <= '0';
--			elsif(g_output_data_last = "YES") then
--				po_data_last <= s_data_last;
--			end if;
--
--		end if;
--	end process;


--	process(pi_clk)
--	begin
--		if(rising_edge(pi_clk)) then
--
--			-------------
--			-- PO_DATA --		6
--			-------------
--			case pi_select is
--				when "00" =>		po_data <= pi_data_ch_1;
--				when "01" =>		po_data <= pi_data_ch_2;
--				when "10" =>		po_data <= pi_data_ch_3;
--				when "11" =>		po_data <= pi_data_ch_4;
--				when others =>		po_data <= (others=>'0');
--
--			end case;
--
--		end if;
--	end process;


--	process(pi_clk)
--	begin
--		if(rising_edge(pi_clk)) then
--
--			-------------------
--			-- PO_DATA_EXTRA --		6
--			-------------------
--			if(r_ctrl_on = '0') then
--				po_data_extra <= (others=>'0');
--			else
--
--				case pi_select is
--					when "00" =>		po_data_extra <= pi_data_extra_ch_1;
--					when "01" =>		po_data_extra <= pi_data_extra_ch_2;
--					when "10" =>		po_data_extra <= pi_data_extra_ch_3;
--					when "11" =>		po_data_extra <= pi_data_extra_ch_4;
--					when others =>		po_data_extra <= (others=>'0');
--				end case;
--
--			end if;
--
--		end if;
--	end process;


--	DATA_LAST_ONE_OUTPUT_REG: if(g_output_data_last = "YES") generate
--		process(pi_clk)
--		begin
--			if(rising_edge(pi_clk)) then
--
--				------------------
--				-- PO_DATA_LAST --	6
--				------------------
--				if(r_ctrl_on = '0') then
--					po_data_last <= '0';
--				else
--
--					case pi_select is
--						when "00" =>		po_data_last <= pi_data_last_ch_1;
--						when "01" =>		po_data_last <= pi_data_last_ch_2;
--						when "10" =>		po_data_last <= pi_data_last_ch_3;
--						when "11" =>		po_data_last <= pi_data_last_ch_4;
--						when others =>		po_data_last <= '0';
--					end case;
--
--				end if;
--			end if;
--		end process;
--
--	end generate;
--
--
--	NO_DATA_LAST_REG_GEN: if(g_output_data_last = "NO") generate
--		po_data_last <= '0';
--	end generate;

end architecture;
