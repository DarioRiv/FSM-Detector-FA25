vdel -lib work -all
vlib work
vmap work work

vcom -2008 seq_detector.vhd
vcom -2008 tb_seq_detector.vhd

vsim -voptargs=+acc work.tb_seq_detector

add wave -radix binary  sim:/tb_seq_detector/clk
add wave -radix binary  sim:/tb_seq_detector/reset
add wave -radix binary  sim:/tb_seq_detector/x
add wave -radix binary  sim:/tb_seq_detector/z
add wave -radix binary  sim:/tb_seq_detector/Q
add wave -radix binary  sim:/tb_seq_detector/P

run -all
