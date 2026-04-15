library ieee;
use ieee.std_logic_1164.all;

entity memory_data_register is
generic(
  DATA_WIDTH : integer := 32
);
port(
  ram_data_bus : inout std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => 'Z');
  cpu_data_bus : inout std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => 'Z');
  cpu_bus_wre  : in std_logic;
  cpu_bus_en   : in std_logic;
  ram_bus_wre  : in std_logic;
  ram_bus_en   : in std_logic;
  clk          : in std_logic
);
end entity memory_data_register;

architecture rtl of memory_data_register is
  signal data : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
begin

  cpu_bus: process(clk, cpu_bus_wre, cpu_data_bus, cpu_bus_en, ram_bus_wre, ram_data_bus, ram_bus_en)
  begin
    if rising_edge(clk) and cpu_bus_en = '1' then
      if cpu_bus_wre = '1' then
        data <= cpu_data_bus;
      else
        cpu_data_bus <= data;
      end if;
    elsif rising_edge(clk) and cpu_bus_en = '0' then
      cpu_data_bus <= (others => 'Z');
    end if;

    if rising_edge(clk) and ram_bus_en = '1' then
      if ram_bus_wre = '1' then
        data <= ram_data_bus;
      else
        ram_data_bus <= data;
      end if;
    elsif rising_edge(clk) and ram_bus_en = '0' then
      ram_data_bus <= (others => 'Z');
    end if;
  end process;

end architecture rtl;
