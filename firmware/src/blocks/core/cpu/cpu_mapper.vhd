-------------------------------------------
-- Company:        SRS
-- Engineer:       Kamil Rudnicki
-- Create Date:    07/05/2017
-- Project Name:   MPALU
-- Design Name:    core
-- Module Name:    cpu_mapper
-------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.pro_pack.all;
use work.my_pack.all;

-------------------------------------------
-------------------------------------------
--
-- TO DO:
--			- speed up mapper remapping process (during swap after addition)
--
-------------------------------------------
-------------------------------------------

entity cpu_mapper is
generic (
	g_sim									: boolean := false;
	g_num_of_logic_registers		: natural := 16;
	g_num_of_phys_registers			: natural := 18;
	g_reg_logic_addr_width			: natural := 4;
	g_reg_phys_addr_width			: natural := 5
);
port(
	pi_clk								: in std_logic;
	pi_rst								: in std_logic;

	pi_swap_pre							: in std_logic;								-- from CPU
	pi_swap_post						: in std_logic;								-- from ADDER
	pi_swap_post_en					: in std_logic;								-- from ADDER

	pi_logic_reg_1						: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	pi_logic_reg_2						: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	pi_logic_reg_3						: in std_logic_vector(g_reg_logic_addr_width-1 downto 0);
	pi_logic_reg_3_oh					: in std_logic_vector(g_num_of_logic_registers-1 downto 0);

	pi_logic_reg_all_oh				: in std_logic_vector(g_num_of_logic_registers-1 downto 0);
	pi_use_aux_reg						: in std_logic;

	po_phys_reg_1						: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	po_phys_reg_1_oh					: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_phys_reg_2						: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	po_phys_reg_2_oh					: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_phys_reg_3						: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	po_phys_reg_3_oh					: out std_logic_vector(g_num_of_phys_registers-1 downto 0);
	po_phys_reg_3_aux					: out std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	--po_phys_reg_3_aux_oh				: out std_logic_vector(g_num_of_phys_registers-1 downto 0);

	po_phys_reg_all_oh				: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
);
end cpu_mapper;

architecture cpu_mapper of cpu_mapper is

	constant c_or_gate_latency				: natural := 2;

	constant c_num_of_shadow_registers	: natural := g_num_of_phys_registers-g_num_of_logic_registers;
	constant c_reg_shadow_addr_width		: natural := addr_width(c_num_of_shadow_registers);

	type t_logic_mux_addr is array (0 to g_reg_phys_addr_width-1) of std_logic_vector(g_num_of_logic_registers-1 downto 0);
	type t_logic_mux_oh_addr is array (0 to g_num_of_phys_registers-1) of std_logic_vector(g_num_of_logic_registers-1 downto 0);

	signal s_phys_reg						: t_phys;
	signal s_phys_reg_oh					: t_phys_oh;

	signal s_mux_reg_in					: t_logic_inv;
	signal s_mux_reg_oh_in				: t_logic_oh_inv;

	signal s_or_gate_oh_in				: t_phys_oh;

	signal r_aux_reg_index				: std_logic_vector(addr_width(c_num_of_shadow_registers)-1 downto 0);

	signal s_phys_reg_1					: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_phys_reg_2					: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_phys_reg_3					: std_logic_vector(g_reg_phys_addr_width-1 downto 0);
	signal s_phys_reg_3_aux				: std_logic_vector(g_reg_phys_addr_width-1 downto 0);

	signal s_phys_reg_1_oh				: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_phys_reg_2_oh				: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	signal s_phys_reg_3_oh				: std_logic_vector(g_num_of_phys_registers-1 downto 0);
	--signal s_phys_reg_3_aux_oh			: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal s_phys_reg_all_oh			: std_logic_vector(g_num_of_phys_registers-1 downto 0);

	signal s_shadow_data					: std_logic_vector(c_num_of_shadow_registers*g_reg_phys_addr_width-1 downto 0);
	signal s_shadow_data_oh				: std_logic_vector(c_num_of_shadow_registers*g_num_of_phys_registers-1 downto 0);
	signal s_swap_data					: std_logic_vector(g_num_of_logic_registers*g_reg_phys_addr_width-1 downto 0);
	signal s_swap_data_oh				: std_logic_vector(g_num_of_logic_registers*g_num_of_phys_registers-1 downto 0);
	signal s_origin						: std_logic_vector(c_num_of_shadow_registers*g_reg_phys_addr_width-1 downto 0);
	signal s_origin_oh					: std_logic_vector(c_num_of_shadow_registers*g_num_of_phys_registers-1 downto 0);

	signal s_main_reg_swap				: std_logic_vector(g_num_of_logic_registers-1 downto 0);
	signal s_shadow_reg_swap			: std_logic;

begin

	po_phys_reg_1 <= s_phys_reg_1;
	po_phys_reg_2 <= s_phys_reg_2;
	po_phys_reg_3 <= s_phys_reg_3;
	po_phys_reg_3_aux <= s_phys_reg_3_aux;


	po_phys_reg_1_oh <= s_phys_reg_1_oh;
	po_phys_reg_2_oh <= s_phys_reg_2_oh;
	po_phys_reg_3_oh <= s_phys_reg_3_oh;
	--po_phys_reg_3_aux_oh <= s_phys_reg_3_aux_oh;
	po_phys_reg_all_oh <= s_phys_reg_all_oh;


	REGISTERS_GEN: for i in 0 to g_num_of_logic_registers-1 generate

		CPU_MAPPER_MAIN_REG_INST: entity work.cpu_mapper_reg generic map (
			g_reg_width			=> g_reg_phys_addr_width,						--: natural := 2;
			g_reg_oh_width		=> g_num_of_phys_registers,					--: natural := 4;
			g_init_id			=> i													--: natural := 2;
		)
		port map (
			pi_clk				=> pi_clk,											--: in std_logic;
			pi_rst				=> pi_rst,											--: in std_logic;
			pi_load				=> s_main_reg_swap(i),							--: in std_logic;
			pi_reg_on			=> pi_logic_reg_all_oh(i),						--: in std_logic;
			pi_data				=> s_swap_data(g_reg_phys_addr_width*(i+1)-1 downto g_reg_phys_addr_width*i),			--: in std_logic_vector(g_reg_width-1 downto 0);
			pi_data_oh			=> s_swap_data_oh(g_num_of_phys_registers*(i+1)-1 downto g_num_of_phys_registers*i),			--: in std_logic_vector(g_reg_width-1 downto 0);
			po_data				=> s_phys_reg(i),									--: out std_logic_vector(g_reg_width-1 downto 0);
			po_data_oh			=> s_phys_reg_oh(i)								--: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
		);

		SHADOW_REGISTER_GEN: if(i < c_num_of_shadow_registers) generate
			CPU_MAPPER_SHADOW_REG_INST: entity work.cpu_mapper_reg generic map (
				g_reg_width			=> g_reg_phys_addr_width,						--: natural := 2;
				g_reg_oh_width		=> g_num_of_phys_registers,					--: natural := 4;
				g_init_id			=> i+g_num_of_logic_registers					--: natural := 2;
			)
			port map (
				pi_clk				=> pi_clk,											--: in std_logic;
				pi_rst				=> pi_rst,											--: in std_logic;
				pi_load				=> s_shadow_reg_swap,							--: in std_logic;
				pi_reg_on			=> pi_use_aux_reg,								--: in std_logic;
				pi_data				=> s_origin(g_reg_phys_addr_width*(i+1)-1 downto g_reg_phys_addr_width*i),					--: in std_logic_vector(g_reg_width-1 downto 0);
				pi_data_oh			=> s_origin_oh(g_num_of_phys_registers*(i+1)-1 downto g_num_of_phys_registers*i),					--: in std_logic_vector(g_reg_width-1 downto 0);
				po_data				=> s_phys_reg(i+g_num_of_logic_registers),	--: out std_logic_vector(g_reg_width-1 downto 0)
				po_data_oh			=> s_phys_reg_oh(i+g_num_of_logic_registers)	--: out std_logic_vector(g_num_of_phys_registers-1 downto 0)
			);

		end generate;

	end generate;


	PHYS_REG_3_AUX_DELAYER_INST: entity work.data_delayer generic map (
		g_data_width		=> g_reg_phys_addr_width,							--: natural := 64;
		g_delay				=> 2														--: natural := 4
	)
	port map (
		pi_clk				=> pi_clk,												--: in std_logic;
		pi_data				=> s_phys_reg(g_num_of_logic_registers),	--: in std_logic_vector(g_data_width-1 downto 0);
		po_data				=> s_phys_reg_3_aux									--: out std_logic_vector(g_data_width-1 downto 0)
	);


--	PHYS_REG_3_AUX_OH_DELAYER_INST: entity work.data_delayer generic map (
--		g_data_width		=> g_num_of_phys_registers,						--: natural := 64;
--		g_delay				=> 2														--: natural := 4
--	)
--	port map (
--		pi_clk				=> pi_clk,												--: in std_logic;
--		pi_data				=> s_phys_reg_oh(g_num_of_logic_registers),	--: in std_logic_vector(g_data_width-1 downto 0);
--		po_data				=> s_phys_reg_3_aux_oh								--: out std_logic_vector(g_data_width-1 downto 0)
--	);


	REG_ALL_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		OR_GATE_INST: entity work.or_gate generic map (
			g_latency		=> c_or_gate_latency			--: natural
		)
		port map (
			pi_clk			=> pi_clk,						--: in std_logic;
			pi_data			=> s_or_gate_oh_in(i),		--: in std_logic_vector(16 downto 0);
			po_data			=> s_phys_reg_all_oh(i)		--: out std_logic
		);

	end generate;


	--------------------
	-- SIGNAL MAPPING --
	--------------------

	-- PHYS 2 MUX
	PHYS_REG_2_MUX_IN_GEN: for i in 0 to g_num_of_logic_registers-1 generate
		MUX_REG_IN_GEN: for j in 0 to g_reg_phys_addr_width-1 generate
			s_mux_reg_in(j)(i) <= s_phys_reg(i)(j);
		end generate;
	end generate;

	-- PHYS 2 MUX_OH
	PHYS_REG_2_MUX_OH_IN_GEN: for i in 0 to g_num_of_logic_registers-1 generate
		MUX_REG_OH_IN_GEN: for j in 0 to g_num_of_phys_registers-1 generate
			s_mux_reg_oh_in(j)(i) <= s_phys_reg_oh(i)(j);
		end generate;
	end generate;

	-- PHYS 2 OR_GATE
	PHYS_REG_2_OR_GATE_OH_IN_GEN: for i in 0 to g_num_of_phys_registers-1 generate
		OR_GATE_OH_IN_GEN: for j in 0 to g_num_of_phys_registers-1 generate
			s_or_gate_oh_in(j)(i) <= s_phys_reg_oh(i)(j);
		end generate;
	end generate;

	-- PHYS 2 SHADOW_DATA
	SHADOW_DATA_GEN: for i in 0 to g_num_of_phys_registers-g_num_of_logic_registers-1 generate
		s_shadow_data(g_reg_phys_addr_width*(i+1)-1 downto g_reg_phys_addr_width*i) <= s_phys_reg(i+g_num_of_logic_registers);
		s_shadow_data_oh(g_num_of_phys_registers*(i+1)-1 downto g_num_of_phys_registers*i) <= s_phys_reg_oh(i+g_num_of_logic_registers);
	end generate;



	-- PHYSICAL REGISTER OUT

	PHYS_REG_GEN: for i in 0 to g_reg_phys_addr_width-1 generate

		MUX_LOGIC_REG_1_INST: entity work.mux_auto_logic generic map (
			g_latency					=> 1									--: boolean := true
		)
		port map (
			pi_clk						=> pi_clk,							--: in std_logic;
			pi_addr						=> pi_logic_reg_1,				--: in std_logic_vector(3 downto 0);
			pi_data						=> s_mux_reg_in(i),				--: in std_logic_vector(15 downto 0);
			po_data						=> s_phys_reg_1(i)				--: out std_logic
		);

		MUX_LOGIC_REG_2_INST: entity work.mux_auto_logic generic map (
			g_latency					=> 1									--: boolean := true
		)
		port map (
			pi_clk						=> pi_clk,							--: in std_logic;
			pi_addr						=> pi_logic_reg_2,				--: in std_logic_vector(3 downto 0);
			pi_data						=> s_mux_reg_in(i),				--: in std_logic_vector(15 downto 0);
			po_data						=> s_phys_reg_2(i)				--: out std_logic
		);

		MUX_LOGIC_REG_3_INST: entity work.mux_auto_logic generic map (
			g_latency					=> 1									--: boolean := true
		)
		port map (
			pi_clk						=> pi_clk,							--: in std_logic;
			pi_addr						=> pi_logic_reg_3,				--: in std_logic_vector(3 downto 0);
			pi_data						=> s_mux_reg_in(i),				--: in std_logic_vector(15 downto 0);
			po_data						=> s_phys_reg_3(i)				--: out std_logic
		);

	end generate;



	-- PHYSICAL REGISTER ONE HOT OUT

	REG_OH_GEN: for i in 0 to g_num_of_phys_registers-1 generate

		MUX_LOGIC_REG_1_OH_INST: entity work.mux_auto_logic generic map (
			g_latency					=> 1									--: boolean := true
		)
		port map (
			pi_clk						=> pi_clk,							--: in std_logic;
			pi_addr						=> pi_logic_reg_1,				--: in std_logic_vector(3 downto 0);
			pi_data						=> s_mux_reg_oh_in(i),			--: in std_logic_vector(15 downto 0);
			po_data						=> s_phys_reg_1_oh(i)			--: out std_logic
		);

		MUX_LOGIC_REG_2_OH_INST: entity work.mux_auto_logic generic map (
			g_latency					=> 1									--: boolean := true
		)
		port map (
			pi_clk						=> pi_clk,							--: in std_logic;
			pi_addr						=> pi_logic_reg_2,				--: in std_logic_vector(3 downto 0);
			pi_data						=> s_mux_reg_oh_in(i),			--: in std_logic_vector(15 downto 0);
			po_data						=> s_phys_reg_2_oh(i)			--: out std_logic
		);

		MUX_LOGIC_REG_3_OH_INST: entity work.mux_auto_logic generic map (
			g_latency					=> 1									--: boolean := true
		)
		port map (
			pi_clk						=> pi_clk,							--: in std_logic;
			pi_addr						=> pi_logic_reg_3,				--: in std_logic_vector(3 downto 0);
			pi_data						=> s_mux_reg_oh_in(i),			--: in std_logic_vector(15 downto 0);
			po_data						=> s_phys_reg_3_oh(i)			--: out std_logic
		);

	end generate;





	CPU_MAPPER_SWAPPER_INST: entity work.cpu_mapper_swapper generic map (
		g_num_of_logic_registers	=> g_num_of_logic_registers		--: natural := 16;
	)
	port map (
		pi_clk							=> pi_clk,								--: in std_logic;
		pi_rst							=> pi_rst,								--: in std_logic;
		pi_swap_pre						=> pi_swap_pre,						--: in std_logic;
		pi_logic_reg_oh				=> pi_logic_reg_3_oh,				--: in std_logic_vector(g_num_of_logic_registers-1 downto 0);
		pi_swap_post					=> pi_swap_post,						--: in std_logic;
		pi_swap_post_en				=> pi_swap_post_en,					--: in std_logic;
		po_shadow_reg_swap			=> s_shadow_reg_swap,				--: out std_logic;
		po_main_reg_swap				=> s_main_reg_swap					--: out std_logic_vector(g_num_of_logic_registers-1 downto 0)
	);




	CPU_MAPPER_SWAPPER_A2M_INST: entity work.cpu_mapper_swapper_a2m generic map (
		g_reg_phys_addr_width			=> g_reg_phys_addr_width,			--: natural := 5;
		g_num_of_logic_registers		=> g_num_of_logic_registers,		--: natural := 16;
		g_num_of_phys_registers			=> g_num_of_phys_registers,		--: natural := 16;
		g_num_of_shadow_registers		=> c_num_of_shadow_registers,		--: natural := 2;
		g_reg_shadow_addr_width			=> c_reg_shadow_addr_width			--: natural := 1
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_swap_pre							=> pi_swap_pre,						--: in std_logic;
		pi_dest_logic_reg_oh				=> pi_logic_reg_3_oh,				--: in std_logic_vector(g_num_of_logic_registers-1 downto 0);
		pi_shadow_channel					=> r_aux_reg_index,					--: in std_logic_vector(g_reg_shadow_addr_width-1 downto 0);
		pi_data								=> s_shadow_data,						--: in std_logic_vector(g_num_of_shadow_registers*g_reg_phys_addr_width-1 downto 0);
		po_data								=> s_swap_data,						--: out std_logic_vector(g_num_of_logic_registers*g_reg_phys_addr_width-1 downto 0);
		pi_data_oh							=> s_shadow_data_oh,					--: in std_logic_vector(g_num_of_shadow_registers*g_num_of_phys_registers-1 downto 0);
		po_data_oh							=> s_swap_data_oh						--: out std_logic_vector(g_num_of_logic_registers*g_num_of_phys_registers-1 downto 0);
	);



	CPU_MAPPER_SWAPPER_M2A_INST: entity work.cpu_mapper_swapper_m2a generic map (
		g_reg_phys_addr_width			=> g_reg_phys_addr_width,			--: natural := 5;
		g_num_of_phys_registers			=> g_num_of_phys_registers,		--: natural := 16;
		g_num_of_shadow_registers		=> c_num_of_shadow_registers,		--: natural := 2;
		g_reg_shadow_addr_width			=> c_reg_shadow_addr_width			--: natural := 1
	)
	port map (
		pi_clk								=> pi_clk,								--: in std_logic;
		pi_swap_pre							=> pi_swap_pre,						--: in std_logic;
		pi_shadow_channel					=> r_aux_reg_index,					--: in std_logic_vector(g_reg_shadow_addr_width-1 downto 0);
		pi_data								=> s_phys_reg_3,						--: in std_logic_vector(g_reg_phys_addr_width-1 downto 0);
		pi_data_oh							=> s_phys_reg_3_oh,					--: in std_logic_vector(g_num_of_phys_registers-1 downto 0);
		po_data								=> s_origin,							--: out std_logic_vector(g_num_of_shadow_registers*g_reg_phys_addr_width-1 downto 0);
		po_data_oh							=> s_origin_oh							--: out std_logic_vector(g_num_of_shadow_registers*g_num_of_phys_registers-1 downto 0)
	);



	process(pi_clk)
	begin
		if(rising_edge(pi_clk)) then

			-----------------
			-- R_SECONDARY --
			-----------------
			if(pi_rst = '1') then
				r_aux_reg_index <= (others=>'0');
			else

				if(pi_swap_pre = '1') then
					if(r_aux_reg_index = g_num_of_phys_registers-g_num_of_logic_registers-1) then
						r_aux_reg_index <= (others=>'0');
					else
						r_aux_reg_index <= r_aux_reg_index + 1;
					end if;
				end if;

			end if;

		end if;
	end process;

end architecture;
