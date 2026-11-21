:@echo off

wsl verilator --cc --binary --timing --hierarchical --trace-vcd --trace-params ^
--trace-structs --coverage --assert --trace-underscore -j 0 ^
-Wno-IMPLICITSTATIC -Wno-WIDTHTRUNC ^
random_example_tb.sv

cd obj_dir

wsl ./Vrandom_example_tb

cd ..