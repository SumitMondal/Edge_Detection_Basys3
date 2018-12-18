
--Engineer     : Sumit Mondal 
--Date         : 10/01/2018
--Name of file : tb_top_level.vhd
--Description  : test bench for top level

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.env.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;

entity tb_top_level is
	generic (
	   input_file_str   : string := "tb_top_level.txt"
	);
end tb_top_level;

architecture tb_arch of tb_top_level is
component top_level is 
port (
	clk		: in std_logic;
	rst		: in std_logic;
	vga_hsync	: out std_logic;
	vga_vsync	: out std_logic;
	r		: out std_logic_vector(3 downto 0);
	g		: out std_logic_vector(3 downto 0);
	b		: out std_logic_vector(3 downto 0)
);
end component top_level;


signal clk	: std_logic;
signal rst	: std_logic;
signal hsync	: std_logic;
signal vsync	: std_logic;
signal r	: std_logic_vector(3 downto 0);
signal g	: std_logic_vector(3 downto 0);
signal b	: std_logic_vector(3 downto 0);

constant T: time  := 10 ns;
file input_data_file : text;

begin

inst_cont : top_level port map(
	clk => clk,
	rst => rst,
	vga_hsync => hsync,
	vga_vsync => vsync,
	r => r,
	g => g,
	b => b
);

process 
  begin
    clk <= '0';
    wait for T/2;
    clk <= '1';
    wait for T/2;
end process;

sim_that_ish : process
variable input_data_line : line;
variable term_rst : std_logic;
begin
file_open(input_data_file, input_file_str, read_mode);

while not endfile(input_data_file) loop
	readline(input_data_file, input_data_line);
	read(input_data_line, term_rst);
	rst <= term_rst;
	wait until rising_edge(clk);
end loop;

file_close(input_data_file);
report "test complete";
stop(0);
end process;

end tb_arch;

