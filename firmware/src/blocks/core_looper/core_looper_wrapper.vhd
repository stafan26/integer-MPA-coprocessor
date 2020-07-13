--Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2017.3 (lin64) Build 2018833 Wed Oct  4 19:58:07 MDT 2017
--Date        : Sun Jun 10 15:55:18 2018
--Host        : ts-tiger running 64-bit Ubuntu 16.04.4 LTS
--Command     : generate_target core_looper_wrapper.bd
--Design      : core_looper_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity core_looper_wrapper is
  port (
    pi_clk_ext_100 : in STD_LOGIC;
    pi_rst_ext_100 : in STD_LOGIC;
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_cas_n : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
--    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC
--    M_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
--    M_AXIS_0_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
--    M_AXIS_0_tlast : out STD_LOGIC;
--    M_AXIS_0_tready : in STD_LOGIC;
--    M_AXIS_0_tvalid : out STD_LOGIC;
--    M_AXIS_1_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
--    M_AXIS_1_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
--    M_AXIS_1_tlast : out STD_LOGIC;
--    M_AXIS_1_tready : in STD_LOGIC;
--    M_AXIS_1_tvalid : out STD_LOGIC;
--    S_AXIS_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
--    S_AXIS_0_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
--    S_AXIS_0_tlast : in STD_LOGIC;
--    S_AXIS_0_tready : out STD_LOGIC;
--    S_AXIS_0_tvalid : in STD_LOGIC;
--    S_AXIS_1_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
--    S_AXIS_1_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
--    S_AXIS_1_tlast : in STD_LOGIC;
--    S_AXIS_1_tready : out STD_LOGIC;
--    S_AXIS_1_tvalid : in STD_LOGIC;
--    po_clk : out STD_LOGIC;
--    po_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
--    s_axis_aclk_0 : in STD_LOGIC;
--    s_axis_aclk_1 : in STD_LOGIC;
--    s_axis_aresetn_0 : in STD_LOGIC;
--    s_axis_aresetn_1 : in STD_LOGIC
  );
end core_looper_wrapper;

architecture core_looper_wrapper of core_looper_wrapper is

  component proc_sys is
  port (
    DDR_cas_n : inout STD_LOGIC;
    DDR_cke : inout STD_LOGIC;
    DDR_ck_n : inout STD_LOGIC;
    DDR_ck_p : inout STD_LOGIC;
    DDR_cs_n : inout STD_LOGIC;
    DDR_reset_n : inout STD_LOGIC;
    DDR_odt : inout STD_LOGIC;
    DDR_ras_n : inout STD_LOGIC;
    DDR_we_n : inout STD_LOGIC;
    DDR_ba : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_dm : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dq : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_dqs_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_dqs_p : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    FIXED_IO_mio : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    FIXED_IO_ddr_vrn : inout STD_LOGIC;
    FIXED_IO_ddr_vrp : inout STD_LOGIC;
    FIXED_IO_ps_srstb : inout STD_LOGIC;
    FIXED_IO_ps_clk : inout STD_LOGIC;
    FIXED_IO_ps_porb : inout STD_LOGIC;
    M_AXIS_1_tvalid : out STD_LOGIC;
    M_AXIS_1_tready : in STD_LOGIC;
    M_AXIS_1_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_1_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXIS_0_tvalid : in STD_LOGIC;
    S_AXIS_0_tready : out STD_LOGIC;
    S_AXIS_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_0_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXIS_1_tvalid : in STD_LOGIC;
    S_AXIS_1_tready : out STD_LOGIC;
    S_AXIS_1_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_1_tkeep : in STD_LOGIC_VECTOR ( 3 downto 0 );
    po_clk : out STD_LOGIC;
    po_rst_n : out STD_LOGIC_VECTOR ( 0 to 0 );
    S_AXIS_0_tlast : in STD_LOGIC;
    S_AXIS_1_tlast : in STD_LOGIC;
    M_AXIS_1_tlast : out STD_LOGIC;
--    s_axis_aresetn_0 : in STD_LOGIC;
--    s_axis_aclk_0 : in STD_LOGIC;
--    s_axis_aclk_1 : in STD_LOGIC;
--    s_axis_aresetn_1 : in STD_LOGIC;
	pi_ext_rst : in std_logic;
    M_AXIS_0_tvalid : out STD_LOGIC;
    M_AXIS_0_tready : in STD_LOGIC;
    M_AXIS_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_0_tkeep : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXIS_0_tlast : out STD_LOGIC
  );
  end component proc_sys;



	constant c_sim										: boolean := false;
	constant c_num_of_bram							: natural := 1;
	constant c_lfsr									: boolean := true;
	constant c_num_of_registers					: natural := 16;
	constant c_data_width							: natural := 64;
	constant c_addr_width							: natural := 9;
	constant c_ctrl_width							: natural := 8;


	-- CLK & RST
	signal s_clk_100									: std_logic;
	signal r_rst_100									: std_logic;
	signal s_rst_n_100								: std_logic;
	signal r_rst_n_100								: std_logic;

	signal s_clk_300									: std_logic;
	signal s_rst_300									: std_logic;
	signal r_rst_n_300								: std_logic;
	signal r_rst_300									: std_logic;

	-- SYNC FIFO AXIS 0 - FEEDBACK
	signal M_AXIS_0_tdata							: STD_LOGIC_VECTOR (31 downto 0);
	signal M_AXIS_0_tkeep							: STD_LOGIC_VECTOR (3 downto 0);
	signal M_AXIS_0_tlast							: STD_LOGIC;
	signal M_AXIS_0_tready							: STD_LOGIC;
	signal M_AXIS_0_tvalid							: STD_LOGIC;
	signal s_post_fifo_AXIS_0_tdata				: STD_LOGIC_VECTOR (31 downto 0);
	signal s_post_fifo_AXIS_0_tkeep				: STD_LOGIC_VECTOR (3 downto 0);
	signal s_post_fifo_AXIS_0_tlast				: STD_LOGIC;
	signal s_post_fifo_AXIS_0_tready				: STD_LOGIC;
	signal s_post_fifo_AXIS_0_tvalid				: STD_LOGIC;


	-- GEAR UP AXIS 0 - FEEDBACK
	signal s_int_tdata								: STD_LOGIC_VECTOR (63 downto 0);
	signal s_int_tdata_mod							: STD_LOGIC_VECTOR (63 downto 0);
	signal s_int_tlast								: STD_LOGIC_VECTOR(1 downto 0);
	signal s_int_tkeep								: STD_LOGIC_VECTOR (7 downto 0);
	signal s_int_tready								: STD_LOGIC;
	signal s_int_tvalid								: STD_LOGIC;


	-- GEAR DOWN AXIS 0 - FEEDBACK
	signal nsync_AXIS_0_tdata						: STD_LOGIC_VECTOR (31 downto 0);
	signal nsync_AXIS_0_tkeep						: STD_LOGIC_VECTOR (3 downto 0);
	signal nsync_AXIS_0_tlast						: STD_LOGIC;
	signal nsync_AXIS_0_tready						: STD_LOGIC;
	signal nsync_AXIS_0_tvalid						: STD_LOGIC;

	-- SYNC FIFO AXIS 0 - FEEDBACK
	signal S_AXIS_0_tdata							: STD_LOGIC_VECTOR (31 downto 0);
	signal S_AXIS_0_tlast							: STD_LOGIC;
	signal S_AXIS_0_tkeep							: STD_LOGIC_VECTOR(3 downto 0);
	signal S_AXIS_0_tready							: STD_LOGIC;
	signal S_AXIS_0_tvalid							: STD_LOGIC;



	-- SYNC FIFO AXIS 1 - CORE
	signal M_AXIS_1_tdata							: STD_LOGIC_VECTOR (31 downto 0);
	signal M_AXIS_1_tkeep							: STD_LOGIC_VECTOR (3 downto 0);
	signal M_AXIS_1_tlast							: STD_LOGIC;
	signal M_AXIS_1_tready							: STD_LOGIC;
	signal M_AXIS_1_tvalid							: STD_LOGIC;


	-- GEAR UP AXIS 1 - CORE
	signal s_post_fifo_AXIS_1_tdata				: STD_LOGIC_VECTOR (31 downto 0);
	signal s_post_fifo_AXIS_1_tkeep				: STD_LOGIC_VECTOR (3 downto 0);
	signal s_post_fifo_AXIS_1_tlast				: STD_LOGIC;
	signal s_post_fifo_AXIS_1_tready				: STD_LOGIC;
	signal s_post_fifo_AXIS_1_tvalid				: STD_LOGIC;


	-- CORE
	signal s00a_axis_tdata							: std_logic_vector(c_data_width-1 downto 0);
	signal s00a_axis_tvalid							: std_logic;
	signal s00a_axis_tready							: std_logic;
	signal m00_axis_tdata							: std_logic_vector(c_data_width-1 downto 0);
	signal m00_axis_tlast							: std_logic;
	signal m00_axis_tlast_mod						: std_logic_vector(1 downto 0);
	signal m00_axis_tvalid							: std_logic;
	signal m00_axis_tready							: std_logic;


	-- GEAR DOWN AXIS 1 - CORE
	signal nsync_AXIS_1_tdata						: STD_LOGIC_VECTOR (31 downto 0);
	signal nsync_AXIS_1_tkeep						: STD_LOGIC_VECTOR (3 downto 0);
	signal nsync_AXIS_1_tlast						: STD_LOGIC;
	signal nsync_AXIS_1_tready						: STD_LOGIC;
	signal nsync_AXIS_1_tvalid						: STD_LOGIC;

	-- SYNC FIFO AXIS 1 - CORE
	signal S_AXIS_1_tdata							: STD_LOGIC_VECTOR (31 downto 0);
	signal S_AXIS_1_tlast							: STD_LOGIC;
	signal S_AXIS_1_tkeep							: STD_LOGIC_VECTOR(3 downto 0);
	signal S_AXIS_1_tready							: STD_LOGIC;
	signal S_AXIS_1_tvalid							: STD_LOGIC;

begin

proc_sys_i: component proc_sys
     port map (
      DDR_addr(14 downto 0) => DDR_addr(14 downto 0),
      DDR_ba(2 downto 0) => DDR_ba(2 downto 0),
      DDR_cas_n => DDR_cas_n,
      DDR_ck_n => DDR_ck_n,
      DDR_ck_p => DDR_ck_p,
      DDR_cke => DDR_cke,
      DDR_cs_n => DDR_cs_n,
      DDR_dm(3 downto 0) => DDR_dm(3 downto 0),
      DDR_dq(31 downto 0) => DDR_dq(31 downto 0),
      DDR_dqs_n(3 downto 0) => DDR_dqs_n(3 downto 0),
      DDR_dqs_p(3 downto 0) => DDR_dqs_p(3 downto 0),
      DDR_odt => DDR_odt,
      DDR_ras_n => DDR_ras_n,
      DDR_reset_n => DDR_reset_n,
      DDR_we_n => DDR_we_n,
      FIXED_IO_ddr_vrn => FIXED_IO_ddr_vrn,
      FIXED_IO_ddr_vrp => FIXED_IO_ddr_vrp,
      FIXED_IO_mio(53 downto 0) => FIXED_IO_mio(53 downto 0),
      FIXED_IO_ps_clk => FIXED_IO_ps_clk,
      FIXED_IO_ps_porb => FIXED_IO_ps_porb,
      FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
      M_AXIS_0_tdata(31 downto 0) => M_AXIS_0_tdata(31 downto 0),
      M_AXIS_0_tkeep(3 downto 0) => M_AXIS_0_tkeep(3 downto 0),
      M_AXIS_0_tlast => M_AXIS_0_tlast,
      M_AXIS_0_tready => M_AXIS_0_tready,
      M_AXIS_0_tvalid => M_AXIS_0_tvalid,
      M_AXIS_1_tdata(31 downto 0) => M_AXIS_1_tdata(31 downto 0),
      M_AXIS_1_tkeep(3 downto 0) => M_AXIS_1_tkeep(3 downto 0),
      M_AXIS_1_tlast => M_AXIS_1_tlast,
      M_AXIS_1_tready => M_AXIS_1_tready,
      M_AXIS_1_tvalid => M_AXIS_1_tvalid,
      S_AXIS_0_tdata(31 downto 0) => S_AXIS_0_tdata(31 downto 0),
      S_AXIS_0_tkeep(3 downto 0) => S_AXIS_0_tkeep(3 downto 0),
      S_AXIS_0_tlast => S_AXIS_0_tlast,
      S_AXIS_0_tready => S_AXIS_0_tready,
      S_AXIS_0_tvalid => S_AXIS_0_tvalid,
      S_AXIS_1_tdata(31 downto 0) => S_AXIS_1_tdata(31 downto 0),
      S_AXIS_1_tkeep(3 downto 0) => S_AXIS_1_tkeep(3 downto 0),
      S_AXIS_1_tlast => S_AXIS_1_tlast,
      S_AXIS_1_tready => S_AXIS_1_tready,
      S_AXIS_1_tvalid => S_AXIS_1_tvalid,
      pi_ext_rst => pi_rst_ext_100,
      po_clk => s_clk_100,
      po_rst_n(0) => s_rst_n_100
    );



	MY_PLL_INST: entity work.my_pll port map (
		pi_clk_ext		=> pi_clk_ext_100,	--: in std_logic;
		pi_rst_ext		=> pi_rst_ext_100,	--: in std_logic;
		--pi_rst_ext		=> r_rst_100,			--: in std_logic;
		po_clk			=> s_clk_300,			--: out std_logic;
		po_rst			=> s_rst_300			--: out std_logic;
	);


	-------------------
	-- FEEDBACK LOOP --
	-------------------

--	AXIS_FIFO_SYNC_INST: entity work.axis_fifo_sync port map (
--		s_aclk				=> s_clk_100,							--: in std_logic;
--		m_aclk				=> s_clk_300,							--: in std_logic;
--		s_aresetn			=> r_rst_n_100,						--: in std_logic;
--		s_axis_tdata		=> M_AXIS_0_tdata,					--: in STD_LOGIC_VECTOR (31 downto 0);
--		s_axis_tkeep		=> M_AXIS_0_tkeep,					--: in STD_LOGIC_VECTOR (3 downto 0);
--		s_axis_tlast		=> M_AXIS_0_tlast,					--: in STD_LOGIC;
--		s_axis_tready		=> M_AXIS_0_tready,					--: out STD_LOGIC;
--		s_axis_tvalid		=> M_AXIS_0_tvalid,					--: in STD_LOGIC;
--		m_axis_tdata		=> s_post_fifo_AXIS_0_tdata,		--: out STD_LOGIC_VECTOR (31 downto 0);
--		m_axis_tlast		=> s_post_fifo_AXIS_0_tlast,		--: out STD_LOGIC;
--		m_axis_tkeep		=> s_post_fifo_AXIS_0_tkeep,		--: out STD_LOGIC_VECTOR (7 downto 0);
--		m_axis_tready		=> s_post_fifo_AXIS_0_tready,		--: in STD_LOGIC;
--		m_axis_tvalid		=> s_post_fifo_AXIS_0_tvalid,		--: out STD_LOGIC
--		wr_rst_busy			=> open,									--: out STD_LOGIC
--		rd_rst_busy			=> open									--: out STD_LOGIC
--	);


--	AXIS_FIFO_GEAR_UP_INST: entity work.axis_fifo_gear_up port map (
--		pi_clk				=> s_clk_300,							--: in std_logic;
--		pi_rst				=> r_rst_300,							--: in std_logic;
--		S_AXIS_0_tdata		=> s_post_fifo_AXIS_0_tdata,		--: in STD_LOGIC_VECTOR (31 downto 0);
--		S_AXIS_0_tkeep		=> s_post_fifo_AXIS_0_tkeep,		--: in STD_LOGIC_VECTOR (3 downto 0);
--		S_AXIS_0_tlast		=> s_post_fifo_AXIS_0_tlast,		--: in STD_LOGIC;
--		S_AXIS_0_tready	=> s_post_fifo_AXIS_0_tready,		--: out STD_LOGIC;
--		S_AXIS_0_tvalid	=> s_post_fifo_AXIS_0_tvalid,		--: in STD_LOGIC;
--		M_AXIS_0_tdata		=> s_int_tdata,						--: out STD_LOGIC_VECTOR (63 downto 0);
--		M_AXIS_0_tlast		=> s_int_tlast,						--: out STD_LOGIC_VECTOR(1 downto 0);
--		M_AXIS_0_tkeep		=> s_int_tkeep,						--: out STD_LOGIC_VECTOR (7 downto 0);
--		M_AXIS_0_tready	=> s_int_tready,						--: in STD_LOGIC;
--		M_AXIS_0_tvalid	=> s_int_tvalid						--: out STD_LOGIC
--	);
--
--
--	ILA: entity work.ila_0 port map (
--		clk					=> s_clk_300,							--: in std_logic;
--		probe0				=> s_int_tdata,						--: in std_logic_vector(63 downto 0);
--		probe1				=> s_int_tlast,						--: in std_logic_vector(1 downto 0);
--		probe2(0)			=> s_int_tready,						--: in std_logic_vector(0 downto 0);
--		probe3(0)			=> s_int_tvalid,						--: in std_logic_vector(0 downto 0);
--
--		probe4				=> s_post_fifo_AXIS_0_tdata,		--: in STD_LOGIC_VECTOR (31 downto 0);
--		probe5				=> s_post_fifo_AXIS_0_tkeep,		--: in STD_LOGIC_VECTOR (3 downto 0);
--		probe6(0)			=> s_post_fifo_AXIS_0_tlast,		--: in STD_LOGIC;
--		probe7(0)			=> s_post_fifo_AXIS_0_tready,		--: in STD_LOGIC;
--		probe8(0)			=> s_post_fifo_AXIS_0_tvalid		--: in STD_LOGIC;
--	);
--
--
--	s_int_tdata_mod <= s_int_tdata(63 downto 3) & not s_int_tdata(2) & s_int_tdata(1 downto 0);
--
--
--
--	AXIS_FIFO_GEAR_DOWN_INST: entity work.axis_fifo_gear_down port map (
--		pi_clk				=> s_clk_300,						--: in std_logic;
--		pi_rst				=> r_rst_300,						--: in std_logic;
--		S_AXIS_0_tdata		=> s_int_tdata_mod,				--: in STD_LOGIC_VECTOR (63 downto 0);
--		S_AXIS_0_tlast		=> s_int_tlast,					--: in STD_LOGIC_VECTOR (1 downto 0);
--		S_AXIS_0_tkeep		=> s_int_tkeep,					--: in STD_LOGIC_VECTOR (7 downto 0);
--		S_AXIS_0_tready	=> s_int_tready,					--: out STD_LOGIC;
--		S_AXIS_0_tvalid	=> s_int_tvalid,					--: in STD_LOGIC;
--		M_AXIS_0_tdata		=> nsync_AXIS_0_tdata,			--: out STD_LOGIC_VECTOR (31 downto 0);
--		M_AXIS_0_tlast		=> nsync_AXIS_0_tlast,			--: out STD_LOGIC;
--		M_AXIS_0_tkeep		=> nsync_AXIS_0_tkeep,			--: out STD_LOGIC_VECTOR(3 downto 0);
--		M_AXIS_0_tready	=> nsync_AXIS_0_tready,			--: in STD_LOGIC;
--		M_AXIS_0_tvalid	=> nsync_AXIS_0_tvalid			--: out STD_LOGIC
--	);
--
--
--
--	AXIS_0_FIFO_SYNC_INST: entity work.axis_fifo_sync port map (
--		m_aclk				=> s_clk_100,							--: in std_logic;
--		s_aclk				=> s_clk_300,							--: in std_logic;
--		s_aresetn			=> r_rst_n_100,						--: in std_logic;
--		s_axis_tdata		=> nsync_AXIS_0_tdata,				--: in STD_LOGIC_VECTOR (31 downto 0);
--		s_axis_tkeep		=> nsync_AXIS_0_tkeep,				--: in STD_LOGIC_VECTOR (3 downto 0);
--		s_axis_tlast		=> nsync_AXIS_0_tlast,				--: in STD_LOGIC;
--		s_axis_tready		=> nsync_AXIS_0_tready,				--: out STD_LOGIC;
--		s_axis_tvalid		=> nsync_AXIS_0_tvalid,				--: in STD_LOGIC;
--		m_axis_tdata		=> S_AXIS_0_tdata,					--: out STD_LOGIC_VECTOR (31 downto 0);
--		m_axis_tlast		=> S_AXIS_0_tlast,					--: out STD_LOGIC;
--		m_axis_tkeep		=> S_AXIS_0_tkeep,					--: out STD_LOGIC_VECTOR (7 downto 0);
--		m_axis_tready		=> S_AXIS_0_tready,					--: in STD_LOGIC;
--		m_axis_tvalid		=> S_AXIS_0_tvalid,					--: out STD_LOGIC
--		wr_rst_busy			=> open,									--: out STD_LOGIC
--		rd_rst_busy			=> open									--: out STD_LOGIC
--	);



--	ILA: entity work.ila_0 port map (
--		clk					=> s_clk_300,							--: in std_logic;
--		probe0				=> (others=>'0'),						--: in std_logic_vector(63 downto 0);
--		probe1				=> (others=>'0'),						--: in std_logic_vector(1 downto 0);
--		probe2(0)			=> '0',						--: in std_logic_vector(0 downto 0);
--		probe3(0)			=> '0',						--: in std_logic_vector(0 downto 0);
--
--		probe4				=> s_post_fifo_AXIS_0_tdata,		--: in STD_LOGIC_VECTOR (31 downto 0);
--		probe5				=> s_post_fifo_AXIS_0_tkeep,		--: in STD_LOGIC_VECTOR (3 downto 0);
--		probe6(0)			=> s_post_fifo_AXIS_0_tlast,		--: in STD_LOGIC;
--		probe7(0)			=> s_post_fifo_AXIS_0_tready,		--: in STD_LOGIC;
--		probe8(0)			=> s_post_fifo_AXIS_0_tvalid		--: in STD_LOGIC;
--	);



--	AXIS_0_FIFO_SYNC_INST: entity work.axis_fifo_sync port map (
--		m_aclk				=> s_clk_100,							--: in std_logic;
--		s_aclk				=> s_clk_300,							--: in std_logic;
--		s_aresetn			=> r_rst_n_300,						--: in std_logic;
--		s_axis_tdata		=> s_post_fifo_AXIS_0_tdata,		--: in STD_LOGIC_VECTOR (31 downto 0);
--		s_axis_tkeep		=> s_post_fifo_AXIS_0_tkeep,		--: in STD_LOGIC_VECTOR (3 downto 0);
--		s_axis_tlast		=> s_post_fifo_AXIS_0_tlast,		--: in STD_LOGIC;
--		s_axis_tready		=> s_post_fifo_AXIS_0_tready,		--: out STD_LOGIC;
--		s_axis_tvalid		=> s_post_fifo_AXIS_0_tvalid,		--: in STD_LOGIC;
--		m_axis_tdata		=> S_AXIS_0_tdata,					--: out STD_LOGIC_VECTOR (31 downto 0);
--		m_axis_tlast		=> S_AXIS_0_tlast,					--: out STD_LOGIC;
--		m_axis_tkeep		=> S_AXIS_0_tkeep,					--: out STD_LOGIC_VECTOR (7 downto 0);
--		m_axis_tready		=> S_AXIS_0_tready,					--: in STD_LOGIC;
--		m_axis_tvalid		=> S_AXIS_0_tvalid,					--: out STD_LOGIC
--		wr_rst_busy			=> open,									--: out STD_LOGIC
--		rd_rst_busy			=> open									--: out STD_LOGIC
--	);

	S_AXIS_0_tdata		<= M_AXIS_0_tdata;			--: out STD_LOGIC_VECTOR (31 downto 0);
	S_AXIS_0_tlast		<= M_AXIS_0_tlast;			--: out STD_LOGIC;
	S_AXIS_0_tkeep		<= M_AXIS_0_tkeep;			--: out STD_LOGIC_VECTOR (7 downto 0);
	M_AXIS_0_tready	<= M_AXIS_0_tready;				--: in STD_LOGIC;
	S_AXIS_0_tvalid	<= M_AXIS_0_tvalid;				--: out STD_LOGIC





	process(s_clk_100)
	begin
		if(rising_edge(s_clk_100)) then
			r_rst_100 <= not s_rst_n_100;
			r_rst_n_100 <= s_rst_n_100;
		end if;
	end process;


	process(s_clk_300)
	begin
		if(rising_edge(s_clk_300)) then
			r_rst_300 <= s_rst_300;
			r_rst_n_300 <= not s_rst_300;
		end if;
	end process;




	CORE_AXIS_FIFO_SYNC_INST: entity work.axis_fifo_sync port map (
		m_aclk				=> s_clk_300,							--: in std_logic;
		s_aclk				=> s_clk_100,							--: in std_logic;
		s_aresetn			=> r_rst_n_100,						--: in std_logic;
		s_axis_tdata		=> M_AXIS_1_tdata,					--: in STD_LOGIC_VECTOR (31 downto 0);
		s_axis_tkeep		=> M_AXIS_1_tkeep,					--: in STD_LOGIC_VECTOR (3 downto 0);
		s_axis_tlast		=> M_AXIS_1_tlast,					--: in STD_LOGIC;
		s_axis_tready		=> M_AXIS_1_tready,					--: out STD_LOGIC;
		s_axis_tvalid		=> M_AXIS_1_tvalid,					--: in STD_LOGIC;
		m_axis_tdata		=> s_post_fifo_AXIS_1_tdata,		--: out STD_LOGIC_VECTOR (31 downto 0);
		m_axis_tlast		=> s_post_fifo_AXIS_1_tlast,		--: out STD_LOGIC;
		m_axis_tkeep		=> s_post_fifo_AXIS_1_tkeep,		--: out STD_LOGIC_VECTOR (7 downto 0);
		m_axis_tready		=> s_post_fifo_AXIS_1_tready,		--: in STD_LOGIC;
		m_axis_tvalid		=> s_post_fifo_AXIS_1_tvalid,		--: out STD_LOGIC
		wr_rst_busy			=> open,									--: out STD_LOGIC
		rd_rst_busy			=> open									--: out STD_LOGIC
	);

	CORE_AXIS_FIFO_GEAR_UP_INST: entity work.axis_fifo_gear_up port map (
		pi_clk				=> s_clk_300,							--: in std_logic;
		pi_rst				=> r_rst_300,							--: in std_logic;
		S_AXIS_0_tdata		=> s_post_fifo_AXIS_1_tdata,		--: in STD_LOGIC_VECTOR (31 downto 0);
		S_AXIS_0_tkeep		=> s_post_fifo_AXIS_1_tkeep,		--: in STD_LOGIC_VECTOR (3 downto 0);
		S_AXIS_0_tlast		=> s_post_fifo_AXIS_1_tlast,		--: in STD_LOGIC;
		S_AXIS_0_tready	=> s_post_fifo_AXIS_1_tready,		--: out STD_LOGIC;
		S_AXIS_0_tvalid	=> s_post_fifo_AXIS_1_tvalid,		--: in STD_LOGIC;
		M_AXIS_0_tdata		=> s00a_axis_tdata,					--: out STD_LOGIC_VECTOR (63 downto 0);
		M_AXIS_0_tlast		=> open,									--: out STD_LOGIC_VECTOR(1 downto 0);
		M_AXIS_0_tkeep		=> open,									--: out STD_LOGIC_VECTOR (7 downto 0);
		M_AXIS_0_tready	=> s00a_axis_tready,					--: in STD_LOGIC;
		M_AXIS_0_tvalid	=> s00a_axis_tvalid					--: out STD_LOGIC
	);

	CORE_INST: entity work.core_looper generic map (
		g_sim							=> c_sim,								--: boolean := false;
		g_num_of_bram				=> c_num_of_bram,						--: natural := 1;
		g_lfsr						=> c_lfsr,								--: boolean := true;
		g_num_of_registers		=> c_num_of_registers,				--: natural := C_NUM_OF_REGISTERS;
		g_data_width				=> c_data_width,						--: natural := C_STD_DATA_WIDTH;
		g_addr_width				=> c_addr_width,						--: natural := C_STD_ADDR_WIDTH;
		g_ctrl_width				=> c_ctrl_width						--: natural := C_STD_CTRL_WIDTH
	)
	port map (
		pi_clk						=> s_clk_300,							--: in std_logic;
		pi_rst						=> r_rst_300,							--: in std_logic;
		s00a_axis_tdata			=> s00a_axis_tdata,					--: in std_logic_vector(g_data_width-1 downto 0);
		s00a_axis_tvalid			=> s00a_axis_tvalid,					--: in std_logic;
		s00a_axis_tready			=> s00a_axis_tready,					--: out std_logic;
		s00b_axis_tdata			=> (others=>'0'),						--: in std_logic_vector(g_data_width-1 downto 0);
		s00b_axis_tvalid			=> '0',									--: in std_logic;
		s00b_axis_tready			=> open,									--: out std_logic;
		m00_axis_tdata				=> m00_axis_tdata,					--: out std_logic_vector(g_data_width-1 downto 0);
		m00_axis_tvalid			=> m00_axis_tvalid,					--: out std_logic;
		m00_axis_tlast				=> m00_axis_tlast,					--: out std_logic;
		m00_axis_tready			=> m00_axis_tready					--: in std_logic
	);


	m00_axis_tlast_mod <= m00_axis_tlast & '0';

	CORE_AXIS_FIFO_GEAR_DOWN_INST: entity work.axis_fifo_gear_down port map (
		pi_clk				=> s_clk_300,				--: in std_logic;
		pi_rst				=> r_rst_300,				--: in std_logic;
		S_AXIS_0_tdata		=> m00_axis_tdata,		--: in STD_LOGIC_VECTOR (63 downto 0);
		S_AXIS_0_tlast		=> m00_axis_tlast_mod,	--: in STD_LOGIC_VECTOR (1 downto 0);
		S_AXIS_0_tkeep		=> (others=>'1'),			--: in STD_LOGIC_VECTOR (7 downto 0);
		S_AXIS_0_tready	=> m00_axis_tready,		--: out STD_LOGIC;
		S_AXIS_0_tvalid	=> m00_axis_tvalid,		--: in STD_LOGIC;
		M_AXIS_0_tdata		=> nsync_AXIS_1_tdata,	--: out STD_LOGIC_VECTOR (31 downto 0);
		M_AXIS_0_tlast		=> nsync_AXIS_1_tlast,	--: out STD_LOGIC;
		M_AXIS_0_tkeep		=> nsync_AXIS_1_tkeep,	--: out STD_LOGIC_VECTOR(3 downto 0);
		M_AXIS_0_tready	=> nsync_AXIS_1_tready,	--: in STD_LOGIC;
		M_AXIS_0_tvalid	=> nsync_AXIS_1_tvalid	--: out STD_LOGIC
	);


	AXIS_1_FIFO_SYNC_INST: entity work.axis_fifo_sync port map (
		m_aclk				=> s_clk_100,							--: in std_logic;
		s_aclk				=> s_clk_300,							--: in std_logic;
		s_aresetn			=> r_rst_n_100,						--: in std_logic;
		s_axis_tdata		=> nsync_AXIS_1_tdata,				--: in STD_LOGIC_VECTOR (31 downto 0);
		s_axis_tkeep		=> nsync_AXIS_1_tkeep,				--: in STD_LOGIC_VECTOR (3 downto 0);
		s_axis_tlast		=> nsync_AXIS_1_tlast,				--: in STD_LOGIC;
		s_axis_tready		=> nsync_AXIS_1_tready,				--: out STD_LOGIC;
		s_axis_tvalid		=> nsync_AXIS_1_tvalid,				--: in STD_LOGIC;
		m_axis_tdata		=> S_AXIS_1_tdata,					--: out STD_LOGIC_VECTOR (31 downto 0);
		m_axis_tlast		=> S_AXIS_1_tlast,					--: out STD_LOGIC;
		m_axis_tkeep		=> S_AXIS_1_tkeep,					--: out STD_LOGIC_VECTOR (7 downto 0);
		m_axis_tready		=> S_AXIS_1_tready,					--: in STD_LOGIC;
		m_axis_tvalid		=> S_AXIS_1_tvalid,					--: out STD_LOGIC
		wr_rst_busy			=> open,									--: out STD_LOGIC
		rd_rst_busy			=> open									--: out STD_LOGIC
	);

end architecture;
