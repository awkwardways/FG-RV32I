library ieee;
use ieee.std_logic_1164.all;

entity memory_address_register is 
generic(
  ADDR_WIDTH : integer := 32 
);
port(
  address_in      : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  next_pc         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  pc              : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  clk, wre, reset : in std_logic
);
end entity memory_address_register;

architecture rtl of memory_address_register is 
  signal next_address : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal address      : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

  next_pc <= next_address;
  pc      <= address;

  process(clk, wre, address_in, reset)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        address <= next_address when wre = '1' else address;
        next_address <= address_in when wre = '1' else next_address;
      else 
        address <= (others => '0');
        next_address <= (others => '0');
      end if;
    end if;
  end process;

end architecture rtl;