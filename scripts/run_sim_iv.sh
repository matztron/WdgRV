export RGGEN_VERILOG_RTL_ROOT="./submodules/rggen-verilog-rtl"

iverilog -f "${RGGEN_VERILOG_RTL_ROOT}/compile.f" sim/wdg_tb.v wdg_top.v down_counter/cntr.v fsm/fsm.v reg/wdgrv_regs.v -o out/wdg_rv_out -s wdg_tb
vvp out/wdg_rv_out
#gtkwave out/wdg_rv_out.vcd &