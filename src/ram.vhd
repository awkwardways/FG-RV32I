library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram is
generic(
  DATA_WIDTH : integer := 8
);
port(
  clk     : in std_logic;
  wre     : in std_logic;
  en      : in std_logic;
  address : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  din     : in std_logic_vector(DATA_WIDTH - 1 downto 0)
);
end entity ram;

architecture rtl of ram is
  type memory_t is array (0 to 2 ** DATA_WIDTH - 1) of std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal memory : memory_t := (others => x"AA");
begin
  process(clk, wre, en, address, din)
  begin
    if rising_edge(clk) then
      if en = '1' then
        dout   <= memory(to_integer(unsigned(address))) when wre = '0' else (others => '0');
        memory(to_integer(unsigned(address))) <= din when wre = '1' else memory(to_integer(unsigned(address)));
      end if;
    end if;
  end process;
end architecture;
