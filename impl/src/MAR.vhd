library ieee;
use ieee.std_logic_1164.all;

entity memory_address_register is 
generic(
  ADDR_WIDTH : integer := 32 
);
port(
  address_in : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  next_pc    : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  pc         : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  clk, reset : in std_logic
);
end entity memory_address_register;

architecture rtl of memory_address_register is 
  signal next_address : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin
  
  process(clk, address_in, reset)
  begin
    if rising_edge(clk) then
      pc <= next_address;
      next_pc <= address_in;
      next_address <= address_in when reset = '0' else (others => '0');
    end if;
  end process;

end architecture rtl;