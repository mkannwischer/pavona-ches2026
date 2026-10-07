/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/**
 * Constants and shared scratch buffers for ChaCha20 (RFC 8439).
 */

.data
.balign 32

/* "expand 32-byte k" as four little-endian words, each broadcast across
 * 8 lanes for rows 0-3 of chacha20_state. */
.globl chacha20_sigma_rows
chacha20_sigma_rows:
  .word 0x61707865
  .word 0x61707865
  .word 0x61707865
  .word 0x61707865
  .word 0x61707865
  .word 0x61707865
  .word 0x61707865
  .word 0x61707865

  .word 0x3320646e
  .word 0x3320646e
  .word 0x3320646e
  .word 0x3320646e
  .word 0x3320646e
  .word 0x3320646e
  .word 0x3320646e
  .word 0x3320646e

  .word 0x79622d32
  .word 0x79622d32
  .word 0x79622d32
  .word 0x79622d32
  .word 0x79622d32
  .word 0x79622d32
  .word 0x79622d32
  .word 0x79622d32

  .word 0x6b206574
  .word 0x6b206574
  .word 0x6b206574
  .word 0x6b206574
  .word 0x6b206574
  .word 0x6b206574
  .word 0x6b206574
  .word 0x6b206574

/* Per-lane block counter offsets. */
.globl chacha20_lane_index
chacha20_lane_index:
  .word 0x00000000
  .word 0x00000001
  .word 0x00000002
  .word 0x00000003
  .word 0x00000004
  .word 0x00000005
  .word 0x00000006
  .word 0x00000007

/* Counter increment for each group of 8 blocks. */
.globl chacha20_eight
chacha20_eight:
  .word 0x00000008
  .word 0x00000008
  .word 0x00000008
  .word 0x00000008
  .word 0x00000008
  .word 0x00000008
  .word 0x00000008
  .word 0x00000008

.bss
.balign 32

/* Shared transposed state, rebuilt on each keystream call.
 * Row i at offset 32*i holds 8 copies of word i, except row 12, which
 * holds counter+0 .. counter+7. Reloaded at the start of each group. */
.globl chacha20_state
chacha20_state:
.zero 512

/* Saved x13/x14 for the XOR routines' call to keystream generation. */
.globl chacha20_xor_save
chacha20_xor_save:
.zero 8
