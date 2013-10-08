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

module ahb_slave
#(
  addrWidth = 8,
  dataWidth = 32,
  memDepth = 1024
)
(
  input                        hresetn,
  input                        hclk,

  input                        hselx,

  output wire                  hready,
// output logic [1:0]           hresp,
//
//
  input [addrWidth-1:0]        haddr,
  input                        hwrite,
  input [1:0]                  htrans,
// input [2:0]                  hsize,
// input [2:0]                  hburst,
//
  input [dataWidth-1:0]        hwdata,
  output logic [dataWidth-1:0] hrdata,

  input                        slv_busy
);

parameter IDLE   = 2'b00,
          NONSEQ = 2'b10;

logic [dataWidth-1:0] mem [memDepth];

logic [addrWidth-1:0] haddr_ap;
logic                 hwrite_ap;
logic [1:0]           htrans_ap;


assign hready = ~slv_busy;

always @(posedge hclk or negedge hresetn) begin
  if (!hresetn) begin
    hrdata    <= 0;
    htrans_ap <= 0;
    hwrite_ap <= 0;
    haddr_ap  <= 0;
  end

  else begin
    if (hready) begin
      htrans_ap <= htrans;
      hwrite_ap <= hwrite;
      haddr_ap  <= haddr;
    end

//$display("%t - htrans_ap:%0x hwrite_ap:%0x haddr_ap:0x%0x hwdata:0x%0x", $time, htrans_ap, hwrite_ap, haddr_ap, hwdata);

//$display("%t - slv_busy:%0x hready:%0x htrans:%0x hwrite:%0x haddr:0x%0x hwdata:0x%0x", $time, slv_busy, hready, htrans, hwrite, haddr, hwdata);

    // nonseq writes
    if (htrans_ap == NONSEQ && hwrite_ap && hready) begin
      mem[haddr_ap] <= hwdata;
    end

    // nonseq reads
    if (htrans == NONSEQ && !hwrite) begin
      hrdata <= mem[haddr];
    end

    else begin
      hrdata <= 0;
    end
  end
end

endmodule
