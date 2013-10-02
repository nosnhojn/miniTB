`include "miniTB_defines.svh"
`include "miniTB_ahb_master.sv"

import miniTB_pkg::*;

module ahb_slave_miniTB;
  string name = "ahb_slave_miniTB";
  miniTB_logger logger;

  logic clk;
  logic rst_n;


  //===================================
  // This is the module that we're 
  // smoke testing
  //===================================
  ahb_slave uut
  (
    .hclk(clk),
    .hresetn(rst_n)
  );

  minitb_ahb_master mst
  (
    .hclk(clk),
    .hresetn(rst_n)
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



  `SMOKE_TESTS_END

endmodule
