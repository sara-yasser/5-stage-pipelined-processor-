# make run length 50 ns
vsim -gui work.pipeline
add wave -position end sim:/pipeline/*
force -freeze sim:/pipeline/hazard_E 0 0
force -freeze sim:/pipeline/forward_E 0 0
force -freeze sim:/pipeline/interrupt_sig 0 0
force -freeze sim:/pipeline/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/pipeline/rst 1 0
run
force -freeze sim:/pipeline/rst 0 0
run
run
run
run
force -freeze sim:/pipeline/in_port 32'h5 0
run
run
force -freeze sim:/pipeline/in_port 32'h00000019 0
run
run
force -freeze sim:/pipeline/in_port 32'hfffd 0
run
run
force -freeze sim:/pipeline/in_port 32'h0000F320 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run
run