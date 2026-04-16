library ieee;
use ieee.std_logic_1164.all;

entity pctb is 
end entity pctb;

architecture sim of pctb is 

  constant ADDR_WIDTH_TB : integer := 32;
  constant CLK_FREQ      : integer := 20e6;
  constant CLK_PERIOD    : time    := 1000 ms / CLK_FREQ;

  signal pc_in_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal pc_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal wre_tb : std_logic;
  signal clk_tb : std_logic := '0';
  signal reset_tb : std_logic;

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

  UUT: entity work.program_counter(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    pc_in => pc_in_tb,
    pc_out => pc_out_tb,
    wre => wre_tb,
    clk => clk_tb,
    reset => reset_tb
  );


  stimuli: process
  begin
    reset_tb <= '1';
    wait until rising_edge(clk_tb);
    reset_tb <= '0';
    pc_in_tb <= x"00000004";
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    wait for 1 ns;
    assert pc_out_tb = x"00000004" report "Contents shown at pc_out are incorrect" severity failure;
    wre_tb <= '0';
    wait;
    
  end process;

end architecture sim;