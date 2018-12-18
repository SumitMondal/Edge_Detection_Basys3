--Author       : Alex Saad-Falcon and Jaison George
--Date         : 11/28/18
--Name of file : sobel_kernel.vhd
--Description  : applies 3x3 sobel filter on img stream

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sobel_top is
  port (
        -- input side
        pclk, rst      : in std_logic;
        p0_in          : in std_logic_vector (7 downto 0);
        p1_in          : in std_logic_vector (7 downto 0);
        p2_in          : in std_logic_vector (7 downto 0);
        p3_in          : in std_logic_vector (7 downto 0);
        p4_in          : in std_logic_vector (7 downto 0);
        p5_in          : in std_logic_vector (7 downto 0);
        p6_in          : in std_logic_vector (7 downto 0);
        p7_in          : in std_logic_vector (7 downto 0);
        p8_in          : in std_logic_vector (7 downto 0);
       -- threshold_val  : in std_logic_vector (7 downto 0);
        in_valid       : in std_logic;
        -- output side
        out_valid      : out std_logic;
        sobel_done     : out std_logic;
        p_out          : out std_logic_vector (7 downto 0);
        w_addr         : out std_logic_vector (16 downto 0)
       );
end sobel_top;
architecture arch of sobel_top is
  signal sum_x : signed(12 downto 0);
  signal sum_y : signed(12 downto 0);
  signal in_valid_reg_s0 : std_logic;
  signal sum_x_y : unsigned(7  downto 0);
  signal in_valid_reg_s1 : std_logic;
  signal p_out_reg : unsigned(7 downto 0);
  signal in_valid_reg_s2 : std_logic;
  signal sobel_done_reg : std_logic;
  signal count_reg : integer := 0;
  signal threshold_val : std_logic_vector(7 downto 0) := "00000000";

  begin
  --stage 0
  sobel_s0 : process(pclk)
   begin
    if(rising_edge(pclk)) then
      if rst = '1' then
        sum_x <=  (others => '0');
        sum_y <=  (others => '0');
        in_valid_reg_s0 <= '0';
      else
        in_valid_reg_s0 <= in_valid;
        if in_valid = '1' then
              sum_x <= abs(signed(resize(unsigned(p6_in),13)) + signed(resize(shift_left(unsigned(p7_in), 1),13)) + signed(resize(unsigned(p8_in),13)) -
			signed(resize(unsigned(p0_in),13)) - signed(resize(shift_left(unsigned(p1_in), 1),13)) - signed(resize(unsigned(p2_in),13)));
              sum_y <= abs(signed(resize(unsigned(p2_in),13)) + signed(resize(shift_left(unsigned(p5_in), 1),13)) + signed(resize(unsigned(p8_in),13)) - 
			signed(resize(unsigned(p0_in),13)) - signed(resize(shift_left(unsigned(p3_in), 1),13)) - signed(resize(unsigned(p6_in),13)));
        end if;
      end if;
    end if;
  end process;

  sobel_s1 : process(pclk)
  begin
    if(rising_edge(pclk)) then
      if rst = '1' then
        sum_x_y <=  (others => '0');
        in_valid_reg_s1 <= '0';
      else
        in_valid_reg_s1 <= in_valid_reg_s0;
        if in_valid_reg_s0 = '1' then
          sum_x_y <= unsigned(sum_x(10 downto 3)) + unsigned(sum_y(10 downto 3));
        end if;
       end if;
    end if;
  end process;

  sobel_s3 : process(pclk)
  begin
    if(rising_edge(pclk)) then
      if rst = '1' then
        p_out_reg <=  (others => '0');
        in_valid_reg_s2 <= '0';
        count_reg <= 0;
        sobel_done_reg <= '0';
      else
        in_valid_reg_s2 <= in_valid_reg_s1;
        if in_valid_reg_s1 = '1' then
          if count_reg < 76799 then 
            if sum_x_y >= unsigned(threshold_val) then 
              p_out_reg <= sum_x_y;
              count_reg <= count_reg + 1;
              sobel_done_reg <= '0';
            else
              p_out_reg <= (others => '0');
              count_reg <= count_reg + 1;
              sobel_done_reg <= '0';
            end if;
          else
            if sum_x_y >= unsigned(threshold_val) then 
              p_out_reg <= sum_x_y;
              count_reg <= 0;
              sobel_done_reg <= '1';
            else
              p_out_reg <= (others => '0');
              count_reg <= 0;
              sobel_done_reg <= '1';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

being_done : process(pclk)
begin
if rising_edge(pclk) then
if rst = '1' then
sobel_done <= '0';
else
if sobel_done_reg = '1' then
sobel_done <= '1';
end if;
end if;
end if;
end process;

  p_out <= std_logic_vector(p_out_reg);
  out_valid <= in_valid_reg_s2;
  --count_reg is one ahead of pixel output, so this is the old way
  --w_addr <= std_logic_vector(to_unsigned(count_reg, w_addr'length))
  -- this is the  new way
  w_addr <= "10010101111111111" when count_reg = 0 else std_logic_vector(to_unsigned(count_reg - 1, w_addr'length));
  --sobel_done <= sobel_done_reg;

end arch;




