library ieee;
use ieee.std_logic_1164.all;

entity pc_treeTB is
end entity pc_treeTB;

architecture sim of pc_treeTB is
  constant INSTR_WIDTH_TB : integer := 32;
  constant ADDR_WIDTH_TB  : integer := 32;
  constant CLK_FREQ       : integer := 20e6;
  constant CLK_PERIOD     : time    := 1000 ms / CLK_FREQ;

  signal address_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal pc_tb          : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_tb     : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"ffaa0127";
  signal offset_tb      : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"aa000033";
  signal mar_addr_out   : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal stall_tb       : std_logic;
  signal address_src_tb : std_logic := '0';
  signal pc_mod_tb      : std_logic := '0';
  signal wre_tb         : std_logic;
  signal reset_tb       : std_logic;
  signal clk_tb         : std_logic := '0';

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;
  
  MAR: entity work.memory_address_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_in  => pc_tb,
    address_out => mar_addr_out, 
    clk         => clk_tb,
    wre         => wre_tb
  );

  PC: entity work.program_counter(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    pc_in => address_out_tb,
    pc_out => pc_tb,
    inc => pc_mod_tb,
    wre => wre_tb,
    clk => clk_tb,
    reset => reset_tb
  );

  UUT: entity work.pc_tree(rtl)
  generic map(
    INSTR_WIDTH => INSTR_WIDTH_TB,
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_out => address_out_tb,
    stall => stall_tb,
    pc => pc_tb,
    address => address_tb,
    offset => offset_tb,
    address_src => address_src_tb,
    pc_mod => pc_mod_tb
  );

  stimuli: process
  begin
    reset_tb <= '0';
    wait until rising_edge(clk_tb);
    assert pc_tb = x"00000000" report "Address going into the MAR is not correct" severity failure;
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    wait for 1 ns;  --Wait for delta cycles to propagate
    wre_tb <= '0';
    assert mar_addr_out = x"00000000" and pc_tb = x"00000004" report "Address found at MAR or address found at pc is incorrect" severity failure;
    pc_mod_tb <= '1';
    wait until rising_edge(clk_tb);
    wre_tb <= '1';
    assert address_out_tb = x"aa000037" report "Offset address is incorrect" severity failure;
    wait until rising_edge(clk_tb);
    wait for 1 ns;  --Wait for delta cycles to propagate
    assert mar_addr_out = x"aa000037" and pc_tb = x"aa00003b" report "Address found at MAR or address found at pc is incorrect" severity failure;
    wait;

  end process;

end architecture sim;