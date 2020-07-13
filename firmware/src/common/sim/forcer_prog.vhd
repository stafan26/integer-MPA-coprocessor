library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

entity forcer_prog is
generic(
	g_filepath			: string := "i.txt";
	g_data_width		: natural := 64
);
port(
	pi_clk				: in std_logic;
	pi_rst				: in std_logic;

	po_m00_tdata		: out std_logic_vector(g_data_width-1 downto 0);
	po_m00_tlast		: out std_logic;
	po_m00_tvalid		: out std_logic;
	pi_m00_tready		: in std_logic
);
end forcer_prog;


architecture forcer_prog of forcer_prog is

	constant c_bits_in_byte								: natural := 8;
	constant c_num_of_portions							: natural := g_data_width / c_bits_in_byte;
	constant c_ctrl_words								: natural := 1;
	constant c_num_of_words								: natural := c_num_of_portions + c_ctrl_words;

	TYPE t_char_file is FILE OF character;
	file file_in											: t_char_file;

	signal r_opened										: std_logic;
	signal r_closed										: std_logic;

	signal r_tdata											: std_logic_vector(g_data_width-1 downto 0);
	signal r_tlast											: std_logic;
	signal r_tvalid										: std_logic;

begin

	po_m00_tdata <= r_tdata;
	po_m00_tlast <= r_tlast;
	po_m00_tvalid <= r_tvalid;

	process(pi_clk)
		variable char_buffer				: character;
		variable t_tmp						: std_logic_vector(c_bits_in_byte-1 downto 0);
		variable v_tdata					: std_logic_vector(g_data_width-1 downto 0);
	begin

		if(rising_edge(pi_clk)) then

			if(pi_rst = '1') then

				r_tdata <= (others=>'0');
				r_tlast <= '0';
				r_tvalid <= '0';

				r_opened <= '0';
				r_closed <= '0';

			else

				if(r_closed = '0' and pi_m00_tready = '1') then
					if(r_opened = '0') then
						file_open(file_in, g_filepath, read_mode);  -- open the frame file for reading
						r_opened <= '1';
					end if;

					if(not endfile(file_in)) then
						for i in 0 to c_num_of_portions-1 loop
							read(file_in, char_buffer);
							v_tdata := std_logic_vector(to_unsigned(character'pos(char_buffer), c_bits_in_byte)) & v_tdata(v_tdata'length-1 downto c_bits_in_byte);
						end loop;
						read(file_in, char_buffer);
						t_tmp := std_logic_vector(to_unsigned(character'pos(char_buffer), 8));

						r_tdata <= v_tdata;
						r_tlast <= t_tmp(0);
						r_tvalid <= '1';
					else
						file_close(file_in);
						r_closed <= '1';
						r_tvalid <= '0';
					end if;

				end if;
			end if;
		end if;

	end process;


end forcer_prog;
