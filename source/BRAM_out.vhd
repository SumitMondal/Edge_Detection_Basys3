
--Engineer     : Hariank Mistry
--Date         : 11/30/2018
--Name of file : tb_new_bram_out.vhd
--Description  : test bench for bram
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_arith.all;

entity BRAM_out is
   port(
	clk	: in std_logic;
	--addr	: in std_logic_vector(16 downto 0);
	px_out	: out std_logic_vector(7 downto 0);
	out_valid : out std_logic
   );
end BRAM_out;

architecture arch of BRAM_out is
  signal row : integer := 0;
  signal column : integer := -1;
  signal index : integer range 0 to 8 := 8;
  signal cycles : integer range 0 to 3 := 0;

  signal BRAM_PORTA_addr : STD_LOGIC_VECTOR( 16 downto 0) := (others => '0');
  signal BRAM_PORTA_clk : STD_LOGIC;
  signal BRAM_PORTA_din : STD_LOGIC_VECTOR ( 7 downto 0);
  signal BRAM_PORTA_dout : STD_LOGIC_VECTOR ( 7 downto 0);
  signal BRAM_PORTA_en : STD_LOGIC;
  signal BRAM_PORTA_we : STD_LOGIC_VECTOR ( 0 to 0 );
  signal valid1 : std_logic := '0';
  signal valid2 : std_logic := '0';
  signal valid3 : std_logic := '0';

  component BRAM_block_wrapper
  port (
    BRAM_PORTA_addr : in STD_LOGIC_VECTOR ( 16 downto 0 );
    BRAM_PORTA_clk : in STD_LOGIC;
    BRAM_PORTA_din : in STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_dout : out STD_LOGIC_VECTOR ( 7 downto 0 );
    BRAM_PORTA_en : in STD_LOGIC;
    BRAM_PORTA_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component BRAM_block_wrapper;

begin
  BRAM_PORTA_clk <= clk;
  BRAM_PORTA_en <= '1';
  BRAM_PORTA_we(0) <= '0';

  bram: BRAM_block_wrapper port map ( BRAM_PORTA_addr => BRAM_PORTA_addr,
                                     BRAM_PORTA_clk  => BRAM_PORTA_clk,
                                     BRAM_PORTA_din  => BRAM_PORTA_din,
                                     BRAM_PORTA_dout => BRAM_PORTA_dout,
                                     BRAM_PORTA_en   => BRAM_PORTA_en,
                                     BRAM_PORTA_we   => BRAM_PORTA_we );

  increment : process(clk)
  begin
  if rising_edge(clk) then
    if index = 8 then
      if column = 319 then
        column <= 0;
        if row = 239 then
          row <= 0;
        else
          row <= row + 1;
        end if;
      else
        column <= column + 1;
      end if;
      index <= 0;
    else
      index <= index + 1;
    end if;
    if cycles /= 3 then
      cycles <= cycles + 1;
      out_valid <= '0';
    else
      out_valid <= '1';
    end if;
  end if;
  end process;

  get_data : process(clk)
  begin
  if rising_edge(clk) then
    case index is
      when 0 =>
        if row = 0 or column = 0 then
          valid1 <= '0';
        else
          valid1 <= '1';
        	BRAM_PORTA_addr <= std_logic_vector(to_unsigned((row-1) * 320 + column - 1,17));
        end if;
      when 1 =>
        if row = 0 then
          valid1 <= '0';
        else
          valid1 <= '1';
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned((row-1) * 320 + column,17));
        end if;
      when 2 =>
        if row = 0 or column = 319 then
          valid1 <= '0';
        else
          valid1 <= '1';
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned((row-1) * 320 + column + 1,17));
        end if;
      when 3 =>
        if column = 0 then
          valid1 <= '0';
        else
          valid1 <= '1';
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned(row * 320 + column - 1,17));
        end if;
      when 4 =>
        valid1 <= '1';
        BRAM_PORTA_addr <= std_logic_vector(to_unsigned(row * 320 + column,17));
      when 5 =>
        if column = 319 then
          valid1 <= '0';
        else
          valid1 <= '1';
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned(row * 320 + column + 1,17));
        end if;
      when 6 =>
        if column = 0 or row = 239 then
          valid1 <= '0';
        else
          valid1 <= '1';
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned((row+1) * 320 + column -1,17));
        end if;
      when 7 =>
        if row = 239 then
          valid1 <= '0';
        else
          valid1 <= '1';
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned((row+1) * 320 + column,17));
        end if;
      when 8 =>
        if column = 319 or row = 239 then
          valid1 <= '0';
        else
          BRAM_PORTA_addr <= std_logic_vector(to_unsigned((row+1) * 320 + column + 1,17));
        end if;
      when others =>
        valid1 <= '1';
    end case;
  end if;
  end process;

  set_output : process(clk)
  begin
    if (rising_edge(clk)) then
    valid2 <= valid1;
    valid3 <= valid2;
      if (valid3 = '0') then
        px_out <= "00000000";
      else
        px_out <= BRAM_PORTA_dout;
      end if;
    end if;
  end process;

end arch;
