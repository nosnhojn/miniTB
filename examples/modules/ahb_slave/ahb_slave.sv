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

always @(posedge hclk or negedge hresetn) begin
  if (!hresetn) begin
    hready <= 0;
  end

  else begin
    if (htrans == IDLE) begin
      hready <= 1;
    end

    else if (htrans == NONSEQ) begin
      if (hwrite) begin
        mem[haddr] <= hwdata;
        hready <= 1;
      end
    end
  end
end

endmodule
