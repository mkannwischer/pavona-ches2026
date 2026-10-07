/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * RFC 8439 Section 2.1.1 quarter-round test vector in all 8 lanes.
 * Build with -DCHACHA20_ROTV for the bn.rotv variant.
 */

#ifdef CHACHA20_ROTV
#define QUARTERROUND quarterround_rotv
#else
#define QUARTERROUND quarterround
#endif

.section .text.start

main:
  la    x2, op
  bn.ld w0, 0(x2)
  bn.ld w1, 32(x2)
  bn.ld w2, 64(x2)
  bn.ld w3, 96(x2)

  jal   x1, QUARTERROUND

  ecall

.data
.balign 32
op:
  /* a */
  .word 0x11111111
  .word 0x11111111
  .word 0x11111111
  .word 0x11111111
  .word 0x11111111
  .word 0x11111111
  .word 0x11111111
  .word 0x11111111

  /* b */
  .word 0x01020304
  .word 0x01020304
  .word 0x01020304
  .word 0x01020304
  .word 0x01020304
  .word 0x01020304
  .word 0x01020304
  .word 0x01020304

  /* c */
  .word 0x9b8d6f43
  .word 0x9b8d6f43
  .word 0x9b8d6f43
  .word 0x9b8d6f43
  .word 0x9b8d6f43
  .word 0x9b8d6f43
  .word 0x9b8d6f43
  .word 0x9b8d6f43

  /* d */
  .word 0x01234567
  .word 0x01234567
  .word 0x01234567
  .word 0x01234567
  .word 0x01234567
  .word 0x01234567
  .word 0x01234567
  .word 0x01234567
