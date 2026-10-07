/* Copyright zeroRISC Inc. */
/* Licensed under the Apache License, Version 2.0, see LICENSE for details. */
/* SPDX-License-Identifier: Apache-2.0 */

/* A rotate amount that is not smaller than the element width is illegal:
   bn.rotv.16h rotates 16-bit elements, so a rotate amount of 16 is out of
   range even though the encoding field itself has room for it. */

.section .text.start

main:
    bn.rotv.16h w1, w0, 16
    ecall
