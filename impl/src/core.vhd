library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity core is 
port(
  clk   : in std_logic;
  reset : in std_logic;
  res   : out std_logic_vector(31 downto 0)
);
end entity core;

architecture rtl of core is
  constant INSTR_WIDTH       : integer := 32;
  constant ADDR_WIDTH        : integer := 32;
  constant DATA_WIDTH        : integer := 32;
  constant OPCODE_WIDTH      : integer := 7;
  constant IMM_WIDTH         : integer := 32;
  constant INST_WIDTH        : integer := 32;

  signal address_out         : std_logic_vector(ADDR_WIDTH - 1 downto 0);
  signal ram_dout            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal inst_out            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal pc_out              : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal next_pc             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal pc                  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal immediate           : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal imm_sel             : std_logic;
  signal funct3_out          : std_logic_vector(2 downto 0);
  signal rs1                 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rs2                 : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rd                  : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rd_in               : std_logic_vector(4 downto 0);
  signal rd_sel              : std_logic_vector(4 downto 0);
  signal rs1_out             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rs2_out             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal rd_out              : std_logic_vector(4 downto 0);
  signal imm_out             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal alu_mod_out         : std_logic;
  signal a                   : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal b                   : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal c                   : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem_rs2_out         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal res_out             : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem_rd_out          : std_logic_vector(4 downto 0);
  signal ex_rs1_sel_out      : std_logic_vector(4 downto 0);
  signal ex_rs2_sel_out      : std_logic_vector(4 downto 0);
  signal data_dout           : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem_op              : std_logic_vector(1 downto 0);
  signal data_wre            : std_logic;
  signal data_sel_out        : std_logic;
  signal wb_data_out         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal data_mask           : std_logic_vector(2 downto 0);
  signal mem_data            : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal sign_ext_out        : std_logic_vector(2 downto 0);
  signal alu_op              : std_logic_vector(2 downto 0);
  signal idex_pc_out         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal res_in              : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal fwd_rs1             : std_logic_vector(1 downto 0);
  signal fwd_rs2             : std_logic_vector(1 downto 0);
  signal next_pc_out         : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal pc_plus_four        : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal mem_en              : std_logic;
  signal mem_wre             : std_logic;
  signal ex_outp             : std_logic_vector(1 downto 0);
  signal alu_op_sel          : std_logic;
  signal b_fwd_mux              : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal imm_addr_src        : std_logic;
  signal ifid_reset          : std_logic;
  signal imm_addr               : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal cu_alu_op           : std_logic_vector(2 downto 0);
  signal branch              : std_logic;
  signal neg_alu             : std_logic;
  signal load_address        : std_logic;
  signal branch_taken        : std_logic;
  signal alu_mod             : std_logic;
  signal branch_reset        : std_logic;
  signal pc_tree_address     : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal opcode_out          : std_logic_vector(6 downto 0);
  
begin

  res             <= res_out;
  rd              <= wb_data_out when data_sel_out = '0' else mem_data;
  rd_in           <= inst_out(11 downto 7) when inst_out(6 downto 0) /= "0100011" and inst_out(6 downto 0) /= "1100011" else (others => '0');
  pc_plus_four    <= std_logic_vector(unsigned(idex_pc_out) + 4);
  res_in          <= pc_plus_four when ex_outp = "01" else 
                        imm_out when ex_outp = "10" else 
                        pc_tree_address when ex_outp = "11" else c;
  a               <= res_out when fwd_rs1 = "01" else rd when fwd_rs1 = "10" else rs1_out;
  b_fwd_mux       <= res_out when fwd_rs2 = "01" else rd when fwd_rs2 = "10" else rs2_out;
  b               <= b_fwd_mux when imm_sel = '0' else imm_out;
  alu_op          <= funct3_out when alu_op_sel = '0' else cu_alu_op;
  imm_addr        <= idex_pc_out when imm_addr_src = '0' else rs1_out;
  branch_taken    <= c(0) when neg_alu = '0' else not(c(0));
  branch_reset    <= branch and branch_taken;
  load_address    <= (ifid_reset or branch_reset) when branch = '0' else branch_taken;
  pc_tree_address <= std_logic_vector(unsigned(imm_addr) + unsigned(imm_out));

  -- INSTRUCTION FETCH

  INSTRUCTION_MEM: entity work.instruction_mem(rtl)
  generic map( 
    ADDR_WIDTH => 10,
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    address => next_pc(11 downto 2),
    data_out => ram_dout,
    en => not reset,
    clk => clk
  );

  MAR: entity work.memory_address_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH
  )
  port map(
    next_pc     => next_pc,
    pc          => pc,
    address_in  => address_out,
    reset       => reset,
    clk         => clk
  );

  address_out <= std_logic_vector(unsigned(next_pc) + 4) when load_address = '0' else pc_tree_address;

  IFID: entity work.ifid_register(rtl)
  generic map(
    ADDR_WIDTH => ADDR_WIDTH
  )
  port map(
    wre             => (not ifid_reset) or (not branch_reset),
    reset           => reset or ifid_reset or branch_reset,
    clk             => clk,
    pc_in           => pc,
    pc_out          => pc_out,
    instruction_in  => ram_dout,
    instruction_out => inst_out
  );

  -- INSTRUCTION DECODE

  CONTROL_UNIT: entity work.control_unit(rtl)
  port map(
    opcode       => opcode_out,
    funct_3      => funct3_out,
    amod         => alu_mod_out,
    alu_op_sel   => alu_op_sel,
    mem_en       => mem_en,
    mem_wre      => mem_wre,
    imm_sel      => imm_sel,
    ex_outp      => ex_outp,
    imm_addr_src => imm_addr_src,
    ifid_reset   => ifid_reset,
    alu_op       => cu_alu_op,
    branch       => branch,
    neg_alu      => neg_alu,
    alu_mod      => alu_mod
  );

  IMM: entity work.immediate_generator(rtl)
  generic map(
    OPCODE_WIDTH => OPCODE_WIDTH,
    IMM_WIDTH => IMM_WIDTH,
    INST_WIDTH => INSTR_WIDTH
  )
  port map(
    immediate => immediate,
    instruction => inst_out
  );

  REG_FILE: entity work.registers_unit(rtl)
  generic map(
    REG_WIDTH => DATA_WIDTH
  )
  port map(
    clk => clk,
    reset => reset,
    rs1_en => '1',
    rs2_en => '1',
    rs1_sel => inst_out(19 downto 15),
    rs2_sel => inst_out(24 downto 20),
    rd_sel => rd_sel,
    rs1 => rs1,
    rs2 => rs2,
    rd => rd,
    wre => '1'
  );

  IDEX: entity work.idex_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    clk              => clk,
    reset            => reset or ifid_reset or branch_reset,
    wre              => '1',
    opcode_in        => inst_out(6 downto 0),
    opcode_out       => opcode_out,
    funct3_in        => inst_out(14 downto 12),
    funct3_out       => funct3_out,
    rs1_sel_in       => inst_out(19 downto 15),
    rs1_sel_out      => ex_rs1_sel_out,
    rs1_in           => rs1,
    rs1_out          => rs1_out,
    rs2_sel_in       => inst_out(24 downto 20),
    rs2_sel_out      => ex_rs2_sel_out,
    rs2_in           => rs2,
    rs2_out          => rs2_out,
    rd_in            => rd_in,
    rd_out           => rd_out,
    imm_in           => immediate,
    imm_out          => imm_out, 
    alu_mod_in       => inst_out(30),
    alu_mod_out      => alu_mod_out,
    idex_pc_in       => pc_out,
    idex_pc_out      => idex_pc_out
  );

  -- EXECUTE
  ALU: entity work.alu(rtl)
  generic map(
    A_WIDTH => DATA_WIDTH,
    B_WIDTH => DATA_WIDTH,
    C_WIDTH => DATA_WIDTH
  )
  port map(
    a => a,
    b => b,
    c => c,
    op_select => alu_op & alu_mod_out
  );

  EXMEM: entity work.exmem_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    clk => clk,
    reset => reset,
    wre => '1',
    rs2_in => rs2_out,
    rs2_out => mem_rs2_out,
    res_in => res_in,
    res_out => res_out,
    mem_op_in => mem_en & mem_wre,
    mem_op_out => mem_op,
    rd_in => rd_out,
    rd_out => mem_rd_out,
    mask_in => funct3_out,
    mask_out => data_mask
  );

  -- MEMORY ACCESS

  DATA_MEM: entity work.ram(rtl)
  generic map(
    ADDR_WIDTH => 10,
    DATA_WIDTH => DATA_WIDTH,
    WORD_WIDTH => 8
  )
  port map(
    address => res_out(9 downto 0),
    din     => mem_rs2_out,
    dout    => data_dout,
    mask    => data_mask(1 downto 0),
    en      => mem_op(1),
    wre     => mem_op(0),
    clk     => clk
  );
  
  MEMWB: entity work.memwb_register(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    clk => clk,
    reset => reset,
    wre => '1',
    data_in => res_out,
    data_out => wb_data_out,
    data_sel_in => mem_op(1),
    data_sel_out => data_sel_out,
    rd_in => mem_rd_out,
    rd_out => rd_sel,
    sign_ext_in => data_mask,
    sign_ext_out => sign_ext_out
  );
      
  SIGN_EXT: entity work.sign_extender(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    data_in => data_dout,
    data_out => mem_data,
    op => sign_ext_out 
  );

  -- HAZARD CONTROL
  FORWARDING: entity work.forwarding_unit(rtl)
  generic map(
    DATA_WIDTH => DATA_WIDTH
  )
  port map(
    rs1_sel    => ex_rs1_sel_out,
    rs2_sel    => ex_rs2_sel_out,
    mem_rd_sel => mem_rd_out,
    wb_rd_sel  => rd_sel,
    fwd_rs1    => fwd_rs1,
    fwd_rs2    => fwd_rs2 
  );

end architecture rtl;