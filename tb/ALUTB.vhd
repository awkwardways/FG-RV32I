library ieee;
use ieee.std_logic_1164.all;
use std.env.finish;

entity ALUTB is 
end entity ALUTB;

architecture sim of ALUTB is
  constant DATA_WIDTH : integer := 32;
  signal a_tb      : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal b_tb      : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal c_tb      : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal op_select_tb : std_logic_vector(2 downto 0);
  signal enable_tb : std_logic;
  signal modifier_tb  : std_logic; 
begin

  UUT: entity work.ALU(rtl)
  generic map(
    A_WIDTH => DATA_WIDTH,
    B_WIDTH => DATA_WIDTH,
    C_WIDTH => DATA_WIDTH
  )
  port map(
    a => a_tb,
    b => b_tb,
    c => c_tb,
    modifier => modifier_tb,
    enable => enable_tb,
    op_select => op_select_tb
  );

  stimuli: process
  begin
    enable_tb <= '0';
    
    --Addition
    op_select_tb <= "000";
    a_tb <= x"ffffffff";
    b_tb <= x"ffffffff";
    wait for 2 ns;
    assert c_tb = 32x"0" report "Sum not performed correctly" severity failure;

    --Substraction
    modifier_tb <= '1';
    wait for 2 ns;
    assert c_tb = 32x"0" report "Substraction not performed correctly" severity failure;

    --Shift Left Logical
    modifier_tb <= '0';
    op_select_tb <= "001";
    a_tb <= 32x"5";
    b_tb <= 32x"2";
    wait for 2 ns;
    assert c_tb <= 32x"14" report "Left logical shift not performed correctly" severity failure;

    --Set Less Than signed
    op_select_tb <= "010";
    a_tb <= 32x"14";
    b_tb <= x"fffffffe";
    wait for 2 ns;
    assert c_tb <= 32x"1" report "Set less than signed not performed correctly" severity failure;
    a_tb <= x"fffffffe";
    b_tb <= 32x"14";
    wait for 2 ns;
    assert c_tb <= 32x"0" report "Set less than signed not performed correctly" severity failure;

    --Set Less Than Unsigned
    op_select_tb <= "011";
    a_tb <= 32x"14";
    b_tb <= 32x"20";
    wait for 2 ns;
    assert c_tb <= 32x"0" report "Set less than not performed correctly" severity failure;
    a_tb <= 32x"20";
    b_tb <= 32x"14";
    wait for 2 ns;
    assert c_tb <= 32x"1" report "Set less than not performed correctly" severity failure;

    --XOR
    op_select_tb <= "100";
    a_tb <= 32x"aaaaaaaa";
    b_tb <= 32x"55555555";
    wait for 2 ns;
    assert c_tb <= x"ffffffff" report "XOR not performed correctly" severity failure;

    --Shift Right Logical
    op_select_tb <= "101";
    a_tb <= 32x"5";
    b_tb <= 32x"2";
    wait for 2 ns;
    assert c_tb <= 32x"1" report "Right Logical Shift not performed correctly" severity failure;
    
    --Shift Right Arithmetic
    modifier_tb <= '1';
    a_tb <= 32x"fffffffe";
    b_tb <= 32x"2";
    wait for 2 ns;
    assert c_tb <= x"ffffffff" report "Right arithmetic shift not performed correctly" severity failure;

    --OR
    op_select_tb <= "110";
    a_tb <= 32x"aaaaaaaa";
    b_tb <= 32x"5a5a5a5a";
    wait for 2 ns;
    assert c_tb <= x"fafafafa" report "OR not performed correctly" severity failure;
    
    --AND 
    op_select_tb <= "111";
    wait for 2 ns;
    assert c_tb <= x"0a0a0a0a" report "AND not performed correctly" severity failure;
    finish;

  end process;

end architecture sim;