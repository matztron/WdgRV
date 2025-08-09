// This is an optional module that may be used to reset the RISC-V CORE and the WDG at the end
// ! IT WORKS ONLY FOR LOW RST ACTIVE !

// Function:
// Once wdg_to is received a counter counts up to CORE_RST_CYCLES + WDG_RST_CYCLES cycles. 
// For the first CORE_RST_CYCLES we hold the core_res_n active. 
// Then we wait some time (PADDING_CYCLES) here no reset is asserted. 
// This should give the core time to get ready again (note SW should not try to access WDG in that time as it will be reset after this step)
// Then for WDG_RST_CYCLES we reset the watchdog so it starts up fresh.
//
//This has the side-effect that CPU needs to reprogram the watchdog once again as it is reset to default register values after reset.
module reset_ctrl #(
    parameter CORE_RST_CYCLES = 60,     // cycles for which CORE is held in reset after watchdog timeout is received
    parameter PADDING_CYCLES = 5,       // must be at least 1
    parameter WDG_RST_CYCLES = 1,       // cycles for which WDG is held in reset after CORE was reset        
) (
    input clk,          // system clock
    input sys_res_n,

    input wdg_to        // watchdog timeout
    output wdg_res_n,   // AND-ed together with System RST_N and connected to WDG active-low reset
    output core_res_n   // AND-ed together with System RST_N and connected to CORE active-low reset 
);

    localparam MAX_COUNT_CYCLES = CORE_RST_CYCLES + PADDING_CYCLES + WDG_RST_CYCLES;

    //
    wire [$clog2(MAX_COUNT_CYCLES)-1:0] cnt;
    wire do_cnt;

    wire done_reset_core;
    wire done_padding;
    wire done_reset_wdg;

    /*********************************************************************/
    // FSM:

    // state coding table
    parameter S_IDLE        = 3'b110; // RST_CORE: 1 | RST_WDG: 1 | DO_CNT: 0
    parameter S_CORE_RST    = 3'b011; // RST_CORE: 0 | RST_WDG: 1 | DO_CNT: 1
    parameter S_PADDING     = 3'b111; // RST_CORE: 1 | RST_WDG: 1 | DO_CNT: 1
    parameter S_WDG_RST     = 3'b101; // RST_CORE: 1 | RST_WDG: 0 | DO_CNT: 1

    wire [3:0] inp;
    reg [3:0] state, next_state;

    assign inp = {wdg_to, done_reset_core, done_padding, done_reset_wdg};
    assign {core_res_n, wdg_res_n, do_cnt, h1} = state;

    // combinational transition block
    always @(*) begin
        casex ({inp, state})
            {4'b0xxx, S_IDLE}: next_state <= S_IDLE;
            {4'b1xxx, S_IDLE}: next_state <= S_CORE_RST;

            {4'bx0xx, S_CORE_RST}: next_state <= S_CORE_RST;
            {4'bx1xx, S_CORE_RST}: next_state <= S_PADDING;

            {4'bxx0x, S_PADDING}: next_state <= S_PADDING;
            {4'bxx1x, S_PADDING}: next_state <= S_WDG_RST;

            {4'bxxx0, S_WDG_RST}: next_state <= S_WDG_RST;
            {4'bxxx1, S_WDG_RST}: next_state <= S_IDLE;
        endcase
    end

    // Register stage
    always @(posedge clk) begin
        if (~sys_res_n) begin
            state <= IDLE;
        end
        else begin
            state <= next_state;
        end
    end

    /*********************************************************************/

    assign done_reset_core = (cnt == CORE_RST_CYCLES-1) ? 1'b1 : 1'b0;
    assign done_padding = (cnt == CORE_RST_CYCLES + PADDING_CYCLES) ? 1'b1 : 1'b0;
    assign done_reset_wdg = (cnt < CORE_RST_CYCLES + PADDING_CYCLES + WDG_RST_CYCLES) ? 1'b1 : 1'b0;

    // counter
    always @(posedge clk) begin
        if (~res_n) begin
            cnt <= 0;
        end else begin
            if (do_cnt) begin
                cnt <= cnt + 1;
            end else begin
                // in fsm idle state set to 0
                cnt <= 0;
            end
        end
    end

endmodule