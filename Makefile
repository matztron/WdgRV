# Makefile to run rggen with specified configuration and register map

# Variables
RTL_PATH = rtl
SIM_PATH = sim
RGGEN_PATH = rggen_spec
# rggen files
CONFIG_FILE = design_cfg.yml
WDG_REG_MAP = reg_wdg_map_spec.rb
MTIME_REG_MAP = reg_mtime_map_spec.rb
REG_OUTPUT_DIR = $(RTL_PATH)/reg/

# wdg & mtime memory mapped register design
#DESIGN_SOURCES = $(RTL_PATH)/wdg_top.v $(RTL_PATH)/mtime_top.v $(RTL_PATH)/cntr.v $(RTL_PATH)/fsm.v $(RTL_PATH)/reg/wdgrv_regs.v $(RTL_PATH)/reg/machine_time.v $(RTL_PATH)/wdg_interface_def.h
# only wdg
DESIGN_SOURCES = $(RTL_PATH)/wdg_top.v $(RTL_PATH)/cntr.v $(RTL_PATH)/fsm.v $(RTL_PATH)/reg/wdgrv_regs.v $(RTL_PATH)/clkdiv.v $(RTL_PATH)/wdg_interface_def.h

DESIGN_SOURCES_FLAT = -I${RGGEN_VERILOG_RTL_ROOT} \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_or_reducer.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_mux.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_bit_field.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_bit_field_w01trg.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_address_decoder.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_register_common.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_default_register.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_external_register.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_indirect_register.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_adapter_common.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_apb_adapter.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_apb_bridge.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_axi4lite_skid_buffer.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_axi4lite_adapter.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_axi4lite_bridge.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_avalon_adapter.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_avalon_bridge.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_wishbone_adapter.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_wishbone_bridge.v \
	${RGGEN_VERILOG_RTL_ROOT}/rggen_native_adapter.v \
	$(DESIGN_SOURCES)

export RGGEN_VERILOG_RTL_ROOT = ./submodules/rggen-verilog-rtl

# Default target
all: simulate

# Rule to run rggen
# clean old reg output beforehand
generate_regs: clean
	rggen --plugin rggen-verilog --configuration $(RGGEN_PATH)/$(CONFIG_FILE) $(RGGEN_PATH)/$(WDG_REG_MAP) -o $(REG_OUTPUT_DIR)
#	rggen --plugin rggen-verilog --configuration $(RGGEN_PATH)/$(CONFIG_FILE) $(RGGEN_PATH)/$(MTIME_REG_MAP) -o $(REG_OUTPUT_DIR)

sim_iv:
	iverilog -f "${RGGEN_VERILOG_RTL_ROOT}/compile.f" $(SIM_PATH)/wdg_tb.v $(DESIGN_SOURCES) -o $(SIM_PATH)/out/wdg_rv_out -s wdg_tb

sim_vvp: sim_iv
	vvp sim/out/wdg_rv_out

sim_gtkwave: sim_vvp
	gtkwave sim/out/wdg_rv_out.vcd &

simulate: sim_gtkwave

# Verilator - not needed for now
#sim_veril:

# Get an area estimate for the design
# estimate wdg part size
estmate_area_wdg:
	yosys -p "read_verilog $(DESIGN_SOURCES_FLAT); \
	hierarchy -top wdg_top; \
	show -prefix generic_ro -format pdf -notitle wdg_top; \
	synth -top wdg_top"

# estimate mtime part size
#estmate_area_mtim:
#	yosys -p "read_verilog $(DESIGN_SOURCES_FLAT) \
#	hierarchy -top mtime_rv; \
#	synth_ice40"

# TODO: Properly add Slang to $PATH
lint_slang_wdg:
	/home/mat/EDA/slang/build/bin/slang --lint-only $(DESIGN_SOURCES_FLAT)

lint_verilator_wdg:
	verilator --lint-only --top-module wdg_top -Wall -Wno-GENUNNAMED -Wno-WIDTHEXPAND -Wno-UNUSEDPARAM -Wno-UNUSEDSIGNAL -Wno-WIDTHTRUNC $(DESIGN_SOURCES_FLAT)

# Clean rule
clean:
	rm -rf $(REG_OUTPUT_DIR)
	rm -f sim/out/*
