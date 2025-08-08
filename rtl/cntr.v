// Down count_wdger
module cntr 
  #(
    parameter WIDTH = 4
    // parameter 
  )(
    //input sys_clk,                  // received tick source
    input mtick_clk,                  // driven by mtime reg
    input res_n,                      // system reset (active low)
    input [WIDTH-1:0] init_cnt,       // initialize downcounter to at async reset
    output reg [WIDTH-1:0] count_wdg  // current count value of watchdog
    //output reg cnt0                 // signals counter reached 0 - unused...
    //output reg wdg_valid
  );

  //localparam CNT_WDG_VERIFY_START = 32'hFFFF_FFFF;

  // internal count to verify watchdog is still working
  reg [39:0] count_wdg_timeout;
  reg [WIDTH-1:0] count_wdg_last;
  
  // with async reset
  always @(posedge mtick_clk, negedge res_n) 
    begin
      if (~res_n) 
        begin
          count_wdg <= init_cnt; // start at max value // TODO: NOT SURE IF THIS CAN BY SYNTESIZED! (requires weird flop)
        end
      else
        begin
          if (count_wdg == 0) begin
            count_wdg <= init_cnt;
            //cnt0 <= 1'b1;
          end else begin
            count_wdg <= count_wdg - 1'b1;
            //cnt0 <= 1'b0;
          end
        end
    end
  
endmodule
