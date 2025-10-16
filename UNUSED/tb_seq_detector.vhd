-- tb_seq_detector.vhd
library ieee;
use ieee.std_logic_1164.all;

entity tb_seq_detector is
end entity;

architecture sim of tb_seq_detector is
  -- DUT ports
  signal clk   : std_logic := '0';
  signal reset : std_logic := '0';
  signal x     : std_logic := '0';
  signal z     : std_logic;
  signal Q     : std_logic_vector(2 downto 0);

  constant Tclk : time := 10 ns; -- 100 MHz for simulation

  -- expected-model bookkeeping
  signal last2      : std_logic_vector(1 downto 0) := "00";
  signal exp_now    : std_logic := '0';  -- combinational: does current 3-bit window match?
  signal exp_z_pipe : std_logic := '0';  -- one-cycle delayed expected z (since DUT asserts in DETECT state)

  -- stimulus bitstream covering overlaps & multiple detections:
  -- windows hitting: 001, 010, 110 (several times)
  constant STIM : std_logic_vector := 
    --   0 0 1 0 1 1 0  0 1 0  1 1 0 0 1
       "001011001011001";
  constant N : integer := STIM'length;
begin
  ---------------------------------------------------------------------------
  -- Clock
  ---------------------------------------------------------------------------
  clk <= not clk after Tclk/2;

  ---------------------------------------------------------------------------
  -- DUT
  ---------------------------------------------------------------------------
  uut: entity work.seq_detector
    port map (
      clk   => clk,
      reset => reset,
      x     => x,
      z     => z,
      Q     => Q
    );

  ---------------------------------------------------------------------------
  -- Reset & stimulus drive
  ---------------------------------------------------------------------------
  stim_proc : process
  begin
    -- hold reset for a few cycles
    reset <= '1';
    x     <= '0';
    wait for 4*Tclk;
    reset <= '0';

    -- drive the bitstream, one bit per rising edge
    for i in 0 to N-1 loop
      x <= STIM(i);
      wait until rising_edge(clk);
    end loop;

    -- let pipeline flush a couple more cycles
    x <= '0';
    wait for 3*Tclk;

    report "Simulation finished." severity note;
    wait;
  end process;

  ---------------------------------------------------------------------------
  -- Detect 001, 010, 110 and compare with DUT 'z'
  ---------------------------------------------------------------------------
  model_chk : process(clk)
    variable errors : integer := 0;
  begin
    if rising_edge(clk) then
      if reset = '1' then
        last2      <= "00";
        exp_now    <= '0';
        exp_z_pipe <= '0';
      else
        -- build current 3-bit window: last2 & x
        case last2 & x is
          when "001" | "010" | "110" => exp_now <= '1';
          when others                 => exp_now <= '0';
        end case;

        -- z should assert one cycle AFTER detect decision (FSM goes to DETECT, then outputs)
        exp_z_pipe <= exp_now;

        -- update last two bits for next window
        last2 <= last2(0) & x;

        -- compare
        if z /= exp_z_pipe then
          errors := errors + 1;
          report "Mismatch at time " & time'image(now) &
                 "  (x=" & std_logic'image(x) &
                 ", last2=" & std_logic'image(last2(1)) & std_logic'image(last2(0)) &
                 ")  expected z=" & std_logic'image(exp_z_pipe) &
                 " got z=" & std_logic'image(z)
                 severity error;
        end if;
      end if;

      -- stop automatically if too many errors (optional)
      if errors > 10 then
        report "Too many mismatches; stopping." severity failure;
      end if;
    end if;
  end process;

end architecture;
