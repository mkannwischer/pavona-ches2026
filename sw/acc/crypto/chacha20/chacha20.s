/* Copyright zeroRISC Inc & MPI-SP. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

.text

#ifdef CHACHA20_ROTV
#define CHACHA20_KEYSTREAM chacha20_keystream_rotv
#define CHACHA20_XOR chacha20_xor_rotv
#define QUARTERROUND quarterround_rotv
#else
#define CHACHA20_KEYSTREAM chacha20_keystream
#define CHACHA20_XOR chacha20_xor
#define QUARTERROUND quarterround
#endif

/*
 * ChaCha20 keystream generator (RFC 8439).
 *
 * Generates num_groups * 512 bytes, processing 8 blocks at a time.
 * During rounds, w(16+i) holds state word i, one block per lane.
 * Quarter rounds use w0-w3, plus w4 as scratch in the non-rotv build.
 *
 * Blocks share a key and nonce and use consecutive 32-bit counters.
 * The counter must not wrap during a call.
 *
 * @param[in]  x10: dmem pointer to the 32-byte key (32-byte aligned)
 * @param[in]  x11: dmem pointer to the 12-byte nonce (32-byte aligned;
 *                  32 bytes are read, only the first 12 matter)
 * @param[in]  x12: initial 32-bit block counter
 * @param[in]  x13: number of 8-block (512-byte) groups to generate, >= 1
 * @param[in]  x14: dmem pointer to the output keystream buffer
 *                  (num_groups * 512 bytes, 32-byte aligned)
 *
 * clobbered registers: x4, x5, x13, x14, w0-w31
 * clobbered flag groups: FG0
 *
 * Control flow and memory accesses depend only on num_groups.
 */
.globl CHACHA20_KEYSTREAM
.type CHACHA20_KEYSTREAM, @function
CHACHA20_KEYSTREAM:
  /* Avoid underflow when x13 is zero. */
  beq     x13, x0, _chacha20_keystream_ret

  /* Shared transposed state. */
  la      x5, chacha20_state

  /* Rows 0-3: "expand 32-byte k", broadcast across 8 lanes. */
  la      x4, chacha20_sigma_rows
  bn.ld   w0, 0(x4)
  bn.ld   w1, 32(x4)
  bn.ld   w2, 64(x4)
  bn.ld   w3, 96(x4)
  bn.sd   w0, 0(x5)
  bn.sd   w1, 32(x5)
  bn.sd   w2, 64(x5)
  bn.sd   w3, 96(x5)

  /* Rows 4-11: broadcast each key word with a bn.trn tree. */
  bn.ld       w4, 0(x10)

  bn.trn1.8s  w5, w4, w4    /* w5 = [k0 k0 k2 k2 k4 k4 k6 k6] */
  bn.trn2.8s  w6, w4, w4    /* w6 = [k1 k1 k3 k3 k5 k5 k7 k7] */

  bn.trn1.4d  w7,  w5, w5   /* w7  = k0,k0,k0,k0,k4,k4,k4,k4 */
  bn.trn2.4d  w8,  w5, w5   /* w8  = k2,k2,k2,k2,k6,k6,k6,k6 */
  bn.trn1.4d  w9,  w6, w6   /* w9  = k1,k1,k1,k1,k5,k5,k5,k5 */
  bn.trn2.4d  w10, w6, w6   /* w10 = k3,k3,k3,k3,k7,k7,k7,k7 */

  bn.trn1.2q  w11, w7,  w7  /* w11 = k0 broadcast */
  bn.trn2.2q  w12, w7,  w7  /* w12 = k4 broadcast */
  bn.trn1.2q  w13, w8,  w8  /* w13 = k2 broadcast */
  bn.trn2.2q  w14, w8,  w8  /* w14 = k6 broadcast */
  bn.trn1.2q  w15, w9,  w9  /* w15 = k1 broadcast */
  bn.trn2.2q  w16, w9,  w9  /* w16 = k5 broadcast */
  bn.trn1.2q  w17, w10, w10 /* w17 = k3 broadcast */
  bn.trn2.2q  w18, w10, w10 /* w18 = k7 broadcast */

  bn.sd  w11, 128(x5)  /* row 4  = k0 */
  bn.sd  w15, 160(x5)  /* row 5  = k1 */
  bn.sd  w13, 192(x5)  /* row 6  = k2 */
  bn.sd  w17, 224(x5)  /* row 7  = k3 */
  bn.sd  w12, 256(x5)  /* row 8  = k4 */
  bn.sd  w16, 288(x5)  /* row 9  = k5 */
  bn.sd  w14, 320(x5)  /* row 10 = k6 */
  bn.sd  w18, 352(x5)  /* row 11 = k7 */

  /* Row 12: counter + lane index. Transfer x12 through dmem, then
   * broadcast lane 0. Zero the whole row first so bn.ld sees valid
   * integrity bits in all lanes. */
  la          x4, chacha20_lane_index
  bn.ld       w20, 0(x4)

  bn.xor      w19, w19, w19
  bn.sd       w19, 384(x5)
  sw          x12, 384(x5)
  bn.ld       w19, 384(x5)
  bn.trn1.2q  w19, w19, w19
  bn.trn1.4d  w19, w19, w19
  bn.trn1.8s  w19, w19, w19
  bn.addv.8s  w19, w19, w20
  bn.sd       w19, 384(x5)

  /* Rows 13-15: broadcast the three nonce words. */
  bn.ld       w21, 0(x11)

  bn.trn1.2q  w21, w21, w21   /* w21 = n0,n1,n2,-, n0,n1,n2,- */
  bn.trn1.4d  w22, w21, w21   /* w22 = n0,n1,n0,n1,n0,n1,n0,n1 */
  bn.trn2.4d  w23, w21, w21   /* w23 = n2,-, n2,-, n2,-, n2,- */

  bn.trn1.8s  w24, w22, w22   /* w24 = n0 broadcast */
  bn.trn2.8s  w25, w22, w22   /* w25 = n1 broadcast */
  bn.trn1.8s  w26, w23, w23   /* w26 = n2 broadcast */

  bn.sd  w24, 416(x5)   /* row 13 = n0 */
  bn.sd  w25, 448(x5)   /* row 14 = n1 */
  bn.sd  w26, 480(x5)   /* row 15 = n2 */

  /* Counter increment for each group. */
  la      x4, chacha20_eight

_chacha20_keystream_group_loop:
  /* Load state word i into w(16+i); w0-w4 are reserved for quarterround. */
  bn.ld      w16, 0(x5)
  bn.ld      w17, 32(x5)
  bn.ld      w18, 64(x5)
  bn.ld      w19, 96(x5)
  bn.ld      w20, 128(x5)
  bn.ld      w21, 160(x5)
  bn.ld      w22, 192(x5)
  bn.ld      w23, 224(x5)
  bn.ld      w24, 256(x5)
  bn.ld      w25, 288(x5)
  bn.ld      w26, 320(x5)
  bn.ld      w27, 352(x5)
  bn.ld      w28, 384(x5)
  bn.ld      w29, 416(x5)
  bn.ld      w30, 448(x5)
  bn.ld      w31, 480(x5)

  /* 20 rounds. Each quarter round gathers into w0-w3, calls QUARTERROUND,
   * then copies back: 9 instructions per call, 72 per double round. */
  loopi 10, 72
    /* Column round: QR(0,4,8,12), QR(1,5,9,13), QR(2,6,10,14), QR(3,7,11,15). */
    bn.mov w0, w16
    bn.mov w1, w20
    bn.mov w2, w24
    bn.mov w3, w28
    jal    x1, QUARTERROUND
    bn.mov w16, w0
    bn.mov w20, w1
    bn.mov w24, w2
    bn.mov w28, w3

    bn.mov w0, w17
    bn.mov w1, w21
    bn.mov w2, w25
    bn.mov w3, w29
    jal    x1, QUARTERROUND
    bn.mov w17, w0
    bn.mov w21, w1
    bn.mov w25, w2
    bn.mov w29, w3

    bn.mov w0, w18
    bn.mov w1, w22
    bn.mov w2, w26
    bn.mov w3, w30
    jal    x1, QUARTERROUND
    bn.mov w18, w0
    bn.mov w22, w1
    bn.mov w26, w2
    bn.mov w30, w3

    bn.mov w0, w19
    bn.mov w1, w23
    bn.mov w2, w27
    bn.mov w3, w31
    jal    x1, QUARTERROUND
    bn.mov w19, w0
    bn.mov w23, w1
    bn.mov w27, w2
    bn.mov w31, w3

    /* Diagonal round: QR(0,5,10,15), QR(1,6,11,12), QR(2,7,8,13), QR(3,4,9,14). */
    bn.mov w0, w16
    bn.mov w1, w21
    bn.mov w2, w26
    bn.mov w3, w31
    jal    x1, QUARTERROUND
    bn.mov w16, w0
    bn.mov w21, w1
    bn.mov w26, w2
    bn.mov w31, w3

    bn.mov w0, w17
    bn.mov w1, w22
    bn.mov w2, w27
    bn.mov w3, w28
    jal    x1, QUARTERROUND
    bn.mov w17, w0
    bn.mov w22, w1
    bn.mov w27, w2
    bn.mov w28, w3

    bn.mov w0, w18
    bn.mov w1, w23
    bn.mov w2, w24
    bn.mov w3, w29
    jal    x1, QUARTERROUND
    bn.mov w18, w0
    bn.mov w23, w1
    bn.mov w24, w2
    bn.mov w29, w3

    bn.mov w0, w19
    bn.mov w1, w20
    bn.mov w2, w25
    bn.mov w3, w30
    jal    x1, QUARTERROUND
    bn.mov w19, w0
    bn.mov w20, w1
    bn.mov w25, w2
    bn.mov w30, w3
  endloop

  /* Add the original state to w16-w31, mod 2^32 per lane. */
  bn.ld      w0, 0(x5)
  bn.ld      w1, 32(x5)
  bn.ld      w2, 64(x5)
  bn.ld      w3, 96(x5)
  bn.ld      w4, 128(x5)
  bn.ld      w5, 160(x5)
  bn.ld      w6, 192(x5)
  bn.ld      w7, 224(x5)
  bn.ld      w8, 256(x5)
  bn.ld      w9, 288(x5)
  bn.ld      w10, 320(x5)
  bn.ld      w11, 352(x5)
  bn.ld      w12, 384(x5)
  bn.ld      w13, 416(x5)
  bn.ld      w14, 448(x5)
  bn.ld      w15, 480(x5)

  bn.addv.8s w16, w16, w0
  bn.addv.8s w17, w17, w1
  bn.addv.8s w18, w18, w2
  bn.addv.8s w19, w19, w3
  bn.addv.8s w20, w20, w4
  bn.addv.8s w21, w21, w5
  bn.addv.8s w22, w22, w6
  bn.addv.8s w23, w23, w7
  bn.addv.8s w24, w24, w8
  bn.addv.8s w25, w25, w9
  bn.addv.8s w26, w26, w10
  bn.addv.8s w27, w27, w11
  bn.addv.8s w28, w28, w12
  bn.addv.8s w29, w29, w13
  bn.addv.8s w30, w30, w14
  bn.addv.8s w31, w31, w15

  /* Transpose words 0-7 of each block (now in w16..w23) into w0..w7, so
   * that w(0+j) holds the first 32 bytes of block j's keystream. */
  /* Stage 1: .8s */
  bn.trn1.8s w0, w16, w17
  bn.trn2.8s w1, w16, w17
  bn.trn1.8s w2, w18, w19
  bn.trn2.8s w3, w18, w19
  bn.trn1.8s w4, w20, w21
  bn.trn2.8s w5, w20, w21
  bn.trn1.8s w6, w22, w23
  bn.trn2.8s w7, w22, w23

  /* Stage 2: .4d */
  bn.trn1.4d w16, w0, w2
  bn.trn2.4d w18, w0, w2
  bn.trn1.4d w17, w1, w3
  bn.trn2.4d w19, w1, w3
  bn.trn1.4d w20, w4, w6
  bn.trn2.4d w22, w4, w6
  bn.trn1.4d w21, w5, w7
  bn.trn2.4d w23, w5, w7

  /* Stage 3: .2q */
  bn.trn1.2q w0, w16, w20
  bn.trn2.2q w4, w16, w20
  bn.trn1.2q w1, w17, w21
  bn.trn2.2q w5, w17, w21
  bn.trn1.2q w2, w18, w22
  bn.trn2.2q w6, w18, w22
  bn.trn1.2q w3, w19, w23
  bn.trn2.2q w7, w19, w23

  bn.sd      w0, 0(x14)
  bn.sd      w1, 64(x14)
  bn.sd      w2, 128(x14)
  bn.sd      w3, 192(x14)
  bn.sd      w4, 256(x14)
  bn.sd      w5, 320(x14)
  bn.sd      w6, 384(x14)
  bn.sd      w7, 448(x14)

  /* Transpose words 8-15 of each block (now in w24..w31) into w8..w15, so
   * that w(8+j) holds the second 32 bytes of block j's keystream. */
  /* Stage 1: .8s */
  bn.trn1.8s w8, w24, w25
  bn.trn2.8s w9, w24, w25
  bn.trn1.8s w10, w26, w27
  bn.trn2.8s w11, w26, w27
  bn.trn1.8s w12, w28, w29
  bn.trn2.8s w13, w28, w29
  bn.trn1.8s w14, w30, w31
  bn.trn2.8s w15, w30, w31

  /* Stage 2: .4d */
  bn.trn1.4d w24, w8, w10
  bn.trn2.4d w26, w8, w10
  bn.trn1.4d w25, w9, w11
  bn.trn2.4d w27, w9, w11
  bn.trn1.4d w28, w12, w14
  bn.trn2.4d w30, w12, w14
  bn.trn1.4d w29, w13, w15
  bn.trn2.4d w31, w13, w15

  /* Stage 3: .2q */
  bn.trn1.2q w8, w24, w28
  bn.trn2.2q w12, w24, w28
  bn.trn1.2q w9, w25, w29
  bn.trn2.2q w13, w25, w29
  bn.trn1.2q w10, w26, w30
  bn.trn2.2q w14, w26, w30
  bn.trn1.2q w11, w27, w31
  bn.trn2.2q w15, w27, w31

  bn.sd      w8, 32(x14)
  bn.sd      w9, 96(x14)
  bn.sd      w10, 160(x14)
  bn.sd      w11, 224(x14)
  bn.sd      w12, 288(x14)
  bn.sd      w13, 352(x14)
  bn.sd      w14, 416(x14)
  bn.sd      w15, 480(x14)

  /* Advance counters by 8 blocks. */
  bn.ld      w1, 0(x4)
  bn.ld      w0, 384(x5)
  bn.addv.8s w0, w0, w1
  bn.sd      w0, 384(x5)

  addi x14, x14, 512
  addi x13, x13, -1
  bne  x13, x0, _chacha20_keystream_group_loop

_chacha20_keystream_ret:
  ret

/*
 * ChaCha20 encryption/decryption (RFC 8439).
 *
 * Generates num_groups * 512 bytes of keystream in the output buffer,
 * then XORs in the input. Input and output buffers must not overlap.
 *
 * @param[in]  x10: dmem pointer to the 32-byte key (32-byte aligned)
 * @param[in]  x11: dmem pointer to the 12-byte nonce (32-byte aligned;
 *                  32 bytes are read, only the first 12 matter)
 * @param[in]  x12: initial 32-bit block counter
 * @param[in]  x13: number of 8-block (512-byte) groups to process, >= 1
 * @param[in]  x14: dmem pointer to the output buffer
 *                  (num_groups * 512 bytes, 32-byte aligned)
 * @param[in]  x15: dmem pointer to the input buffer (num_groups * 512
 *                  bytes, 32-byte aligned; must not overlap x14)
 *
 * clobbered registers: x4, x5, x13-x15, w0-w31
 * clobbered flag groups: FG0
 *
 * Control flow and memory accesses depend only on num_groups.
 */
.globl CHACHA20_XOR
.type CHACHA20_XOR, @function
CHACHA20_XOR:
  /* A zero iteration count would cause a LOOP error. */
  beq x13, x0, _chacha20_xor_ret

  /* Preserve the group count and output pointer across keystream generation. */
  la  x4, chacha20_xor_save
  sw  x13, 0(x4)
  sw  x14, 4(x4)

  jal x1, CHACHA20_KEYSTREAM

  la  x4, chacha20_xor_save
  lw  x13, 0(x4)
  lw  x14, 4(x4)

  /* 16 WLEN-sized chunks per group. */
  slli x4, x13, 4

  loop x4, 4
    bn.ld  w0, 0(x15++)
    bn.ld  w1, 0(x14)
    bn.xor w0, w0, w1
    bn.sd  w0, 0(x14++)
  endloop

_chacha20_xor_ret:
  ret
