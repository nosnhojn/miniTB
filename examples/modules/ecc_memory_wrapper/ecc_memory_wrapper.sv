module ecc_memory_wrapper
#(
  DWIDTH = 32,
  AWIDTH = 8,
  BEWIDTH = 4
)
(
  input               clk,

  input [DWIDTH-1:0]  wdata,
  input [AWIDTH-1:0]  waddress,
  input               wen,
  input [BEWIDTH-1:0] byteena,

  input [AWIDTH-1:0]  raddress,
  input               ren,
  output [DWIDTH-1:0] q
);

endmodule
