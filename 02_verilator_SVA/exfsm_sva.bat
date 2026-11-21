:@echo off

wsl verilator --main --cc --binary --build --coverage --trace --trace-coverage --trace-params ^
--trace-structs --trace-underscore -j 0 -Wno-TIMESCALEMOD -DSVA=1 --no-stop-fail exfsm_sva_tb.sv

cd obj_dir

wsl ./Vexfsm_sva_tb

gtkwave exfsm_sva.vcd

