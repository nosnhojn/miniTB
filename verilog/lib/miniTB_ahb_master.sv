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
  input hresetn,
  input hclk
);

//logic                 hgrantx;
//logic                 hbusreqx;
//logic                 hlockx;
//
//logic                 hready;
//logic [1:0]           hresp;
//
//logic [1:0]           htrans;
//
//logic [addrWidth-1:0] haddr;
//logic                 hwrite;
//logic [2:0]           hsize;
//logic [2:0]           hburst;
//logic [3:0]           hprot;
//
//logic [dataWidth-1:0] hwdata;
//logic [dataWidth-1:0] hrdata;


endinterface
