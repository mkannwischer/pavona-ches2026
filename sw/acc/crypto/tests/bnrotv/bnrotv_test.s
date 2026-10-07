/* Copyright zeroRISC Inc. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* Test vector bit rotate instruction. */

.section .text.start

main:
    la          x2, op
    bn.ld       w0, 0(x2)

    bn.rotv.16h w2, w0, 0
    bn.rotv.16h w3, w0, 1
    bn.rotv.16h w4, w0, 8
    bn.rotv.16h w5, w0, 15

    bn.rotv.8s  w6, w0, 16     /* pairwise 16-bit swap within each 32-bit element */
    bn.rotv.8s  w7, w0, 12     /* ChaCha20 ROTL12, expressed as a right rotate */
    bn.rotv.8s  w8, w0, 7      /* ChaCha20 ROTL7 */

    bn.rotv.4d  w9, w0, 28

    bn.rotv.2q  w10, w0, 127

    /* Round trip: rotating right by k and then by (S - k) returns the
       original operand, for every element width. */
    bn.rotv.16h w11, w3, 15
    bn.rotv.8s  w12, w7, 20
    bn.rotv.4d  w13, w9, 36
    bn.rotv.2q  w14, w10, 1

    ecall

.data
.balign 32
op:
    .quad 0x0706050403020100
    .quad 0x0f0e0d0c0b0a0908
    .quad 0x1716151413121110
    .quad 0x1f1e1d1c1b1a1918
