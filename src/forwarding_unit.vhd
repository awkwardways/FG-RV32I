library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is 
generic(
  DATA_WIDTH : integer := 32
);
port(
  rs1_sel    : in std_logic_vector(4 downto 0);
  rs2_sel    : in std_logic_vector(4 downto 0);
  rd_sel     : in std_logic_vector(4 downto 0);
  fwd_rs1    : out std_logic;
  fwd_rs2    : out std_logic
);
end entity forwarding_unit;

architecture rtl of forwarding_unit is
begin
  
  fwd_rs1 <= '1' when rs1_sel = rd_sel else '0';
  fwd_rs2 <= '1' when rs2_sel = rd_sel else '0';

end architecture;