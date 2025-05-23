
`ifndef EMPTY_SIGNAL
  `define EMPTY_SIGNAL
`endif
`ifndef FULL_SIGNAL
  `define FULL_SIGNAL
`endif
`define TWO_CLOCK
module asfifo (rst_n, wr, rd,
                  `ifdef TWO_CLOCK
                    clk_rd, clk_wr,
                  `else
                    clk,
                  `endif
                  `ifdef EMPTY_SIGNAL
                    fifo_empty,
                  `endif
                  `ifdef FULL_SIGNAL
                    fifo_full,
                  `endif
                    data_in, data_out);
//Parameters are used to set the capacity of FIFO
parameter DATA_WIDTH    = 8;
parameter POINTER_WIDTH = 3;
parameter DATA_NUM      = 2**POINTER_WIDTH;
//
//inputs
`ifdef TWO_CLOCK
  input clk_rd;
  input clk_wr;
`else
  input clk;
`endif
input rst_n;
input wr;
input rd;
input [DATA_WIDTH-1:0] data_in;
//outputs
output  reg [DATA_WIDTH-1:0] data_out;
`ifdef EMPTY_SIGNAL
  output  fifo_empty;
`else
  wire    fifo_empty;
`endif
`ifdef FULL_SIGNAL
  output  fifo_full;
`else
  wire    fifo_full;
`endif
//internal signals
reg [POINTER_WIDTH:0] w_pointer;
reg [POINTER_WIDTH:0] r_pointer;
reg [DATA_WIDTH-1:0] mem_array [DATA_NUM-1:0];
wire    msb_diff;
wire    lsb_equal;
wire    fifo_re;
wire    fifo_we;
//write pointer
assign fifo_we = wr & (~fifo_full);
//
`ifdef TWO_CLOCK
  wire rclk = clk_rd;
  wire wclk = clk_wr;
`else
  wire rclk = clk;
  wire wclk = clk;
`endif
always @ (posedge wclk or negedge rst_n) begin
  if (~rst_n) w_pointer <= {POINTER_WIDTH+1{1'b0}};
  else if (fifo_we) w_pointer <= w_pointer+1'b1;
end
//read pointer
assign fifo_re = rd & (~fifo_empty);
//
always @ (posedge rclk or negedge rst_n) begin
  if (~rst_n) r_pointer <= {POINTER_WIDTH+1{1'b0}};
  else if (fifo_re) r_pointer <= r_pointer + 1'b1;
end
//memory array and write decoder
always @ (posedge wclk) begin
  if (fifo_we)
    mem_array[w_pointer[POINTER_WIDTH-1:0]]
             <= data_in[DATA_WIDTH-1:0];
end
//read decoder
`ifdef OUTPUT_REG
  always @ (posedge rclk) begin
    data_out[DATA_WIDTH-1:0]
    <= mem_array[r_pointer[POINTER_WIDTH-1:0]];
  end
`else
  always @ (*) begin
    data_out[DATA_WIDTH-1:0]
    = mem_array[r_pointer[POINTER_WIDTH-1:0]];
  end
`endif
//status signal
assign  msb_diff = w_pointer[POINTER_WIDTH]
                  ^r_pointer[POINTER_WIDTH];
//
assign  lsb_equal = (w_pointer[POINTER_WIDTH-1:0]
                  == r_pointer[POINTER_WIDTH-1:0]);
//
assign  fifo_full = msb_diff & lsb_equal;
//
assign  fifo_empty = (~msb_diff) & lsb_equal;
endmodule: asfifo
