library ieee;
use ieee.std_logic_1164.all;

entity memwb_register is
generic(
  DATA_WIDTH : integer := 32
);
port(
  clk          : in std_logic;
  reset        : in std_logic;
  wre          : in std_logic;
  data_in      : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_out     : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_sel_in  : in std_logic;
  data_sel_out : out std_logic;
  rd_in        : in std_logic_vector(4 downto 0);
  rd_out       : out std_logic_vector(4 downto 0);
  sign_ext_in  : in std_logic_vector(2 downto 0);
  sign_ext_out : out std_logic_vector(2 downto 0)
);
end entity memwb_register;

architecture rtl of memwb_register is
  signal data : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rd : std_logic_vector(4 downto 0);
  signal data_sel : std_logic;
  signal sign_ext : std_logic_vector(2 downto 0);
begin

  data_out     <= data;
  rd_out       <= rd;
  data_sel_out <= data_sel;
  sign_ext_out <= sign_ext;

  process(clk, reset, wre, data_in, rd_in, sign_ext_in)
  begin
    if rising_edge(clk) then
      if reset = '0' then
        data     <= data_in when wre = '1' else data;
        rd       <= rd_in when wre = '1' else rd;
        data_sel <= data_sel_in when wre = '1' else data_sel;
        sign_ext <= sign_ext_in when wre = '1' else sign_ext;
      else
        data     <= (others => '0');
        rd       <= (others => '0');
        data_sel <= '0';
        sign_ext <= (others => '0');
      end if;
    end if;
  end process;

end architecture rtl;
