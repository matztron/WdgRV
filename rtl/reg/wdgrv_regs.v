`include "rggen_rtl_macros.vh"
module wdgrv_regs #(
  parameter ADDRESS_WIDTH = 3,
  parameter PRE_DECODE = 0,
  parameter [ADDRESS_WIDTH-1:0] BASE_ADDRESS = 0,
  parameter ERROR_STATUS = 0,
  parameter [31:0] DEFAULT_READ_DATA = 0,
  parameter INSERT_SLICER = 0,
  parameter USE_STALL = 1
)(
  input i_clk,
  input i_rst_n,
  input i_wb_cyc,
  input i_wb_stb,
  output o_wb_stall,
  input [ADDRESS_WIDTH-1:0] i_wb_adr,
  input i_wb_we,
  input [31:0] i_wb_dat,
  input [3:0] i_wb_sel,
  output o_wb_ack,
  output o_wb_err,
  output o_wb_rty,
  output [31:0] o_wb_dat,
  output o_wdcsr_wden,
  input i_wdcsr_rvd1,
  output o_wdcsr_s1wto,
  input i_wdcsr_s1wto_hw_set,
  output o_wdcsr_s1wto_write_trigger,
  output o_wdcsr_s2wto,
  input i_wdcsr_s2wto_hw_set,
  output o_wdcsr_s2wto_write_trigger,
  output [9:0] o_wdcsr_wtocnt,
  input [17:0] i_wdcsr_rvd2,
  input [31:0] i_wdcnt_cnt
);
  wire w_register_valid;
  wire [1:0] w_register_access;
  wire [2:0] w_register_address;
  wire [31:0] w_register_write_data;
  wire [31:0] w_register_strobe;
  wire [1:0] w_register_active;
  wire [1:0] w_register_ready;
  wire [3:0] w_register_status;
  wire [63:0] w_register_read_data;
  wire [63:0] w_register_value;
  rggen_wishbone_adapter #(
    .ADDRESS_WIDTH        (ADDRESS_WIDTH),
    .LOCAL_ADDRESS_WIDTH  (3),
    .BUS_WIDTH            (32),
    .REGISTERS            (2),
    .PRE_DECODE           (PRE_DECODE),
    .BASE_ADDRESS         (BASE_ADDRESS),
    .BYTE_SIZE            (8),
    .ERROR_STATUS         (ERROR_STATUS),
    .DEFAULT_READ_DATA    (DEFAULT_READ_DATA),
    .INSERT_SLICER        (INSERT_SLICER),
    .USE_STALL            (USE_STALL)
  ) u_adapter (
    .i_clk                  (i_clk),
    .i_rst_n                (i_rst_n),
    .i_wb_cyc               (i_wb_cyc),
    .i_wb_stb               (i_wb_stb),
    .o_wb_stall             (o_wb_stall),
    .i_wb_adr               (i_wb_adr),
    .i_wb_we                (i_wb_we),
    .i_wb_dat               (i_wb_dat),
    .i_wb_sel               (i_wb_sel),
    .o_wb_ack               (o_wb_ack),
    .o_wb_err               (o_wb_err),
    .o_wb_rty               (o_wb_rty),
    .o_wb_dat               (o_wb_dat),
    .o_register_valid       (w_register_valid),
    .o_register_access      (w_register_access),
    .o_register_address     (w_register_address),
    .o_register_write_data  (w_register_write_data),
    .o_register_strobe      (w_register_strobe),
    .i_register_active      (w_register_active),
    .i_register_ready       (w_register_ready),
    .i_register_status      (w_register_status),
    .i_register_read_data   (w_register_read_data)
  );
  generate if (1) begin : g_wdcsr
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'hffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (3),
      .OFFSET_ADDRESS (3'h0),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[0+:1]),
      .o_register_ready         (w_register_ready[0+:1]),
      .o_register_status        (w_register_status[0+:2]),
      .o_register_read_data     (w_register_read_data[0+:32]),
      .o_register_value         (w_register_value[0+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_wden
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (1'h0),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[0+:1]),
        .i_sw_write_data    (w_bit_field_write_data[0+:1]),
        .o_sw_read_data     (w_bit_field_read_data[0+:1]),
        .o_sw_value         (w_bit_field_value[0+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_wdcsr_wden),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rvd1
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[1+:1]),
        .i_sw_write_data    (w_bit_field_write_data[1+:1]),
        .o_sw_read_data     (w_bit_field_read_data[1+:1]),
        .o_sw_value         (w_bit_field_value[1+:1]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           ({1{1'b0}}),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            (i_wdcsr_rvd1),
        .i_mask             ({1{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_s1wto
      rggen_bit_field #(
        .WIDTH              (1),
        .INITIAL_VALUE      (1'h0),
        .SW_READ_ACTION     (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION    (`RGGEN_WRITE_0_CLEAR),
        .SW_WRITE_ONCE      (0),
        .HW_ACCESS          (3'b010),
        .STORAGE            (1),
        .EXTERNAL_READ_DATA (0),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[2+:1]),
        .i_sw_write_data    (w_bit_field_write_data[2+:1]),
        .o_sw_read_data     (w_bit_field_read_data[2+:1]),
        .o_sw_value         (w_bit_field_value[2+:1]),
        .o_write_trigger    (o_wdcsr_s1wto_write_trigger),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_wdcsr_s1wto_hw_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_wdcsr_s1wto),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_s2wto
      rggen_bit_field #(
        .WIDTH              (1),
        .INITIAL_VALUE      (1'h0),
        .SW_READ_ACTION     (`RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION    (`RGGEN_WRITE_0_CLEAR),
        .SW_WRITE_ONCE      (0),
        .HW_ACCESS          (3'b010),
        .STORAGE            (1),
        .EXTERNAL_READ_DATA (0),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[3+:1]),
        .i_sw_write_data    (w_bit_field_write_data[3+:1]),
        .o_sw_read_data     (w_bit_field_read_data[3+:1]),
        .o_sw_value         (w_bit_field_value[3+:1]),
        .o_write_trigger    (o_wdcsr_s2wto_write_trigger),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({1{1'b0}}),
        .i_hw_set           (i_wdcsr_s2wto_hw_set),
        .i_hw_clear         ({1{1'b0}}),
        .i_value            ({1{1'b0}}),
        .i_mask             ({1{1'b1}}),
        .o_value            (o_wdcsr_s2wto),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_wtocnt
      rggen_bit_field #(
        .WIDTH          (10),
        .INITIAL_VALUE  (10'h3ff),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b1),
        .i_sw_mask          (w_bit_field_mask[4+:10]),
        .i_sw_write_data    (w_bit_field_write_data[4+:10]),
        .o_sw_read_data     (w_bit_field_read_data[4+:10]),
        .o_sw_value         (w_bit_field_value[4+:10]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({10{1'b0}}),
        .i_hw_set           ({10{1'b0}}),
        .i_hw_clear         ({10{1'b0}}),
        .i_value            ({10{1'b0}}),
        .i_mask             ({10{1'b1}}),
        .o_value            (o_wdcsr_wtocnt),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rvd2
      rggen_bit_field #(
        .WIDTH              (18),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[14+:18]),
        .i_sw_write_data    (w_bit_field_write_data[14+:18]),
        .o_sw_read_data     (w_bit_field_read_data[14+:18]),
        .o_sw_value         (w_bit_field_value[14+:18]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({18{1'b0}}),
        .i_hw_set           ({18{1'b0}}),
        .i_hw_clear         ({18{1'b0}}),
        .i_value            (i_wdcsr_rvd2),
        .i_mask             ({18{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_wdcnt
    wire w_bit_field_read_valid;
    wire w_bit_field_write_valid;
    wire [31:0] w_bit_field_mask;
    wire [31:0] w_bit_field_write_data;
    wire [31:0] w_bit_field_read_data;
    wire [31:0] w_bit_field_value;
    `rggen_tie_off_unused_signals(32, 32'hffffffff, w_bit_field_read_data, w_bit_field_value)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (3),
      .OFFSET_ADDRESS (3'h4),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32)
    ) u_register (
      .i_clk                    (i_clk),
      .i_rst_n                  (i_rst_n),
      .i_register_valid         (w_register_valid),
      .i_register_access        (w_register_access),
      .i_register_address       (w_register_address),
      .i_register_write_data    (w_register_write_data),
      .i_register_strobe        (w_register_strobe),
      .o_register_active        (w_register_active[1+:1]),
      .o_register_ready         (w_register_ready[1+:1]),
      .o_register_status        (w_register_status[2+:2]),
      .o_register_read_data     (w_register_read_data[32+:32]),
      .o_register_value         (w_register_value[32+:32]),
      .o_bit_field_read_valid   (w_bit_field_read_valid),
      .o_bit_field_write_valid  (w_bit_field_write_valid),
      .o_bit_field_mask         (w_bit_field_mask),
      .o_bit_field_write_data   (w_bit_field_write_data),
      .i_bit_field_read_data    (w_bit_field_read_data),
      .i_bit_field_value        (w_bit_field_value)
    );
    if (1) begin : g_cnt
      rggen_bit_field #(
        .WIDTH              (32),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .i_sw_read_valid    (w_bit_field_read_valid),
        .i_sw_write_valid   (w_bit_field_write_valid),
        .i_sw_write_enable  (1'b0),
        .i_sw_mask          (w_bit_field_mask[0+:32]),
        .i_sw_write_data    (w_bit_field_write_data[0+:32]),
        .o_sw_read_data     (w_bit_field_read_data[0+:32]),
        .o_sw_value         (w_bit_field_value[0+:32]),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_hw_write_enable  (1'b0),
        .i_hw_write_data    ({32{1'b0}}),
        .i_hw_set           ({32{1'b0}}),
        .i_hw_clear         ({32{1'b0}}),
        .i_value            (i_wdcnt_cnt),
        .i_mask             ({32{1'b1}}),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
endmodule
