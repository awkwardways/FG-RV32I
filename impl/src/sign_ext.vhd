library ieee;
use ieee.std_logic_1164.all;

entity sign_extender is 
generic(
  DATA_WIDTH : integer := 32
);
port(
  data_in  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  op       : in std_logic_vector(2 downto 0)
);
end entity sign_extender;

architecture rtl of sign_extender is
begin
  process(data_in, op)
  begin
    case op is
      when "000" => 
        data_out(7 downto 0) <= data_in(7 downto 0);
        data_out(DATA_WIDTH - 1 downto 8) <= (others => data_in(7)); 
      
      when "001" => 
        data_out(15 downto 0) <= data_in(15 downto 0);
        data_out(DATA_WIDTH - 1 downto 16) <= (others => data_in(15));

      when others => data_out <= data_in;
      end case;
  end process;
end architecture rtl;