//###############################################################
//
//  Licensed to the Apache Software Foundation (ASF) under one
//  or more contributor license agreements.  See the NOTICE file
//  distributed with this work for additional information
//  regarding copyright ownership.  The ASF licenses this file
//  to you under the Apache License, Version 2.0 (the
//  "License"); you may not use this file except in compliance
//  with the License.  You may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing,
//  software distributed under the License is distributed on an
//  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
//  KIND, either express or implied.  See the License for the
//  specific language governing permissions and limitations
//  under the License.
//
//###############################################################

`include "miniTB_defines.svh"
`include "miniTB_apb_master.sv"

import miniTB_pkg::*;

module apb_slave_miniTB;
  string name = "apb_slave_miniTB";
  miniTB_logger logger;

  logic clk;
  logic rst_n;
  logic [7:0] addr;
  logic [31:0] data, rdata;

  // clk generator
  initial begin
    clk = 0;
    forever begin
      #5 clk = ~clk;
    end
  end

  //===================================
  // This is the module that we're
  // smoke testing
  //===================================
  apb_slave my_apb_slave(
    .clk(mst.clk),
    .rst_n(mst.rst_n),
    .paddr(mst.paddr),
    .pwrite(mst.pwrite),
    .psel(mst.psel),
    .penable(mst.penable),
    .pwdata(mst.pwdata),
    .prdata(mst.prdata)
  );

  miniTB_apb_master mst(
    .clk(clk),
    .rst_n(rst_n)
  );

  //===================================
  // Build
  //===================================
  function void build();
    logger = new(name);
  endfunction


  //===================================
  // reset each smoke test
  //===================================
  task smoketest_reset();
    //-----------------------------------------
    // move the bus into the IDLE state
    // before each test
    //-----------------------------------------
    mst.idle();

    //-----------------------------
    // then do a reset for the uut
    //-----------------------------
    rst_n = 0;
    repeat (8) @(posedge clk);
    rst_n = 1;
  endtask


  //===================================
  // All tests are defined between the
  // SMOKE_TESTS_BEGIN/END macros
  //
  // Each individual test must be
  // defined between `SMOKETEST(_NAME_)
  // `SMOKETEST_END(_NAME_)
  //
  // i.e.
  //   `SMOKETEST(mytest)
  //     <test code>
  //   `SMOKETEST_END(mytest)
  //===================================
  `SMOKE_TESTS_BEGIN

  //************************************************************
  // Test:
  //   single_write_to_idle
  //
  // Desc:
  //   make sure a write finishes in the idle state
  //************************************************************
  `SMOKETEST(single_write_idle)
    mst.write(addr, data);
    wait_a_few_cycles(1);
    `FAIL_IF(mst.psel !== 0);
    `FAIL_IF(mst.penable !== 0);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   single_write_is_2_cycles
  //
  // Desc:
  //   make sure a write completes in 2 cycles
  //************************************************************
  `SMOKETEST(single_write_is_2_cycles)
    fail_on_timeout(3);
    mst.write(addr, data);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   single_read_is_2_cycles
  //
  // Desc:
  //   make sure a read completes in 2 cycles
  //************************************************************
  `SMOKETEST(single_read_is_2_cycles)
    fail_on_timeout(3);
    mst.read(addr, data);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   single_read_idle
  //
  // Desc:
  //   make sure a read finishes in the idle state
  //************************************************************
  `SMOKETEST(single_read_idle)
    mst.read(addr, data);
    wait_a_few_cycles(1);
    `FAIL_IF(mst.psel !== 0);
    `FAIL_IF(mst.penable !== 0);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   single_write_then_read
  //
  // Desc:
  //   do a write then a read at the same address
  //************************************************************
  `SMOKETEST(single_write_then_read)
    addr = 'h32;
    data = 'h61;

    mst.write(addr, data);
    wait_a_few_cycles(1);
    mst.read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   write_wo_psel
  //
  // Desc:
  //   do a write then a read at the same address but insert a
  //   write without psel asserted during setup to ensure mem
  //   isn't corrupted by a protocol error.
  //************************************************************
  `SMOKETEST(write_wo_psel)
    addr = 'h0;
    data = 'hffff_ffff;

    mst.write(addr, data);
    wait_a_few_cycles(1);
    mst.write(addr, 'hff, 0 /* inactive psel */);
    wait_a_few_cycles(1);
    mst.read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   write_wo_write
  //
  // Desc:
  //   do a write then a read at the same address but insert a
  //   write without pwrite asserted during setup to ensure mem
  //   isn't corrupted by a protocol error.
  //************************************************************
  `SMOKETEST(write_wo_write)
    addr = 'h10;
    data = 'h99;

    mst.write(addr, data);
    wait_a_few_cycles(1);
    mst.write(addr, 'hff, 1, 0 /* inactive pwrite */);
    wait_a_few_cycles(1);
    mst.read(addr, rdata);
    `FAIL_IF(data !== rdata);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   _2_writes_then_2_reads
  //
  // Desc:
  //   Do back-to-back writes then back-to-back reads
  //************************************************************
  `SMOKETEST(_2_writes_then_2_reads)
    mst.write(addr, data);
    mst.write(addr+1, data+1);
    mst.read(addr, rdata);
    `FAIL_IF(data !== rdata);
    mst.read(addr+1, rdata);
    `FAIL_IF(data+1 !== rdata);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   _no_space_between_back2back_write
  //************************************************************
  `SMOKETEST(_no_space_between_back2back_write)
    fail_on_timeout(5);
    repeat(2) mst.write(addr, data);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   _no_space_between_back2back_read
  //************************************************************
  `SMOKETEST(_no_space_between_back2back_read)
    fail_on_timeout(5);
    repeat(2) mst.read(addr, data);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   _no_space_between_back2back_write_then_read
  //************************************************************
  `SMOKETEST(_no_space_between_back2back_write_then_read)
    fail_on_timeout(5);
    mst.write(addr, data);
    mst.read(addr, data);
  `SMOKETEST_END


  //************************************************************
  // Test:
  //   _no_space_between_back2back_read_then_write
  //************************************************************
  `SMOKETEST(_no_space_between_back2back_read_then_write)
    fail_on_timeout(5);
    mst.read(addr, data);
    mst.write(addr, data);
  `SMOKETEST_END


  `SMOKE_TESTS_END


task wait_a_few_cycles(int num_cycles);
  repeat (num_cycles) @(posedge clk);
endtask

function bit mst_is_active();
  return (mst.penable || mst.psel);
endfunction

task fail_on_timeout(int num_cycles);
  @(posedge clk);
  fork
    begin
      wait_a_few_cycles(num_cycles);
      `FAIL_IF(mst_is_active());
    end
  join_none
endtask

endmodule
