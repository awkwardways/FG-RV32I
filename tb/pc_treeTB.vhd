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
  signal wre_tb         : std_logic := '0';
  signal reset_tb       : std_logic;
  signal clk_tb         : std_logic := '0';
  signal inst_out_tb    : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_out_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_en_tb      : std_logic;
  signal begin_stb_tb   : std_logic;
  signal wre_idif_tb    : std_logic;

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;
  
  MAR: entity work.memory_address_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_in  => address_out_tb,
    address_out => mar_addr_out, 
    reset       => reset_tb,
    clk         => clk_tb,
    wre         => wre_idif_tb
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
    en => mem_en_tb,
    wre => '0',
    clk => clk_tb
  );

  MCU: entity work.memory_control_unit(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    cpu_data_in => (others => '0'),
    cpu_data_out => open,
    mem_data_in => ram_dout_tb,
    mem_data_out => open,
    mem_en => mem_en_tb,
    begin_stb => begin_stb_tb,
    wre_idif => wre_idif_tb,
    clk => clk_tb,
    reset => reset_tb
  );

  pipeline_reg: entity work.idif_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    wre             => wre_idif_tb,
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
    begin_stb_tb <= '1';
    wait;

  end process;

end architecture sim;