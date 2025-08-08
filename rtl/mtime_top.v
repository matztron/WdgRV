//`include "rtl/wdg_interface_def.h"

module mtime_rv #(
    parameter REG_ADDRESS_WIDTH = 3,
    parameter REG_PRE_DECODE = 0,
    parameter REG_BASE_ADDRESS = 0,
    parameter REG_ERROR_STATUS = 0,
    parameter REG_DEFAULT_READ = 0,
    parameter REG_INSERT_SLICER = 0,
    parameter REG_USE_STALLS = 1,

    parameter WB_DATA_WIDTH = 32,

    parameter CNTR_WIDTH = 64,

    // Bit index to use from MTIME register for counter clock ("pre-scaler")
    // TODO: This has to be exposed to SW
    parameter WDG_TICK_BIT = 4
)(
    //
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

    // dedicated port for watchdog to get mtime ticks
    output wdg_tick
);

    reg [CNTR_WIDTH-1:0] cnt;

    // Register file instance
    machine_time #(
        .ADDRESS_WIDTH(REG_ADDRESS_WIDTH),
        .PRE_DECODE(REG_PRE_DECODE),
        .BASE_ADDRESS(REG_BASE_ADDRESS),
        .ERROR_STATUS(REG_ERROR_STATUS),
        .DEFAULT_READ_DATA(REG_DEFAULT_READ),
        .INSERT_SLICER(REG_INSERT_SLICER),
        .USE_STALL(REG_USE_STALLS)
    ) mtime_inst (
        . i_clk(clk),
        .i_rst_n(res_n),
        .i_wb_cyc(i_wb_cyc),
        .i_wb_stb(i_wb_stb),
        .o_wb_stall(o_wb_stall),
        .i_wb_adr(i_wb_adr),
        .i_wb_we(i_wb_we),
        .i_wb_dat(i_wb_dat),
        .i_wb_sel(i_wb_sel),
        .o_wb_ack(o_wb_ack),
        .o_wb_err(o_wb_err),
        .o_wb_rty(o_wb_rty),
        .o_wb_dat(o_wb_dat),
        .i_mtime_tim_valid(1'b1),
        .i_mtime_tim(cnt),
        .o_mtime_tim() // unused
    );

    // count up the mtime value
    always @(posedge clk) begin
        if (~res_n) begin
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
        end
    end

    // time base for watchdog timer
    assign wdg_tick = cnt[WDG_TICK_BIT];

endmodule