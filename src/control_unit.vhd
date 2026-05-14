library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
generic(
  DATA_WIDTH : integer := 32
);
port(
  ex_fwd_data : in std_logic_vector(DATA_WIDTH - 1 downto 0); 
  id_fwd_data : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs2_out     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  reg_rs2     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs1_out     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  reg_rs1     : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  imm         : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  inst        : in std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs1         : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  rs2         : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  alu_a       : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  alu_b       : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  imm_found   : in std_logic;
  ex_fwd_rs2  : in std_logic;
  id_fwd_rs2  : in std_logic;
  ex_fwd_rs1  : in std_logic;
  id_fwd_rs1  : in std_logic;  
  alu_op      : out std_logic_vector(2 downto 0);
  clear_ifid  : out std_logic;
  pc_offset   : out std_logic;
  alu_mux     : out std_logic;
  addr_src    : out std_logic
);
end entity control_unit;

architecture rtl of control_unit is
begin
  process(inst)
  begin
    case inst(6 downto 0) is
      when "1101111" | "1100111"=> 
        alu_mux <= '1';
        clear_ifid <= '1';
        pc_offset <= '1';
        alu_op <= "000";
        addr_src <= not inst(3);
      
      when "0000011" | "0100011" => 
        alu_mux <= '0';
        clear_ifid <= '0';
        pc_offset <= '0';
        alu_op <= "000";
        addr_src <= '0';

      when others => 
        alu_mux <= '0';
        clear_ifid <= '0'; 
        pc_offset <= '0';
        alu_op <= inst(14 downto 12);
        addr_src <= '0';

    end case;
  end process;

  B_PROCESS: process(imm_found, ex_fwd_rs2, rs2_out, ex_fwd_data, imm)
  begin
    alu_b <= rs2_out when imm_found = '0' and ex_fwd_rs2 = '0' else ex_fwd_data 
                     when imm_found = '0' and ex_fwd_rs2 = '0' else imm;
  end process B_PROCESS;

  A_PROCESS: process(ex_fwd_rs1, rs1_out, ex_fwd_data)
  begin
    alu_a <= rs1_out when ex_fwd_rs1 = '0' else ex_fwd_data;
  end process A_PROCESS;

  RS1_PROCESS: process(id_fwd_rs1, reg_rs1, id_fwd_data)
  begin
    rs1 <= reg_rs1 when id_fwd_rs1 = '0' else id_fwd_data;
  end process RS1_PROCESS;

  RS2_PROCESS: process(id_fwd_rs2, reg_rs2, id_fwd_data)
  begin
    rs2 <= reg_rs2 when id_fwd_rs2 = '0' else id_fwd_data;
  end process;

end architecture rtl;