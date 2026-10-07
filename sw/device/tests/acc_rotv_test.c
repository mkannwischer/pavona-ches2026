// Copyright lowRISC contributors (OpenTitan project).
// Copyright MPI-SP.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/dif/dif_acc.h"
#include "sw/device/lib/testing/acc_testutils.h"
#include "sw/device/lib/testing/entropy_testutils.h"
#include "sw/device/lib/testing/test_framework/check.h"
#include "sw/device/lib/testing/test_framework/ottf_main.h"

/**
 * This test runs every `bn.rotv` variant in ACC's ISA and checks the result.
 *
 * The zero register and `x1` stack register are ignored.
 */
OTTF_DEFINE_TEST_CONFIG();

ACC_DECLARE_APP_SYMBOLS(smoke_test);
ACC_DECLARE_SYMBOL_ADDR(smoke_test, gpr_state);
ACC_DECLARE_SYMBOL_ADDR(smoke_test, wdr_state);

static const acc_app_t kAppSmokeTest = ACC_APP_T_INIT(smoke_test);
static const acc_addr_t kGprState = ACC_ADDR_T_INIT(smoke_test, gpr_state);
static const acc_addr_t kWdrState = ACC_ADDR_T_INIT(smoke_test, wdr_state);

enum {
  kNumExpectedGprs = 30,
  kNumExpectedWdrs = 32,
  kExpectedInstrCount = 173,
};

// The expected values of the GPRs and WDRs are taken from
// `hw/ip/acc/dv/smoke_rotv/smoke_expected.txt`. Note that the WDR values there
// are printed most-significant word first, so each row below is that line
// reversed.
static const uint32_t kExpectedGprs[kNumExpectedGprs] = {
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000,
    0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000, 0x00000000};

static const uint32_t kExpectedWdrs[kNumExpectedWdrs][8] = {
    [0] = {0x06040200, 0x0e0c0a08, 0x16141210, 0x1e1c1a18, 0x26242220,
           0x2e2c2a28, 0x36343230, 0x3e3c3a38},
    [1] = {0x0c080400, 0x1c181410, 0x2c282420, 0x3c383430, 0x4c484440,
           0x5c585450, 0x6c686460, 0x7c787470},
    [2] = {0x18100800, 0x38302820, 0x58504840, 0x78706860, 0x98908880,
           0xb8b0a8a0, 0xd8d0c8c0, 0xf8f0e8e0},
    [3] = {0x05850484, 0x07870686, 0x01810080, 0x03830282, 0x0d8d0c8c,
           0x0f8f0e8e, 0x09890888, 0x0b8b0a8a},
    [4] = {0x0b0a0908, 0x0f0e0d0c, 0x03020100, 0x07060504, 0x1b1a1918,
           0x1f1e1d1c, 0x13121110, 0x17161514},
    [5] = {0x80604020, 0x00e0c0a0, 0x81614121, 0x01e1c1a1, 0x82624222,
           0x02e2c2a2, 0x83634323, 0x03e3c3a3},
    [6] = {0x00c08040, 0x01c18141, 0x02c28242, 0x03c38343, 0x04c48444,
           0x05c58545, 0x06c68646, 0x07c78747},
    [7] = {0x01810080, 0x03830282, 0x05850484, 0x07870686, 0x09890888,
           0x0b8b0a8a, 0x0d8d0c8c, 0x0f8f0e8e},
    [8] = {0x06040200, 0x0e0c0a08, 0x16141210, 0x1e1c1a18, 0x26242220,
           0x2e2c2a28, 0x36343230, 0x3e3c3a38},
    [9] = {0x0c080400, 0x1c181410, 0x2c282420, 0x3c383430, 0x4c484440,
           0x5c585450, 0x6c686460, 0x7c787470},
    [10] = {0x18100800, 0x38302820, 0x58504840, 0x78706860, 0x98908880,
            0xb8b0a8a0, 0xd8d0c8c0, 0xf8f0e8e0},
    [11] = {0x03830282, 0x01810080, 0x07870686, 0x05850484, 0x0b8b0a8a,
            0x09890888, 0x0f8f0e8e, 0x0d8d0c8c},
    [12] = {0x07060504, 0x03020100, 0x0f0e0d0c, 0x0b0a0908, 0x17161514,
            0x13121110, 0x1f1e1d1c, 0x1b1a1918},
    [13] = {0x80604020, 0x00e0c0a0, 0x81614121, 0x01e1c1a1, 0x82624222,
            0x02e2c2a2, 0x83634323, 0x03e3c3a3},
    [14] = {0x00c08040, 0x01c18141, 0x02c28242, 0x03c38343, 0x04c48444,
            0x05c58545, 0x06c68646, 0x07c78747},
    [15] = {0x01810080, 0x03830282, 0x05850484, 0x07870686, 0x09890888,
            0x0b8b0a8a, 0x0d8d0c8c, 0x0f8f0e8e},
    [16] = {0x06040200, 0x0e0c0a08, 0x16141210, 0x1e1c1a18, 0x26242220,
            0x2e2c2a28, 0x36343230, 0x3e3c3a38},
    [17] = {0x0c080400, 0x1c181410, 0x2c282420, 0x3c383430, 0x4c484440,
            0x5c585450, 0x6c686460, 0x7c787470},
    [18] = {0x18100800, 0x38302820, 0x58504840, 0x78706860, 0x98908880,
            0xb8b0a8a0, 0xd8d0c8c0, 0xf8f0e8e0},
    [19] = {0x00800181, 0x02820383, 0x04840585, 0x06860787, 0x08880989,
            0x0a8a0b8b, 0x0c8c0d8d, 0x0e8e0f8f},
    [20] = {0x01000302, 0x05040706, 0x09080b0a, 0x0d0c0f0e, 0x11101312,
            0x15141716, 0x19181b1a, 0x1d1c1f1e},
    [21] = {0x00604020, 0x80e0c0a0, 0x01614121, 0x81e1c1a1, 0x02624222,
            0x82e2c2a2, 0x03634323, 0x83e3c3a3},
    [22] = {0x00c08040, 0x01c18141, 0x02c28242, 0x03c38343, 0x04c48444,
            0x05c58545, 0x06c68646, 0x07c78747},
    [23] = {0x01810080, 0x03830282, 0x05850484, 0x07870686, 0x09890888,
            0x0b8b0a8a, 0x0d8d0c8c, 0x0f8f0e8e},
    [24] = {0x06040200, 0x0e0c0a08, 0x16141210, 0x1e1c1a18, 0x26242220,
            0x2e2c2a28, 0x36343230, 0x3e3c3a38},
    [25] = {0x0c080400, 0x1c181410, 0x2c282420, 0x3c383430, 0x4c484440,
            0x5c585450, 0x6c686460, 0x7c787470},
    [26] = {0x18100800, 0x38302820, 0x58504840, 0x78706860, 0x98908880,
            0xb8b0a8a0, 0xd8d0c8c0, 0xf8f0e8e0},
    [27] = {0x81018000, 0x83038202, 0x85058404, 0x87078606, 0x89098808,
            0x8b0b8a0a, 0x8d0d8c0c, 0x8f0f8e0e},
    [28] = {0x02030001, 0x06070405, 0x0a0b0809, 0x0e0f0c0d, 0x12131011,
            0x16171415, 0x1a1b1819, 0x1e1f1c1d},
    [29] = {0x40600020, 0xc0e080a0, 0x41610121, 0xc1e181a1, 0x42620222,
            0xc2e282a2, 0x43630323, 0xc3e383a3},
    [30] = {0x80c00040, 0x81c10141, 0x82c20242, 0x83c30343, 0x84c40444,
            0x85c50545, 0x86c60646, 0x87c70747},
    [31] = {0x01810080, 0x03830282, 0x05850484, 0x07870686, 0x09890888,
            0x0b8b0a8a, 0x0d8d0c8c, 0x0f8f0e8e},
};

bool test_main(void) {
  // Initialise the entropy source and ACC
  dif_acc_t acc;
  CHECK_STATUS_OK(entropy_testutils_auto_mode_init());
  CHECK_DIF_OK(dif_acc_init_from_dt(kDtAcc, &acc));

  // Load the Smoke Test App
  CHECK_STATUS_OK(acc_testutils_load_app(&acc, kAppSmokeTest));
  CHECK_STATUS_OK(acc_testutils_execute(&acc));
  CHECK_STATUS_OK(acc_testutils_wait_for_done(&acc, kDifAccErrBitsNoError));

  // Check the instruction count is what was expected.
  uint32_t instruction_count;
  CHECK_DIF_OK(dif_acc_get_insn_cnt(&acc, &instruction_count));
  CHECK(kExpectedInstrCount == instruction_count,
        "Expected ACC to execute %d instructions, but it executed %d",
        kExpectedInstrCount, instruction_count);

  // Check the GPR registers of interest hold the expected values.
  uint32_t gpr_state[kNumExpectedGprs];
  CHECK_STATUS_OK(acc_testutils_read_data(&acc, sizeof(kExpectedGprs),
                                          kGprState, &gpr_state));
  CHECK_ARRAYS_EQ(gpr_state, kExpectedGprs, kNumExpectedGprs);

  // Check the WDR registers of interest hold the expected values.
  uint32_t wdr_state[kNumExpectedWdrs][8];
  CHECK_STATUS_OK(acc_testutils_read_data(&acc, sizeof(kExpectedWdrs),
                                          kWdrState, &wdr_state));

  for (size_t i = 0; i < kNumExpectedWdrs; ++i) {
    CHECK_ARRAYS_EQ(wdr_state[i], kExpectedWdrs[i], 8,
                    "w%d didn't match the expected value.", i);
  }
  return true;
}
