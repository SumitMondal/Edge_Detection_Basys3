
--Engineer     : Sumit Mondal
--Date         : 
--Name of file : top_level.vhd
--Description  : file connected all clusters and outputting to pins
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use std.textio.all;


entity top_level is 
port (
	clk		: in std_logic;
	rst		: in std_logic;
	vga_hsync	: out std_logic;
	vga_vsync	: out std_logic;
	r		: out std_logic_vector(3 downto 0);
	g		: out std_logic_vector(3 downto 0);
	b		: out std_logic_vector(3 downto 0)
);
end top_level;

architecture arch of top_level is

component clock_divider is
   port(
 	clk         : in  std_logic;
-- 	rst         : in  std_logic;
 	clk_out   : out std_logic
);
end component clock_divider;

component BRAM_out is
   port(
	clk	: in std_logic;
	px_out	: out std_logic_vector(7 downto 0);
	out_valid : out std_logic
   );
end component BRAM_out;


component sobel_buffer is 
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
end component sobel_buffer;



component sobel_top is
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
        --threshold_val  : in std_logic_vector (7 downto 0);
        in_valid       : in std_logic;
        -- output side
        out_valid      : out std_logic;
        sobel_done     : out std_logic;
        p_out          : out std_logic_vector (7 downto 0);
        w_addr         : out std_logic_vector (16 downto 0)
       );
end component sobel_top;


component vga_controller is 
   port(
	clk	: in std_logic;
	rst	: in std_logic;
	sobel	: in std_logic;
	pixel	: out std_logic_vector(7 downto 0);
	din	: in std_logic_vector(7 downto 0);
	Hsync	: out std_logic;
	Vsync	: out std_logic;
	r_en	: out std_logic;
	addr	: out std_logic_vector(16 downto 0)
   );
end component vga_controller;


component BRAM_IO
port (
	clk	: in std_logic;
	en_a	: in std_logic;
	en_b	: in std_logic;
	wea	: in std_logic;
	din	: in std_logic_vector(7 downto 0);
	dout	: out std_logic_vector(7 downto 0);
	addra	: in std_logic_vector(16 downto 0);
	addrb	: in std_logic_vector(16 downto 0)
);
end component BRAM_IO;


-- for clk divider
signal clk_out : std_logic;

-- for bram out
signal bram_pix	: std_logic_vector( 7 downto 0);
signal bram_valid	: std_logic;


-- for sobel_buffer
signal buffer_valid	: std_logic;
signal p0_out		: std_logic_vector(7 downto 0);
signal p1_out		: std_logic_vector(7 downto 0);
signal p2_out		: std_logic_vector(7 downto 0);
signal p3_out		: std_logic_vector(7 downto 0);
signal p4_out		: std_logic_vector(7 downto 0);
signal p5_out		: std_logic_vector(7 downto 0);
signal p6_out		: std_logic_vector(7 downto 0);
signal p7_out		: std_logic_vector(7 downto 0);
signal p8_out		: std_logic_vector(7 downto 0);

-- for sobel
signal sobel_valid	: std_logic;
signal sobel_done	: std_logic;
signal p_out		: std_logic_vector(7 downto 0);
signal w_addr		: std_logic_vector(16 downto 0);
--signal threshold_val	: std_logic_vector(7 downto 0);

--for VGA controller
signal Hsync : std_logic;
signal Vsync : std_logic;
signal r_en	: std_logic;
signal r_addr	: std_logic_vector(16 downto 0);
signal pixel 	: std_logic_vector(7 downto 0);


-- for BRAM
signal en_a : std_logic;
signal wea  : std_logic;
signal din  : std_logic_vector(7 downto 0);
signal dout_bramio : std_logic_vector(7 downto 0);
signal addra	: std_logic_vector(16 downto 0); 


begin
inst_clk_div : clock_divider port map(
	clk => clk,
--	rst => rst,
	clk_out => clk_out
);


inst_bram_out	: BRAM_out port map(
	clk => clk_out,
	px_out => bram_pix,
	out_valid => bram_valid
);

inst_buffer	: sobel_buffer port map(
	clk => clk_out,
	rst => rst,
	in_valid => bram_valid,
	pixel => bram_pix,
	px0 => p0_out,
	px1 => p1_out,
	px2 => p2_out,
	px3 => p3_out,
	px4 => p4_out,
	px5 => p5_out,
	px6 => p6_out,
	px7 => p7_out,
	px8 => p8_out,
	out_valid => buffer_valid
);


inst_sobel : sobel_top port map(
	pclk => clk_out,
	rst => rst,
	p0_in => p0_out,
	p1_in => p1_out,
	p2_in => p2_out,
	p3_in => p3_out,
	p4_in => p4_out,
	p5_in => p5_out,
	p6_in => p6_out,
	p7_in => p7_out,
	p8_in => p8_out,
	--threshold_val => threshold_val,
	in_valid => buffer_valid,
	out_valid => sobel_valid,
	sobel_done => sobel_done,
	p_out => p_out,
	w_addr => w_addr
);

inst_IO : BRAM_IO port map(
	clk => clk_out,
	en_a => sobel_valid,
	en_b => r_en,
	wea => sobel_valid,
	din => p_out,
	dout => dout_bramio,
	addra => w_addr,
	addrb => r_addr
);


inst_vga_controller : vga_controller port map(
	clk => clk_out,
	rst => rst,
	sobel => sobel_done,
	pixel => pixel,
	din => dout_bramio,
	Hsync => Hsync,
	Vsync => Vsync,
	r_en => r_en,
	addr => r_addr
);

vga_hsync <= Hsync;
vga_vsync <= Vsync;

r <= pixel(3 downto 0);
g <= pixel(3 downto 0);
b <= pixel(3 downto 0);

--final : process(clk_out)
--begin
--if rising_edge(clk_out) then
-- if rst = '1' then
-- vga_hsync <= '0';
-- vga_vsync <= '0';
-- r <= (others =>'0');
-- g <= (others =>'0');
-- b <= (others =>'0');
-- else
-- vga_hsync <= Hsync;
-- vga_vsync <= Vsync;
-- r <= pixel(3 downto 0);
-- g <= pixel(3 downto 0);
-- b <= pixel(3 downto 0);
--end if;
--end if;
--end process;

end arch;

