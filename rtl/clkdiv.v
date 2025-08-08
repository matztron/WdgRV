module clkdiv #(
    parameter WIDTH = 20,
    parameter WDG_TICK_BIT = 2
)(
    input clk,
    input res_n,
    output wdg_tick
);

    reg [WIDTH-1:0] cnt;

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
