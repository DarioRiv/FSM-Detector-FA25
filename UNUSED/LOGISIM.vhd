library ieee;
use ieee.std_logic_1164.all;

entity seq_detector is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;      -- async, active high
    x     : in  std_logic;      -- serial bit input
    z     : out std_logic;      -- one-cycle pulse on 001/010/110
    Q     : out std_logic_vector(2 downto 0)  -- present state (for LEDs)
  );
end entity seq_detector;

architecture rtl of seq_detector is
  type state_t is (
    START,
    S0, S1,
    S00, S01,
    S10, S11,
    DETECT
  );

  signal s, s_n : state_t;
begin
  -- State register
  process(clk, reset)
  begin
    if reset = '1' then
      s <= START;
    elsif rising_edge(clk) then
      s <= s_n;
    end if;
  end process;

  -- Next-state and Moore output
  process(s, x)
  begin
    z   <= '0';
    s_n <= s;

    case s is
      when START =>
        if x='0' then s_n <= S0;  else s_n <= S1;  end if;

      when S0 =>
        if x='0' then s_n <= S00; else s_n <= S01; end if;

      when S1 =>
        if x='0' then s_n <= S10; else s_n <= S11; end if;

      when S00 =>
        if x='1' then s_n <= DETECT;                -- 001
        else            s_n <= S00;
        end if;

      when S01 =>
        if x='0' then s_n <= DETECT;                -- 010
        else            s_n <= S11;                 -- 011 keeps suffix 11
        end if;

      when S10 =>
        if x='0' then s_n <= S00; else s_n <= S01; end if;

      when S11 =>
        if x='0' then s_n <= DETECT;                -- 110  
        else            s_n <= S11;
        end if;

      when DETECT =>
        z   <= '1';                                  -- one-cycle pulse
        s_n <= START;                                -- no overlap
    end case;
  end process;

  -- Present-state output for LEDs (no numeric conversions)
  with s select
    Q <= "000" when START,
         "001" when S0,
         "010" when S1,
         "011" when S00,
         "100" when S01,
         "101" when S10,
         "110" when S11,
         "111" when DETECT;

end architecture rtl;
