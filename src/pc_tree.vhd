library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_tree is
generic(
  INSTR_WIDTH : integer := 32;
  ADDR_WIDTH  : integer := 32
);
port(
  address_out : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
  stall       : out std_logic;
  pc          : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address     : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  offset      : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address_src : in std_logic;
  pc_mod      : in std_logic
);
end entity pc_tree;

architecture rtl of pc_tree is
  signal pc_sum     : std_logic_vector(ADDR_WIDTH - 1 downto 0) := (others => '0');
  signal pc_mod_val : std_logic_vector(ADDR_WIDTH - 1 downto 0); 
begin

  address_out <= pc_sum when address_src = '0' else address;
  pc_mod_val  <= x"00000004" when pc_mod = '0' else offset;
  pc_sum <= std_logic_vector(unsigned(pc) + unsigned(pc_mod_val));
  stall <= pc_mod or address_src;

end architecture rtl;