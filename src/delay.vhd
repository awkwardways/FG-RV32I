library ieee;
use ieee.std_logic_1164.all;

entity delay is
port(
  clk   : in std_logic;
  q_in  : in std_logic; 
  q_out : out std_logic := '0' 
);
end entity delay;

architecture rtl of delay is
begin

  process(clk, q_in)
  begin
    if rising_edge(clk) then
      q_out <= q_in;
    end if;
  end process;

end architecture rtl;