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

logic end_of_trans = 0;

//
// reset
//
function void reset();
  htrans = 0;
  haddr  = 0;
  hwrite = 0;
  hwdata = 0;
  end_of_trans = 0;
endfunction


//
// idle
//
task idle();
  if (!end_of_trans) @(negedge hclk);
  htrans = IDLE;
  end_of_trans = 0;
endtask


//
// basic_write
//
task automatic basic_write(logic [addrWidth-1:0] addr,
                           logic [dataWidth-1:0] data);
  // address phase
  if (!end_of_trans) @(negedge hclk);
  haddr = addr;
  htrans = NONSEQ;
  hwrite = 1;

  // data phase
  @(negedge hclk);
  hwdata = data;
  end_of_trans = 1;

  fork
    #1 end_of_trans = 0;
  join_none
endtask


//
// basic_read
//
task automatic basic_read(logic [addrWidth-1:0] addr,
                          ref logic [dataWidth-1:0] data);
  // address phase
  if (!end_of_trans) @(negedge hclk);
  haddr = addr;
  htrans = NONSEQ;
  hwrite = 0;

  // sample hrdata during the data phase
  @(negedge hclk);
  data = hrdata;
  end_of_trans = 1;

  fork
    #1 end_of_trans = 0;
  join_none
endtask

endinterface
