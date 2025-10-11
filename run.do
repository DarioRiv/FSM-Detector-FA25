transcript on
onerror {quit -code 1}

vdel -lib work -all
vlib work
vmap work work

vcom -2008 seq_detector.vhd
vcom -2008 tb_seq_detector.vhd

vsim -voptargs=+acc work.tb_seq_detector

# log everything and add key waves
log -r /*

add wave -radix binary  sim:/tb_seq_detector/clk
add wave -radix binary  sim:/tb_seq_detector/reset
add wave -radix binary  sim:/tb_seq_detector/x
add wave -radix binary  sim:/tb_seq_detector/z
add wave -radix binary  sim:/tb_seq_detector/Q

# enum state inside UUT (note: instance name 'uut', signal 'current_state')
add wave -radix symbolic sim:/tb_seq_detector/uut/current_state

# optional: also watch the tiny checker signals if you kept them
# add wave -radix binary sim:/tb_seq_detector/last2
# add wave -radix binary sim:/tb_seq_detector/exp_now
# add wave -radix binary sim:/tb_seq_detector/exp_z_pipe

run -all
wave zoom full
