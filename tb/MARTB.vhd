library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity MARTB is 
end entity MARTB;

architecture sim of MARTB is 
  constant ADDR_WIDTH_TB : integer := 32;
  constant CLK_FREQ      : integer := 20e6;
  constant CLK_PERIOD    : time    := 1000 ms / CLK_FREQ;

  signal address_in_tb  : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal wre_tb         : std_logic;
  signal clk_tb         : std_logic := '0';
begin

  UUT: entity work.memory_address_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_in  => address_in_tb,
    address_out => address_out_tb,
    wre         => wre_tb,
    clk         => clk_tb
  );

  clk_tb <= not clk_tb after CLK_PERIOD / 2;

  stimuli: process
  begin
    wre_tb        <= '0';
    wait until rising_edge(clk_tb);
    address_in_tb <= x"aaaaffff";
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    assert address_out_tb = x"aaaaffff" report "Write not performed correctly" severity failure;
    wait;
  end process stimuli;

end architecture sim;