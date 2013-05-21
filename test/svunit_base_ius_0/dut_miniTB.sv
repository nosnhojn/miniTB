`include "miniTB_defines.svh"
import miniTB_pkg::*;

module dut_miniTB;
  string name = "dut_miniTB";
  miniTB_logger logger;


  //===================================
  // This is the module that we're 
  // smoke testing
  //===================================
  dut uut();


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

  `SMOKETEST(TEST0)
    `INFO("Use the INFO macro");
  `SMOKETEST_END


  `SMOKETEST(TEST1)
    `ERROR("Use the ERROR macro");
    `FAIL_IF(1);
  `SMOKETEST_END


  `SMOKE_TESTS_END

endmodule
