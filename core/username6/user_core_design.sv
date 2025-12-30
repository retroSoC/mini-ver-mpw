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

  logic        s_cpu_wr;
  logic        s_cpu_rd;
  logic [ 3:0] s_cpu_be;
  logic [31:0] s_cpu_rdata;
  logic [31:0] s_cpu_rdata_d, s_cpu_rdata_q;

  assign nmi.wstrb = s_cpu_wr ? s_cpu_be : '0;
  darkbridge u_darkbridge (
      .CLK   (clk_i),
      .RES   (~rst_n_i),
      .HLT   (),
      // x-bus
      .XXDREQ(nmi.valid),
      .XXWR  (s_cpu_wr),
      .XXRD  (s_cpu_rd),
      .XXBE  (s_cpu_be),
      .XXADDR(nmi.addr),
      .XXATAO(nmi.wdata),
      .XXATAI(s_cpu_rdata),
      .XXDACK(nmi.ready),
      .DEBUG ()
  );

  assign s_cpu_rdata   = (nmi.valid && s_cpu_rd && nmi.ready) ? nmi.rdata : s_cpu_rdata_q;
  assign s_cpu_rdata_d = nmi.rdata;
  dffer #(32) u_cpu_rdata_dffer (
      clk_i,
      rst_n_i,
      nmi.valid && s_cpu_rd && nmi.ready,
      s_cpu_rdata_d,
      s_cpu_rdata_q
  );
endmodule
