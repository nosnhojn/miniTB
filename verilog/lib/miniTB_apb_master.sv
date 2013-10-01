interface miniTB_apb_master
(
  input wire clk,
  input wire rst_n
);
  logic [7:0]   paddr;
  logic         pwrite;
  logic         psel;
  logic         penable;
  logic [31:0]  pwdata;
  wire [31:0] prdata;

  //-------------------------------------------------------------------------------
  //
  // write ()
  //
  // Simple write method used in the unit tests. Includes options for back-to-back
  // writes and protocol errors on the psel and pwrite.
  //
  //-------------------------------------------------------------------------------
  task write(logic [7:0] addr,
             logic [31:0] data,
             logic back2back = 0,
             logic setup_psel = 1,
             logic setup_pwrite = 1);

    // if !back2back, insert an idle cycle before the write
    if (!back2back) begin
      @(negedge clk);
      psel = 0;
      penable = 0;
    end

    // this is the SETUP state where the psel,
    // pwrite, paddr and pdata are set
    //
    // NOTE:
    //   setup_psel == 0 for protocol errors on the psel
    //   setup_pwrite == 0 for protocol errors on the pwrite
    @(negedge clk);
    psel = setup_psel;
    pwrite = setup_pwrite;
    paddr = addr;
    pwdata = data;
    penable = 0;

    // this is the ENABLE state where the penable is asserted
    @(negedge clk);
    pwrite = 1;
    penable = 1;
    psel = 1;
  endtask


  //-------------------------------------------------------------------------------
  //
  // read ()
  //
  // Simple read method used in the unit tests. Includes options for back-to-back
  // reads.
  //
  //-------------------------------------------------------------------------------
  task read(logic [7:0] addr, output logic [31:0] data, input logic back2back = 0);

    // if !back2back, insert an idle cycle before the read
    if (!back2back) begin
      @(negedge clk);
      psel = 0;
      penable = 0;
    end

    // this is the SETUP state where the psel, pwrite and paddr
    @(negedge clk);
    psel = 1;
    paddr = addr;
    penable = 0;
    pwrite = 0;

    // this is the ENABLE state where the penable is asserted
    @(negedge clk);
    penable = 1;

    // the prdata should be flopped after the subsequent posedge
    @(posedge clk);
    #1 data = prdata;
  endtask


  //-------------------------------------------------------------------------------
  //
  // idle ()
  //
  // Clear the all the inputs to the uut (i.e. move to the IDLE state)
  //
  //-------------------------------------------------------------------------------
  task idle();
    @(negedge clk);
    psel = 0;
    penable = 0;
    pwrite = 0;
    paddr = 0;
    pwdata = 0;
  endtask

endinterface
