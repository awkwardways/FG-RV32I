library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
port(
  opcode       : in std_logic_vector(6 downto 0);
  funct_3      : in std_logic_vector(2 downto 0);
  amod         : in std_logic;
  alu_op_sel   : out std_logic;
  mem_en       : out std_logic;
  mem_wre      : out std_logic;
  imm_sel      : out std_logic;
  ex_outp      : out std_logic_vector(1 downto 0);
  imm_addr_src : out std_logic;
  ifid_reset   : out std_logic;
  alu_op       : out std_logic_vector(2 downto 0);
  branch       : out std_logic;
  neg_alu      : out std_logic;
  alu_mod      : out std_logic
);
end entity control_unit;

architecture rtl of control_unit is
begin

  alu_op_sel   <= '0' when opcode = "0010011" or opcode = "0110011" else '1';
  mem_en       <= '1' when opcode = "0000011" or opcode = "0100011" else '0';
  mem_wre      <= '1' when opcode = "0100011" else '0';
  imm_sel      <= '0' when opcode = "0110011" or opcode = "0001111" or opcode = "1110011" or opcode = "1100011" else '1';
  ex_outp      <= "01" when opcode = "1101111" or opcode = "1100111" else 
                  "10" when opcode = "0110111" else "11" when opcode = "0010111" else "00";
  imm_addr_src <= '1' when opcode = "1100111" else '0';
  ifid_reset   <= '1' when opcode = "1100111" or opcode = "1101111" else '0';
  branch       <= '1' when opcode = "1100011" else '0';
  alu_mod      <= '1' when opcode = "1100011" and funct_3 = "001" else amod;
  alu_op       <= "100" when opcode = "1100011" and funct_3 = "000" else
                  "100" when opcode = "1100011" and funct_3 = "001" else
                  "010" when opcode = "1100011" and funct_3 = "100" else
                  "010" when opcode = "1100011" and funct_3 = "101" else 
                  "011" when opcode = "1100011" and funct_3 = "110" else
                  "011" when opcode = "1100011" and funct_3 = "111" else "000";
  neg_alu      <= '1' when opcode = "1100011" and (funct_3 = "000" or funct_3 = "101" or funct_3 = "111") else '0';

end architecture rtl;