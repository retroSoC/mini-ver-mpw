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
 * 0. copy this file as `user_ip_design.sv`
 * 1. create a new folder `userip` and simply put `user_ip_design.sv` into `userip` folder
 * 2. put all user custom design files into `userip` folder
 *    - instance top module of user design in `user_ip_design.sv`
 *    - create a filelist named `userip.fl` to include all files needed to be included
 * 3. archive 'userip' as `userip.zip` and upload `userip.zip` to cloud platform
 */

// NOTE: opt include `mdd_config.svh`
`include "mdd_config.svh"

// NOTE: dont remove `ID` parameter and port defines
module user_ip_design #(
    parameter [7:0] ID = 8'd255
) (
    // verilog_format: off
    input logic      clk_i,
    input logic      rst_n_i,
    user_gpio_if.dut gpio,
    apb4_if.slave    apb
    // verilog_format: on
);

  // ========== USER CUSTOM AREA ==============
  // NOTE: define constants by using `localparam`
  // and dont DELETE or MODIFY the addr and read
  // logic of `USER_IP_APB_ID`.
  // User should add new register defines like
  // `USER_IP_APB_XX`.
  localparam USER_IP_APB_ID = 8'h00;  // ro
  localparam USER_IP_APB_OE = 8'h04;  // rw
  localparam USER_IP_APB_CS = 8'h08;  // rw
  localparam USER_IP_APB_PU = 8'h0C;  // rw
  localparam USER_IP_APB_PD = 8'h10;  // rw
  localparam USER_IP_APB_DO = 8'h14;  // rw
  localparam USER_IP_APB_DI = 8'h18;  // ro
  // ========== USER CUSTOM AREA END ==========

  // ========== USER CUSTOM AREA ==============
  // NOTE: recommand define variables here
  logic s_apb_wr_hdshk, s_apb_rd_hdshk;
  logic s_gpio_oe_en;
  logic [`USER_GPIO_NUM-1:0] s_gpio_oe_d, s_gpio_oe_q;
  logic s_gpio_cs_en;
  logic [`USER_GPIO_NUM-1:0] s_gpio_cs_d, s_gpio_cs_q;
  logic s_gpio_pu_en;
  logic [`USER_GPIO_NUM-1:0] s_gpio_pu_d, s_gpio_pu_q;
  logic s_gpio_pd_en;
  logic [`USER_GPIO_NUM-1:0] s_gpio_pd_d, s_gpio_pd_q;
  logic s_gpio_do_en;
  logic [`USER_GPIO_NUM-1:0] s_gpio_do_d, s_gpio_do_q;
  // ========== USER CUSTOM AREA END ==========

  assign s_apb_wr_hdshk = apb.psel && apb.penable && apb.pwrite;
  assign s_apb_rd_hdshk = apb.psel && apb.penable && (~apb.pwrite);
  // `pready` can be set according to requirements.
  assign apb.pready     = 1'b1;
  // error handling is not supported, `pslverr`
  // must be set to 0.
  assign apb.pslverr    = 1'b0;

  always_comb begin
    apb.prdata = '0;
    if (s_apb_rd_hdshk) begin
      unique case (apb.paddr[7:0])
        USER_IP_APB_ID: apb.prdata = {24'd0, ID};
        // NOTE: If needed, define the register's read logic here, like
        // `USER_IP_APB_XX: apb.prdata = {xxx}`
        USER_IP_APB_OE: apb.prdata = {{(32 - `USER_GPIO_NUM) {1'b0}}, s_gpio_oe_q};
        USER_IP_APB_CS: apb.prdata = {{(32 - `USER_GPIO_NUM) {1'b0}}, s_gpio_cs_q};
        USER_IP_APB_PU: apb.prdata = {{(32 - `USER_GPIO_NUM) {1'b0}}, s_gpio_pu_q};
        USER_IP_APB_PD: apb.prdata = {{(32 - `USER_GPIO_NUM) {1'b0}}, s_gpio_pd_q};
        USER_IP_APB_DO: apb.prdata = {{(32 - `USER_GPIO_NUM) {1'b0}}, s_gpio_do_q};
        USER_IP_APB_DI: apb.prdata = {{(32 - `USER_GPIO_NUM) {1'b0}}, gpio.gpio_in};
        default:        apb.prdata = '0;
      endcase
    end
  end

  // ========== USER CUSTOM AREA ==============
  // NOTE: If needed, define io logic here.
  // `gpio_oe` is active high, meaning gpio is
  // output when `gpio_oe[x]` = 1'b1
  assign gpio.gpio_oe  = s_gpio_oe_q;
  assign gpio.gpio_cs  = s_gpio_cs_q;  // 1: CMOS 0: SCHMI
  assign gpio.gpio_pu  = s_gpio_pu_q;
  assign gpio.gpio_pd  = s_gpio_pd_q;
  assign gpio.gpio_out = s_gpio_do_q;
  // ========== USER CUSTOM AREA END ==========

  // ====== INSTANCE USER CUSTOM TOP DESIGN HERE ======
  // ==================================================
  // ==================================================
  assign s_gpio_oe_en  = s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_OE;
  assign s_gpio_oe_d   = apb.pwdata[`USER_GPIO_NUM-1:0];
  dffer #(`USER_GPIO_NUM) u_gpio_oe_dffer (
      clk_i,
      rst_n_i,
      s_gpio_oe_en,
      s_gpio_oe_d,
      s_gpio_oe_q
  );


  assign s_gpio_cs_en = s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_CS;
  assign s_gpio_cs_d  = apb.pwdata[`USER_GPIO_NUM-1:0];
  dffer #(`USER_GPIO_NUM) u_gpio_cs_dffer (
      clk_i,
      rst_n_i,
      s_gpio_cs_en,
      s_gpio_cs_d,
      s_gpio_cs_q
  );


  assign s_gpio_pu_en = s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_PU;
  assign s_gpio_pu_d  = apb.pwdata[`USER_GPIO_NUM-1:0];
  dffer #(`USER_GPIO_NUM) u_gpio_pu_dffer (
      clk_i,
      rst_n_i,
      s_gpio_pu_en,
      s_gpio_pu_d,
      s_gpio_pu_q
  );


  assign s_gpio_pd_en = s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_PD;
  assign s_gpio_pd_d  = apb.pwdata[`USER_GPIO_NUM-1:0];
  dffer #(`USER_GPIO_NUM) u_gpio_pd_dffer (
      clk_i,
      rst_n_i,
      s_gpio_pd_en,
      s_gpio_pd_d,
      s_gpio_pd_q
  );


  assign s_gpio_do_en = s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_DO;
  assign s_gpio_do_d  = apb.pwdata[`USER_GPIO_NUM-1:0];
  dffer #(`USER_GPIO_NUM) u_gpio_do_dffer (
      clk_i,
      rst_n_i,
      s_gpio_do_en,
      s_gpio_do_d,
      s_gpio_do_q
  );

endmodule
