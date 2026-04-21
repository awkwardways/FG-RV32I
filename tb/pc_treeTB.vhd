library ieee;
use ieee.std_logic_1164.all;

entity pc_treeTB is
end entity pc_treeTB;

architecture sim of pc_treeTB is
  constant INSTR_WIDTH_TB : integer := 32;
  constant ADDR_WIDTH_TB  : integer := 32;
  constant DATA_WIDTH_TB  : integer := 32;
  constant CLK_FREQ       : integer := 20e6;
  constant CLK_PERIOD     : time    := 1000 ms / CLK_FREQ;

  signal address_out_tb : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_tb     : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"ffaa0127";
  signal offset_tb      : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"aa000033";
  signal mar_addr_out   : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal ram_dout_tb    : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal stall_tb       : std_logic;
  signal address_src_tb : std_logic := '0';
  signal pc_mod_tb      : std_logic := '0';
  signal wre_tb         : std_logic;
  signal reset_tb       : std_logic;
  signal clk_tb         : std_logic := '0';
  signal inst_out_tb    : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_out_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pipe_reg_wre_tb: std_logic;

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;
  pipe_reg_wre_tb <= wre_tb;
  
  MAR: entity work.memory_address_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_in  => address_out_tb,
    address_out => mar_addr_out, 
    reset       => reset_tb,
    clk         => clk_tb,
    wre         => wre_tb
  );

  UUT: entity work.pc_tree(rtl)
  generic map(
    INSTR_WIDTH => INSTR_WIDTH_TB,
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_out => address_out_tb,
    stall => stall_tb,
    pc => mar_addr_out,
    address => address_tb,
    offset => offset_tb,
    address_src => address_src_tb,
    pc_mod => pc_mod_tb
  );

  RAM: entity work.ram(rtl)
  generic map( 
    ADDR_WIDTH => 12,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address => mar_addr_out(11 downto 0),
    din => (others => '0'),
    dout => ram_dout_tb,
    mask => "00",
    en => '1',
    wre => '0',
    clk => clk_tb
  );

  pipeline_reg: entity work.idif_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    wre             => pipe_reg_wre_tb,
    reset           => reset_tb,
    clk             => clk_tb,
    pc_in           => mar_addr_out,
    pc_out          => pc_out_tb,
    instruction_in  => ram_dout_tb,
    instruction_out => inst_out_tb
  );

  stimuli: process
  begin
    reset_tb <= '1';
    wait until rising_edge(clk_tb);
    reset_tb <= '0';
    assert mar_addr_out = x"00000000" report "Address being output by MAR does not match expected (0x00000000)" severity failure;
    wait until falling_edge(clk_tb);
    wre_tb <= '1';
    wait until rising_edge(clk_tb);
    wre_tb <= '0';
    wait for 1 ns;
    assert mar_addr_out = x"00000004" report "Address being output by MAR does not match expected (0x00000004)" severity failure;
    wait until falling_edge(clk_tb);
    wre_tb <= '1';
    pc_mod_tb <= '1';
    wait until rising_edge(clk_tb);
    wre_tb <= '0';
    pc_mod_tb <= '0';
    wait for 1 ns;
    assert mar_addr_out = x"aa000037" and address_out_tb = x"aa00003b" report "Address being output by MAR or address being output by PC selection tree do not match expected (0xaa000037, 0xaa00003b)" severity failure;
    wait;

  end process;

end architecture sim;