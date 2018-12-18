--Engineer     : Sumit Mondal
--Date         : 
--Name of file : BRAM_IO.vhd
--Description  : BRAM IO before final VGA outpt
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;


entity BRAM_IO is 
   port(
	clk	: in std_logic;
	en_a	: in std_logic;
	en_b	: in std_logic;
	wea	: in std_logic;
	din	: in std_logic_vector(7 downto 0);
	dout	: out std_logic_vector(7 downto 0);
	addra	: in std_logic_vector(16 downto 0);
	addrb	: in std_logic_vector(16 downto 0)
   );
end BRAM_IO;

architecture arch of BRAM_IO is

type rom_type is array(76799 downto 0) of std_logic_vector(7 downto 0);

--impure function InitRomFromFile (RomFileName : in string) return rom_type is
--  file romfile : text is in RomFileName;
--  variable RomFileLine : line;
--  variable rom : rom_type;
--   begin
--     for i in rom_type'range loop
--       readline(romfile,RomFileLine);
--       read(RomFileLine,rom(i));
--     end loop;
--   return rom;
-- end function;

--signal rom : rom_type := InitRomFromFile ("/nethome/smondal30/dsp_hw/vga_controller/run/test.data");

shared variable rom : rom_type;

begin

get_data : process(clk)
begin 
if rising_edge(clk) then
if en_a = '1' then
 if wea = '1' then
 rom(conv_integer(addra)) := din;
 --rom(conv_integer(addra)) <= din;
 end if;
end if;
end if;
end process;

give_data : process(clk)
begin
if rising_edge(clk) then
if en_b = '1' then
 dout <= rom(conv_integer(addrb));
end if;
end if;
end process;

end arch;




