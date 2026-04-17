library ieee;
use ieee.std_logic_1164.all;

entity memory_address_register is 
generic(
  ADDR_WIDTH : integer := 32 
);
port(
  address_in      : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address_out     : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  clk, wre, reset : in std_logic
);
end entity memory_address_register;

architecture rtl of memory_address_register is 
  signal address : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

  address_out <= address;

  process(clk, wre, address_in)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        address <= address_in when wre = '1' else address;
      else 
        address <= (others => '0');
      end if;
    end if;
  end process;

end architecture rtl;