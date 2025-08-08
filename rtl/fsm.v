// "Notes / Limitations"
// When one of the bitfields (s1wto / s2wto) are cleared by SW - both are cleared

module fsm( 
  input clk,            // clock for sync state transitions 
  input res_n,          // reset
  input en,             // watchdog enable
  input count0,         // 1: down counter of watchdog reached 0

  output s2wto,         // values of watchdog bit field -> indicates interrupt
  output s1wto,         // (see above)
  output do_cnt,        // counter should count downwards
  input sw_trg_s1wto,   // sw successfully wrote field -> reset downcounter
  input sw_trg_s2wto    // (see above)
);
  
  // state coding table
  parameter S_IDLE        = 3'b000;
  parameter S_CNT0        = 3'b001;
  parameter S_RAISE_S1    = 3'b010;
  parameter S_CNT1        = 3'b011;
  parameter S_RAISE_S2    = 3'b110;

  wire [3:0] inp;
  reg [2:0] state, next_state;
  
  assign inp = {en, count0, sw_trg_s1wto, sw_trg_s2wto};
  assign {s2wto, s1wto, do_cnt} = state;
  
  // combinational transition block
  always @(*) begin
    casex ({inp, state})
      // IDLE: Count is 
      {4'b0xxx, S_IDLE}: next_state = S_IDLE;
      {4'bxx1x, S_IDLE}: next_state = S_IDLE;        // sw re-initialized wdg
      {4'bxxx1, S_IDLE}: next_state = S_IDLE;        // sw re-initialized wdg
      {4'b1xxx, S_IDLE}: next_state = S_CNT0;

      {4'b0xxx, S_CNT0}: next_state = S_IDLE;        // enable deasserted: Go back to idle!
      {4'bxx1x, S_CNT0}: next_state = S_IDLE;        // sw re-initialized wdg
      {4'bxxx1, S_CNT0}: next_state = S_IDLE;        // sw re-initialized wdg
      {4'b1000, S_CNT0}: next_state = S_CNT0;        // count down: stay here
      {4'b11xx, S_CNT0}: next_state = S_RAISE_S1;    // counter reached 0: Raise S1WTO

      {4'b0xxx, S_RAISE_S1}: next_state = S_IDLE;    // enable deasserted: Go back to idle!
      {4'bxx1x, S_RAISE_S1}: next_state = S_IDLE;    // sw re-initialized wdg
      {4'bxxx1, S_RAISE_S1}: next_state = S_IDLE;    // sw re-initialized wdg
      {4'bxxxx, S_RAISE_S1}: next_state = S_CNT1;    // stay here for 1 cycle
      
      {4'b0xxx, S_CNT1}: next_state = S_IDLE;        // enable deasserted: Go back to idle!
      {4'bxx1x, S_CNT1}: next_state = S_IDLE;        // sw re-initialized wdg
      {4'bxxx1, S_CNT1}: next_state = S_IDLE;        // sw re-initialized wdg
      {4'b1000, S_CNT1}: next_state = S_CNT1;        // count down: stay here
      {4'b11xx, S_CNT1}: next_state = S_RAISE_S2;

      {4'b0xxx, S_RAISE_S2}: next_state = S_IDLE;    // enable deasserted: Go back to idle!
      {4'bxx1x, S_RAISE_S2}: next_state = S_IDLE;    // sw re-initialized wdg
      {4'bxxx1, S_RAISE_S2}: next_state = S_IDLE;    // sw re-initialized wdg
      {4'bxxxx, S_RAISE_S2}: next_state = S_RAISE_S2;// WDG WILL WAIT FOR CPU TO CLEAR THAT CONDITION
      
      default: next_state = S_IDLE;
    endcase
  end
  
  // Register stage
  always @(posedge clk or negedge res_n) begin
    if (~res_n) begin
      state <= S_IDLE;
    end
    else begin
      state <= next_state;
    end
  end
  
endmodule
