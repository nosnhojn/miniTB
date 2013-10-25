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
  then_at_wdata_phase(N-1); \
  `FAIL_UNLESS(slave_data_eq('h99-(N-1), 'hfff-(N-1))); \
`SMOKETEST_END

import miniTB_pkg::*;

module ahb_slave_miniTB;
  string name = "ahb_slave_miniTB";
  miniTB_logger logger;

  logic clk;
  logic rst_n;
  logic [31:0] rdata;
  logic [31:0] ignore;

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
  logic slv_busy;
  ahb_slave uut
  (
    .hclk(clk),
    .hresetn(rst_n),
    .hready(mst.hready),
    .htrans(mst.htrans),
    .hwrite(mst.hwrite),
    .haddr(mst.haddr),
    .hwdata(mst.hwdata),
    .hrdata(mst.hrdata),
    .slv_busy(slv_busy)
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
    rdata = 0;
    slv_busy = 0;
    mst.reset();
    slave_reset();

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
    `FAIL_UNLESS(hwrite_eq('hx));
    `FAIL_UNLESS(haddr_eq('hx));
    `FAIL_UNLESS(hwdata_eq('hx));
    `FAIL_UNLESS(hrdata_eq(0));
  `SMOKETEST_END


  //---------------
  // Idle transfer
  //---------------

  `SMOKETEST(hready_inactive_while_busy)
    slave_busy();
    at_sample_edge();
    `FAIL_UNLESS(hready_eq(0));
  `SMOKETEST_END
 
  `SMOKETEST(hready_active_for_IDLE_xfer)
    single_idle_trans();
    then_at_wdata_phase(0);
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END


  //-------------------------------
  // Single NONSEQ write transfers
  //-------------------------------

  `SMOKETEST(NONSEQ_write_ready)
    fork_a_basic_write(8'h0, 32'h0);
    then_at_address_phase();
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END

  `SMOKETEST(single_NONSEQ_write_data_undefined_during_address_phase)
    fork_a_basic_write(8'h0, 32'h0);
    then_at_address_phase();
    `FAIL_UNLESS(hwdata_eq('hx));
  `SMOKETEST_END

  `SMOKETEST(single_NONSEQ_write_transitions_to_IDLE)
    fork_a_basic_write(8'h0, 32'h0);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(htrans_eq(0));
    `FAIL_UNLESS(haddr_eq('hx));
    `FAIL_UNLESS(hwrite_eq('hx));
  `SMOKETEST_END

  `SMOKETEST(single_NONSEQ_write_data_undefined_after_data_phase)
    fork_a_basic_write(8'h0, 32'h0);
    then_at_wdata_phase(1);
    `FAIL_UNLESS(hwdata_eq('hx));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_0_to_base)
    fork_a_basic_write(8'h0, 32'h0);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('h0, 'h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_0_to_n)
    fork_a_basic_write(8'hc, 32'h0);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('hc, 'h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_n_to_addr)
    fork_a_basic_write(8'hd, 32'h5a5a_5a5a);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('hd, 'h5a5a_5a5a));
  `SMOKETEST_END
  

  //---------------------------------
  // Multiple NONSEQ write transfers
  //---------------------------------

  `SMOKETEST(multiple_NONSEQ_write_n_to_addr)
    fork_a_basic_write('h2, 'h22);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('h2, 'h22));

    fork_a_basic_write('h3, 'h33);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('h3, 'h33));
  `SMOKETEST_END

  `SMOKETEST(first_of_multiple_back2back_NONSEQ_write_n_to_addr)
    fork
      begin
        mst.basic_write('h5, 'h55);
        mst.basic_write('h4, 'h44);
      end
    join_none
 
    then_at_wdata_phase(0); // first
    `FAIL_UNLESS(slave_data_eq('h5, 'h55));
  `SMOKETEST_END

  /* maybe a little overkill here but I'm fine with it */
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(2)
  `_NTH_of_multiple_back2back_NONSEQ_write_n_to_addr(3)


  //------------------------------
  // Single NONSEQ read transfers
  //------------------------------

  `SMOKETEST(NONSEQ_read_ready)
    do_a_basic_read(8'h0, rdata);
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END

  `SMOKETEST(single_NONSEQ_read_data_undefined_during_address_phase)
    set_slave_data('h0, 'h8);
    fork_a_basic_read('hx, rdata);
    #0 `FAIL_UNLESS(hrdata_eq('h0));
  `SMOKETEST_END
 
  `SMOKETEST(single_NONSEQ_read_transitions_to_IDLE)
    fork_a_basic_read('hx, rdata);
    then_at_rdata_phase(1);
    `FAIL_UNLESS(htrans_eq(0));
    `FAIL_UNLESS(haddr_eq('hx));
    `FAIL_UNLESS(hwrite_eq('hx));
  `SMOKETEST_END
 
  `SMOKETEST(single_NONSEQ_read_data_undefined_after_data_phase)
    set_slave_data('h0, 'h8);
    fork_a_basic_read('hx, rdata);
    then_at_rdata_phase(1);
    `FAIL_UNLESS(hrdata_eq('h0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_reads_complete_in_1_cycles)
    fail_on_timeout(2);
    do_a_basic_read('hx, rdata);
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_read_0_from_base)
    set_slave_data('h0, 'h0);
    do_a_basic_read(8'h0, rdata);
    `FAIL_UNLESS(rdata_eq('h0));
  `SMOKETEST_END
 
  `SMOKETEST(NONSEQ_read_0_from_n)
    set_slave_data('hc, 'h0);
    do_a_basic_read(8'hc, rdata);
    `FAIL_UNLESS(rdata_eq('h0));
  `SMOKETEST_END
 
  `SMOKETEST(NONSEQ_read_n_from_addr)
    set_slave_data(8'h1d, 32'h5a5a_5a5a);
    do_a_basic_read(8'h1d, rdata);
    `FAIL_UNLESS(rdata_eq('h5a5a_5a5a));
  `SMOKETEST_END


  //------------------------------------------
  // Multiple pipelined NONSEQ read transfers
  //------------------------------------------

  `SMOKETEST(_2_back2back_NONSEQ_reads_complete_in_2_cycles)
    fail_on_timeout(3);
    repeat (2) do_a_basic_read('hx, rdata);
  `SMOKETEST_END

  `SMOKETEST(_3_back2back_NONSEQ_reads_complete_in_3_cycles)
    fail_on_timeout(4);
    repeat (3) do_a_basic_read('hx, rdata);
  `SMOKETEST_END

  `SMOKETEST(_2_back2back_NONSEQ_reads)
    set_slave_data('h10, 'hffff_ff00);
    set_slave_data('hc, 'hff);

    do_a_basic_read('h10, rdata);
    `FAIL_UNLESS(rdata_eq('hffff_ff00));
    do_a_basic_read('hc, rdata);
    `FAIL_UNLESS(rdata_eq('hff));
  `SMOKETEST_END


  //------------------------------------------------
  // Multiple pipelined NONSEQ write/read transfers 
  //------------------------------------------------

  `SMOKETEST(_back2back_NONSEQ_write_then_read_completes_in_2_cycles)
    fail_on_timeout(3);
    basic_write('hx, 'hx);
    do_a_basic_read('hx, rdata);
  `SMOKETEST_END

  `SMOKETEST(_back2back_NONSEQ_read_then_write_then_completes_in_2_cycles)
    fail_on_timeout(3);
    do_a_basic_read('hx, rdata);
    basic_write('hx, 'hx);
  `SMOKETEST_END

  `SMOKETEST(_back2back_NONSEQ_write_not_disrupted_by_subsequent_read)
    fork
      begin
        basic_write('h8, 'h55);
        do_a_basic_read('h8, rdata);
      end
    join_none
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('h8, 'h55));
  `SMOKETEST_END

  `SMOKETEST(_back2back_NONSEQ_write_not_disrupted_by_previous_read)
    do_a_basic_read('h8, rdata);
    fork_a_basic_write('h8, 'h75);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('h8, 'h75));
  `SMOKETEST_END

  `SMOKETEST(_back2back_NONSEQ_read_not_disrupted_by_subsequent_write)
    set_slave_data('hc, 'hd);
    do_a_basic_read('hc, rdata);
    basic_write('hc, 'hx);
    `FAIL_UNLESS(rdata_eq('hd));
  `SMOKETEST_END

  `SMOKETEST(_back2back_NONSEQ_read_not_disrupted_by_previous_write)
    set_slave_data('hc, 'hd0);
    basic_write('hc, 'hx);
    do_a_basic_read('hc, rdata);
    `FAIL_UNLESS(rdata_eq('hd0));
  `SMOKETEST_END

  `SMOKETEST(_back2back2back_NONSEQ_writes_then_read_hwdata_inactive_for_read)
    fork
      begin
        basic_write('h8, 'h55);
        basic_write('h8, 'h55);
        do_a_basic_read('h8, rdata);
      end
    join_none
    then_at_wdata_phase(2);
    `FAIL_UNLESS(hwdata_eq('hx));
  `SMOKETEST_END

  `SMOKETEST(_consecutive_NONSEQ_write_then_read_with_1_cycle_inbetween_hwdata_inactive_for_read)
    fork
      begin
        basic_write('h8, 'h55);
        @(negedge clk);
        do_a_basic_read('h8, rdata);
      end
    join_none
    then_at_wdata_phase(2);
    `FAIL_UNLESS(hwdata_eq('hx));
  `SMOKETEST_END

  `SMOKETEST(_consecutive_NONSEQ_write_then_read_with_2_cycles_inbetween_hwdata_inactive_for_read)
    fork
      begin
        basic_write('h8, 'h55);
        repeat (2) @(negedge clk);
        do_a_basic_read('h8, rdata);
      end
    join_none
    then_at_wdata_phase(3);
    `FAIL_UNLESS(hwdata_eq('hx));
  `SMOKETEST_END


  //--------------------------------------------
  // combined IDLE/NONSEQ write/ready transfers
  //--------------------------------------------

  `SMOKETEST(alternating_IDLE_NONSEQ_write_take_num_xactions_cycles_to_complete);
    fail_on_timeout(21);
    repeat (10) begin
      mst.idle();
      mst.basic_write('hx, 'hx);
    end
  `SMOKETEST_END

  `SMOKETEST(alternating_IDLE_NONSEQ_read_take_num_xactions_cycles_to_complete);
    fail_on_timeout(21);
    repeat (10) begin
      mst.idle();
      mst.basic_read('hx, rdata);
    end
  `SMOKETEST_END


  //-----------------------------------
  // Single NONSEQ write w/wait states
  //-----------------------------------

  `SMOKETEST(NONSEQ_slave_not_ready_in_wait_state)
    write_with_wait_state(8'h0, 32'h0, 1);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(hready_eq(0));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_slave_ready_after_wait_state)
    write_with_wait_state(8'h0, 32'h0, 1);
    then_at_wdata_phase(1);
    `FAIL_UNLESS(hready_eq(1));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_wdata_active_in_wait_state)
    write_with_wait_state(8'hfc, 32'hff, 1);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(hwdata_eq('hff));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_write_transitions_to_IDLE_during_wait_state)
    write_with_wait_state('h1, 'hx, 1);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(htrans_eq(0));
    `FAIL_UNLESS(haddr_eq('hx));
    `FAIL_UNLESS(hwrite_eq('hx));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_wdata_ignored_in_wait_state)
    write_with_wait_state(8'hfc, 32'hff, 1);
    then_at_wdata_phase(0);
    `FAIL_UNLESS(slave_data_eq('hfc, 'hx));
  `SMOKETEST_END

  `SMOKETEST(NONSEQ_wdata_flopped_after_wait_state)
    write_with_wait_state(8'hfc, 32'hff, 1);
    then_at_wdata_phase(1);
    `FAIL_UNLESS(slave_data_eq('hfc, 'hff));
  `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_wdata_inactive_after_write_with_wait_state)
     write_with_wait_state(8'hfc, 32'hff, 1);
     then_at_wdata_phase(2);
     `FAIL_UNLESS(hwdata_eq('hx));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_wdata_active_on_first_of_several_wait_states)
     write_with_wait_state(8'hfc, 32'hff, 8);
     then_at_wdata_phase(1);
     `FAIL_UNLESS(hwdata_eq('hff));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_wdata_active_on_last_of_several_wait_states)
     write_with_wait_state(8'hfc, 32'hff, 8);
     then_at_wdata_phase(7);
     `FAIL_UNLESS(hwdata_eq('hff));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_wdata_ignored_during_several_wait_states)
     write_with_wait_state(8'hfc, 32'hff, 8);
     then_at_wdata_phase(7);
     `FAIL_UNLESS(slave_data_eq('hfc, 'hx));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_wdata_flopped_after_several_wait_states)
     write_with_wait_state(8'hfc, 32'hff, 8);
     then_at_wdata_phase(8);
     `FAIL_UNLESS(slave_data_eq('hfc, 'hff));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_wdata_inactive_after_write_with_several_wait_states)
     write_with_wait_state(8'hfc, 32'hff, 10);
     then_at_wdata_phase(11);
     `FAIL_UNLESS(hwdata_eq('hx));
   `SMOKETEST_END
 
 
   //----------------------------------
   // Single NONSEQ read w/wait states
   //----------------------------------
 
   `SMOKETEST(NONSEQ_rdata_inactive_in_wait_state)
     set_slave_data('hf8, 'hdfe);
     read_with_wait_state(8'hf8, rdata, 1);
     then_at_rdata_phase(0);
     `FAIL_UNLESS(hrdata_eq('h0));
   `SMOKETEST_END
  
  `SMOKETEST(NONSEQ_rdata_active_after_wait_state)
    set_slave_data('hf8, 'hdfe);
    read_with_wait_state(8'hf8, rdata, 1);
    then_at_rdata_phase(1);
    `FAIL_UNLESS(hrdata_eq('hdfe));
  `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_rdata_inactive_after_read_with_wait_state)
     set_slave_data('hf8, 'hdfe);
     read_with_wait_state(8'hf8, rdata, 1);
     then_at_rdata_phase(2);
     `FAIL_UNLESS(hrdata_eq('h0));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_read_transitions_to_IDLE_during_wait_state)
     read_with_wait_state('hx, rdata, 1);
     then_at_rdata_phase(1);
     `FAIL_UNLESS(htrans_eq(0));
     `FAIL_UNLESS(haddr_eq('hx));
     `FAIL_UNLESS(hwrite_eq('hx));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_rdata_inactive_on_first_of_several_wait_states)
     set_slave_data('hf8, 'hdfe);
     read_with_wait_state(8'hf8, rdata, 9);
     then_at_rdata_phase(1);
     `FAIL_UNLESS(hrdata_eq('h0));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_rdata_active_on_last_of_several_wait_states)
     set_slave_data('hf8, 'hdfe);
     read_with_wait_state(8'hf8, rdata, 9);
     then_at_rdata_phase(9);
     `FAIL_UNLESS(hrdata_eq('hdfe));
   `SMOKETEST_END
  
   `SMOKETEST(NONSEQ_rdata_ignored_during_several_wait_states)
     set_slave_data('hf8, 'hdfe);
     read_with_wait_state(8'hf8, rdata, 9);
     then_at_rdata_phase(8);
     `FAIL_UNLESS(hrdata_eq('h0));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_rdata_inactive_after_write_with_several_wait_states)
     set_slave_data('hf8, 'hdfe);
     read_with_wait_state(8'hf8, rdata, 9);
     then_at_rdata_phase(10);
     `FAIL_UNLESS(hrdata_eq('h0));
   `SMOKETEST_END
  
   `SMOKETEST(NONSEQ_read_n_from_addr_with_1_wait_state)
     set_slave_data(8'h1d, 32'h5a5a_5a5a);
     inject_wait_states(0, 1);
     do_a_basic_read(8'h1d, rdata);
     `FAIL_UNLESS(rdata_eq('h5a5a_5a5a));
   `SMOKETEST_END
  
   `SMOKETEST(NONSEQ_read_n_from_addr_with_several_wait_states)
     fail_on_timeout(30);
     set_slave_data(8'h2d, 32'h7a5a_5a5a);
     inject_wait_states(0, 23);
     do_a_basic_read(8'h2d, rdata);
     `FAIL_UNLESS(rdata_eq('h7a5a_5a5a));
   `SMOKETEST_END
 
 
   //-------------------------------------------------------------
   // combined IDLE/NONSEQ write/ready transfers with wait states
   //-------------------------------------------------------------
 
   `SMOKETEST(NONSEQ_write_with_wait_state_not_disrupted_by_read)
     inject_wait_states(1, 1);
     fork
       basic_write(8'h40, 'h9911);
       #0 do_a_basic_read(8'h44, rdata);
     join_none
     then_at_wdata_phase(1);
     `FAIL_UNLESS(slave_data_eq(8'h40, 'h9911));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_read_with_wait_state_not_disrupted_by_write)
     set_slave_data(8'h1d, 32'h5a5a_5a5a);
     inject_wait_states(0, 1);
     fork
       #0 basic_write(8'h2d, 'h9911);
     join_none
     do_a_basic_read(8'h1d, rdata);
     `FAIL_UNLESS(rdata_eq(32'h5a5a_5a5a));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_write_with_wait_state_not_disrupted_by_write)
     inject_wait_states(1, 1);
     fork
       basic_write(8'h40, 'h9911);
       #0 basic_write(8'h44, 'hx);
     join_none
     then_at_wdata_phase(1);
     `FAIL_UNLESS(slave_data_eq(8'h40, 'h9911));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_read_with_wait_state_not_disrupted_by_read)
     set_slave_data(8'h1d, 32'h5a5a_5a5a);
     inject_wait_states(0,1);
     fork
       #0 do_a_basic_read(8'h2d, ignore);
     join_none
     do_a_basic_read(8'h1d, rdata);
     `FAIL_UNLESS(rdata_eq(32'h5a5a_5a5a));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_write_with_several_wait_states_not_disrupted_by_read)
     inject_wait_states(1, 11);
     fork
       basic_write(8'h40, 'h9911);
       #0 do_a_basic_read(8'h41, rdata);
     join_none
     then_at_wdata_phase(11);
     `FAIL_UNLESS(slave_data_eq(8'h40, 'h9911));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_read_with_several_wait_states_not_disrupted_by_write)
     fail_on_timeout(15);
     set_slave_data(8'h1d, 32'h5a5a_5a5a);
     inject_wait_states(0, 11);
     fork
       #0 basic_write(8'h1e, 'h9911);
     join_none
     do_a_basic_read(8'h1d, rdata);
     `FAIL_UNLESS(rdata_eq(32'h5a5a_5a5a));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_write_with_several_wait_states_not_disrupted_by_write)
     inject_wait_states(1, 11);
     fork
       basic_write(8'h40, 'h9911);
       #0 basic_write(8'h44, 'hx);
     join_none
     then_at_wdata_phase(11);
     `FAIL_UNLESS(slave_data_eq(8'h40, 'h9911));
   `SMOKETEST_END
 
   `SMOKETEST(NONSEQ_read_with_several_wait_states_not_disrupted_by_read)
     set_slave_data(8'h1d, 32'h5a5a_5a5a);
     inject_wait_states(11);
     fork
       #0 do_a_basic_read(8'h4d, ignore);
     join_none
     do_a_basic_read(8'h1d, rdata);
     `FAIL_UNLESS(rdata_eq(32'h5a5a_5a5a));
   `SMOKETEST_END


   //--------------------------------------
   // Pipelined NONSEQ write w/wait states
   //--------------------------------------
 
   `SMOKETEST(first_pipelined_NONSEQ_write_transition_scheduled_first)
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_address_phase();
     `FAIL_UNLESS(haddr_eq('h1));
   `SMOKETEST_END
 
   `SMOKETEST(second_pipelined_NONSEQ_write_transition_scheduled_second)
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_address_phase(1);
     `FAIL_UNLESS(haddr_eq('h2));
   `SMOKETEST_END
 
   `SMOKETEST(pipelined_NONSEQ_write_first_of_extended_address_phase_with_wait_states)
     inject_wait_states(1, 3);
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_address_phase(1);
     `FAIL_UNLESS(haddr_eq('h2) && htrans_eq(uut.NONSEQ) && hwrite_eq('h1));
   `SMOKETEST_END
 
   `SMOKETEST(pipelined_NONSEQ_write_last_of_extended_address_phase_with_wait_states)
     inject_wait_states(1, 3);
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_address_phase(4);
     `FAIL_UNLESS(haddr_eq('h2) && htrans_eq(uut.NONSEQ) && hwrite_eq('h1));
   `SMOKETEST_END
 
   `SMOKETEST(pipelined_NONSEQ_write_with_wait_states_transitions_to_IDLE)
     inject_wait_states(3);
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_address_phase(5);
     `FAIL_UNLESS(haddr_eq('hx));
   `SMOKETEST_END
 
   `SMOKETEST(first_pipelined_NONSEQ_write_n_to_addr)
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_wdata_phase(0);
     `FAIL_UNLESS(slave_data_eq(1,1));
   `SMOKETEST_END
 
   `SMOKETEST(second_pipelined_NONSEQ_write_n_to_addr)
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
     join_none
     then_at_wdata_phase(1);
     `FAIL_UNLESS(slave_data_eq(2,2));
   `SMOKETEST_END
 
   `SMOKETEST(third_pipelined_NONSEQ_write_n_to_addr)
     fork
       basic_write('h1, 'h1);
       #0 basic_write('h2, 'h2);
       #1 basic_write('h3, 'h3);
     join_none
     then_at_wdata_phase(3);
     `FAIL_UNLESS(slave_data_eq(3,3));
   `SMOKETEST_END

  // incremental bursts of various length



  // other burst types

  `SMOKE_TESTS_END

task write_with_wait_state(logic [31:0] addr,
                           logic [31:0] data,
                           int wait_states);
  fork_a_basic_write(addr, data);
  if (wait_states > 0) begin
    inject_wait_states(1, wait_states);
  end
endtask


task automatic read_with_wait_state(logic [31:0] addr = 0,
                                    ref logic [31:0] rd,
                                    input int wait_states);
  if (wait_states > 0) begin
    inject_wait_states(0, wait_states);
  end
  fork_a_basic_read(8'hf8, rdata);
endtask


task fail_on_timeout(int num_cycles);
  bit timeout = 1;
  @(posedge clk);
  fork
    begin
      at_sample_edge(num_cycles);
      `FAIL_IF(timeout);
    end
  join_none
endtask

task single_idle_trans();
  fork
    mst.idle();
  join_none
endtask

task fork_a_basic_write(logic [31:0] addr,
                      logic [31:0] data);
  fork
    begin
      mst.basic_write(addr, data);
    end
  join_none
endtask

task fork_a_basic_read(logic [31:0] addr = 0,
                     output logic [31:0] rd);
  fork
    begin
      mst.basic_read(addr, rd);
    end
  join_none
endtask

task basic_write(logic [31:0] addr,
                 logic [31:0] data);
  mst.basic_write(addr, data);
endtask

task automatic do_a_basic_read(logic [31:0] addr,
                          ref logic [31:0] data);
  mst.basic_read(addr, data);
endtask

task at_sample_edge(int n = 1);
  repeat (n) begin
    @(posedge clk);
    #1;
  end
endtask

task then_at_wdata_phase(int n=0);
  at_sample_edge(2+n);
endtask

task then_at_rdata_phase(int n=0);
  at_sample_edge(1+n);
endtask

task next_data_phase();
  at_sample_edge(1);
endtask

task next_addr_phase();
  next_data_phase();
endtask

task then_at_address_phase(int cnt = 0);
  at_sample_edge(cnt+1);
endtask

function bit hready_eq(logic l);        return (l === mst.hready);  endfunction
function bit htrans_eq(logic [1:0] l);  return (l === mst.htrans);  endfunction
function bit hwrite_eq(logic l);        return (l === mst.hwrite);  endfunction
function bit haddr_eq(logic [7:0] l);   return (l === mst.haddr);   endfunction
function bit hwdata_eq(logic [31:0] l); return (l === mst.hwdata);  endfunction
function bit hrdata_eq(logic [31:0] l); return (l === mst.hrdata);  endfunction
function bit rdata_eq(logic [31:0] l);  return (l === rdata);       endfunction

function void set_slave_data(logic [31:0] addr, logic [31:0] data);
  uut.mem[addr] = data;
endfunction

function bit slave_data_eq(logic [31:0] addr,
                           logic [31:0] exp);
  return (uut.mem[addr] === exp);
endfunction

function void slave_reset();
  for (int i=0; i<uut.memDepth; i+=1) uut.mem[i] = 'hx;
endfunction

task slave_busy();
  slv_busy <= 1;
endtask

task slave_ready();
  slv_busy <= 0;
endtask

task inject_wait_states(int starting_cycle, int cnt = 1);
  fork
    begin
      repeat (1 + starting_cycle) @(negedge clk);
      slave_busy();
      repeat (cnt) @(negedge clk);
      slave_ready();
    end
  join_none
endtask

endmodule
