library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity ram is
generic(
  ADDR_WIDTH : integer := 8;
  DATA_WIDTH : integer := 32;
  WORD_WIDTH : integer := 8
);
port(
  address : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  din     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  mask    : in std_logic_vector(1 downto 0);
  wre     : in std_logic;
  clk     : in std_logic
);
end entity ram;

architecture rtl of ram is
  type memory_t is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(WORD_WIDTH - 1  downto 0);

  signal memory : memory_t := (others => x"00");
  signal addr_p1 : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal addr_p2 : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal addr_p3 : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

  process(clk, wre, address, mask)
  begin
    if rising_edge(clk) and wre = '1' and mask = "10" then
      addr_p1 <= std_logic_vector(unsigned(address) + 1);
    end if;
  end process;

  process(clk, wre, address, mask)
  begin
    if rising_edge(clk) and wre = '1' and mask = "01" then
      addr_p2 <= std_logic_vector(unsigned(address) + 2);
      addr_p3 <= std_logic_vector(unsigned(address) + 3);
    end if;
  end process;

  process(clk, wre, address, din)
  begin
    if rising_edge(clk) and wre = '1' then
      memory(to_integer(unsigned(address))) <= din(7 downto 0);
    end if;
  end process;

  process(clk, wre, address, din, mask)
  begin
    if rising_edge(clk) and wre = '1' and mask = "10" then
      memory(to_integer(unsigned(addr_p1))) <= din(15 downto 8);
    end if;
  end process;

  process(clk, wre, address, din, mask)
  begin
    if rising_edge(clk) and wre = '1' and mask = "01" then
      memory(to_integer(unsigned(addr_p2))) <= din(23 downto 16);
    end if;
  end process;

  process(clk, wre, address, din, mask)
  begin
    if rising_edge(clk) and wre = '1' and mask = "01" then
      memory(to_integer(unsigned(addr_p3))) <= din(31 downto 24);
    end if;
  end process;

  process(clk, wre, address)
  begin
    if rising_edge(clk) and wre = '0' then
      dout <= memory(to_integer(unsigned(address) + 3)) & memory(to_integer(unsigned(address) + 2)) & memory(to_integer(unsigned(address) + 1)) & memory(to_integer(unsigned(address)));
    end if;
  end process;

end architecture rtl;
