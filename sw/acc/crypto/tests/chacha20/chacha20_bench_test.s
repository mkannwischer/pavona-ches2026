/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Benchmark keystream or XOR across message sizes with
 * bench/acc/collect_stats.sh and bench/acc/analyze_stats.py.
 *
 * NUM_GROUPS must match the test generator's --num-groups.
 * -DCHACHA20_ROTV selects bn.rotv.
 * -DBENCH_XOR checks ct and requires --routine=xor; otherwise checks ks
 * and requires --routine=keystream.
 */

#ifdef CHACHA20_ROTV
#define CHACHA20_KEYSTREAM chacha20_keystream_rotv
#define CHACHA20_XOR chacha20_xor_rotv
#else
#define CHACHA20_KEYSTREAM chacha20_keystream
#define CHACHA20_XOR chacha20_xor
#endif

.section .text.start

main:
  /* NUM_GROUPS/num_groups cross-check via x20; see chacha20_test.s. */
  la    x20, num_groups
  lw    x20, 0(x20)
  addi  x4, x0, NUM_GROUPS
  sub   x20, x4, x20

  la    x10, key
  la    x11, nonce
  la    x12, counter
  lw    x12, 0(x12)
  addi  x13, x0, NUM_GROUPS

#ifdef BENCH_XOR
  la    x14, ct
  la    x15, pt
  jal   x1, CHACHA20_XOR
#else
  la    x14, ks
  jal   x1, CHACHA20_KEYSTREAM
#endif

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

#ifdef BENCH_XOR
.balign 32
.weak pt
pt:
  .zero (NUM_GROUPS * 512)

.balign 32
.globl ct
ct:
  .zero (NUM_GROUPS * 512)
#else
.balign 32
.globl ks
ks:
  .zero (NUM_GROUPS * 512)
#endif
