// Counting direction: Upwards!
module cntr 
  #(
    parameter WIDTH = 4
    // parameter 
  )(
    //input sys_clk,                  // main system clock
    input mtick_clk,                  // received tick source
    input res_n,                      // system reset (active low)
    input [WIDTH-1:0] cnt_thrhd,      // count till threshold
    output reg [WIDTH-1:0] count_wdg  // current count value of watchdog
  );
  
  // with async reset
  /*always @(posedge mtick_clk, negedge res_n) 
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
    end*/

  // cross-domain reset synchronization scheme
  // -> assert asynchronously, release synchronously <-
  reg [1:0] rst_sync;
  wire rst_n_sync;

  // Synchronize deassertion of reset to mtick_clk
  always @(posedge mtick_clk or negedge res_n) begin
      if (~res_n)
          rst_sync <= 2'b00;
      else
          rst_sync <= {rst_sync[0], 1'b1};
  end

  assign rst_n_sync = rst_sync[1];

  // Counter with async reset, but only released synchronously
  always @(posedge mtick_clk or negedge rst_n_sync) begin
      if (~rst_n_sync)
          count_wdg <= 0;
      else if (count_wdg == cnt_thrhd)
          count_wdg <= 0;
      else
          count_wdg <= count_wdg + 1'b1;
  end
  
endmodule
