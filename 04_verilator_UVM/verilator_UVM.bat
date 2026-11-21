:@echo off

wsl verilator --cc --binary --timing --hierarchical --trace-vcd --trace-params --top tb ^
--trace-structs --coverage --assert --trace-underscore -j 0 -Wno-WIDTHEXPAND -Wno-TIMESCALEMOD ^
-Wno-WIDTHTRUNC -Wno-INITIALDLY -Wno-UNSIGNED -Wno-IGNOREDRETURN -Wno-fatal ^
+incdir+"/opt/accellera/1800.2-2020.3.2/src" +define+UVM_NO_DPI ^
/opt/accellera/1800.2-2020.3.2/src/uvm_pkg.sv switch.sv switch_tb.sv

cd obj_dir

wsl ./Vtb

gtkwave dump.vcd

cd ..

wsl verilator_coverage --annotate ./coverage --annotate-all --annotate-min 1 --write-info ./coverage/coverage.info ./obj_dir/coverage.dat

wsl genhtml ./coverage/coverage.info --branch-coverage -o ./coverage/info