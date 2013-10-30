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
  input hclk,
  input hresetn
);

//logic                 hgrantx;
//logic                 hbusreqx;
//logic                 hlockx;
//
logic                 hready;
logic                 hready_d1;
//logic [1:0]           hresp;
//
logic [1:0]           htrans;
logic [1:0]           htrans_ap;
logic [1:0]           m_trans [$];

logic [addrWidth-1:0] haddr;
logic [addrWidth-1:0] m_addr [$];
logic                 hwrite;
logic                 hwrite_ap;
logic                 m_write [$];
//logic [2:0]           hsize;
//logic [2:0]           hburst;
//logic [3:0]           hprot;
//
logic [dataWidth-1:0] hwdata;
logic [dataWidth-1:0] next_hwdata;
logic [dataWidth-1:0] m_wdata [$];

logic [dataWidth-1:0] hrdata;
logic [dataWidth-1:0] rdata;

int next_completion_id;
int completion_id;
event rdata_e;

parameter IDLE   = 2'b00,
          NONSEQ = 2'b10;

logic data_phase = 0;
logic address_phase = 0;

wire slave_is_ready;
wire new_xaction_ready;
wire read_in_progress;


//---------------------------
// Public API
//  reset();
//  idle();
//  basic_write(addr, data);
//  basic_read(addr, data);
//---------------------------

//
// reset
//
function void reset();
  htrans = IDLE;
  haddr  = 'hx;
  hwrite = 'hx;
  hwdata = 'hx;
  data_phase = 0;
  address_phase = 0;
  next_completion_id = 0;
  completion_id = 0;
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
// basic_write
//
task automatic basic_write(logic [addrWidth-1:0] addr,
                           logic [dataWidth-1:0] data);
  m_write.push_back(1);
  m_addr.push_back(addr);
  m_wdata.push_back(data);
  m_trans.push_back(NONSEQ);

  @(posedge hclk);
endtask


//
// basic_read
//
task automatic basic_read(logic [addrWidth-1:0] addr,
                          ref logic [dataWidth-1:0] data);
  int my_completion_id;

  next_completion_id += 1;
  my_completion_id = next_completion_id;

  m_write.push_back(0);
  m_addr.push_back(addr);
  m_trans.push_back(NONSEQ);

  @(rdata_e);
  while (my_completion_id != completion_id) begin
    @(rdata_e);
  end

  data = rdata;
endtask


 
wire active;
wire read_data_ready;
wire read_without_wait;
wire read_with_wait;

always @(negedge hresetn) reset();

//
// Signal Mastering
//
always @(negedge hclk) begin
  case ({address_phase , data_phase})
    'b00 :
      begin
        if (new_xaction_ready) start_address_phase();
      end

    'b10 :
      begin
        if (new_xaction_ready) start_address_phase();
        else                   end_address_phase();

        start_data_phase();

        if (read_in_progress) remember_read_phase();
      end

    'b11 :
      begin
        if (slave_is_ready) begin
          if (new_xaction_ready) start_address_phase();
          else                   end_address_phase();

          start_data_phase();
        end

        if (read_in_progress) remember_read_phase();
      end

    'b01 :
      begin
        if (new_xaction_ready) start_address_phase();

        if (slave_is_ready) end_data_phase();
      end
  endcase
end

//
// Signal Sampling
//
always @(posedge hclk) begin
  #1;
  if (active) begin
    hready_d1 <= hready;
    if (read_data_ready) return_read();
  end
end


//------------------------------------
// tasks/wires for managing the logic
// for the address and data phases
//------------------------------------

assign active = hresetn;
assign slave_is_ready = hready;
assign new_xaction_ready = (m_addr.size() > 0);
assign read_in_progress = !hwrite;
assign read_without_wait = (htrans == NONSEQ && !hwrite && hready);
assign read_with_wait = (htrans_ap == NONSEQ && !hwrite_ap && hready && !hready_d1);
assign read_data_ready = (read_without_wait || read_with_wait);

function bit return_read();
  rdata = hrdata;
  completion_id += 1;
  -> rdata_e;
endfunction

function void remember_read_phase();
  htrans_ap <= htrans;
  hwrite_ap <= hwrite;
endfunction

task start_address_phase();
  address_phase <= 1;
  haddr <= m_addr.pop_front();
  htrans <= m_trans.pop_front();
  if (m_write[0] == 1) next_hwdata <= m_wdata.pop_front();
  else                 next_hwdata <= 'hx;
  hwrite <= m_write.pop_front();
endtask

task end_address_phase();
  address_phase <= 0;
  htrans <= 'h0;
  haddr <= 'hx;
  hwrite <= 'hx;
endtask

task start_data_phase();
  data_phase <= 1;
  hwdata <= next_hwdata;
endtask

task end_data_phase();
  data_phase <= 0;
  hwdata <= 'hx;
endtask

endinterface
