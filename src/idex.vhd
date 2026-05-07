library ieee;
use ieee.std_logic_1164.all;

entity idex_register is
generic(
  DATA_WIDTH : integer := 32
);
port(
  clk           : in std_logic;
  reset         : in std_logic;
  wre           : in std_logic;
  funct3_in     : in std_logic_vector(2 downto 0);
  funct3_out    : out std_logic_vector(2 downto 0);
  rs1_sel_in    : in std_logic_vector(4 downto 0);
  rs1_sel_out   : out std_logic_vector(4 downto 0);
  rs1_in        : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs1_out       : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs2_sel_in    : in std_logic_vector(4 downto 0);
  rs2_sel_out   : out std_logic_vector(4 downto 0);
  rs2_in        : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs2_out       : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  rd_in         : in std_logic_vector(4 downto 0);
  rd_out        : out std_logic_vector(4 downto 0);
  imm_in        : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  imm_out       : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  imm_found_in  : in std_logic;
  imm_found_out : out std_logic;
  mem_op_in     : in std_logic;
  mem_op_out    : out std_logic;
  mem_wre_in    : in std_logic;
  mem_wre_out   : out std_logic;
  alu_mod_in    : in std_logic;
  alu_mod_out   : out std_logic;
  alu_op_in     : in std_logic_vector(2 downto 0);
  alu_op_out    : out std_logic_vector(2 downto 0)
);
end entity idex_register;

architecture rtl of idex_register is 
  signal funct3    : std_logic_vector(2 downto 0);
  signal rs1_sel   : std_logic_vector(4 downto 0);
  signal rs1       : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rs2_sel   : std_logic_vector(4 downto 0);
  signal rs2       : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rd        : std_logic_vector(4 downto 0);
  signal imm       : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal alu_mod   : std_logic;
  signal imm_found : std_logic;
  signal mem_op    : std_logic;
  signal mem_wre   : std_logic;
  signal alu_op    : std_logic_vector(2 downto 0);
begin
  
  funct3_out    <= funct3;
  rs1_sel_out   <= rs1_sel;       
  rs1_out       <= rs1;
  rs2_sel_out   <= rs2_sel;
  rs2_out       <= rs2;
  rd_out        <= rd;
  imm_out       <= imm;
  alu_mod_out   <= alu_mod;
  imm_found_out <= imm_found;
  mem_op_out    <= mem_op;
  mem_wre_out   <= mem_wre;
  alu_op_out    <= alu_op;

  process(clk, wre, reset, funct3_in, rs1_in, rs2_in, rd_in, imm_in, alu_mod_in, imm_found_in, mem_op_in, rs1_sel_in, rs2_sel_in, mem_wre_in, alu_op_in)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        funct3    <= funct3_in when wre = '1' else funct3;
        rs1_sel   <= rs1_sel_in when wre = '1' else rs1_sel;
        rs1       <= rs1_in when wre = '1' else rs1;
        rs2_sel   <= rs2_sel_in when wre = '1' else rs2_sel;
        rs2       <= rs2_in when wre = '1' else rs2;
        rd        <= rd_in when wre = '1' else rd;
        imm       <= imm_in when wre = '1' else imm;
        alu_mod   <= alu_mod_in when wre = '1' else alu_mod;
        alu_op    <= alu_op_in when wre = '1' else alu_op;
        imm_found <= imm_found_in when wre = '1' else imm_found;
        mem_op    <= mem_op_in when wre = '1' else mem_op;
        mem_wre   <= mem_wre_in when wre = '1' else mem_wre;
      else
        funct3    <= (others => '0');
        rs1_sel   <= (others => '0');
        rs1       <= (others => '0');
        rs2_sel   <= (others => '0');
        rs2       <= (others => '0');
        rd        <= (others => '0');
        imm       <= (others => '0');
        alu_mod   <= '0';
        alu_op    <= (others => '0');
        imm_found <= '0';
        mem_op    <= '0';
        mem_wre   <= '0';
      end if;
    end if;
  end process;

end architecture rtl;