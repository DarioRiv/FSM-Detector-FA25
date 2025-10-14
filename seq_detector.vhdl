library ieee;
use ieee.std_logic_1164.all;

-- Mealy sequence detector: pulses z on 001, 010, 110 (non-overlap).
-- Ports match your Logisim block: clk, reset, x, z, Q[2:0].
entity seq_detector is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;                       -- synchronous, active high
    x     : in  std_logic;                       -- serial input bit
    z     : out std_logic;                       -- 1-cycle Mealy pulse
    Q     : out std_logic_vector(2 downto 0)     -- present state (for LEDs)
  );
end entity seq_detector;

architecture rtl of seq_detector is
  -- States (no DETECT state in Mealy)
  type state_t is (START, S0, S1, S00, S01, S10, S11);

  signal s, s_n : state_t := START;
begin

  -- State register (synchronous reset)

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        s <= START;
      else
        s <= s_n;
      end if;
    end if;
  end process;
  -- Next-state & Mealy output (combinational)
  -- Non-overlap: after detection we return to START.

  process(s, x)
  begin
    z   <= '0';          -- default
    s_n <= s;            -- default hold

    case s is
      when START =>
        if x = '0' then s_n <= S0;  else s_n <= S1;  end if;

      when S0 =>
        if x = '0' then s_n <= S00; else s_n <= S01; end if;

      when S1 =>
        if x = '0' then s_n <= S10; else s_n <= S11; end if;

      -- detect 001 (we were in "00" and got '1')
      when S00 =>
        if x = '1' then
          z   <= '1';
          s_n <= START;                   -- non-overlap restart
        else
          s_n <= S00;
        end if;

      -- detect 010 (we were in "01" and got '0')
      when S01 =>
        if x = '0' then
          z   <= '1';
          s_n <= START;                   -- non-overlap restart
        else
          s_n <= S11;                     -- suffix 11 kept
        end if;

      when S10 =>
        if x = '0' then s_n <= S00; else s_n <= S01; end if;

      -- detect 110 (we were in "11" and got '0')
      when S11 =>
        if x = '0' then
          z   <= '1';
          s_n <= START;                   -- non-overlap restart
        else
          s_n <= S11;
        end if;
    end case;
  end process;

  
  -- Present-state code to 3 LEDs 

  with s select
    Q <= "000" when START,
         "001" when S0,
         "010" when S1,
         "011" when S00,
         "100" when S01,
         "101" when S10,
         "110" when S11,
         "111" when others;   -- unused in this Mealy design
end architecture rtl;
