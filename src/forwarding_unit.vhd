library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is 
generic(
  DATA_WIDTH : integer := 32
);
port(
  rs1_sel    : in std_logic_vector(4 downto 0);
  rs2_sel    : in std_logic_vector(4 downto 0);
  mem_rd_sel : in std_logic_vector(4 downto 0);
  wb_rd_sel  : in std_logic_vector(4 downto 0);
  fwd_rs1    : out std_logic_vector(1 downto 0);
  fwd_rs2    : out std_logic_vector(1 downto 0)
);
end entity forwarding_unit;

architecture rtl of forwarding_unit is
begin
  
  fwd_rs1 <= "01" when rs1_sel = mem_rd_sel and rs1_sel /= "00000" 
              else "10" when rs1_sel = wb_rd_sel and rs1_sel /= "00000" else "00";
  fwd_rs2 <= "01" when rs2_sel = mem_rd_sel and rs2_sel /= "00000" 
              else "10" when rs2_sel = wb_rd_sel and rs2_sel /= "00000" else "00";

end architecture;