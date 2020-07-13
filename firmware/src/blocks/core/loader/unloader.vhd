-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    02/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    unloader
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

Library UNISIM;
use UNISIM.vcomponents.all;

--Library UNIMACRO;
--use UNIMACRO.vcomponents.all;

Library xpm;
use xpm.vcomponents.all;

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

entity unloader is
generic (
	g_lfsr								: boolean := true;
	g_addr_width						: natural := 9;
	g_data_width						: natural := 64;
	g_ctrl_width						: natural := 8;
	g_select_width						: natural := 4
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	po_busy								: out std_logic;
	pi_start								: in std_logic;
	pi_select							: in std_logic_vector(g_select_width-1 downto 0);

	pi_size								: in std_logic_vector(g_addr_width-1 downto 0);
	pi_last								: in std_logic_vector(2 downto 0);
	pi_sign								: in std_logic;

	pi_data								: in t_data_x1;
	pi_data_last						: in std_logic;
	pi_data_wr_en						: in std_logic;

	m00_axis_tdata						: out std_logic_vector(g_data_width-1 downto 0);
	m00_axis_tvalid					: out std_logic;
	m00_axis_tlast						: out std_logic;
	m00_axis_tready					: in std_logic
);
end unloader;

architecture unloader of unloader is

	constant c_data_buf_width			: natural := 4;

	signal r_busy							: std_logic;

	signal r_start							: std_logic;
	signal r_select						: std_logic_vector(g_select_width-1 downto 0);

	signal s_data							: std_logic_vector(g_data_width-1 downto 0);
	signal s_data_last					: std_logic;
	signal s_data_wr_en					: std_logic;

	signal r_first_wr_en					: std_logic;

	signal r_data_wr_en_on				: std_logic;
	signal r_data_wr_en					: std_logic;

	signal r_data_rd_en_on				: std_logic;
	signal r_data_rd_en					: std_logic;
	signal r_data_rd_en_dly				: std_logic;
	signal r_data_rd_shreg				: std_logic_vector(c_data_buf_width-1 downto 0);
	signal r_mem_data_valid				: std_logic;

	signal s_data_in						: std_logic_vector(g_data_width+1-1 downto 0);
	signal s_data_out						: std_logic_vector(g_data_width+1-1 downto 0);

	signal s_write_addr					: std_logic_vector(8 downto 0);
	signal s_read_addr					: std_logic_vector(8 downto 0);

	signal r_start_scheduled			: std_logic;
	signal r_size_scheduled				: std_logic_vector(g_addr_width-1 downto 0);
	signal r_last_scheduled				: std_logic_vector(2 downto 0);
	signal r_sign_scheduled				: std_logic;

	signal r_data							: std_logic_vector(g_data_width-1 downto 0);
	signal r_data_valid					: std_logic;
	signal r_data_last					: std_logic;

	signal r_buf_shift					: std_logic_vector(c_data_buf_width-1 downto 0);

	type t_buf_data is array (0 to c_data_buf_width-1) of std_logic_vector(g_data_width-1 downto 0);
	signal r_buf_data						: t_buf_data;

	signal r_buf_valid					: std_logic_vector(c_data_buf_width-1 downto 0);
	signal r_buf_last						: std_logic_vector(c_data_buf_width-1 downto 0);

	signal r_mux_cnt						: std_logic_vector(addr_width(c_data_buf_width)-1 downto 0);

	signal r_data_out						: std_logic_vector(g_data_width-1 downto 0);
	signal r_data_out_valid				: std_logic;
	signal r_data_out_last				: std_logic;

begin

	UNLOADER_SWITCHBOX_INST: entity work.oper_switchbox generic map (
		g_output_data_last		=> true,								--: boolean := false;
		g_data_width				=> g_data_width,					--: natural := 64
		g_select_width				=> g_select_width					--: natural := 5
	)
	port map (
		pi_clk						=> pi_clk,							--: in std_logic;
		pi_rst						=> pi_rst,							--: in std_logic;
		pi_select					=> r_select,						--: in std_logic_vector(g_select_width-1 downto 0);
		pi_start						=> r_start,							--: in std_logic;
		pi_data						=> pi_data,							--: in t_data_x1;
		pi_data_last				=> pi_data_last,					--: in std_logic;
		po_data						=> s_data,							--: out std_logic_vector(g_data_width-1 downto 0);
		po_data_last				=> s_data_last						--: out std_logic;
	);

	DATA_WR_EN_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width			=> 1,									--: natural := 1;
		g_delay					=> 1									--: natural := 15
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_data(0)				=> pi_data_wr_en,					--: in std_logic_vector(g_data_width-1 downto 0);
		po_data(0)				=> s_data_wr_en					--: out std_logic_vector(g_data_width-1 downto 0)
	);

	s_data_in <= s_data_last & s_data;


--	BRAM_SDP_MACRO_inst: BRAM_SDP_MACRO generic map (
--		BRAM_SIZE				=> "36Kb",								-- Target BRAM, "18Kb" or "36Kb"
--		DEVICE					=> "7SERIES",							-- Target device: "VIRTEX5", "VIRTEX6", "7SERIES", "SPARTAN6"
--		WRITE_WIDTH				=> 65,									-- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
--		READ_WIDTH				=> 65,									-- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
--		DO_REG					=> 1,										-- Optional output register (0 or 1)
--		INIT_FILE				=> "NONE",
--		SIM_COLLISION_CHECK	=> "NONE",								-- Collision check enable "ALL", "WARNING_ONLY", "GENERATE_X_ONLY" or "NONE"
--		SRVAL						=> X"000000000000000000",			-- Set/Reset value for port output
--		WRITE_MODE				=> "WRITE_FIRST",						-- Specify "READ_FIRST" for same clock or synchronous clocks / Specify "WRITE_FIRST for asynchrononous clocks on ports
--		INIT						=> X"000000000000000000"			-- Initial values on output port
--	)
--	port map (
--		RST		=> '0',				-- 1-bit input reset
--
--		WRCLK		=> pi_clk,			-- 1-bit input write clock
--		WREN		=> r_data_wr_en,	-- 1-bit input write port enable
--		--WE			=> (others=>others=>'1'),	-- Input write enable, width defined by write port depth
--		--WE			=> '1',				-- Input write enable, width defined by write port depth
--		WE			=> (7 downto 0 => '1'),				-- Input write enable, width defined by write port depth
--		WRADDR	=> s_write_addr,	-- Input write address, width defined by write port depth
--		DI			=> s_data_in,		-- Input write data port, width defined by WRITE_WIDTH parameter
--
--		RDCLK		=> pi_clk,			-- 1-bit input read clock
--		RDADDR	=> s_read_addr,	-- Input read address, width defined by read port depth
--		DO			=> s_data_out,		-- Output read data port, width defined by READ_WIDTH parameter
--		RDEN		=> '1',				-- 1-bit input read port enable
--		REGCE		=> '1'				-- 1-bit input read output register enable
--
--	);
-- End of BRAM_SDP_MACRO_inst instantiation

 BRAM_SDP_MACRO_inst: xpm_memory_sdpram
   generic map (
      ADDR_WIDTH_A => 9,               -- DECIMAL
      ADDR_WIDTH_B => 9,               -- DECIMAL
      AUTO_SLEEP_TIME => 0,            -- DECIMAL
      BYTE_WRITE_WIDTH_A => 65,        -- DECIMAL
      CLOCKING_MODE => "common_clock", -- String
      ECC_MODE => "no_ecc",            -- String
      MEMORY_INIT_FILE => "none",      -- String
      MEMORY_INIT_PARAM => "0",        -- String
      MEMORY_OPTIMIZATION => "true",   -- String
      MEMORY_PRIMITIVE => "auto",      -- String
      MEMORY_SIZE => 33280,--975,             -- DECIMAL
      MESSAGE_CONTROL => 0,            -- DECIMAL
      READ_DATA_WIDTH_B => 65,         -- DECIMAL
      READ_LATENCY_B => 2,             -- DECIMAL
      READ_RESET_VALUE_B => "0",       -- String
      --RST_MODE_A => "SYNC",            -- String
      --RST_MODE_B => "SYNC",            -- String
      USE_EMBEDDED_CONSTRAINT => 0,    -- DECIMAL
      USE_MEM_INIT => 0,               -- DECIMAL
      WAKEUP_TIME => "disable_sleep",  -- String
      WRITE_DATA_WIDTH_A => 65,        -- DECIMAL
      WRITE_MODE_B => "no_change"      -- String
   )
   port map (
--      dbiterrb => dbiterrb,             -- 1-bit output: Status signal to indicate double bit error occurrence
                                        -- on the data output of port B.

      doutb => 		s_data_out,                  -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
--      sbiterrb => sbiterrb,             -- 1-bit output: Status signal to indicate single bit error occurrence
                                        -- on the data output of port B.

      addra => 		s_write_addr,                   -- ADDR_WIDTH_A-bit input: Address for port A write operations.
      addrb => 		s_read_addr,                  -- ADDR_WIDTH_B-bit input: Address for port B read operations.
      clka =>		pi_clk,                     -- 1-bit input: Clock signal for port A. Also clocks port B when
                                        -- parameter CLOCKING_MODE is "common_clock".

      clkb => 		pi_clk,                     -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                        -- "independent_clock". Unused when parameter CLOCKING_MODE is
                                        -- "common_clock".

      dina => 		s_data_in,                     -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      ena =>		r_data_wr_en,                       -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                        -- cycles when write operations are initiated. Pipelined internally.

      enb => '1',                      -- 1-bit input: Memory enable signal for port B. Must be high on clock
                                        -- cycles when read operations are initiated. Pipelined internally.

      injectdbiterra => '0', -- 1-bit input: Controls double bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      injectsbiterra => '0', -- 1-bit input: Controls single bit error injection on input data when
                                        -- ECC enabled (Error injection capability is not available in
                                        -- "decode_only" mode).

      regceb => '1',	                    -- 1-bit input: Clock Enable for the last register stage on the output
                                        -- data path.

      rstb => 			pi_rst,                       -- 1-bit input: Reset signal for the final port B output register
                                        -- stage. Synchronously resets output port doutb to the value specified
                                        -- by parameter READ_RESET_VALUE_B.

      sleep =>		'0',                   -- 1-bit input: sleep signal to enable the dynamic power saving feature.
      wea => 		(0 downto 0 => '1')
	  									-- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                        -- data port dina. 1 bit wide when word-wide writes are used. In
                                        -- byte-wide write configurations, each bit controls the writing one
                                        -- byte of dina to address addra. For example, to synchronously write
                                        -- only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                        -- 4'b0010.

   );

	WRITE_CNT_DELAYER_INST: entity work.lfsr_counter_up generic map (
		g_lfsr					=> g_lfsr,							--: boolean := false;
		g_n						=> g_addr_width					--: natural := 16
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_rst					=> r_start,							--: in std_logic;
		pi_change				=> r_data_wr_en,					--: in std_logic;
		po_data					=> s_write_addr					--: out std_logic_vector(g_data_width-1 downto 0)
	);

	READ_CNT_DELAYER_INST: entity work.lfsr_counter_up generic map (
		g_lfsr					=> g_lfsr,							--: boolean := false;
		g_n						=> g_addr_width					--: natural := 16
	)
	port map (
		pi_clk					=> pi_clk,							--: in std_logic;
		pi_rst					=> r_start,							--: in std_logic;
		pi_change				=> r_data_rd_en,					--: in std_logic;
		po_data					=> s_read_addr						--: out std_logic_vector(g_data_width-1 downto 0)
	);

----------------
-- INPUT CTRL --
----------------

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-------------
			-- R_START --
			-------------
			r_start <= pi_start;


			--------------
			-- R_SELECT --
			--------------
			if(pi_start = '1') then
				r_select <= pi_select;
			end if;

			if(pi_start = '1') then
				r_size_scheduled <= pi_size;
				r_last_scheduled <= pi_last;
				r_sign_scheduled <= pi_sign;
			end if;


			-----------------------
			-- R_START_SCHEDULED --
			-----------------------
			r_start_scheduled <= pi_start;

		end if;
	end process;


----------------
-- BRAM WRITE --
----------------
	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-------------------
			-- R_FIRST_WR_EN --
			-------------------
			if(pi_rst = '1') then
				r_first_wr_en <= '1';
			else

				if(s_data_wr_en = '1' and r_data_wr_en_on = '1') then
					r_first_wr_en <= '0';
				elsif(r_data_last = '1') then
					r_first_wr_en <= '1';
				end if;

			end if;


			---------------------
			-- R_DATA_WR_EN_ON --
			---------------------
			if(pi_rst = '1') then
				r_data_wr_en_on <= '0';
			else
				if(pi_start = '1') then
					r_data_wr_en_on <= '1';
				elsif(s_data_last = '1') then
					r_data_wr_en_on <= '0';
				end if;
			end if;


			------------------
			-- R_DATA_WR_EN --
			------------------
			if(pi_rst = '1') then
				r_data_wr_en <= '0';
			else

				if(s_data_wr_en = '1' and r_data_wr_en_on = '1') then
					r_data_wr_en <= '1';
				else
					r_data_wr_en <= '0';
				end if;

			end if;

		end if;
	end process;


---------------
-- BRAM READ --
---------------
	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			----------------------
			-- R_MEM_DATA_VALID --		3
			----------------------
			if(r_mem_data_valid = '1' and s_data_out(g_data_width) = '1') then
				r_mem_data_valid <= '0';
			elsif(r_data_rd_en_dly = '1') then
				r_mem_data_valid <= '1';
			else
				r_mem_data_valid <= '0';
			end if;


			---------------------
			-- R_DATA_RD_EN_ON --		7
			---------------------
			if(pi_rst = '1') then
				r_data_rd_en_on <= '0';
			else
				if(r_first_wr_en = '1' and s_data_wr_en = '1' and r_data_wr_en_on = '1') then
					r_data_rd_en_on <= '1';
				elsif(r_mem_data_valid = '1' and s_data_out(g_data_width) = '1') then
					r_data_rd_en_on <= '0';
				end if;
			end if;


			------------------
			-- R_DATA_RD_EN --
			------------------
			if(r_mem_data_valid = '1' and s_data_out(g_data_width) = '1') then
				r_data_rd_en <= '0';
			elsif(r_data_rd_en_on = '1' and (m00_axis_tready = '1' or r_data_rd_shreg(0) = '1')) then
				r_data_rd_en <= '1';
			else
				r_data_rd_en <= '0';
			end if;

			----------------------
			-- R_DATA_RD_EN_DLY --
			----------------------
			if(r_mem_data_valid = '1' and s_data_out(g_data_width) = '1') then
				r_data_rd_en_dly <= '0';
			else
				r_data_rd_en_dly <= r_data_rd_en;
			end if;


			---------------------
			-- R_DATA_RD_SHREG --		4
			---------------------
			if(pi_rst = '1') then
				r_data_rd_shreg <= (others=>'0');
			else

				if(pi_start = '1') then
					r_data_rd_shreg <= (others=>'1');
				elsif(m00_axis_tready = '0') then
					r_data_rd_shreg <= '0' & r_data_rd_shreg(r_data_rd_shreg'length-1 downto 1);
				end if;

			end if;
		end if;
	end process;




------------
-- R_BUSY --
------------
	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			------------
			-- R_BUSY --
			------------
			if(pi_rst = '1') then
				r_busy <= '0';
			else
				if(pi_start = '1') then
					r_busy <= '1';
				elsif(r_data_last = '1') then
					r_busy <= '0';
				end if;
			end if;


		end if;
	end process;


------------
-- R_DATA --
------------
	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			if(r_start_scheduled = '1') then
				r_data <= (others=>'0');
				r_data(18 downto 16) <= r_last_scheduled;
				r_data(15) <= r_sign_scheduled;
				r_data(g_addr_width-1 downto 0) <= r_size_scheduled;
				r_data_last <= '0';
				r_data_valid <= '1';
			elsif(r_mem_data_valid = '1') then
				r_data <= s_data_out(g_data_width-1 downto 0);
				r_data_last <= s_data_out(g_data_width);
				r_data_valid <= '1';
			else
				r_data <= (others=>'0');
				r_data_last <= '0';
				r_data_valid <= '0';
			end if;

		end if;
	end process;


----------------
-- R_BUF_DATA --
----------------

	R_BUF_DATA_GEN: for i in 0 to c_data_buf_width-1 generate


		EQUAL_ZERO_GEN: if(i = 0) generate
			process(pi_clk)
			begin
				if(rising_edge(pi_clk)) then

					-------------------
					-- R_BUF_DATA(0) --
					-------------------
					if(pi_rst = '1') then
						r_buf_valid(i) <= '0';
					else
						if(r_buf_shift(i) = '1') then
							r_buf_data(i) <= r_data;
							r_buf_valid(i) <= r_data_valid;
							r_buf_last(i) <= r_data_last;
						end if;
					end if;

				end if;
			end process;
		end generate;


		GREATER_THAN_ZERO_GEN: if(i > 0) generate
			process(pi_clk)
			begin
				if(rising_edge(pi_clk)) then

					-------------------
					-- R_BUF_DATA(i) --
					-------------------
					if(pi_rst = '1') then
						r_buf_valid(i) <= '0';
					else
						if(r_buf_shift(i) = '1') then
							r_buf_data(i) <= r_buf_data(i-1);
							r_buf_valid(i) <= r_buf_valid(i-1);
							r_buf_last(i) <= r_buf_last(i-1);
						end if;
					end if;

				end if;
			end process;
		end generate;


		BUF_SHIFT_LESS_THAN_MAX_GEN: if(i < c_data_buf_width-1) generate

			BUF_SHIFT_CTRL_PROC: process(pi_clk)
			begin
				if(rising_edge(pi_clk)) then

					-----------------
					-- R_BUF_SHIFT --
					-----------------
					if(m00_axis_tready = '1' or r_buf_valid(i+1) = '0' or (r_buf_valid(i+1) = '1' and r_buf_valid(c_data_buf_width-1) = '0')) then
						r_buf_shift(i) <= '1';
					else
						r_buf_shift(i) <= '0';
					end if;

				end if;
			end process;

		end generate;


		BUF_SHIFT_MAX_GEN: if(i = c_data_buf_width-1) generate
			BUF_SHIFT_CTRL_PROC: process(pi_clk)
			begin
				if(rising_edge(pi_clk)) then

					-----------------
					-- R_BUF_SHIFT --
					-----------------
					if(m00_axis_tready = '1') then
						r_buf_shift(i) <= '1';
					else
						r_buf_shift(i) <= '0';
					end if;

				end if;
			end process;
		end generate;


	end generate;


----------------
-- R_DATA_OUT --
----------------

	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			---------------
			-- R_MUX_CNT --
			---------------
			if(pi_rst = '1') then
				r_mux_cnt <= (others=>'0');
			else

				if(r_buf_valid(0) = '1' and m00_axis_tready = '0') then
					r_mux_cnt <= r_mux_cnt + 1;
				elsif(r_buf_valid = (c_data_buf_width-1 downto 0 => '0')) then
					r_mux_cnt <= (others=>'0');
				end if;

			end if;


			r_data_out <= r_buf_data(to_natural(r_mux_cnt));
			r_data_out_valid <= r_buf_valid(to_natural(r_mux_cnt));
			r_data_out_last <= r_buf_last(to_natural(r_mux_cnt));

		end if;
	end process;

	po_busy <= r_busy;

	m00_axis_tdata <= r_data_out;
	m00_axis_tvalid <= r_data_out_valid;
	m00_axis_tlast <= r_data_out_last;

end architecture;
