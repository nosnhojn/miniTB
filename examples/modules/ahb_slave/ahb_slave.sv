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

  output logic                 hready,
// output logic [1:0]           hresp,
//
//
  input [addrWidth-1:0]        haddr,
  input                        hwrite,
  input [1:0]                  htrans,
// input [2:0]                  hsize,
// input [2:0]                  hburst,
//
  input [dataWidth-1:0]        hwdata
// output logic [dataWidth-1:0] hrdata
);

parameter IDLE   = 2'b00,
          NONSEQ = 2'b10;

logic [dataWidth-1:0] mem [memDepth];

logic [addrWidth-1:0] haddr_ap;
logic                 hwrite_ap;
logic [1:0]           htrans_ap;

always @(posedge hclk or negedge hresetn) begin
  if (!hresetn) begin
    hready    <= 0;
    htrans_ap <= 0;
    hwrite_ap <= 0;
    haddr_ap  <= 0;
  end

  else begin
    htrans_ap <= htrans;
    hwrite_ap <= hwrite;
    haddr_ap  <= haddr;

    if (htrans_ap == IDLE) begin
      hready <= 1;
    end

    else if (htrans_ap == NONSEQ) begin
//$display("%t - htrans_ap:%0x hwrite_ap:%0x haddr_ap:0x%0x hwdata:0x%0x", $time, htrans_ap, hwrite_ap, haddr_ap, hwdata);
      if (hwrite_ap) begin
        mem[haddr_ap] <= hwdata;
        hready <= 1;
      end
    end
  end
end

endmodule
