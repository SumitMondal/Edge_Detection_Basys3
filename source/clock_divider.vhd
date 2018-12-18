--Author     : Jaison George
--Date         : 11/14/18
--Name of file : clock_divider.vhd
--Description  : generates 25MHz clock from 100 MHz mclk

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
port(
 clk         : in  std_logic;
-- rst         : in  std_logic;
 clk_out   : out std_logic
);
end clock_divider;

architecture bev of clock_divider is
 begin
   clk_div_by_4 : process(clk)
     variable counter : integer :=0;
     variable flag1 : std_logic :='0';      
     begin
--       if(rst='1') then
--         counter  := 0;
--         flag1 := '0';
--       else
         if(rising_edge(clk)) then
           counter := counter +1;
           if counter = 2 then
             flag1 := not flag1;
             counter :=0;
           end if;
         end if;
         clk_out <= flag1;
--       end if;
   end process;
end bev;
