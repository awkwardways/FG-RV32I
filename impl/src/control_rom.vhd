library ieee;
use ieee.std_logic_1164.all;

entity control_rom is 
port(
  address : in std_logic_vector(7 downto 0);  --opcode(6 downto 2) & funct3
  clk     : in std_logic;
  dout    : out std_logic_vector(13 downto 0)
);
end entity control_rom;

architecture rtl of control_rom is 
begin

  process(clk, address)
  begin
    if rising_edge(clk) then
      case? address is 
        when "00100---" => dout <= "00010000000000";
        when "01100---" => dout <= "00000000000000";
        when "00000---" => dout <= "11010000000000";
        when "01000---" => dout <= "11110000000000";
        when "00011---" => dout <= "10000000000000";
        when "11100---" => dout <= "10000000000000";
        when "11000000" => dout <= "10000000101001";
        when "11000001" => dout <= "10000000111000";
        when "11000100" => dout <= "10000000100100";
        when "11000101" => dout <= "10000000100101";
        when "11000110" => dout <= "10000000100110";
        when "11000111" => dout <= "10000000100111";
        when "11011---" => dout <= "10010101000000";
        when "11001---" => dout <= "10010111000000";
        when "01101---" => dout <= "10011000000000";
        when "00101---" => dout <= "10011100000000";
        when others => dout <= (others => '0');
      end case?;
    end if;
  end process;

end architecture rtl;