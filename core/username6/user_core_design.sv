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

  darkriscv u_darkriscv (
      .CLK  (clk_i),             // clock
      .RES  (~rst_n_i),          // reset
      .IDATA(s_cpu_inst_data),   // instruction data bus
      .IADDR(s_cpu_inst_addr),   // instruction addr bus
      .IDREQ(s_cpu_inst_req),    // instruction req
      .IDACK(s_cpu_inst_ack),    // instruction ack
      .DATAI(s_cpu_data_rdata),  // data bus (input)
      .DATAO(s_cpu_data_wdata),  // data bus (output)
      .DADDR(s_cpu_data_addr),   // addr bus
      .DLEN (),                  // data length
      .DBE  (s_cpu_data_wstrb),  // data byte enable
      .DRW  (),                  // data read/write
      .DRD  (s_cpu_data_rd),     // data read
      .DWR  (s_cpu_data_wr),     // data write
      .DDREQ(s_cpu_data_req),    // data req
      .DDACK(s_cpu_data_ack),    // data ack
      .BERR ('0),                // bus error
      .DEBUG()                   // old-school osciloscope based debug! :)
  );

endmodule
