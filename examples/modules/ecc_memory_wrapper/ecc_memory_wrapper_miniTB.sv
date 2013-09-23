`include "miniTB_defines.svh"
import miniTB_pkg::*;

module ecc_memory_wrapper_miniTB;
  string name = "ecc_memory_wrapper_miniTB";
  miniTB_logger logger;


  //===================================
  // This is the module that we're 
  // smoke testing
  //===================================
  ecc_memory_wrapper uut();


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
