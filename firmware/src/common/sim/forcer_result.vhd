library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use STD.textio.all;
use ieee.std_logic_textio.all;

use work.my_pack.all;

entity forcer_result is
generic(
	g_filepath			: string := "i.txt";
	g_data_width		: natural := 64
);
port(
	pi_clk				: in std_logic;
	pi_rst				: in std_logic;

	pi_close				: in std_logic;

	pi_m00_tdata		: in std_logic_vector(g_data_width-1 downto 0);
	pi_m00_tvalid		: in std_logic;
	po_m00_tready		: out std_logic
);
end forcer_result;


architecture forcer_result of forcer_result is

	constant c_bits_in_byte								: natural := 8;
	constant c_num_of_portions							: natural := g_data_width / c_bits_in_byte;
	constant c_ctrl_words								: natural := 1;
	constant c_num_of_words								: natural := c_num_of_portions + c_ctrl_words;

	TYPE t_char_file is FILE OF character;
	file file_in											: t_char_file;

	signal r_opened										: std_logic;
	signal r_closed										: std_logic;

	signal r_tdata											: std_logic_vector(g_data_width-1 downto 0);

begin

	po_m00_tready <= r_opened;

	process(pi_clk)
		variable char_buffer				: character;
		variable v_tdata					: std_logic_vector(g_data_width-1 downto 0);
		variable f_status					: file_open_status;
	begin

		if(rising_edge(pi_clk)) then

			if(pi_rst = '1') then

				r_tdata <= (others=>'0');

				r_opened <= '0';
				r_closed <= '0';

			else

				if(r_closed = '0') then
					if(r_opened = '0') then
						file_open(f_status, file_in, g_filepath, write_mode);  -- open the frame file for writing
						r_opened <= '1';
					end if;

					if(r_opened = '1' and pi_m00_tvalid = '1') then
						for i in 0 to c_num_of_portions-1 loop
							char_buffer := character'val(to_natural(pi_m00_tdata((i+1)*c_bits_in_byte-1 downto i*c_bits_in_byte)));
							write(file_in, char_buffer);
						end loop;

						r_tdata <= v_tdata;
					end if;

					if(pi_close = '1') then
						file_close(file_in);
						r_opened <= '0';
						r_closed <= '1';
					end if;

				end if;
			end if;
		end if;

	end process;

end forcer_result;
