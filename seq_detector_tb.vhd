-- Testbench created online at:
--   https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd

library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity seq_detector_tb is
end;

architecture bench of seq_detector_tb is

  component seq_detector
    port (
      clk   : in  std_logic;
      reset : in  std_logic;
      x     : in  std_logic;
      z     : out std_logic;
      Q     : out std_logic_vector(2 downto 0)
    );
  end component;

  signal clk  : std_logic := '0';
  signal reset: std_logic := '0';
  signal x    : std_logic := '0';
  signal z    : std_logic;
  signal Q    : std_logic_vector(2 downto 0);

  constant clock_period : time := 10 ns;
  signal stop_the_clock : boolean := false;

begin
  uut: seq_detector
    port map (
      clk   => clk,
      reset => reset,
      x     => x,
      z     => z,
      Q     => Q
    );

  -- CLOCK ----------------------------------------------------------
  clocking: process
  begin
    while not stop_the_clock loop
      clk <= '0';
      wait for clock_period/2;
      clk <= '1';
      wait for clock_period/2;
    end loop;
    wait;
  end process;

  -- STIMULUS -------------------------------------------------------
  stimulus: process
    -- std_logic -> "0"/"1"/"?"
    function sl_to_str(s : std_logic) return string is
    begin
      if s = '0' then
        return "0";
      elsif s = '1' then
        return "1";
      else
        return "?";
      end if;
    end function;

    procedure step_bit(b : std_logic; expect_z : std_logic; msg : string) is
    begin
      x <= b;
      wait until rising_edge(clk);  -- z is Mealy; check same cycle
      wait for 1 ns;                -- small settle time
      assert z = expect_z
        report msg & "  (got z=" & sl_to_str(z) &
               ", expect=" & sl_to_str(expect_z) & ")"
        severity error;
    end procedure;

  begin
    -- Sync reset high for one rising edge
    reset <= '1';
    wait until rising_edge(clk);
    reset <= '0';
    wait until rising_edge(clk);
    wait for 1 ns;

    -- T1: 001 -> expect z = 0,0,1
    step_bit('0','0',"T1 001 bit1");
    step_bit('0','0',"T1 001 bit2");
    step_bit('1','1',"T1 001 bit3");

    wait until rising_edge(clk); wait for 1 ns;  -- spacer

    -- T2: 010 -> expect z = 0,0,1
    step_bit('0','0',"T2 010 bit1");
    step_bit('1','0',"T2 010 bit2");
    step_bit('0','1',"T2 010 bit3");

    wait until rising_edge(clk); wait for 1 ns;  -- spacer

    -- T3: 110 -> expect z = 0,0,1
    step_bit('1','0',"T3 110 bit1");
    step_bit('1','0',"T3 110 bit2");
    step_bit('0','1',"T3 110 bit3");

    wait until rising_edge(clk); wait for 1 ns;  -- spacer

    -- T4: non-overlap check: 0010 -> 0,0,1,0
    step_bit('0','0',"T4 0010 bit1");
    step_bit('0','0',"T4 0010 bit2");
    step_bit('1','1',"T4 0010 bit3");
    step_bit('0','0',"T4 0010 bit4");

    wait until rising_edge(clk); wait for 1 ns;  -- spacer

    -- T5: noise: 10000 -> 0,0,0,0,0
    step_bit('1','0',"T5 10000 bit1");
    step_bit('0','0',"T5 10000 bit2");
    step_bit('0','0',"T5 10000 bit3");
    step_bit('0','0',"T5 10000 bit4");
    step_bit('0','0',"T5 10000 bit5");

    report "All tests executed." severity note;

    stop_the_clock <= true;
    wait;
  end process;

end architecture bench;

-- Test bench configuration created online at:
--    https://www.doulos.com/knowhow/perl/vhdl-testbench-creation-using-perl/
-- Copyright Doulos Ltd
configuration cfg_seq_detector_tb of seq_detector_tb is
  for bench
    for uut: seq_detector
      -- Default configuration
    end for;
  end for;
end cfg_seq_detector_tb;

configuration cfg_seq_detector_tb_rtl of seq_detector_tb is
  for bench
    for uut: seq_detector
      use entity work.seq_detector(rtl);
    end for;
  end for;
end cfg_seq_detector_tb_rtl;
