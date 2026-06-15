library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram is
port(
  clk    : in std_logic;
  wre_a  : in std_logic;
  wre_b  : in std_logic;
  en_a   : in std_logic;
  en_b   : in std_logic;
  din_a  : in std_logic_vector(7 downto 0);
  din_b  : in std_logic_vector(7 downto 0);
  dout_a : out std_logic_vector(7 downto 0);
  dout_b : out std_logic_vector(7 downto 0)
);
end entity dpram;

architecture rtl of dpram is
  type memory_t is array(0 to 0) of std_logic_vector(7 downto 0);
  signal memory : memory_t := (others => x"00");
begin

  process(clk, wre_a, en_a, din_a, wre_b, en_b, din_b)
  begin
    if rising_edge(clk) then
      if en_a = '1' then
        if wre_a = '1' then
          memory(0) <= din_a;
        else
          dout_a <= memory(0);
        end if;
      else
        dout_a <= (others => 'Z');
      end if;
      if en_b = '1' then
        if wre_b = '1' then
          memory(0) <= din_b;
        else
          dout_b <= memory(0);
        end if;
      else
        dout_b <= (others => 'Z');
      end if;
    end if;
  end process;

end architecture rtl;
