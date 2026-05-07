library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
generic(
  DATA_WIDTH : integer := 32
);
port(
  inst       : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  alu_op     : out std_logic_vector(2 downto 0);
  clear_ifid : out std_logic;
  pc_offset  : out std_logic
);
end entity control_unit;

architecture rtl of control_unit is
begin

  process(inst)
  begin
    case inst(6 downto 0) is
      when "1101111" | "1100111"=> 
        clear_ifid <= '1';
        pc_offset <= '1';
        alu_op <= "000";
      
      when "0000011" | "0100011" => 
        clear_ifid <= '0';
        pc_offset <= '0';
        alu_op <= "000";

      when others => 
        clear_ifid <= '0'; 
        pc_offset <= '0';
        alu_op <= inst(14 downto 12);
    end case;
  end process;

end architecture rtl;