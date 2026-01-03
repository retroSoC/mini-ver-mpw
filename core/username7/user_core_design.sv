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

  ibex_top #(
      .PMPEnable       (0),
      .PMPGranularity  (0),
      .PMPNumRegions   (4),
      .MHPMCounterNum  (0),
      .MHPMCounterWidth(40),
      .RV32E           (0),
      .RV32M           (ibex_pkg::RV32MSingleCycle),
      .RV32B           (ibex_pkg::RV32BNone),
      .RV32ZC          (ibex_pkg::RV32ZcaZcbZcmp),
      .RegFile         (ibex_pkg::RegFileFF),
      .BranchTargetALU (1),
      .WritebackStage  (1),
      .ICache          (0),
      .ICacheECC       (0),
      .ICacheScramble  (0),
      .BranchPrediction(0),
      .SecureIbex      (0),
      .RndCnstLfsrSeed (ibex_pkg::RndCnstLfsrSeedDefault),
      .RndCnstLfsrPerm (ibex_pkg::RndCnstLfsrPermDefault),
      .DbgTriggerEn    (0),
      .DmBaseAddr      (32'h1A110000),
      .DmAddrMask      (32'h00000FFF),
      .DmHaltAddr      (32'h1A110800),
      .DmExceptionAddr (32'h1A110808)
  ) u_ibex_top (
      // Clock and reset
      .clk_i                    (clk_i),
      .rst_ni                   (rst_n_i),
      // enable all clock gates for testing
      .test_en_i                (1'b0),
      .ram_cfg_icache_tag_i     ('0),
      .ram_cfg_rsp_icache_tag_o (),
      .ram_cfg_icache_data_i    ('0),
      .ram_cfg_rsp_icache_data_o(),
      // Configuration
      .hart_id_i                ('0),
      .boot_addr_i              (`FLASH_START_ADDR - 32'h80),  // refer to TRM.
      // Instruction memory interface
      .instr_req_o              (),
      .instr_gnt_i              ('0),
      .instr_rvalid_i           ('0),
      .instr_addr_o             (),
      .instr_rdata_i            ('0),
      .instr_rdata_intg_i       ('0),
      .instr_err_i              ('0),
      // Data memory interface
      .data_req_o               (),
      .data_gnt_i               ('0),
      .data_rvalid_i            ('0),
      .data_we_o                (),
      .data_be_o                (),
      .data_addr_o              (),
      .data_wdata_o             (),
      .data_wdata_intg_o        (),
      .data_rdata_i             ('0),
      .data_rdata_intg_i        ('0),
      .data_err_i               ('0),
      // Interrupt inputs
      .irq_software_i           (irq_i[1]),
      .irq_timer_i              (irq_i[0]),
      .irq_external_i           ('0),
      .irq_fast_i               ('0),
      // non-maskeable interrupt
      .irq_nm_i                 ('0),
      // Scrambling Interface
      .scramble_key_valid_i     ('0),
      .scramble_key_i           ('0),
      .scramble_nonce_i         ('0),
      .scramble_req_o           (),
      // Debug interface
      .debug_req_i              ('0),
      .crash_dump_o             (),
      .double_fault_seen_o      (),
      // Special control signals
      .fetch_enable_i           (1'b1),
      .alert_minor_o            (),
      .alert_major_internal_o   (),
      .alert_major_bus_o        (),
      .core_sleep_o             (),
      // DFT bypass controls
      .scan_rst_ni              (1'b1)
  );

endmodule
