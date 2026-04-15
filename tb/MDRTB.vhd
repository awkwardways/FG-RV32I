library ieee;
use ieee.std_logic_1164.all;

entity mdrtb is
end entity mdrtb;

architecture sim of mdrtb is 
  constant DATA_WIDTH_TB : integer := 32;
  constant ADDR_WIDTH_TB : integer := 32;
  constant CLK_FREQ      : integer := 20e6;
  constant CLK_PERIOD    : time    := 1000 ms / CLK_FREQ;

  signal ram_data_bus_tb : std_logic_vector(DATA_WIDTH_TB - 1 downto 0) := (others => 'Z');
  signal ram_bus_en_tb   : std_logic;
  signal cpu_data_bus_tb : std_logic_vector(DATA_WIDTH_TB - 1 downto 0) := (others => 'Z');
  signal cpu_bus_en_tb   : std_logic;
  signal cpu_bus_wre_tb  : std_logic;
  signal ram_bus_wre_tb  : std_logic;
  signal address_in_tb   : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_out_tb  : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal wre_tb          : std_logic;
  signal clk_tb          : std_logic := '0';
begin

  UUT: entity work.memory_data_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    ram_data_bus => ram_data_bus_tb,
    ram_bus_en => ram_bus_en_tb,
    cpu_data_bus => cpu_data_bus_tb,
    cpu_bus_en => cpu_bus_en_tb,
    cpu_bus_wre => cpu_bus_wre_tb,
    ram_bus_wre => ram_bus_wre_tb,
    clk => clk_tb
  );

  MAR: entity work.memory_address_register(rtl)
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
    wre_tb <= '0';
    cpu_bus_wre_tb <= '1';
    cpu_bus_en_tb <= '0';
    ram_bus_wre_tb <= '0';
    ram_bus_en_tb <= '0';
    wait for 10 ns;
    cpu_bus_en_tb <= '1';
    cpu_data_bus_tb <= x"aaaaffff";
    wait until rising_edge(clk_tb);
    address_in_tb <= x"aaaaffff";
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    wre_tb <= '0';
    cpu_bus_en_tb <= '0';
    ram_bus_en_tb <= '1';
    wait;
  end process stimuli;

end architecture sim;

