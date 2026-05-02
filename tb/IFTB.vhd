library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity IFTB is
end entity IFTB;

architecture sim of IFTB is
  constant INSTR_WIDTH_TB : integer := 32;
  constant ADDR_WIDTH_TB  : integer := 32;
  constant DATA_WIDTH_TB  : integer := 32;
  constant CLK_FREQ       : integer := 20e6;
  constant CLK_PERIOD     : time    := 1000 ms / CLK_FREQ;

  signal address_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_tb     : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"ffaa0127";
  signal offset_tb      : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"aa000033";
  signal ram_dout_tb    : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal address_src_tb : std_logic := '0';
  signal pc_mod_tb      : std_logic := '0';
  signal reset_tb       : std_logic;
  signal clk_tb         : std_logic := '0';
  signal inst_out_tb    : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_out_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_en_tb      : std_logic;
  signal next_pc_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_tb          : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;
  
  MAR: entity work.memory_address_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    next_pc     => next_pc_tb,
    pc          => pc_tb,
    address_in  => address_out_tb,
    reset       => reset_tb,
    clk         => clk_tb,
    wre         => '1'
  );

  PC_MUX_TREE: entity work.pc_tree(rtl)
  generic map(
    INSTR_WIDTH => INSTR_WIDTH_TB,
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_out => address_out_tb,
    pc => next_pc_tb,
    address => address_tb,
    offset => offset_tb,
    address_src => address_src_tb,
    pc_mod => pc_mod_tb
  );

  INSTRUCTION_MEM: entity work.instruction_mem(rtl)
  generic map( 
    ADDR_WIDTH => 12,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address => next_pc_tb(13 downto 2),
    data_out => ram_dout_tb,
    en => not reset_tb,
    clk => clk_tb
  );

  IDIF: entity work.ifid_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    wre             => '1',
    reset           => reset_tb,
    clk             => clk_tb,
    pc_in           => pc_tb,
    pc_out          => pc_out_tb,
    instruction_in  => ram_dout_tb,
    instruction_out => inst_out_tb
  );

  stimuli: process
  begin
    mem_en_tb <= '1';
    reset_tb <= '1';
    wait for (CLK_PERIOD / 2);
    reset_tb <= '0';
    wait for CLK_PERIOD;
    wait for CLK_PERIOD;
    wait for 1 ns;  -- wait for delta cycles to propagate
    assert inst_out_tb = x"a8d00093" report "Instruction being output by the pipeline register is incorrect" severity failure;
    wait for CLK_PERIOD;
    assert inst_out_tb = x"a9a0a113" and pc_out_tb = x"00000004" report "Instruction being output by the pipeline register is incorrect" severity failure; 
    wait for CLK_PERIOD;
    assert inst_out_tb = x"a7b13193" and pc_out_tb = x"00000008" report "Instruction being output by the pipeline register is incorrect" severity failure; 
    wait for CLK_PERIOD;
    assert inst_out_tb = x"8000c213" and pc_out_tb = x"0000000C" report "Instruction being output by the pipeline register is incorrect" severity failure; 
    finish;
  end process;

end architecture sim;
