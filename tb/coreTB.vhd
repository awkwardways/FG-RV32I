library ieee;
use ieee.std_logic_1164.all;

entity coreTB is
end entity coreTB;

architecture sim of coreTB is
  constant INSTR_WIDTH_TB  : integer := 32;
  constant ADDR_WIDTH_TB   : integer := 32;
  constant DATA_WIDTH_TB   : integer := 32;
  constant OPCODE_WIDTH_TB : integer := 7;
  constant IMM_WIDTH_TB    : integer := 32;
  constant INST_WIDTH_TB   : integer := 32;
  constant CLK_FREQ        : integer := 20e6;
  constant CLK_PERIOD      : time    := 1000 ms / CLK_FREQ;

  signal address_out_tb   : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal address_tb       : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"ffaa0127";
  signal offset_tb        : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0) := x"aa000033";
  signal mar_addr_out     : std_logic_vector(ADDR_WIDTH_TB - 1 downto 0);
  signal inst_mem_out_tb  : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal stall_tb         : std_logic;
  signal address_src_tb   : std_logic := '0';
  signal pc_mod_tb        : std_logic := '0';
  signal wre_tb           : std_logic := '0';
  signal reset_tb         : std_logic;
  signal clk_tb           : std_logic := '0';
  signal inst_out_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_out_tb        : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_en_tb        : std_logic;
  signal begin_stb_tb     : std_logic;
  signal wre_idif_tb      : std_logic;
  signal imm_tb           : std_logic_vector(IMM_WIDTH_TB - 1 downto 0);
  signal rs1_tb           : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rs2_tb           : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rd_tb            : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rd_sel_tb        : std_logic_vector(4 downto 0);
  signal funct3_out_tb    : std_logic_vector(2 downto 0);
  signal rs1_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rs2_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rd_out_tb        : std_logic_vector(4 downto 0);
  signal imm_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal alu_mod_out_tb   : std_logic;
  signal imm_found_tb     : std_logic;
  signal imm_found_out_tb : std_logic;
  signal alu_c_tb         : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal alu_b_tb         : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_rs2_out_tb   : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal res_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_rd_out_tb    : std_logic_vector(4 downto 0);
  signal mem_op_in_tb     : std_logic;
  signal mem_op_out_tb    : std_logic;

begin

  clk_tb <= not clk_tb after CLK_PERIOD / 2;
  alu_b_tb <= rs2_out_tb when imm_found_out_tb = '0' else imm_out_tb;
  
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

  PC_MUX_TREE: entity work.pc_tree(rtl)
  generic map(
    INSTR_WIDTH => INSTR_WIDTH_TB,
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    address_out => address_out_tb,
    pc => mar_addr_out,
    offset => offset_tb,
    pc_mod => pc_mod_tb
  );

  INSTRUCTION_MEM: entity work.instruction_mem(rtl)
  generic map(
    ADDR_WIDTH => 12,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address => mar_addr_out(13 downto 2),
    data_out => inst_mem_out_tb,
    en => mem_en_tb,
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
    mem_data_in => inst_mem_out_tb,
    mem_data_out => open,
    mem_en => mem_en_tb,
    begin_stb => begin_stb_tb,
    wre_idif => wre_idif_tb,
    clk => clk_tb,
    reset => reset_tb
  );

  IDIF: entity work.idif_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    wre             => wre_idif_tb,
    reset           => reset_tb,
    clk             => clk_tb,
    pc_in           => mar_addr_out,
    pc_out          => pc_out_tb,
    instruction_in  => inst_mem_out_tb,
    instruction_out => inst_out_tb
  );

  REGISTERS: entity work.registers_unit(rtl)
  generic map(
    REG_WIDTH => DATA_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    reset => reset_tb,
    rs1_en => '1',
    rs2_en => inst_out_tb(5) and (not inst_out_tb(2)),
    rs1_sel => inst_out_tb(19 downto 15),
    rs2_sel => inst_out_tb(24 downto 20),
    rd_sel => rd_sel_tb, 
    rs1 => rs1_tb,
    rs2 => rs2_tb,
    rd => rd_tb,
    wre => '1'
  );

  IMM: entity work.immediate_generator(rtl)
  generic map(
    OPCODE_WIDTH => OPCODE_WIDTH_TB,
    IMM_WIDTH => IMM_WIDTH_TB,
    INST_WIDTH => INST_WIDTH_TB
  )
  port map(
    immediate => imm_tb,
    instruction => inst_out_tb,
    imm_found => imm_found_tb
  );

  IFEX: entity work.ifex_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    reset => reset_tb,
    wre => '1',
    funct3_in => inst_out_tb(14 downto 12),
    funct3_out => funct3_out_tb,
    rs1_in => rs1_tb,
    rs1_out => rs1_out_tb,
    rs2_in => rs2_tb,
    rs2_out => rs2_out_tb,
    rd_in => inst_out_tb(11 downto 7),
    rd_out => rd_out_tb,
    imm_in => imm_tb,
    imm_out => imm_out_tb,
    alu_mod_in => inst_out_tb(30),
    alu_mod_out => alu_mod_out_tb,
    imm_found_in => imm_found_tb,
    imm_found_out => imm_found_out_tb
  );

  ALU: entity work.ALU(rtl)
  generic map(
    A_WIDTH => DATA_WIDTH_TB,
    B_WIDTH => DATA_WIDTH_TB,
    C_WIDTH => DATA_WIDTH_TB
  )
  port map(
    a => rs1_out_tb,
    b => alu_b_tb,
    c => alu_c_tb,
    op_select => funct3_out_tb,
    modifier => alu_mod_out_tb
  );
  
  EXMEM: entity work.exmem_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    reset => reset_tb,
    wre => '1',
    rs2_in => rs2_out_tb,
    rs2_out => mem_rs2_out_tb,
    res_in => alu_c_tb,
    res_out => res_out_tb,
    mem_op_in => mem_op_in_tb,
    mem_op_out => mem_op_out_tb,
    rd_in => rd_out_tb,
    rd_out => mem_rd_out_tb
  );

  MEMWB: entity work.memwb_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    clk => clk_tb,
    reset => reset_tb,
    wre => '1',
    data_in => res_out_tb,
    data_out => rd_tb,
    rd_in => mem_rd_out_tb,
    rd_out => rd_sel_tb
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