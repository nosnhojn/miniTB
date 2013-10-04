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

interface miniTB_apb_master
(
  input wire clk,
  input wire rst_n
);
  logic [7:0]  paddr;
  logic        pwrite;
  logic        psel;
  logic        penable;
  logic [31:0] pwdata;
  logic [31:0] prdata;

  //-------------------------------------------------------------------------------
  //
  // write ()
  //
  // Simple write method used in the unit tests. Includes options for back-to-back
  // writes and protocol errors on the psel and pwrite.
  //
  //-------------------------------------------------------------------------------
  task write(logic [7:0] addr,
             logic [31:0] data,
             logic setup_psel = 1,
             logic setup_pwrite = 1);


    // this is the SETUP state where the psel,
    // pwrite, paddr and pdata are set
    //
    // NOTE:
    //   setup_psel == 0 for protocol errors on the psel
    //   setup_pwrite == 0 for protocol errors on the pwrite
    if (!penable) @(negedge clk);
    psel <= setup_psel;
    pwrite <= setup_pwrite;
    paddr <= addr;
    pwdata <= data;
    penable <= 0;

    // this is the ENABLE state where the penable is asserted
    @(negedge clk);
    pwrite <= 1;
    penable <= 1;
    psel <= 1;

    // return to the IDLE state
    @(negedge clk);
    idle();
  endtask


  //-------------------------------------------------------------------------------
  //
  // read ()
  //
  // Simple read method used in the unit tests. Includes options for back-to-back
  // reads.
  //
  //-------------------------------------------------------------------------------
  task read(logic [7:0] addr, output logic [31:0] data);

    // this is the SETUP state where the psel, pwrite and paddr
    if (!penable) @(negedge clk);
    psel <= 1;
    paddr <= addr;
    penable <= 0;
    pwrite <= 0;

    // this is the ENABLE state where the penable is asserted
    @(negedge clk);
    penable <= 1;

    // sample the data and return to the IDLE state
    @(negedge clk);
    data = prdata;
    idle();
  endtask


  //-------------------------------------------------------------------------------
  //
  // idle ()
  //
  // Clear the all the inputs to the uut (i.e. move to the IDLE state)
  //
  //-------------------------------------------------------------------------------
  task idle();
    psel <= 0;
    penable <= 0;
    pwrite <= 0;
    paddr <= 0;
    pwdata <= 0;
  endtask

endinterface
