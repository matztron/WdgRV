// Counting direction: Upwards!
module cntr 
  #(
    parameter WIDTH = 4
    // parameter 
  )(
    //input sys_clk,                  // received tick source
    input mtick_clk,                  // driven by mtime reg
    input res_n,                      // system reset (active low)
    input [WIDTH-1:0] cnt_thrhd,      // count till threshold
    output reg [WIDTH-1:0] count_wdg  // current count value of watchdog
  );
  
  // with async reset
  always @(posedge mtick_clk, negedge res_n) 
    begin
      if (~res_n) 
        begin
          count_wdg <= 0;
        end
      else
        begin
          if (count_wdg == cnt_thrhd) begin
            count_wdg <= 0;
          end else begin
            count_wdg <= count_wdg + 1'b1;
          end
        end
    end
  
endmodule
