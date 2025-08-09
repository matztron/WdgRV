// TODO:
// What happens when MTIME stops ticking? Does the watchdog still provide protection? (OUT OF SCOPE FOR NOW)
// IPXACT speification
// Implement plattform specific bit fields in mtime module

//`include "rtl/wdg_interface_def.h"

module wdg_top #(
  // Wishbone
  parameter REG_ADDRESS_WIDTH = 2,
  parameter REG_PRE_DECODE = 0,
  parameter REG_BASE_ADDRESS = 0,
  parameter REG_ERROR_STATUS = 0,
  parameter REG_DEFAULT_READ = 0,
  parameter REG_INSERT_SLICER = 0,
  parameter REG_USE_STALLS = 1,

  parameter WB_DATA_WIDTH = 32,

  parameter WDG_TICK_BIT = 2, // can be set from 0 up to WDG_PRECLKDIV_WIDTH-1
  parameter WDG_PRECLKDIV_WIDTH = 20
)(
  input clk,
  input res_n,
  // Wishbone interface
  input i_wb_cyc,
  input i_wb_stb,
  output o_wb_stall,
  input [REG_ADDRESS_WIDTH-1:0] i_wb_adr,
  input i_wb_we,
  input [WB_DATA_WIDTH-1:0] i_wb_dat,
  input [3:0] i_wb_sel,
  output o_wb_ack,
  output o_wb_err,
  output o_wb_rty,
  output [WB_DATA_WIDTH-1:0] o_wb_dat,
  // ---
  output o_irq1,                                  // stage 1 watchdog timeout
  output o_irq2                                   // stage 2 watchdog timeout

  //input wdg_tick

);

  wire wdcsr_wden;
  wire [9:0] wdcsr_wtocnt;

  wire wdcsr_s2wto, wdcsr_s1wto;

  wire do_cnt; // TODO: Like a enable signal?

  wire sw_trg_s1wto, sw_trg_s2wto;

  // Down counter
  wire cnt0;
  wire [9:0] cnt;

  wire wdg_tick;

  // Register file instance
  wdgrv_regs #(
    .ADDRESS_WIDTH(REG_ADDRESS_WIDTH),
    .PRE_DECODE(REG_PRE_DECODE),
    .BASE_ADDRESS(REG_BASE_ADDRESS),
    .ERROR_STATUS(REG_ERROR_STATUS),
    .DEFAULT_READ_DATA(REG_DEFAULT_READ),
    .INSERT_SLICER(REG_INSERT_SLICER),
    .USE_STALL(REG_USE_STALLS)
  ) wdgrv_regs_inst (
    // Wishbone interface
    .i_clk(clk),                    // Clock signal. All operations are synchronized to this clock.
    .i_rst_n(res_n),                // Active-low reset. Resets the internal state of the register file.

    .i_wb_cyc(i_wb_cyc),            // Cycle valid. Indicates a valid bus cycle is in progress. It should be asserted for the duration of a bus transaction.
    .i_wb_stb(i_wb_stb),            // Strobe signal. Indicates a valid data transfer request. Used in conjunction with i_wb_cyc.
    .o_wb_stall(o_wb_stall),        // Stall signal. When high, it tells the master to wait before sending more data (i.e., the slave is not ready).
    .i_wb_adr(i_wb_adr),            // Address bus. Specifies the address of the register being accessed.
    .i_wb_we(i_wb_we),              // Write enable. High for write operations, low for read operations.
    .i_wb_dat(i_wb_dat),            // Write data. Carries the data to be written to the addressed register.
    .i_wb_sel(i_wb_sel),            // Byte select. Indicates which byte lanes are active during a write. Useful for partial writes.
    .o_wb_ack(o_wb_ack),            // Acknowledge. Indicates the end of a successful bus cycle.
    .o_wb_err(o_wb_err),            // Error. Indicates an error occurred during the transaction.
    .o_wb_rty(o_wb_rty),            // Retry. Indicates the slave is not ready and the master should retry the transaction.
    .o_wb_dat(o_wb_dat),            // Read data. Carries the data read from the addressed register.

    // Registers
    .o_wdcsr_wden(wdcsr_wden),
    .i_wdcsr_rvd1(), // NC!
    .o_wdcsr_s1wto(), // NC!
    .i_wdcsr_s1wto_hw_set(wdcsr_s1wto),
    .o_wdcsr_s1wto_write_trigger(sw_trg_s1wto),     // signals sw has written (thus cleared) bit field
    .o_wdcsr_s2wto(), // NC!
    .i_wdcsr_s2wto_hw_set(wdcsr_s2wto),
    .o_wdcsr_s2wto_write_trigger(sw_trg_s2wto),     // signals sw has written (thus cleared) bit field
    .o_wdcsr_wtocnt(wdcsr_wtocnt),                  // SW should not write a 0 here!
    .i_wdcsr_rvd2(), // NC!
    .i_wdcnt_cnt({22'b0, cnt})   //TODO                      // Plattform specific: Tell SW how far along timeout count is
  );

  // FSM
  fsm fsm_inst(
    .clk(clk),
    .res_n(res_n),
    .en(wdcsr_wden),
    .count0(cnt0),
    .s2wto(wdcsr_s2wto),
    .s1wto(wdcsr_s1wto), 
    .do_cnt(do_cnt),
    .sw_trg_s1wto(sw_trg_s1wto),
    .sw_trg_s2wto(sw_trg_s2wto)
  );

  // 
  cntr 
  #(
    .WIDTH(10)
  ) cntr_inst (
    .mtick_clk(wdg_tick),
    .res_n(res_n & do_cnt),
    .init_cnt(wdcsr_wtocnt),
    .count_wdg(cnt)
  );

  // Divide system clock down for down-counter to be slower by factor given in WDG_TICK_BIT param
  // WDG_TICK_BIT value can be chosen up to WIDTH-1
  clkdiv #(
    .WIDTH(WDG_PRECLKDIV_WIDTH),
    .WDG_TICK_BIT(WDG_TICK_BIT)
  ) clk_div_inst (
    .clk(clk),
    .res_n(res_n),
    .wdg_tick(wdg_tick)
  );

  // Determine if count reached 0
  assign cnt0 = (cnt == 0) ? 1'b1 : 1'b0;

  assign o_irq1 = wdcsr_s1wto;
  assign o_irq2 = wdcsr_s2wto;

endmodule
