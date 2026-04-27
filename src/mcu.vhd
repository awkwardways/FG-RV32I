library ieee;
use ieee.std_logic_1164.all;

entity memory_control_unit is
generic(
  ADDR_WIDTH : integer := 32;
  DATA_WIDTH : integer := 32
);
port(
  cpu_data_in  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  cpu_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  mem_data_in  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  mem_data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  mem_en       : out std_logic;
  begin_stb    : in std_logic;
  wre_idif     : out std_logic;
  clk          : in std_logic;
  reset        : in std_logic
);
end entity memory_control_unit;

architecture rtl of memory_control_unit is
  type state_t is (idle, addressing, write_idif, deassert);
  signal state : state_t := idle;
begin

  process(clk, cpu_data_in, mem_data_in, begin_stb)
  begin

    if rising_edge(clk) then

      if reset = '0' then
        case state is
          when idle => 
            mem_en <= begin_stb;
            state <= idle when begin_stb = '0' else addressing;

          when addressing => 
            state <= write_idif;

          when write_idif => 
            state <= deassert;
            wre_idif <= '1';
          
          when deassert => 
            state <= idle;
            wre_idif <= '0';
            mem_en <= '0';
        end case;
        
      else
        wre_idif <= '0';
        mem_en <= '0';
      end if;

    end if;

  end process;

end architecture rtl;