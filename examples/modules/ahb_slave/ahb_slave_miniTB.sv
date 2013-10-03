`include "miniTB_defines.svh"
`include "miniTB_ahb_master.sv"

import miniTB_pkg::*;

module ahb_slave_miniTB;
  string name = "ahb_slave_miniTB";
  miniTB_logger logger;

  logic clk;
  logic rst_n;

  initial begin
    clk = 1;
    forever begin
      #5 clk = ~clk;
    end
  end


  //===================================
  // This is the module that we're 
  // smoke testing
  //===================================
  ahb_slave uut
  (
    .hclk(clk),
    .hresetn(rst_n),
    .hready(mst.hready),
    .htrans(mst.htrans),
    .hwrite(mst.hwrite),
    .haddr(mst.haddr),
    .hwdata(mst.hwdata)
  );

  minitb_ahb_master mst
  (
    .hclk(clk)
  );


  //===================================
  // build (like an initial block that
  // executes prior to running any
  // tests)
  //===================================
  function void build();
    logger = new(name);
  endfunction


  //===================================
  // reset each smoke test
  //===================================
  task smoketest_reset();
    mst.reset();

    rst_n = 0;
    at_sample_edge(5);
    rst_n = 1;
  endtask


  //===================================
  // All tests are defined between the
  // SMOKE_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between
  //   `SMOKETEST(_NAME_)
  //   `SMOKETEST_END
  //
  // i.e.
  //   `SMOKETEST(mytest)
  //     <test code>
  //   `SMOKETEST_END
  //===================================
  `SMOKE_TESTS_BEGIN

  //------
  // Misc
  //------

  `SMOKETEST(reset_conditions)
    `FAIL_UNLESS(htrans_eq(0));
    `FAIL_UNLESS(hready_eq(0));
    `FAIL_UNLESS(hwrite_eq(0));
    `FAIL_UNLESS(haddr_eq(0));
  `SMOKETEST_END


  //---------------
  // Idle transfer
  //---------------

  `SMOKETEST(hready_inactive_for_address_phase)
    single_idle_trans();
    at_address_phase();
    `FAIL_UNLESS(hready_eq(0));
  `SMOKETEST_END

  `SMOKETEST(hready_active_for_IDLE_xfer)
    single_idle_trans();
    at_data_phase();
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END


  //-------------------------------
  // Single NONSEQ write transfers
  //-------------------------------

  `SMOKETEST(NONSEQ_write_ready)
    single_nonseq_write(8'h0, 32'h0);
    at_data_phase();
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_0_to_base)
    single_nonseq_write(8'h0, 32'h0);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('h0, 'h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_0_to_n)
    single_nonseq_write(8'hc, 32'h0);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('hc, 'h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_n_to_addr)
    single_nonseq_write(8'hd, 32'h5a5a_5a5a);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('hd, 'h5a5a_5a5a));
  `SMOKETEST_END
  



  // Single NONSEQ read transfers



  // Single NONSEQ write w/wait states



  // Single NONSEQ read w/wait states



  // incremental bursts of various length



  // other burst types

  `SMOKE_TESTS_END


task single_idle_trans();
  fork
    mst.idle();
  join_none
endtask

task single_nonseq_write(logic [31:0] addr,
                       logic [31:0] data);
  fork
    begin
      mst.write(addr, data);
      mst.idle();
    end
  join_none
endtask

task at_sample_edge(int n);
  repeat (n) @(posedge clk);
endtask

task at_data_phase(int n=0);
  at_sample_edge(2+n);
endtask

task at_address_phase();
  at_sample_edge(1);
endtask

function bit hready_eq(logic l);        return (l === mst.hready);  endfunction
function bit htrans_eq(logic [1:0] l);  return (l === mst.htrans);  endfunction
function bit hwrite_eq(logic [1:0] l);  return (l === mst.hwrite);  endfunction
function bit haddr_eq(logic [7:0] l);   return (l === mst.haddr);   endfunction

function bit slave_data_eq(logic [31:0] addr,
                           logic [31:0] exp);
  return (uut.mem[addr] === exp);
endfunction

endmodule
