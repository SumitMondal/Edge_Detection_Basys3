
--Engineer     : Sumit Mondal
--Date         : 
--Name of file : vga_controller.vhd
--Description  : VGA controller for Basys 3 board
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;



entity vga_controller is 
   port(
	clk,rst	: in std_logic;
	din	: in std_logic_vector(7 downto 0);
	sobel	: in std_logic;
	pixel	: out std_logic_vector(7 downto 0);
	Hsync	: out std_logic;
	Vsync	: out std_logic;
	r_en	: out std_logic;
	addr	: out std_logic_vector(16 downto 0)
   );
end vga_controller;

architecture arch of vga_controller is


signal Hcount : std_logic_vector(9 downto 0) := "0000000000";
signal Vcount : std_logic_vector(9 downto 0) := "1000001000";
signal pvalid : std_logic;
signal paddress : std_logic_vector(16 downto 0) := (others => '0');


constant Hs 	: integer := 799; --total sync period
constant Hdisp 	: integer := 640; -- number of pixels in a row
constant Hpw	: integer := 96; -- sync pulse period
constant Hfp	: integer := 16; -- front porch
constant Hbp	: integer := 48; -- back porch

constant Vs 	: integer := 524; --total sync period
constant Vdisp 	: integer := 480; -- number of pixels in a row
constant Vpw	: integer := 10; -- sync pulse period
constant Vfp	: integer := 33; -- front porch
constant Vbp	: integer := 2; -- back porch


signal reg_Hsync 	: std_logic;
signal reg_Vsync	: std_logic;
signal reg_pixel	: std_logic_vector(7 downto 0);
signal r_addr		: std_logic_vector(16 downto 0);

begin

--inst_IO : BRAM_IO port map(
--	clk => clk,
--	en_a => en_a,
--	en_b => r_en,
--	wea => wea,
--	din => din,
--	dout => dout,
--	addra => addra,
--	addrb => r_addr
--);



make_validity:process(clk)
begin
if rising_edge(clk) then
if rst = '1' then
 pvalid <= '0';
elsif sobel = '0' then
 pvalid <= '0';
else
 if Hcount = Hs then
 Hcount <= "0000000000";
  if Vcount = Vs then
  Vcount <= (others=>'0');
  pvalid <= '1';
  else
   if Vcount < 240-1 then
   pvalid <= '1';
   end if;
  Vcount <= Vcount + 1;
  end if;
 else
  if Hcount = 320 - 1 then
  pvalid <= '0';
  end if;
 Hcount <= Hcount + 1;
 end if;
end if;
end if;
end process;


make_hsync : process(clk)
begin
if rising_edge(clk) then
 if rst = '1' then
 reg_Hsync <= '0';
 elsif sobel = '0' then
 reg_Hsync <= '0';
 else
 if Hcount >= 656 and Hcount <= 751 then
 	reg_Hsync <= '0';
 else 
 	reg_Hsync <= '1';
 end if;
end if;
end if;
end process;

make_vsync : process(clk)
begin
if rising_edge(clk) then
 if rst = '1' then
 reg_Vsync <= '0';
 elsif sobel = '0' then
 reg_Vsync <= '0';
 else
 if Vcount >= 490 and Vcount <= 491 then
 reg_Vsync <= '0';
 else 
 reg_Vsync <= '1';
 end if;
end if;
end if;
end process;


send_data : process(clk)
begin
if rising_edge(clk) then
if rst = '1' then
reg_pixel <= (others => '0');
r_addr <= (others => '0');
r_en <= '0';
elsif sobel = '0' then
reg_pixel <= (others => '0');
r_addr <= (others => '0');
r_en <= '0';
else
 if pvalid = '1' then
   if r_addr > "10010101111111110" then
	r_addr <= (others => '0');
	r_en <= '1';
	reg_pixel <= din;
   else
 	r_en <= '1';
 	r_addr <= r_addr + "00000000000000001";
	reg_pixel <= din;
   end if;
else
 reg_pixel <= (others => '0');
 end if;
end if;
end if;
end process;



addr <= r_addr;
pixel <= reg_pixel;
Hsync <= reg_Hsync;
Vsync <= reg_Vsync;

end arch;




 



