library ieee;
use ieee.std_logic_1164.all;

entity seq_detector is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;      -- asynchronous, active high
    x     : in  std_logic;      -- serial input stream
    z     : out std_logic       -- output: 1 when 001, 010, or 110 detected (no overlap)
  );
end entity;

architecture rtl of seq_detector is
  -- Moore FSM States
  type state_t is (
    START,       -- initial/reset
    S0, S1,      -- seen: 0 or 1
    S00, S01,    -- seen: 00 or 01
    S10, S11,    -- seen: 10 or 11
    DETECT       -- output pulse
  );

  signal s, s_n : state_t;
begin
  -------------------------------------------------------------------
  -- State Register
  -------------------------------------------------------------------
  process(clk, reset)
  begin
    if reset = '1' then
      s <= START;
    elsif rising_edge(clk) then
      s <= s_n;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Next-State and Output Logic (Moore)
  -------------------------------------------------------------------
  process(s, x)
  begin
    z   <= '0';
    s_n <= s;

    case s is
      when START =>
        if x='0' then s_n <= S0; else s_n <= S1; end if;

      when S0 =>
        if x='0' then s_n <= S00; else s_n <= S01; end if;

      when S1 =>
        if x='0' then s_n <= S10; else s_n <= S11; end if;

      when S00 =>
        if x='1' then s_n <= DETECT;    -- detects 001
        else            s_n <= S00;
        end if;

      when S01 =>
        if x='0' then s_n <= DETECT;    -- detects 010
        else            s_n <= S11;     -- becomes 011 → suffix 11
        end if;

      when S10 =>
        if x='0' then s_n <= S00; else s_n <= S01; end if;

      when S11 =>
        if x='0' then s_n <= S10; else s_n <= S11; end if;

      when DETECT =>
        z   <= '1';                     -- one-cycle pulse
        s_n <= START;                   -- no overlap: restart
    end case;
  end process;
end architecture;

