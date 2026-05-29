library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instruction_mem is
generic(
  ADDR_WIDTH : integer := 32;
  DATA_WIDTH    : integer := 32
);
port(
  clk      : in std_logic;
  en       : in std_logic;
  address  : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0)
);
end entity instruction_mem;

architecture rtl of instruction_mem is
  type memory_t is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(31 downto 0);

  impure function init_mem return memory_t is
    file init_file : text open read_mode is "";
    variable buf : line;
    variable ram_content : memory_t;
    variable i : integer := 0;
  begin
    while not endfile(init_file) loop
      readline(init_file, buf);
      hread(buf, ram_content(i));
      i := i + 1;
    end loop;
    ram_content(i to 4095) := (others => x"00000013");
    return ram_content;
  end function;

  signal memory : memory_t := init_mem;
begin

  process(clk, en, address)
  begin
    if rising_edge(clk) then
      data_out <= memory(to_integer(unsigned(address))) when en = '1' else (others => '0');
    end if;
  end process;

end architecture rtl;