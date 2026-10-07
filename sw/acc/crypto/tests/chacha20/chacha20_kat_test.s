/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/*
 * Keystream known-answer test using the RFC 8439 section 2.4.2 parameters.
 * -DCHACHA20_ROTV selects bn.rotv.
 *
 * Regenerate chacha20_kat_test.dexp with pycryptodome:
 *
 *   from Crypto.Cipher import ChaCha20
 *   c = ChaCha20.new(key=bytes(range(32)),
 *                    nonce=bytes.fromhex('000000000000004a00000000'))
 *   c.seek(64)  # start at block counter 1
 *   ks = c.encrypt(bytes(512))
 *   print(''.join(bytes(reversed(ks[i:i + 4])).hex()
 *                 for i in range(0, len(ks), 4)))
 *
 * Reverse bytes within each word for the .dexp format (see write_test_dexp
 * in hw/ip/acc/util/shared/testgen.py).
 * The first 114 bytes match plaintext XOR ciphertext from the RFC's
 * "Sunscreen" example.
 */

#ifdef CHACHA20_ROTV
#define CHACHA20_KEYSTREAM chacha20_keystream_rotv
#else
#define CHACHA20_KEYSTREAM chacha20_keystream
#endif

.section .text.start

main:
  la    x10, key
  la    x11, nonce
  addi  x12, x0, 1
  addi  x13, x0, 1
  la    x14, ks
  jal   x1, CHACHA20_KEYSTREAM

  ecall

.data
.balign 32

.globl key
key:
  .word 0x03020100
  .word 0x07060504
  .word 0x0b0a0908
  .word 0x0f0e0d0c
  .word 0x13121110
  .word 0x17161514
  .word 0x1b1a1918
  .word 0x1f1e1d1c

.globl nonce
nonce:
  .word 0x00000000
  .word 0x4a000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000
  .word 0x00000000

.globl ks
ks:
  .zero 512
