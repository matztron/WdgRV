//`include "rtl/wdg_interface_def.h"

module wdg_tb();

    parameter WB_DATA_WIDTH = 32;
    parameter WB_ADDR_WIDTH = 4;

    // Poor mans register map
    parameter WB_WDG_BASE = 0;
    parameter WB_MTIME_BASE = 4;

    // !!!
    // 2: only every 4th clock tick will toggle wdg timer bit
    parameter WDG_TICK_BIT = 2;
    // !!!

    reg clk_tb;
    reg res_n_tb;

    // Wishbone signals (assumed to be declared elsewhere)
    reg         wb_cyc_tb;
    reg         wb_stb_tb;
    reg         wb_we_tb;
    reg [WB_ADDR_WIDTH-1:0]  wb_adr_tb;
    reg [WB_DATA_WIDTH-1:0]  wb_dat_w_tb;
    wire [WB_DATA_WIDTH-1:0] wb_dat_r_tb;
    reg [3:0]   wb_sel_tb;
    wire        wb_ack_tb;
    wire        wb_stall_tb;

    //reg [63:0] mtime_tb;

    //wire wdg_tick_tb;

    // >>> UUT <<<
    wdg_top #(
        .REG_ADDRESS_WIDTH(WB_ADDR_WIDTH),
        .REG_PRE_DECODE(0),
        .REG_BASE_ADDRESS(WB_WDG_BASE),
        .REG_ERROR_STATUS(0),
        .REG_DEFAULT_READ(0),
        .REG_INSERT_SLICER(0),
        .REG_USE_STALLS(1),
        .WB_DATA_WIDTH(WB_DATA_WIDTH)
    ) wdg_rv_inst (
        .clk(clk_tb),
        .res_n(res_n_tb),
        // Wishbone interface
        .i_wb_cyc(wb_cyc_tb),
        .i_wb_stb(wb_stb_tb),
        .o_wb_stall(wb_stall_tb),
        .i_wb_adr(wb_adr_tb),
        .i_wb_we(wb_we_tb),
        .i_wb_dat(wb_dat_w_tb),
        .i_wb_sel(wb_sel_tb),
        .o_wb_ack(wb_ack_tb),
        .o_wb_err(),
        .o_wb_rty(),
        .o_wb_dat(wb_dat_r_tb)
        // ---
        //.wdg_tick(wdg_tick_tb)
    );
    // ---

    // MTIME register
    /*mtime_rv #(
        .REG_ADDRESS_WIDTH(3),
        .REG_PRE_DECODE(0),
        .REG_BASE_ADDRESS(WB_MTIME_BASE),
        .REG_ERROR_STATUS(0),
        .REG_DEFAULT_READ(0),
        .REG_INSERT_SLICER(0),
        .REG_USE_STALLS(1),

        .WB_DATA_WIDTH(32),
        .WDG_TICK_BIT(WDG_TICK_BIT),

        .CNTR_WIDTH(64) // see RISC-V spec
    ) mtime_rv_inst (
        //
        .clk(clk_tb),
        .res_n(res_n_tb),

        // Wishbone interface
        .i_wb_cyc(wb_cyc_tb),
        .i_wb_stb(wb_stb_tb),
        .o_wb_stall(wb_stall_tb),
        .i_wb_adr(wb_adr_tb), // note: bit length mismatch (acceptable)
        .i_wb_we(wb_we_tb),
        .i_wb_dat(wb_dat_w_tb),
        .i_wb_sel(wb_sel_tb),
        .o_wb_ack(wb_ack_tb),
        .o_wb_err(),
        .o_wb_rty(),
        .o_wb_dat(wb_dat_r_tb),
        // ---

        // dedicated port for watchdog to get mtime ticks
        .wdg_tick(wdg_tick_tb)
    );*/
    // ---

    // clock generation
    initial begin
        clk_tb = 1'b0;
        forever #1 clk_tb = ~clk_tb;
    end

    // task to write to MTIME register periodically
    /*initial begin
        forever begin
            // verilog task to write MTIME reg
        end
    end*/

    reg [31:0] rd_data;
    integer mtime_loop_int;
    // Initial block
    initial begin
        $dumpfile("sim/out/wdg_rv_out.vcd");
        $dumpvars(0, wdg_tb);

        // Initialize Wishbone signals
        wb_cyc_tb   = 0;
        wb_stb_tb   = 0;
        wb_we_tb    = 0;
        wb_adr_tb   = 0;
        wb_dat_w_tb = 0;
        wb_sel_tb   = 0;

        // mtime
        //mtime_tb = 64'd0;


        // initial reset
        res_n_tb = 1'b0;
        #20
        res_n_tb = 1'b1;

        #100;

        //wishbone_set_mtime(64'hAFFE);

        #200;

        // Wisbone communication goes here
        wishbone_set_wdcsr(1'b1, 10'h10);

        #20;

        // Do more stuff here
        wishbone_set_wdcsr(1'b1, 10'h10);

        #200

        wishbone_set_wdcsr(1'b1, 10'h10);

        $display("Sequence of reading the watchdog timer value");
        wishbone_readwdg();
        #1;
        wishbone_readwdg();
        #10;
        wishbone_readwdg();
        #10;
        wishbone_readwdg();

        #200;


        //wishbone_set_wdcsr(1'b1, 10'h1);

        #1000;

        wishbone_set_wdcsr(1'b1, 10'h10);

        #200;

        $finish;
    end

    // Wishbone Ack monitor
    /*always @(posedge clk_tb) begin
        if (wait_for_ack)
            #1 $display("Time: %0t | wb_ack_tb = %b | wb_stall_tb = %b", $time, wb_ack_tb, wb_stall_tb);
    end*/

    integer timeout;
    // Verilog tasks for Wishbone communication
    task automatic wishbone_transaction;
        input           write;       // 1 = write, 0 = read
        input  [31:0]   address;
        input  [31:0]   write_data;
        input  [3:0]    sel;         // Byte select
        output [31:0]   read_data;

        begin


            // Wait until slave is ready
            while (wb_stall_tb) @(posedge clk_tb);


            // Initiate transaction
            wb_adr_tb   = address;
            wb_dat_w_tb = write_data;
            wb_sel_tb   = sel;
            wb_we_tb    = write;
            wb_cyc_tb   = 1;
            wb_stb_tb   = 1;


            // Display transaction details
            $display("----------------------------------");
            $display("- Wishbone Transaction Initiated -");
            $display("----------------------------------");
            $display("Mode       : %s", write ? "WRITE" : "READ");
            $display("Address    : 0x%08h", address);
            $display("Write Data : 0x%08h", write_data);
            $display("Byte Sel   : 0b%b", sel);
            $display("----------------------------------");


            // Wait for ACK
            //@(posedge clk);
            //while (!wb_ack_tb) @(posedge clk);
            $display("Waiting for ACK...");
            timeout = 100000;
            /*while (!wb_ack_tb) begin
                @(posedge clk);
                $display("Still waiting...");
            end*/
            while (!wb_ack_tb && timeout > 0) begin
                @(posedge clk_tb);
                timeout = timeout - 1;
                $display("timeout %d", timeout);
            end

            if (timeout == 0) begin
                $display("ERROR: Timeout waiting for ACK!");
            end else begin

                $display("Received ACK");

                // Capture read data if it's a read
                if (!write)
                read_data = wb_dat_r_tb;

            end

            // Deassert control signals
            wb_cyc_tb = 0;
            wb_stb_tb = 0;
            wb_we_tb  = 0;
        end
    endtask

    task automatic wishbone_set_wdcsr;
        input en;
        input [9:0] wtocnt;

        begin

        $display("-  Sending WDCSR Register Access -");
        $display("Enable     : 0x%08h", en);
        $display("WTOCNT     : 0x%08h", wtocnt);

        wishbone_transaction(1'b1, WB_WDG_BASE, {18'b0, wtocnt, 2'b0, 1'b0, en}, 4'b1111, rd_data);

        end
    endtask

    /*task automatic wishbone_set_mtime;
        input [63:0] mtime_w; // write val for mtime

        begin
            // incr counter
            //mtime_tb = mtime_tb + 1;

            // write lower 32bit
            wishbone_transaction(1'b1, WB_MTIME_BASE, mtime_w[31:0], 4'b1111, rd_data);

            // write upper 32bit
            wishbone_transaction(1'b1, WB_MTIME_BASE+4, mtime_w[63:32], 4'b1111, rd_data);
        end
    endtask*/

    task automatic wishbone_readwdg;
        reg [31:0] rdata;
        begin

            // input           write;       // 1 = write, 0 = read
            // input  [31:0]   address;
            // input  [31:0]   write_data;
            // input  [3:0]    sel;         // Byte select
            // output [31:0]   read_data;
            wishbone_transaction(1'b0, 4'd4, 32'b0, 4'b1111, rdata);

            $display("xxxxxxxxxxxxxxxxxxxxx");
            $display("!!!read data: %d !!!", rdata);
            $display("xxxxxxxxxxxxxxxxxxxxx");
        end
    endtask


endmodule