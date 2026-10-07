/* Copyright lowRISC contributors (OpenTitan project). */
/* Copyright zeroRISC Inc. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

# bn.rotv-specific smoke test, runs various instructions which are expected to
# produce the final register state seen in smoke_expected.txt

.section .text.start

la          x2, rotv_value
bn.ld       w0, 0(x2)

# Rotate 16-bit elements in place.
bn.rotv.16h w31, w0, 1
bn.rotv.16h w30, w0, 2
bn.rotv.16h w29, w0, 3
bn.rotv.16h w28, w0, 8   # pairwise byte swap
bn.rotv.16h w27, w0, 9
bn.rotv.16h w26, w0, 13
bn.rotv.16h w25, w0, 14
bn.rotv.16h w24, w0, 15

# Rotate 32-bit elements in place.
bn.rotv.8s w23, w0, 1
bn.rotv.8s w22, w0, 2
bn.rotv.8s w21, w0, 3
bn.rotv.8s w20, w0, 16  # pairwise 16-bit element swap
bn.rotv.8s w19, w0, 17
bn.rotv.8s w18, w0, 29
bn.rotv.8s w17, w0, 30
bn.rotv.8s w16, w0, 31

# Rotate 64-bit elements in place.
bn.rotv.4d w15, w0, 1
bn.rotv.4d w14, w0, 2
bn.rotv.4d w13, w0, 3
bn.rotv.4d w12, w0, 32  # pairwise 32-bit element swap
bn.rotv.4d w11, w0, 33
bn.rotv.4d w10, w0, 61
bn.rotv.4d w9, w0, 62
bn.rotv.4d w8, w0, 63

# Rotate 128-bit elements in place.
bn.rotv.2q w7, w0, 1
bn.rotv.2q w6, w0, 2
bn.rotv.2q w5, w0, 3
bn.rotv.2q w4, w0, 64  # pairwise 64-bit element swap
bn.rotv.2q w3, w0, 65
bn.rotv.2q w2, w0, 125
bn.rotv.2q w1, w0, 126
bn.rotv.2q w0, w0, 127

# Clear unused GPR values for deterministic output.
li          x3, 0
li          x4, 0
li          x5, 0
li          x6, 0
li          x7, 0
li          x8, 0
li          x9, 0
li          x10, 0
li          x11, 0
li          x12, 0
li          x13, 0
li          x14, 0
li          x15, 0
li          x16, 0
li          x17, 0
li          x18, 0
li          x19, 0
li          x20, 0
li          x21, 0
li          x22, 0
li          x23, 0
li          x24, 0
li          x25, 0
li          x26, 0
li          x27, 0
li          x28, 0
li          x29, 0
li          x30, 0
li          x31, 0

jal x1, reg_dump
ecall

# This function dumps both the register files
# into gpr_state and wdr_state.
# The registers aren't clobbered by this function.
reg_dump:
  # Dump all the GPRs into gpr_state
  la x1, gpr_state # (using the x1 to hold a temporary value)
  sw x2, 0(x1)

  la  x2, gpr_state
  sw  x3,   4(x2) #  1 * 4
  sw  x4,   8(x2) #  2 * 4
  sw  x5,  12(x2) #  3 * 4
  sw  x6,  16(x2) #  4 * 4
  sw  x7,  20(x2) #  5 * 4
  sw  x8,  24(x2) #  6 * 4
  sw  x9,  28(x2) #  7 * 4
  sw x10,  32(x2) #  8 * 4
  sw x11,  36(x2) #  9 * 4
  sw x12,  40(x2) # 10 * 4
  sw x13,  44(x2) # 11 * 4
  sw x14,  48(x2) # 12 * 4
  sw x15,  52(x2) # 13 * 4
  sw x16,  56(x2) # 14 * 4
  sw x17,  60(x2) # 15 * 4
  sw x18,  64(x2) # 16 * 4
  sw x19,  68(x2) # 17 * 4
  sw x20,  72(x2) # 18 * 4
  sw x21,  76(x2) # 19 * 4
  sw x22,  80(x2) # 20 * 4
  sw x23,  84(x2) # 21 * 4
  sw x24,  88(x2) # 22 * 4
  sw x25,  92(x2) # 23 * 4
  sw x26,  96(x2) # 24 * 4
  sw x27, 100(x2) # 25 * 4
  sw x28, 104(x2) # 26 * 4
  sw x29, 108(x2) # 27 * 4
  sw x30, 112(x2) # 28 * 4
  sw x31, 116(x2) # 29 * 4

  # Dump all the WDRs into wdr_state
  li     x2, 0
  la     x3, wdr_state
  loopi 32, 2
    bn.sid x2++, 0(x3)
    addi   x3, x3, 32
  endloop

  # Restore the value of x2 and x3 to the value they had
  # before this function.
  la x2, gpr_state
  lw x3, 4(x2)
  lw x2, 0(x2)

  ret

.section .data

.balign 32
rotv_value:
  .quad 0x0706050403020100
  .quad 0x0f0e0d0c0b0a0908
  .quad 0x1716151413121110
  .quad 0x1f1e1d1c1b1a1918

.global gpr_state
.balign 32
gpr_state:
  .zero (32 / 4) * 30 # not including x0 and x1

.global wdr_state
.balign 32
wdr_state:
  .zero (256 / 4) * 32
