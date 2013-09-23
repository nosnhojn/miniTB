/*

Write Cycle
              __    __    __   
  clk      __/  \__/  \__/  \__
           ________ _____ _____
  wdata    ________X__D__X_____
           ________ _____ _____
  waddress ________X__A__X_____
                    _____
  wen      ________/     \_____


Read Cycle
              __    __    __    __    __    __    __   
  clk      __/  \__/  \__/  \__/  \__/  \__/  \__/  \_
                                _____      _____      
  q        XXXXXXXXXXXXXXXXXXXXX__Q__XXXXXX_Q+1_XXXXXX
           ________ _____ _____ _____ ________________
  raddress ________X__A__X_____X_A+1_X________________
                    _____       _____
  ren      ________/     \_____/     \________________

*/


module simple_dpram
#(
  DWIDTH = 32,
  AWIDTH = 8,
  BEWIDTH = 4
)
(
  input        clk,

  input [DWIDTH-1:0]  wdata,
  input [AWIDTH-1:0]  waddress,
  input               wen,
  input [BEWIDTH-1:0] byteena,

  input [AWIDTH-1:0]  raddress,
  input               ren,
  output [DWIDTH-1:0] q
);

endmodule
