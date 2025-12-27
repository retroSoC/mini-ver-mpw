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

  logic [31:0] s_wb_ibus_adr;
  logic        s_wb_ibus_stb;
  logic [31:0] s_wb_ibus_rdt;
  logic        s_wb_ibus_ack;
  logic [31:0] s_wb_dbus_adr;
  logic [31:0] s_wb_dbus_dat;
  logic [ 3:0] s_wb_dbus_sel;
  logic        s_wb_dbus_we;
  logic        s_wb_dbus_stb;
  logic [31:0] s_wb_dbus_rdt;
  logic        s_wb_dbus_ack;
  logic [ 3:0] s_wb_mem_sel;
  logic        s_wb_mem_we;
  logic        s_core_rst_n_sync;

  assign nmi.wstrb = s_wb_mem_we ? s_wb_mem_sel : '0;

  rst_sync #(
      .STAGE(5)
  ) u_core_rst_sync (
      .clk_i  (clk_i),
      .rst_n_i(rst_n_i),
      .rst_n_o(s_core_rst_n_sync)
  );


  serv_rf_top #(
      .RESET_PC      (`FLASH_START_ADDR),
      /*  COMPRESSED=1: Enable the compressed decoder and allowed misaligned jump of pc
        COMPRESSED=0: Disable the compressed decoder and does not allow the misaligned jump of pc
    */
      .COMPRESSED    (0),
      /* Multiplication and Division Unit
       This parameter enables the interface for connecting SERV and MDU
    */
      .MDU           (0),
      /* Register signals before or after the decoder
       0 : Register after the decoder. Faster but uses more resources
       1 : (default) Register before the decoder. Slower but uses less resources
     */
      .PRE_REGISTER  (1),
      /* Amount of reset applied to design
       "NONE" : No reset at all. Relies on a POR to set correct initialization
                 values and that core isn't reset during runtime
       "MINI" : Standard setting. Resets the minimal amount of FFs needed to
                 restart execution from the instruction at RESET_PC
     */
      .RESET_STRATEGY("MINI"),
      .DEBUG         (1'b0),
      .WITH_CSR      (1),
      .W             (1)
  ) u_serv_rf_top (
      .clk         (clk_i),
      .i_rst       (~s_core_rst_n_sync),
      .i_timer_irq (irq_i[0]),
      // Bus
      .o_ibus_adr  (s_wb_ibus_adr),
      .o_ibus_cyc  (s_wb_ibus_stb),
      .i_ibus_rdt  (s_wb_ibus_rdt),
      .i_ibus_ack  (s_wb_ibus_ack),
      .o_dbus_adr  (s_wb_dbus_adr),
      .o_dbus_dat  (s_wb_dbus_dat),
      .o_dbus_sel  (s_wb_dbus_sel),
      .o_dbus_we   (s_wb_dbus_we),
      .o_dbus_cyc  (s_wb_dbus_stb),
      .i_dbus_rdt  (s_wb_dbus_rdt),
      .i_dbus_ack  (s_wb_dbus_ack),
      // Extension
      .o_ext_rs1   (),
      .o_ext_rs2   (),
      .o_ext_funct3(),
      .i_ext_rd    ('0),
      .i_ext_ready ('0),
      // MDU
      .o_mdu_valid ()
  );

  serv_wb_arbiter u_serv_wb_arbiter (
      .wb_ibus_adr_i(s_wb_ibus_adr),
      .wb_ibus_stb_i(s_wb_ibus_stb),
      .wb_ibus_rdt_o(s_wb_ibus_rdt),
      .wb_ibus_ack_o(s_wb_ibus_ack),
      .wb_dbus_adr_i(s_wb_dbus_adr),
      .wb_dbus_dat_i(s_wb_dbus_dat),
      .wb_dbus_sel_i(s_wb_dbus_sel),
      .wb_dbus_we_i (s_wb_dbus_we),
      .wb_dbus_stb_i(s_wb_dbus_stb),
      .wb_dbus_rdt_o(s_wb_dbus_rdt),
      .wb_dbus_ack_o(s_wb_dbus_ack),
      .wb_mem_adr_o (nmi.addr),
      .wb_mem_dat_o (nmi.wdata),
      .wb_mem_sel_o (s_wb_mem_sel),
      .wb_mem_we_o  (s_wb_mem_we),
      .wb_mem_stb_o (nmi.valid),
      .wb_mem_rdt_i (nmi.rdata),
      .wb_mem_ack_i (nmi.ready)
  );

endmodule

/*
 * servile_arbiter.v : I/D arbiter for the servile convenience wrapper.
 *  Relies on the fact that not ibus and dbus are active at the same time.
 *
 * SPDX-FileCopyrightText: 2024 Olof Kindgren <olof.kindgren@gmail.com>
 * SPDX-License-Identifier: Apache-2.0
 */
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// retroSoC is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module serv_wb_arbiter (
    input  logic [31:0] wb_ibus_adr_i,
    input  logic        wb_ibus_stb_i,
    output logic [31:0] wb_ibus_rdt_o,
    output logic        wb_ibus_ack_o,

    input  logic [31:0] wb_dbus_adr_i,
    input  logic [31:0] wb_dbus_dat_i,
    input  logic [ 3:0] wb_dbus_sel_i,
    input  logic        wb_dbus_we_i,
    input  logic        wb_dbus_stb_i,
    output logic [31:0] wb_dbus_rdt_o,
    output logic        wb_dbus_ack_o,

    output logic [31:0] wb_mem_adr_o,
    output logic [31:0] wb_mem_dat_o,
    output logic [ 3:0] wb_mem_sel_o,
    output logic        wb_mem_we_o,
    output logic        wb_mem_stb_o,
    input  logic [31:0] wb_mem_rdt_i,
    input  logic        wb_mem_ack_i
);

  assign wb_ibus_rdt_o = wb_mem_rdt_i;
  assign wb_ibus_ack_o = wb_mem_ack_i & wb_ibus_stb_i;

  assign wb_dbus_rdt_o = wb_mem_rdt_i;
  assign wb_dbus_ack_o = wb_mem_ack_i & (!wb_ibus_stb_i);

  assign wb_mem_adr_o  = wb_ibus_stb_i ? wb_ibus_adr_i : wb_dbus_adr_i;
  assign wb_mem_dat_o  = wb_dbus_dat_i;
  assign wb_mem_sel_o  = wb_dbus_sel_i;
  assign wb_mem_we_o   = wb_dbus_we_i & (!wb_ibus_stb_i);
  assign wb_mem_stb_o  = wb_ibus_stb_i | wb_dbus_stb_i;

endmodule

