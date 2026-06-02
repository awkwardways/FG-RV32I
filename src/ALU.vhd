library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is 
  generic (
    A_WIDTH         : integer := 32;
    B_WIDTH         : integer := 32;
    C_WIDTH         : integer := 32
  );
  port (
    a         : in std_logic_vector(A_WIDTH - 1 downto 0);
    b         : in std_logic_vector(B_WIDTH - 1 downto 0);
    c         : out std_logic_vector(C_WIDTH - 1 downto 0);
    op_select : in std_logic_vector(3 downto 0)
  );
end entity ALU;

architecture rtl of ALU is
begin

  process(op_select, a, b)
  begin
    case op_select is 
      when "0000" => 
        c <= std_logic_vector(unsigned(a) + unsigned(b));
      
      when "0001" => 
        c <= std_logic_vector(unsigned(a) - unsigned(b));

      when "0010" => 
        c  <= std_logic_vector(shift_left(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

      when "0100" => 
        c  <= 32x"1" when signed(a) < signed(b) else 32x"0";

      when "0110" => 
        c  <= 32x"1" when unsigned(a) < unsigned(b) else 32x"0";
      
      when "1000" => 
        c  <= a xor b;
      
      when "1001" => 
        c <= 32x"1" when a /= b else 32x"0";

      when "1010" => 
        c <= std_logic_vector(shift_right(unsigned(a), to_integer(unsigned(b(4 downto 0)))));

      when "1011" => 
        c <= std_logic_vector(shift_right(signed(a), to_integer(unsigned(b(4 downto 0)))));

      when "1100" => 
        c  <= a or b;

      when "1110" => 
        c  <= a and b;

      when others => c <= (others => '0');
    end case;
  end process;

end architecture rtl;