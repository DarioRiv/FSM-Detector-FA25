library ieee;
use ieee.std_logic_1164.all;

entity seq_detector is
  port (
    clk   : in  std_logic;
    reset : in  std_logic;
    x     : in  std_logic;
    z     : out std_logic;
    Q     : out std_logic_vector(2 downto 0)
  );
end seq_detector;

architecture rtl of seq_detector is
  type state_t is (START, S0, S1, S00, S01, S10, S11, DETECT);
  signal current_state : state_t := START;
  signal next_state    : state_t := START;
begin
  -- state register (sync, active-high)
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        current_state <= START;
      else
        current_state <= next_state;
      end if;
    end if;
  end process;

  -- next-state logic
  process(current_state, x)
  begin
    next_state <= current_state;  -- default
    case current_state is
      when START =>
        if x = '0' then next_state <= S0;  else next_state <= S1;  end if;

      when S0 =>
        if x = '0' then next_state <= S00; else next_state <= S01; end if;

      when S1 =>
        if x = '0' then next_state <= S10; else next_state <= S11; end if;

      when S00 =>
        if x = '1' then next_state <= DETECT; else next_state <= S00; end if;

      when S01 =>
        if x = '0' then next_state <= DETECT; else next_state <= S11; end if;

      when S10 =>
        if x = '0' then next_state <= S00; else next_state <= S01; end if;

      when S11 =>
        if x = '0' then next_state <= DETECT; else next_state <= S11; end if;

      when DETECT =>
        next_state <= START;

      when others =>
        next_state <= START;
    end case;
  end process;

  -- Moore output and state display
  z <= '1' when current_state = DETECT else '0';

  with current_state select
    Q <= "000" when START,
         "001" when S0,
         "010" when S1,
         "011" when S00,
         "100" when S01,
         "101" when S10,
         "110" when S11,
         "111" when DETECT,
         "000" when others;
end rtl;
