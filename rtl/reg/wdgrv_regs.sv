`ifndef rggen_connect_bit_field_if
  `define rggen_connect_bit_field_if(RIF, FIF, LSB, WIDTH) \
  always_comb begin \
    FIF.write_valid           = RIF.write_valid; \
    FIF.read_valid            = RIF.read_valid; \
    FIF.mask                  = RIF.mask[LSB+:WIDTH]; \
    FIF.write_data            = RIF.write_data[LSB+:WIDTH]; \
    RIF.read_data[LSB+:WIDTH] = FIF.read_data; \
    RIF.value[LSB+:WIDTH]     = FIF.value; \
  end
`endif
`ifndef rggen_tie_off_unused_signals
  `define rggen_tie_off_unused_signals(WIDTH, VALID_BITS, RIF) \
  if (1) begin : __g_tie_off \
    genvar  __i; \
    for (__i = 0;__i < WIDTH;++__i) begin : g \
      if ((((VALID_BITS) >> __i) % 2) == 0) begin : g \
        always_comb begin \
          RIF.read_data[__i]  = '0; \
          RIF.value[__i]      = '0; \
        end \
      end \
    end \
  end
`endif
module wdgrv_regs
  import rggen_rtl_pkg::*;
#(
  parameter int ADDRESS_WIDTH = 3,
  parameter bit PRE_DECODE = 0,
  parameter bit [ADDRESS_WIDTH-1:0] BASE_ADDRESS = '0,
  parameter bit ERROR_STATUS = 0,
  parameter bit [31:0] DEFAULT_READ_DATA = '0,
  parameter bit INSERT_SLICER = 0,
  parameter bit USE_STALL = 1
)(
  input logic i_clk,
  input logic i_rst_n,
  rggen_wishbone_if.slave wishbone_if,
  output logic o_wdcsr_wden,
  input logic i_wdcsr_rvd1,
  output logic o_wdcsr_s1wto,
  input logic i_wdcsr_s1wto_hw_set,
  output logic o_wdcsr_s1wto_write_trigger,
  output logic o_wdcsr_s2wto,
  input logic i_wdcsr_s2wto_hw_set,
  output logic o_wdcsr_s2wto_write_trigger,
  output logic [9:0] o_wdcsr_wtocnt,
  input logic [17:0] i_wdcsr_rvd2,
  input logic [31:0] i_wdcnt_cnt
);
  rggen_register_if #(3, 32, 32) register_if[2]();
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
    .i_clk        (i_clk),
    .i_rst_n      (i_rst_n),
    .wishbone_if  (wishbone_if),
    .register_if  (register_if)
  );
  generate if (1) begin : g_wdcsr
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hffffffff, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (1),
      .ADDRESS_WIDTH  (3),
      .OFFSET_ADDRESS (3'h0),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[0]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_wden
      localparam bit INITIAL_VALUE = 1'h0;
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 1)
      rggen_bit_field #(
        .WIDTH          (1),
        .INITIAL_VALUE  (INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_wdcsr_wden),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rvd1
      localparam bit INITIAL_VALUE = 1'h0;
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 1, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_wdcsr_rvd1),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_s1wto
      localparam bit INITIAL_VALUE = 1'h0;
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 2, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .INITIAL_VALUE      (INITIAL_VALUE),
        .SW_READ_ACTION     (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION    (RGGEN_WRITE_0_CLEAR),
        .SW_WRITE_ONCE      (0),
        .HW_ACCESS          (3'b010),
        .STORAGE            (1),
        .EXTERNAL_READ_DATA (0),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (o_wdcsr_s1wto_write_trigger),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_wdcsr_s1wto_hw_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_wdcsr_s1wto),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_s2wto
      localparam bit INITIAL_VALUE = 1'h0;
      rggen_bit_field_if #(1) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 3, 1)
      rggen_bit_field #(
        .WIDTH              (1),
        .INITIAL_VALUE      (INITIAL_VALUE),
        .SW_READ_ACTION     (RGGEN_READ_DEFAULT),
        .SW_WRITE_ACTION    (RGGEN_WRITE_0_CLEAR),
        .SW_WRITE_ONCE      (0),
        .HW_ACCESS          (3'b010),
        .STORAGE            (1),
        .EXTERNAL_READ_DATA (0),
        .TRIGGER            (1)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (o_wdcsr_s2wto_write_trigger),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           (i_wdcsr_s2wto_hw_set),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_wdcsr_s2wto),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_wtocnt
      localparam bit [9:0] INITIAL_VALUE = 10'h3ff;
      rggen_bit_field_if #(10) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 4, 10)
      rggen_bit_field #(
        .WIDTH          (10),
        .INITIAL_VALUE  (INITIAL_VALUE),
        .SW_WRITE_ONCE  (0),
        .TRIGGER        (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('1),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            ('0),
        .i_mask             ('1),
        .o_value            (o_wdcsr_wtocnt),
        .o_value_unmasked   ()
      );
    end
    if (1) begin : g_rvd2
      localparam bit [17:0] INITIAL_VALUE = 18'h00000;
      rggen_bit_field_if #(18) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 14, 18)
      rggen_bit_field #(
        .WIDTH              (18),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_wdcsr_rvd2),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
  generate if (1) begin : g_wdcnt
    rggen_bit_field_if #(32) bit_field_if();
    `rggen_tie_off_unused_signals(32, 32'hffffffff, bit_field_if)
    rggen_default_register #(
      .READABLE       (1),
      .WRITABLE       (0),
      .ADDRESS_WIDTH  (3),
      .OFFSET_ADDRESS (3'h4),
      .BUS_WIDTH      (32),
      .DATA_WIDTH     (32),
      .VALUE_WIDTH    (32)
    ) u_register (
      .i_clk        (i_clk),
      .i_rst_n      (i_rst_n),
      .register_if  (register_if[1]),
      .bit_field_if (bit_field_if)
    );
    if (1) begin : g_cnt
      localparam bit [31:0] INITIAL_VALUE = 32'h00000000;
      rggen_bit_field_if #(32) bit_field_sub_if();
      `rggen_connect_bit_field_if(bit_field_if, bit_field_sub_if, 0, 32)
      rggen_bit_field #(
        .WIDTH              (32),
        .STORAGE            (0),
        .EXTERNAL_READ_DATA (1),
        .TRIGGER            (0)
      ) u_bit_field (
        .i_clk              (i_clk),
        .i_rst_n            (i_rst_n),
        .bit_field_if       (bit_field_sub_if),
        .o_write_trigger    (),
        .o_read_trigger     (),
        .i_sw_write_enable  ('0),
        .i_hw_write_enable  ('0),
        .i_hw_write_data    ('0),
        .i_hw_set           ('0),
        .i_hw_clear         ('0),
        .i_value            (i_wdcnt_cnt),
        .i_mask             ('1),
        .o_value            (),
        .o_value_unmasked   ()
      );
    end
  end endgenerate
endmodule
