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

interface minitb_ahb_master
#(
  addrWidth = 8,
  dataWidth = 32
)
(
  input hclk
);

//logic                 hgrantx;
//logic                 hbusreqx;
//logic                 hlockx;
//
logic                 hready;
//logic [1:0]           hresp;
//
logic [1:0]           htrans;

logic [addrWidth-1:0] haddr;
logic                 hwrite;
//logic [2:0]           hsize;
//logic [2:0]           hburst;
//logic [3:0]           hprot;
//
logic [dataWidth-1:0] hwdata;
logic [dataWidth-1:0] hrdata;

parameter IDLE   = 2'b00,
          NONSEQ = 2'b10;

logic data_phase = 0;
logic addr_phase = 0;

//
// reset
//
function void reset();
  htrans = IDLE;
  haddr  = 'hx;
  hwrite = 'hx;
  hwdata = 'hx;
  data_phase = 0;
  addr_phase = 0;
endfunction


//
// idle
//
task idle();
  if (!data_phase) @(negedge hclk);
  reset();
  data_phase = 0;
endtask


//
// pipelined_write
//
task automatic pipelined_write(logic [addrWidth-1:0] addr,
                               logic [dataWidth-1:0] data);
  if (addr_phase) begin
    @(negedge addr_phase);
  end

  fork
    basic_write(addr,data);
  join_none

  // the context swith is here so that consecutive
  // pipelined_writes are scheduled in order
  #0;
endtask


//
// basic_write
//
task automatic basic_write(logic [addrWidth-1:0] addr,
                           logic [dataWidth-1:0] data);
  // address phase
  addr_phase = 1;
  if (!data_phase) begin
    @(negedge hclk);
    hwdata = 'hx;
  end
  haddr = addr;
  htrans = NONSEQ;
  hwrite = 1;

  // data phase
  @(negedge hclk);
  haddr = 'hx;
  htrans = IDLE;
  hwrite = 'hx;
  hwdata = data;
  data_phase = 1;
  addr_phase = 0;

  while (!hready) begin
    @(negedge hclk);
  end

  fork
    #0 data_phase = 0;
    if (!addr_phase) begin
      @(negedge hclk);
      hwdata = 'hx;
    end
  join_none
endtask


//
// basic_read
//
task automatic basic_read(logic [addrWidth-1:0] addr,
                          ref logic [dataWidth-1:0] data);
  // address phase
  if (!data_phase) @(negedge hclk);
  haddr = addr;
  htrans = NONSEQ;
  hwrite = 0;

  // sample hrdata during the data phase
  @(negedge hclk);
  haddr = 'hx;
  htrans = 0;
  hwrite = 'hx;
  data_phase = 1;

  while (!hready) begin
    @(negedge hclk);
  end
  data = hrdata;

  fork
    #0 data_phase = 0;
  join_none
endtask

endinterface
