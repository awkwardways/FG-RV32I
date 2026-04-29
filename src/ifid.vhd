library ieee;
use ieee.std_logic_1164.all;

entity ifid_register is
generic(
  ADDR_WIDTH : integer := 32
);
port(
  wre             : in std_logic;
  reset           : in std_logic;
  clk             : in std_logic;
  pc_in           : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  pc_out          : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  instruction_in  : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  instruction_out : out std_logic_vector(ADDR_WIDTH - 1 downto 0)
);
end entity ifid_register;

architecture rtl of ifid_register is
  signal pc          : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal instruction : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
begin

  pc_out <= pc;
  instruction_out <= instruction;

  process(clk, wre, pc_in, instruction_in, reset)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pc <= (others => '0');
        instruction <= (others => '0');
      else
        pc <= pc_in when wre = '1' else pc;
        instruction <= instruction_in when wre = '1' else instruction;
      end if;
    end if;
  end process;

end architecture rtl;