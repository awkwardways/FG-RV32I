library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registers_unit is
generic(
  REG_WIDTH : integer := 32
);
port(
  clk     : in std_logic;
  reset   : in std_logic;
  rs1_en  : in std_logic;
  rs2_en  : in std_logic;
  rs1_sel : in std_logic_vector(4 downto 0);
  rs2_sel : in std_logic_vector(4 downto 0);
  rd_sel  : in std_logic_vector(4 downto 0);
  rs1     : out std_logic_vector(REG_WIDTH - 1 downto 0);
  rs2     : out std_logic_vector(REG_WIDTH - 1 downto 0);
  rd      : in std_logic_vector(REG_WIDTH - 1 downto 0);
  wre     : in std_logic
);
end entity registers_unit;

architecture rtl of registers_unit is
  -- type register_t is record
  --  data : std_logic_vector(REG_WIDTH - 1 downto 0);
  --  en   : std_logic;
  --  wre  : std_logic;
  -- end record register_t;
  -- type registers_t is array (31 downto 0) of register_t;
  type registers_t is array (31 downto 0) of std_logic_vector(31 downto 0);
  signal registers : registers_t := (others => (others => '0'));
begin

  process(clk, rd_sel, wre, reset, registers)
  begin
    if rising_edge(clk) and reset = '0' then
      if wre = '1' then
        registers(to_integer(unsigned(rd_sel))) <= rd when rd_sel /= "00000" else (others => '0');
      end if;
    elsif rising_edge(clk) and reset = '1' then
      registers <= (others => (others => '0'));
    end if; 
  end process;

  read_regs: process(rs1_sel, rs1_en, rs2_sel, rs2_en, rd, rd_sel, reset, registers)
  begin
    rs1 <= registers(to_integer(unsigned(rs1_sel))) and rs1_en when rs1_sel /= rd_sel else 
          rd and rs1_en when (rs1_sel = rd_sel) else (others => '0');

    rs2 <= registers(to_integer(unsigned(rs2_sel))) and rs2_en when rs2_sel /= rd_sel else 
          rd and rs2_en when (rs2_sel = rd_sel) else (others => '0');
  end process read_regs;

end architecture rtl;
