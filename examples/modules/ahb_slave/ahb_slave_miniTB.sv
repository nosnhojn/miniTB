`include "miniTB_defines.svh"
`include "miniTB_ahb_master.sv"

`define _NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(N) \
`SMOKETEST(data_cycle__``N``_of_multiple_back2back_NONSEQ_write_n_to_addr) \
  fork \
    begin \
      for (int i=0; i<N+1; i+=1) begin \
        mst.basic_write('h99-i, 'hfff-i); \
      end \
    end \
  join_none \
  at_data_phase(N-1); \
  `FAIL_UNLESS(slave_data_eq('h99-(N-1), 'hfff-(N-1))); \
`SMOKETEST_END

import miniTB_pkg::*;

module ahb_slave_miniTB;
  string name = "ahb_slave_miniTB";
  miniTB_logger logger;

  logic clk;
  logic rst_n;
  logic [31:0] rdata;

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
    .hwdata(mst.hwdata),
    .hrdata(mst.hrdata)
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
    `FAIL_UNLESS(hwdata_eq(0));
  `SMOKETEST_END


  //---------------
  // Idle transfer
  //---------------

  `SMOKETEST(hready_inactive_for_address_phase)
    single_idle_trans();
    at_sample_edge(0);
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
    fork_basic_write(8'h0, 32'h0);
    at_address_phase();
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_0_to_base)
    fork_basic_write(8'h0, 32'h0);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('h0, 'h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_0_to_n)
    fork_basic_write(8'hc, 32'h0);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('hc, 'h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_n_to_addr)
    fork_basic_write(8'hd, 32'h5a5a_5a5a);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('hd, 'h5a5a_5a5a));
  `SMOKETEST_END
  

  //---------------------------------
  // Multiple NONSEQ write transfers
  //---------------------------------

  `SMOKETEST(multiple_NONSEQ_write_n_to_addr)
    fork_basic_write('h2, 'h22);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('h2, 'h22));

    fork_basic_write('h3, 'h33);
    at_data_phase();
    `FAIL_UNLESS(slave_data_eq('h3, 'h33));
  `SMOKETEST_END

  `SMOKETEST(first_of_multiple_back2back_NONSEQ_write_n_to_addr)
    fork
      begin
        mst.basic_write('h5, 'h55);
        mst.basic_write('h4, 'h44);
      end
    join_none
 
    at_data_phase(); // first
    `FAIL_UNLESS(slave_data_eq('h5, 'h55));
  `SMOKETEST_END

  /* maybe a little overkill here but I'm fine with it */
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(2)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(3)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(4)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(5)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(6)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(7)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(8)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(9)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(10)


  //------------------------------
  // Single NONSEQ read transfers
  //------------------------------

  `SMOKETEST(NONSEQ_read_ready)
    basic_read(8'h0, rdata);
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_read_0_from_base)
    set_slave_data('h0, 'h0);
    basic_read(8'h0, rdata);
    `FAIL_UNLESS(rdata === 'h0);
  `SMOKETEST_END
 
  `SMOKETEST(NONSEQ_read_0_from_n)
    set_slave_data('hc, 'h0);
    basic_read(8'hc, rdata);
    `FAIL_UNLESS(rdata === 'h0);
  `SMOKETEST_END
 
// `SMOKETEST(NONSEQ_write_n_to_addr)
//   single_nonseq_write(8'hd, 32'h5a5a_5a5a);
//   at_data_phase();
//   `FAIL_UNLESS(slave_data_eq('hd, 'h5a5a_5a5a));
// `SMOKETEST_END


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

task fork_basic_write(logic [31:0] addr,
                       logic [31:0] data);
  fork
    begin
      mst.basic_write(addr, data);
    end
  join_none
endtask

task automatic basic_read(logic [31:0] addr,
                          ref logic [31:0] data);
  mst.basic_read(addr, data);
endtask

task at_sample_edge(int n);
  repeat (n) begin
    @(posedge clk);
    #1;
  end
endtask

task at_data_phase(int n=0);
  at_sample_edge(2+n);
endtask

task next_data_phase();
  at_sample_edge(1);
endtask

task next_addr_phase();
  next_data_phase();
endtask

task at_address_phase();
  at_sample_edge(1);
endtask

function bit hready_eq(logic l);        return (l === mst.hready);  endfunction
function bit htrans_eq(logic [1:0] l);  return (l === mst.htrans);  endfunction
function bit hwrite_eq(logic [1:0] l);  return (l === mst.hwrite);  endfunction
function bit haddr_eq(logic [7:0] l);   return (l === mst.haddr);   endfunction
function bit hwdata_eq(logic [31:0] l);   return (l === mst.hwdata);   endfunction

function void set_slave_data(logic [31:0] addr, logic [31:0] data);
  uut.mem[addr] = data;
endfunction

function bit slave_data_eq(logic [31:0] addr,
                           logic [31:0] exp);
  return (uut.mem[addr] === exp);
endfunction

endmodule
