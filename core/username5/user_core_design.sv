// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// retroSoC is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.


/* NOTE: README FIRST
 * 0. copy this file as `user_core_design.sv`
 * 1. create a new folder `usercore` and simply put `user_core_design.sv` into `usercore` folder
 * 2. put all user custom design files into `usercore` folder
 *    - instance top module of user design in `user_core_design.sv`
 *    - create a filelist named `usercore.fl` to include all files needed to be included
 * 3. archive 'usercore' as `usercore.zip` and upload `usercore.zip` to cloud platform
 */


`include "mmap_define.svh"

// NOTE: dont remove `ID` parameter and port defines
module user_core_design #(
    parameter int ID = 5'd31
) (
    // verilog_format: off
    input  logic        clk_i,
    input  logic        rst_n_i,
    input  logic [31:0] irq_i,
    nmi_if.master       nmi
    // verilog_format: on
);

  logic s_mem_rstrb;
  logic s_mem_rstrb_re, s_mem_wmask_re;
  logic [31:0] s_mem_addr;
  logic [3:0] s_mem_wmask_d, s_mem_wmask_q;
  logic [3:0] s_mem_wmask;
  logic [31:0] s_mem_rdata_d, s_mem_rdata_q;
  logic [1:0] s_mem_req_d, s_mem_req_q;


  assign nmi.valid = |s_mem_req_q;
  assign nmi.addr  = {s_mem_addr[31:2], 2'b00};
  always_comb begin
    nmi.wstrb = '0;
    if (s_mem_wmask_re) nmi.wstrb = s_mem_wmask;
    else if (s_mem_req_q == 2'd2) nmi.wstrb = s_mem_wmask_q;
  end


  edge_det_sync_re #(1) u_mem_rstrb_edge_det_sync_re (
      clk_i,
      rst_n_i,
      s_mem_rstrb,
      s_mem_rstrb_re
  );

  edge_det_sync_re #(1) u_mem_wmask_edge_det_sync_re (
      clk_i,
      rst_n_i,
      |s_mem_wmask,
      s_mem_wmask_re
  );


  // 0: idle 1: rd 2: wr
  always_comb begin
    s_mem_req_d = s_mem_req_q;
    if (s_mem_rstrb_re) s_mem_req_d = 2'd1;
    else if (s_mem_wmask_re) s_mem_req_d = 2'd2;
    else if ((|s_mem_req_q) && nmi.ready) s_mem_req_d = 2'd0;
  end
  dffr #(2) u_mem_req_dffr (
      clk_i,
      rst_n_i,
      s_mem_req_d,
      s_mem_req_q
  );


  assign s_mem_rdata_d = nmi.rdata;
  dffer #(32) u_mem_rdata_dffer (
      clk_i,
      rst_n_i,
      s_mem_req_q == 2'd1 && nmi.ready,
      s_mem_rdata_d,
      s_mem_rdata_q
  );


  assign s_mem_wmask_d = s_mem_wmask;
  dffer #(4) u_mem_mask_dffer (
      clk_i,
      rst_n_i,
      s_mem_wmask_re,
      s_mem_wmask_d,
      s_mem_wmask_q
  );


  FemtoRV32 #(
      .RESET_ADDR(`FLASH_START_ADDR),
      .ADDR_WIDTH(32)
  ) u_FemtoRV32 (
      .clk      (clk_i),
      .reset    (rst_n_i),
      .mem_addr (s_mem_addr),
      .mem_wdata(nmi.wdata),
      .mem_wmask(s_mem_wmask),
      .mem_rdata(s_mem_rdata_q),
      .mem_rstrb(s_mem_rstrb),
      .mem_rbusy(nmi.valid),
      .mem_wbusy(nmi.valid)
  );

endmodule
