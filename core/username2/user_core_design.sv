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

  logic [31:0] s_nmi_addr;
  assign nmi.addr = {s_nmi_addr[31:2], 2'd0};
  kianv_harris_mc_edition #(
      .RESET_ADDR(`FLASH_START_ADDR),
      .STACKADDR ('0),
      .RV32E     (1'b0)
  ) u_kianv_harris_mc_edition (
      .clk         (clk_i),
      .resetn      (rst_n_i),
      .mem_valid   (nmi.valid),
      .mem_ready   (nmi.ready),
      .mem_wstrb   (nmi.wstrb),
      .mem_addr    (s_nmi_addr),
      .mem_wdata   (nmi.wdata),
      .mem_rdata   (nmi.rdata),
      .PC          (),
      .access_fault(1'b0),
      .IRQ3        (irq_i[0]),
      .IRQ7        (irq_i[1])
  );

endmodule
