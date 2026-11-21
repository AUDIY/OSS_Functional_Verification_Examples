:@echo off

wsl verilator --main --cc --binary --build --coverage --trace --trace-coverage --trace-params ^
--trace-structs --trace-underscore -j 0 -Wno-WIDTHTRUNC ex_func_cov_tb.sv

cd obj_dir

wsl ./Vex_func_cov_tb

cd ..

wsl verilator_coverage --annotate ./coverage ^
--annotate-all --annotate-min 1 --write-info ./coverage/coverage.info ./obj_dir/coverage.dat

wsl verilator_coverage --report summary ./obj_dir/coverage.dat | wsl tee ./coverage/coverage_report_summary.txt

wsl verilator_coverage --report hier ./obj_dir/coverage.dat | wsl tee ./coverage/coverage_report_hier.txt

wsl genhtml ./coverage/coverage.info --branch-coverage -o ./coverage/info
