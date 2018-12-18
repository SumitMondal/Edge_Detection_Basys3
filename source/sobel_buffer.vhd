--Engineer     : Sumit Mondal
--Date         : 
--Name of file : sobel_buffer
--Description  : sobel buffer for Basys 3 board
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;


entity sobel_buffer is 
   port(
	clk,rst	: in  std_logic;
	in_valid	: in std_logic;
	pixel	: in  std_logic_vector(7 downto 0);
	px0	: out std_logic_vector(7 downto 0);
	px1	: out std_logic_vector(7 downto 0);
	px2	: out std_logic_vector(7 downto 0);
	px3	: out std_logic_vector(7 downto 0);
	px4	: out std_logic_vector(7 downto 0);
	px5	: out std_logic_vector(7 downto 0);
	px6	: out std_logic_vector(7 downto 0);
	px7	: out std_logic_vector(7 downto 0);
	px8	: out std_logic_vector(7 downto 0);
	out_valid	: out std_logic
   );
end sobel_buffer;

architecture arch of sobel_buffer is
signal reg0 	: std_logic_vector(7 downto 0);
signal reg1 	: std_logic_vector(7 downto 0);
signal reg2 	: std_logic_vector(7 downto 0);
signal reg3 	: std_logic_vector(7 downto 0);
signal reg4 	: std_logic_vector(7 downto 0);
signal reg5 	: std_logic_vector(7 downto 0);
signal reg6 	: std_logic_vector(7 downto 0);
signal reg7 	: std_logic_vector(7 downto 0);
signal reg8 	: std_logic_vector(7 downto 0);
signal counter	: integer;
signal reg_valid	: std_logic;

begin

shift_reg : process(clk)
begin
if rising_edge(clk) then
 if rst = '1' then
 reg_valid <= '0';
 counter <= 0;
 else
 if in_valid = '1' then
 case counter is
 when 0 => 
	reg0 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 	
 when 1 => 
	reg1 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 
 when 2 => 
	reg2 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 	
 when 3 => 
	reg3 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1;  
when 4 => 
	reg4 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 
 when 5 => 
	reg5 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 
 when 6 => 
	reg6 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 
 when 7 => 
	reg7 <= pixel;
	reg_valid <= '0';
	counter <= counter + 1; 
 when 8 => 
	reg8 <= pixel;
	reg_valid <= '1';
	counter <= 0;
 when others => reg_valid <= '0';
 end case;
 end if;
end if;

end if;
end process;

sendit : process(clk)
begin
if rising_edge(clk) then
 if rst = '1' then
 out_valid <= '0';
 else
 out_valid <= reg_valid;
 if reg_valid = '1' then
  px0 <= reg0;
  px1 <= reg1;
  px2 <= reg2;
  px3 <= reg3;
  px4 <= reg4;
  px5 <= reg5;
  px6 <= reg6;
  px7 <= reg7;
  px8 <= reg8;
  end if;
 end if;
end if;
end process;

end arch;

