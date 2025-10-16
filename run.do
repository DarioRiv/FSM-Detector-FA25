vdel -all
vlib work
vmap work work

vcom -2008 seq_detectorMEALY.vhd
vcom -2008 seq_detector_tb.vhd

# Elaborate (suppress Intel's auto -novopt deprecation message)
vsim -suppress 12110 -voptargs=+acc work.seq_detector_tb

# Don't break on asserts / errors during run
quietly set BreakOnAssertion 0
onbreak resume
onerror {resume}
onfinish stop      ;# or: onfinish quit -f

# Waves
add wave -hex    sim:/seq_detector_tb/Q
add wave         sim:/seq_detector_tb/clk
add wave         sim:/seq_detector_tb/reset
add wave         sim:/seq_detector_tb/x
add wave         sim:/seq_detector_tb/z
# add wave sim:/seq_detector_tb/uut/s  ;# (optional internal state)

run -all
