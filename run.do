vdel -all
vlib work
vmap work work

vcom -2008 seq_detectorMEALY.vhd
vcom -2008 seq_detector_tb.vhd

# Elaborate (Intel edition). If your ModelSim injects -novopt, you can add: -suppress 12110
vsim -t ns -voptargs=+acc work.seq_detector_tb

# Don't break on asserts / errors during run
quietly set BreakOnAssertion 0
onbreak resume
onerror {resume}
onfinish stop      ;# or: onfinish quit -f

# Waves (Q in binary)
add wave               sim:/seq_detector_tb/clk
add wave               sim:/seq_detector_tb/reset
add wave               sim:/seq_detector_tb/x
add wave               sim:/seq_detector_tb/z
add wave -radix bin    sim:/seq_detector_tb/Q
# Optional: internal enum state
# add wave             sim:/seq_detector_tb/uut/s

# Optional: global display prefs
configure wave -timelineunits ns
radix binary    ;# default radix for any subsequently added signals

run -all
