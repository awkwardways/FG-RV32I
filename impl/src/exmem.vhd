library ieee;
use ieee.std_logic_1164.all;

entity exmem_register is
generic(
  DATA_WIDTH : integer := 32
);
port(
  clk          : in std_logic;
  reset        : in std_logic;
  wre          : in std_logic;
  rs2_in       : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs2_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  res_in       : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  res_out      : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  mem_op_in    : in std_logic_vector(1 downto 0);
  mem_op_out   : out std_logic_vector(1 downto 0);
  mask_in      : in std_logic_vector(2 downto 0);
  mask_out     : out std_logic_vector(2 downto 0);
  rd_in        : in std_logic_vector(4 downto 0);
  rd_out       : out std_logic_vector(4 downto 0)
);
end entity exmem_register;

architecture rtl of exmem_register is
  signal rs2 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal res : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem_op : std_logic_vector(1 downto 0);
  signal rd : std_logic_vector(4 downto 0);
  signal mask : std_logic_vector(2 downto 0);
begin

  rs2_out <= rs2;
  res_out <= res;
  mem_op_out <= mem_op;
  rd_out <= rd;
  mask_out <= mask;

  process(clk, reset, wre, rs2_in, res_in, mem_op_in, rd_in, mask_in)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        rs2 <= rs2_in when wre = '1' else rs2;
        res <= res_in when wre = '1' else res;
        mem_op <= mem_op_in when wre = '1' else mem_op;
        rd <= rd_in when wre = '1' else rd;
        mask <= mask_in when wre = '1' else mask;
      else
        rs2 <= (others => '0');
        res <= (others => '0');
        mem_op <= (others => '0');
        rd <= (others => '0');
        mask <= (others => '0');
      end if;
    end if;
  end process;

end architecture rtl;
