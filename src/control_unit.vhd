library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
port(
  opcode      : in std_logic_vector(6 downto 0);
  alu_op_sel  : out std_logic;
  mem_en      : out std_logic;
  mem_wre     : out std_logic;
  imm_sel     : out std_logic;
  ex_outp     : out std_logic
);
end entity control_unit;

architecture rtl of control_unit is
begin

  alu_op_sel <= '0' when opcode = "0010011" or opcode = "0110011" else '1';
  mem_en     <= '1' when opcode = "0000011" or opcode = "0100011" else '0';
  mem_wre    <= '1' when opcode = "0100011" else '0';
  imm_sel    <= '0' when opcode = "0110011" or opcode = "0001111" or opcode = "1110011" else '1';
  ex_outp    <= '1' when opcode = "1101111" or opcode = "1100011" else '0';

end architecture rtl;