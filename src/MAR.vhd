library ieee;
use ieee.std_logic_1164.all;

entity memory_address_register is
generic(
  ADDR_WIDTH : integer := 32
);
port(
  address_in     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  next_pc        : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  pc             : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  clk, reset, en : in std_logic
);
end entity memory_address_register;

architecture rtl of memory_address_register is
  signal next_address : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal address      : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

  next_pc <= next_address;
  pc      <= address;

  process(clk, address_in, reset, en)
  begin
    if rising_edge(clk) then
      if en = '1' then
        address <= next_address when reset = '0' else (others => '0');
        next_address <= address_in when reset = '0' else (others => '0');
      else
        address <= address;
        next_address <= address;
      end if;
    end if;
  end process;

end architecture rtl;
