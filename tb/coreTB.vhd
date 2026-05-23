library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity coretb is 
end entity coretb;

architecture sim of coretb is
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
  signal ram_dout_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal address_src_tb   : std_logic := '0';
  signal pc_mod_tb        : std_logic := '0';
  signal reset_tb         : std_logic;
  signal clk_tb           : std_logic := '0';
  signal inst_out_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_out_tb        : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal next_pc_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_tb            : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal immediate_tb     : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal imm_sel_tb       : std_logic;
  signal imm_sel_out_tb     : std_logic;  
  signal funct3_out_tb    : std_logic_vector(2 downto 0);
  signal reg_rs1_tb           : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rs1_tb           : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal reg_rs2_tb           : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rs2_tb           : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rd_tb            : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rd_in_tb         : std_logic_vector(4 downto 0);
  signal rd_sel_tb        : std_logic_vector(4 downto 0);
  signal rs1_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rs2_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal rd_out_tb        : std_logic_vector(4 downto 0);
  signal imm_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal imm_found_out_tb : std_logic;
  signal alu_mod_out_tb   : std_logic;
  signal a_tb             : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal b_tb             : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal c_tb             : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_rs2_out_tb   : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal res_out_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_rd_out_tb    : std_logic_vector(4 downto 0);
  signal ex_rs1_sel_out_tb   : std_logic_vector(4 downto 0);
  signal ex_rs2_sel_out_tb   : std_logic_vector(4 downto 0);
  signal ex_fwd_rs1_tb       : std_logic;
  signal ex_fwd_rs2_tb       : std_logic;
  signal id_fwd_rs1_tb       : std_logic;
  signal id_fwd_rs2_tb       : std_logic;
  signal ex_fwd_data_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal id_fwd_data_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal wb_data_in_tb       : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal data_dout_tb        : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal data_mem_en_tb      : std_logic;
  signal data_wre_tb         : std_logic;
  signal data_sel_out_tb     : std_logic;
  signal wb_data_out_tb      : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal data_mask_tb        : std_logic_vector(2 downto 0);
  signal op_select_tb        : std_logic_vector(2 downto 0);
  signal mem_data_tb         : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal sign_ext_out_tb     : std_logic_vector(2 downto 0);
  signal clear_ifid_tb       : std_logic;
  signal alu_op_tb           : std_logic_vector(2 downto 0);
  signal alu_mux_out_tb      : std_logic;
  signal idex_pc_out_tb         : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal alu_mux_tb             : std_logic;
  signal res_in_tb              : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal tree_pc_tb             : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal addr_src_out_tb        : std_logic;
  signal clear_ifid_idex_out_tb : std_logic;
  signal addr_a_tb              : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal fwd_rs1_tb             : std_logic_vector(1 downto 0);
  signal fwd_rs2_tb             : std_logic_vector(1 downto 0);
  signal next_pc_out_tb         : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal pc_plus_four_tb        : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
  signal mem_en_tb              : std_logic;
  signal mem_en_out_tb          : std_logic;
  signal mem_wre_tb             : std_logic;
  signal mem_wre_out_tb         : std_logic;
  signal ex_outp_tb             : std_logic;
  signal ex_outp_out_tb         : std_logic;
  signal alu_op_sel_tb          : std_logic;
  signal alu_op_sel_out_tb      : std_logic;
  signal b_fwd_mux              : std_logic_vector(DATA_WIDTH_TB - 1 downto 0);
begin

  clk_tb     <= not clk_tb after CLK_PERIOD / 2;
  rd_tb      <= wb_data_out_tb when data_sel_out_tb = '0' else mem_data_tb;
  tree_pc_tb <= next_pc_tb when pc_mod_tb = '0' else pc_tb;
  rd_in_tb   <= inst_out_tb(11 downto 7) when inst_out_tb(6 downto 0) /= "0100011" and inst_out_tb(6 downto 0) /= "1100011" else (others => '0');
  res_in_tb  <= c_tb when ex_outp_out_tb = '0' else pc_plus_four_tb;
  a_tb       <= res_out_tb when fwd_rs1_tb = "01" else rd_tb when fwd_rs1_tb = "10" else rs1_out_tb;
  b_fwd_mux  <= res_out_tb when fwd_rs2_tb = "01" else rd_tb when fwd_rs2_tb = "10" else rs2_out_tb;
  b_tb       <= b_fwd_mux when imm_sel_out_tb = '0' else imm_out_tb;
  alu_op_tb  <= funct3_out_tb when alu_op_sel_out_tb = '0' else "000";

  -- INSTRUCTION FETCH

  INSTRUCTION_MEM: entity work.instruction_mem(rtl)
  generic map( 
    ADDR_WIDTH => 12,
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    address => next_pc_tb(13 downto 2),
    data_out => ram_dout_tb,
    en => not (reset_tb),
    clk => clk_tb
  );

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
    pc => tree_pc_tb,
    address => std_logic_vector(unsigned(addr_a_tb) + unsigned(immediate_tb)),
    address_src => address_src_tb
  );

  IFID: entity work.ifid_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH_TB
  )
  port map(
    wre             => '1',
    reset           => reset_tb,
    clk             => clk_tb,
    pc_in           => pc_tb,
    pc_out          => pc_out_tb,
    next_pc_in      => next_pc_tb,
    next_pc_out     => next_pc_out_tb,
    instruction_in  => ram_dout_tb,
    instruction_out => inst_out_tb
  );

  -- INSTRUCTION DECODE

  CONTROL_UNIT: entity work.control_unit(rtl)
  port map(
    opcode     => inst_out_tb(6 downto 0),
    alu_op_sel => alu_op_sel_tb,
    mem_en     => mem_en_tb,
    mem_wre    => mem_wre_tb,
    imm_sel    => imm_sel_tb,
    ex_outp    => ex_outp_tb 
  );

  IMM: entity work.immediate_generator(rtl)
  generic map(
    OPCODE_WIDTH => OPCODE_WIDTH_TB,
    IMM_WIDTH => IMM_WIDTH_TB,
    INST_WIDTH => INSTR_WIDTH_TB
  )
  port map(
    immediate => immediate_tb,
    instruction => inst_out_tb
  );

  REG_FILE: entity work.registers_unit(rtl)
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

  IDEX: entity work.idex_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    clk              => clk_tb,
    reset            => reset_tb,
    wre              => '1',
    funct3_in        => inst_out_tb(14 downto 12),
    funct3_out       => funct3_out_tb,
    rs1_sel_in       => inst_out_tb(19 downto 15),
    rs1_sel_out      => ex_rs1_sel_out_tb,
    rs1_in           => rs1_tb,
    rs1_out          => rs1_out_tb,
    rs2_sel_in       => inst_out_tb(24 downto 20),
    rs2_sel_out      => ex_rs2_sel_out_tb,
    rs2_in           => rs2_tb,
    rs2_out          => rs2_out_tb,
    rd_in            => rd_in_tb,
    rd_out           => rd_out_tb,
    imm_in           => immediate_tb,
    imm_out          => imm_out_tb, 
    alu_mod_in       => inst_out_tb(30),
    alu_mod_out      => alu_mod_out_tb,
    idex_pc_in       => pc_out_tb,
    idex_pc_out      => idex_pc_out_tb,
    pc_plus_four_in  => next_pc_out_tb,
    pc_plus_four_out => pc_plus_four_tb,
    imm_sel_in       => imm_sel_tb,
    imm_sel_out      => imm_sel_out_tb, 
    mem_en_in        => mem_en_tb,
    mem_en_out       => mem_en_out_tb,
    mem_wre_in       => mem_wre_tb,
    mem_wre_out      => mem_wre_out_tb,
    ex_outp_in       => ex_outp_tb,
    ex_outp_out      => ex_outp_out_tb,
    alu_op_sel_in    => alu_op_sel_tb,
    alu_op_sel_out   => alu_op_sel_out_tb 
  );

  -- EXECUTE
  ALU: entity work.alu(rtl)
  generic map(
    A_WIDTH => DATA_WIDTH_TB,
    B_WIDTH => DATA_WIDTH_TB,
    C_WIDTH => DATA_WIDTH_TB
  )
  port map(
    a => a_tb,
    b => b_tb,
    c => c_tb,
    op_select => alu_op_tb,
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
    res_in => res_in_tb,
    res_out => res_out_tb,
    mem_op_in => mem_en_out_tb,
    mem_op_out => data_mem_en_tb,
    data_wre_in => mem_wre_out_tb,
    data_wre_out => data_wre_tb,
    rd_in => rd_out_tb,
    rd_out => mem_rd_out_tb,
    mask_in => funct3_out_tb,
    mask_out => data_mask_tb
  );

  -- MEMORY ACCESS

  DATA_MEM: entity work.ram(rtl)
  generic map(
    ADDR_WIDTH => 12,
    DATA_WIDTH => DATA_WIDTH_TB,
    WORD_WIDTH => 8
  )
  port map(
    address => res_out_tb(11 downto 0),
    din     => mem_rs2_out_tb,
    dout    => data_dout_tb,
    mask    => data_mask_tb(1 downto 0),
    en      => data_mem_en_tb,
    wre     => data_wre_tb,
    clk     => clk_tb
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
    data_out => wb_data_out_tb,
    data_sel_in => data_mem_en_tb,
    data_sel_out => data_sel_out_tb,
    rd_in => mem_rd_out_tb,
    rd_out => rd_sel_tb,
    sign_ext_in => data_mask_tb,
    sign_ext_out => sign_ext_out_tb
  );
      
  SIGN_EXT: entity work.sign_extender(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    data_in => data_dout_tb,
    data_out => mem_data_tb,
    op => sign_ext_out_tb 
  );


  -- HAZARD CONTROL
  FORWARDING: entity work.forwarding_unit(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH_TB
  )
  port map(
    rs1_sel    => ex_rs1_sel_out_tb,
    rs2_sel    => ex_rs2_sel_out_tb,
    mem_rd_sel => mem_rd_out_tb,
    wb_rd_sel  => rd_sel_tb,
    fwd_rs1    => fwd_rs1_tb,
    fwd_rs2    => fwd_rs2_tb 
  );

  stimuli: process
  begin
    reset_tb <= '1';
    wait until rising_edge(clk_tb);
    reset_tb <= '0';
    wait;

  end process;

end architecture sim;