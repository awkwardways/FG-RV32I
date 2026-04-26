library ieee;
use ieee.std_logic_1164.all;

entity immediate_generator is
generic(
  OPCODE_WIDTH : integer := 7;
  IMM_WIDTH    : integer := 32;
  INST_WIDTH   : integer := 32
);
port(
  immediate   : out std_logic_vector(IMM_WIDTH - 1 downto 0);
  instruction : in std_logic_vector(INST_WIDTH - 1 downto 0);
  imm_found   : out std_logic;
);
end entity immediate_generator;

architecture rtl of immediate_generator is
  alias opcode : std_logic_vector(OPCODE_WIDTH - 1 downto 0) is instruction(OPCODE_WIDTH - 1 downto 0);
  alias funct3 : std_logic_vector(2 downto 0) is instruction(14 downto 12);
begin

  process(opcode, instruction)
  begin
    case opcode is
      when "0010011" | "1100111" | "0000011" => 
        immediate(11 downto 0) <= instruction(31 downto 20);
        immediate(31 downto 12) <= (others => '0') when funct3 = "011" else (others => instruction(31));
        imm_found <= '1';
      
      when "0110111" | "0010111" => 
        immediate(19 downto 0) <= instruction(31 downto 12);
        immediate(31 downto 20) <= (others => instruction(31));
        imm_found <= '1';

      when "1100011" => 
        immediate(11 downto 0) <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);
        immediate(31 downto 12) <= (others => '0') when funct3 = "110" or funct3 = "111" else (others => instruction(31));
        imm_found <= '1';

      when "0100011" => 
        immediate(11 downto 0) <= instruction(31 downto 25) & instruction(11 downto 7);
        immediate(31 downto 12) <= (others => instruction(31));
        imm_found <= '1';

      when others => immediate <= (others => '0'); imm_found <= '0';
    end case;
  end process;

end architecture rtl;