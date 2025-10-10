library ieee;
use ieee.std_logic_1164.all;

entity tb_seq_detector is
end entity;

architecture sim of tb_seq_detector is
  constant T : time := 10 ns;

  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal x     : std_logic := '0';
  signal z     : std_logic;
begin
  -- DUT (clk, reset, x, z)
  dut: entity work.seq_detector(rtl)
    port map (
      clk   => clk,
      reset => reset,
      x     => x,
      z     => z
    );

  -- 10 ns clock
  clk <= not clk after T/2;

  stimulus: process
    -- push one input bit, then give Moore logic a moment to settle
    procedure push(b: std_logic) is
    begin
      x <= b;
      wait until rising_edge(clk);
      wait for 1 ns;  -- avoid delta-cycle race on z
    end procedure;

    -- idle exactly one clean clock (keep x as-is)
    procedure tick is
    begin
      wait until rising_edge(clk);
      wait for 1 ns;
    end procedure;
  begin
    -- async reset
    reset <= '1'; wait for 7 ns; reset <= '0';
    wait until rising_edge(clk);
    wait for 1 ns;

    -- 001 -> exactly one pulse
    push('0'); push('0'); push('1');
    assert z='1' report "ERROR: 001 not detected" severity error;

    -- extra 0 must NOT create overlap (0010)
    push('0');
    assert z='0' report "ERROR: overlap after 0010" severity error;

    -- >>> IMPORTANT: allow FSM to move START -> S0 before beginning 010
    tick;  -- now the machine is in S0

    -- 010 -> one pulse
    push('1');  -- S0 -> S01
    push('0');  -- S01 -> DETECT (z='1')
    assert z='1' report "ERROR: 010 not detected" severity error;

    -- 110 -> one pulse
    push('1');  -- START -> S1
    push('1');  -- S1 -> S11
    push('0');  -- S11 -> DETECT
    assert z='1' report "ERROR: 110 not detected" severity error;

    -- ensure pulse is only 1 cycle
    tick;
    assert z='0' report "ERROR: z lasted > 1 cycle" severity error;

    report "Non-overlap checks passed." severity note;
    wait;
  end process;
end architecture;
