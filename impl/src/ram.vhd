library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;


entity ram is
generic(
  ADDR_WIDTH : integer := 12;
  DATA_WIDTH : integer := 32;
  WORD_WIDTH : integer := 8
);
port(
  address : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  din     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  dout    : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  mask    : in std_logic_vector(1 downto 0);
  en      : in std_logic;
  wre     : in std_logic;
  clk     : in std_logic
);
end entity ram;

architecture rtl of ram is
  type memory_t is array (0 to 2 ** ADDR_WIDTH - 1) of std_logic_vector(7 downto 0);

  signal memory : memory_t := (others => x"aa");
begin

  process(clk, wre, en, address, din)
  begin
    if rising_edge(clk) and en = '1' then
      if wre = '0' then
        case mask is
          when "00" => 
            dout <= x"000000" & memory(to_integer(unsigned(address)));

          -- Half word access
          when "01" => 
            dout <= x"0000" & memory(to_integer(unsigned(address) + 1)) & memory(to_integer(unsigned(address)));

          -- Word access
          when "10" => 
            dout <= memory(to_integer(unsigned(address) + 3)) & memory(to_integer(unsigned(address) + 2)) & memory(to_integer(unsigned(address) + 1)) & memory(to_integer(unsigned(address)));
          
          when others => dout <= (others => '0');
        end case;
      else
        case mask is
          when "00" => 
            memory(to_integer(unsigned(address))) <= din(7 downto 0);

          when "01" => 
            memory(to_integer(unsigned(address))) <= din(7 downto 0);
            memory(to_integer(unsigned(address) + 1)) <= din(15 downto 8);

          when "10" => 
            memory(to_integer(unsigned(address))) <= din(7 downto 0);
            memory(to_integer(unsigned(address) + 1)) <= din(15 downto 8);
            memory(to_integer(unsigned(address) + 2)) <= din(23 downto 16);
            memory(to_integer(unsigned(address) + 3)) <= din(31 downto 24);
          
          when others => memory(to_integer(unsigned(address))) <= (others => '0');
        end case;
      end if;
    elsif rising_edge(clk) and en = '0' then
      dout <= (others => '0');
    end if;
  end process;

end architecture rtl;