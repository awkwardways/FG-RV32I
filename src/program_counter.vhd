library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity program_counter is
generic(
  ADDR_WIDTH : integer := 32
);
port(
  pc_in  : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  pc_out : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  inc    : in std_logic;
  wre    : in std_logic;
  clk    : in std_logic;
  reset  : in std_logic
);
end entity program_counter;

architecture rtl of program_counter is
  signal data : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

  pc_out <= data;

  process(clk, wre, pc_in)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        if wre = '1' then
          data <= std_logic_vector(unsigned(pc_in) + 4) when inc = '1' else pc_in;
        end if;
      else
        data <= (others => '0');
      end if;
    end if;
  end process;

end architecture rtl;
