/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.text

/*
 * ChaCha20 quarter round (RFC 8439 Section 2.1), vectorized.
 *
 * Applies the quarter round in place to (w0, w1, w2, w3) = (a, b, c, d):
 *   a += b; d ^= a; d <<<= 16;
 *   c += d; b ^= c; b <<<= 12;
 *   a += b; d ^= a; d <<<= 8;
 *   c += d; b ^= c; b <<<= 7;
 * Each register holds 8 independent 32-bit lanes, one block per lane.
 *
 * @param[in]  w0: a (state word, 8 lanes)
 * @param[in]  w1: b (state word, 8 lanes)
 * @param[in]  w2: c (state word, 8 lanes)
 * @param[in]  w3: d (state word, 8 lanes)
 * @param[out] w0-w3: a', b', c', d'
 *
 * clobbered registers: w4-w15
 * clobbered flag groups: FG0
 */
.globl quarterround
.type quarterround, @function
quarterround:
  /* TODO (Assignment 1): complete the following
   *
   * Useful instructions:
   *   bn.addv.8s: https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnaddv
   *   bn.xor:     https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnxor
   *   bn.or:      https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnor
   *   bn.shv.8s:  https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnshv
   *
   * Hints:
   *   x <<< n = (x << n) | (x >> (32 - n))
   *   w4-w15 are free to use as scratch.
   *   Leave w16-w31 and the GPRs untouched: chacha20.s keeps its state
   *   and pointers there.
   */

  /* a += b;  d ^= a;  d <<<= 16 */

  /* c += d;  b ^= c;  b <<<= 12 */

  /* a += b;  d ^= a;  d <<<=  8 */

  /* c += d;  b ^= c;  b <<<=  7 */

  ret
