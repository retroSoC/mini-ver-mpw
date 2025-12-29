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

  logic [3:0] s_mem_wmask;
  logic       s_mem_rstrb;

  assign nmi.valid = s_mem_rstrb || (|s_mem_wmask);
  assign nmi.wstrb = s_mem_rstrb ? '0 : s_mem_wmask;

  FemtoRV32 u_FemtoRV32 (
      .clk      (clk_i),
      .reset    (rst_n_i),
      .mem_addr (nmi.addr),
      .mem_wdata(nmi.wdata),
      .mem_wmask(s_mem_wmask),
      .mem_rdata(nmi.rdata),
      .mem_rstrb(s_mem_rstrb),
      .mem_rbusy(nmi.ready),
      .mem_wbusy(nmi.ready)
  );

endmodule
