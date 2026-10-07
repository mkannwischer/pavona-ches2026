/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Test keystream and XOR against generated reference outputs.
 * -DCHACHA20_ROTV selects bn.rotv.
 */

#ifdef CHACHA20_ROTV
#define CHACHA20_KEYSTREAM chacha20_keystream_rotv
#define CHACHA20_XOR chacha20_xor_rotv
#else
#define CHACHA20_KEYSTREAM chacha20_keystream
#define CHACHA20_XOR chacha20_xor
#endif

#define NUM_GROUPS 2

.section .text.start

main:
  /* Check that NUM_GROUPS matches the generator's buffer sizes.
   * The generated .exp requires x20 == 0. */
  la    x20, num_groups
  lw    x20, 0(x20)
  addi  x4, x0, NUM_GROUPS
  sub   x20, x4, x20

  la    x10, key
  la    x11, nonce
  la    x12, counter
  lw    x12, 0(x12)
  addi  x13, x0, NUM_GROUPS
  la    x14, ks
  jal   x1, CHACHA20_KEYSTREAM

  la    x10, key
  la    x11, nonce
  la    x12, counter
  lw    x12, 0(x12)
  addi  x13, x0, NUM_GROUPS
  la    x14, ct
  la    x15, pt
  jal   x1, CHACHA20_XOR

  ecall

.data

.balign 32
.weak key
key:
  .zero 32

.balign 32
.weak nonce
nonce:
  .zero 32

.balign 4
.weak counter
counter:
  .zero 4

.balign 32
.weak pt
pt:
  .zero (NUM_GROUPS * 512)

.balign 32
.globl ks
ks:
  .zero (NUM_GROUPS * 512)

.balign 32
.globl ct
ct:
  .zero (NUM_GROUPS * 512)
