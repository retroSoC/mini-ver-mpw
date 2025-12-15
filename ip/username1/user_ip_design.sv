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
  localparam USER_IP_APB_DIV = 8'h04;  // rw
  localparam USER_IP_APB_CNT = 8'h08;  // rw
  // ========== USER CUSTOM AREA END ==========

  // ========== USER CUSTOM AREA ==============
  // NOTE: recommand define variables here
  logic s_apb_wr_hdshk, s_apb_rd_hdshk;
  logic s_tim_div_en;
  logic [7:0] s_tim_div_d, s_tim_div_q;
  logic [15:0] s_tim_cnt_d, s_tim_cnt_q;
  logic [7:0] s_div_cnt_d, s_div_cnt_q;
  logic s_gpio_rev_d, s_gpio_rev_q;
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
        USER_IP_APB_ID:  apb.prdata = {24'd0, ID};
        // NOTE: If needed, define the register's read logic here, like
        // `USER_IP_APB_XX: apb.prdata = {xxx}`
        USER_IP_APB_DIV: apb.prdata = {24'd0, s_tim_div_q};
        USER_IP_APB_CNT: apb.prdata = {16'd0, s_tim_cnt_q};
        default:         apb.prdata = '0;
      endcase
    end
  end

  // ========== USER CUSTOM AREA ==============
  // NOTE: If needed, define io logic here.
  // `gpio_oen` is active low, meaning gpio is
  // output when `gpio_oen[x]` = 1'b0.
  assign gpio.gpio_out = {`USER_GPIO_NUM{s_gpio_rev_q}};
  assign gpio.gpio_oen = '0;
  // ========== USER CUSTOM AREA END ==========

  // ====== INSTANCE USER CUSTOM TOP DESIGN HERE ======
  // ==================================================
  // ==================================================
  assign s_tim_div_en  = s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_DIV;
  assign s_tim_div_d   = apb.pwdata[7:0];
  dffer #(8) u_tim_div_dffer (
      clk_i,
      rst_n_i,
      s_tim_div_en,
      s_tim_div_d,
      s_tim_div_q
  );

  assign s_div_cnt_d = (s_div_cnt_q == s_tim_div_q) ? '0 : s_div_cnt_q + 1'b1;
  dffr #(8) u_div_cnt_dffr (
      clk_i,
      rst_n_i,
      s_div_cnt_d,
      s_div_cnt_q
  );


  assign s_gpio_rev_d = s_tim_cnt_q == '1 ? ~s_gpio_rev_q : s_gpio_rev_q;
  dffr #(1) u_gpio_rev_dffr (
      clk_i,
      rst_n_i,
      s_gpio_rev_d,
      s_gpio_rev_q
  );

  always_comb begin
    s_tim_cnt_d = s_tim_cnt_q;
    if (s_apb_wr_hdshk && apb.paddr[7:0] == USER_IP_APB_CNT) s_tim_cnt_d = apb.pwdata[15:0];
    else if (s_tim_cnt_q == '1) s_tim_cnt_d = '0;
    else if (s_div_cnt_q == s_tim_div_q) s_tim_cnt_d = s_tim_cnt_q + 1'b1;
  end
  dffr #(16) u_tim_cnt_dffr (
      clk_i,
      rst_n_i,
      s_tim_cnt_d,
      s_tim_cnt_q
  );
endmodule
