library ieee;
use ieee.std_logic_1164.all;

entity forwarding_unit is 
generic(
  DATA_WIDTH : integer := 32
);
port(
  ex_rs1_sel    : in std_logic_vector(4 downto 0);
  id_rs1_sel    : in std_logic_vector(4 downto 0);
  ex_rs2_sel    : in std_logic_vector(4 downto 0);
  id_rs2_sel    : in std_logic_vector(4 downto 0);
  mem_rd_sel : in std_logic_vector(4 downto 0);
  wb_rd_sel  : in std_logic_vector(4 downto 0);
  ex_fwd_rs1    : out std_logic;
  ex_fwd_rs2    : out std_logic;
  id_fwd_rs1    : out std_logic;
  id_fwd_rs2    : out std_logic;
  mem_data   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  wb_data    : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  ex_fwd_data   : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  id_fwd_data   : out std_logic_vector(DATA_WIDTH - 1 downto 0)
);
end entity forwarding_unit;

architecture rtl of forwarding_unit is
begin
  
  ex_fwd_rs1  <= '1' when ex_rs1_sel = mem_rd_sel or ex_rs1_sel = wb_rd_sel else '0';
  ex_fwd_rs2  <= '1' when ex_rs2_sel = mem_rd_sel or ex_rs2_sel = wb_rd_sel  else '0';
  ex_fwd_data <= mem_data when (ex_rs2_sel = mem_rd_sel or ex_rs1_sel = mem_rd_sel) else wb_data;
  id_fwd_rs1 <= '1' when id_rs1_sel = wb_rd_sel else '0';
  id_fwd_rs2 <= '1' when id_rs2_sel = wb_rd_sel else '0';
  id_fwd_data <= wb_data when (id_rs1_sel = wb_rd_sel or id_rs2_sel = wb_rd_sel) else (others => '0');

end architecture;