vsim -gui work.pipeline
add wave -position end sim:/pipeline/*
force -freeze sim:/pipeline/forward_E 1 0
force -freeze sim:/pipeline/clk 1 0, 0 {50 ns} -r 100
force -freeze sim:/pipeline/rst 1 0
force -freeze sim:/pipeline/hazard_E 1 0
force -freeze sim:/pipeline/interrupt_sig 0 0
force -freeze sim:/pipeline/read_same_inst 0 0
add wave -position end sim:/pipeline/HDU/*
run
force -freeze sim:/pipeline/rst 0 0
run
run
run
run
force -freeze sim:/pipeline/in_port 32'h0CDAFE19 0
run
run
force -freeze sim:/pipeline/in_port 32'hffff 0
run
run
force -freeze sim:/pipeline/in_port 32'hf320 0
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