// Copyright MPI-SP.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module bnrotv_v1
  import acc_pkg::*;
(
  input logic [WLEN-1:0]  A,
  input alu_rotv_type_t   rotv_type,
  input logic [6:0]       rotv_amt,
  output logic [WLEN-1:0] res
);
  logic [WLEN/16-1:0] rotv_op_16h [16];
  logic [WLEN/8-1:0]  rotv_op_8s  [8];
  logic [WLEN/4-1:0]  rotv_op_4d  [4];
  logic [WLEN/2-1:0]  rotv_op_2q  [2];

  for (genvar i=0; i<16; ++i) begin : g_rotv_16h
    assign rotv_op_16h[i] = A[i*16+:16];
  end

  for (genvar i=0; i<8; ++i) begin : g_rotv_8s
    assign rotv_op_8s[i] = A[i*32+:32];
  end

  for (genvar i=0; i<4; ++i) begin : g_rotv_4d
    assign rotv_op_4d[i] = A[i*64+:64];
  end

  for (genvar i=0; i<2; ++i) begin : g_rotv_2q
    assign rotv_op_2q[i] = A[i*128+:128];
  end

  // TODO (Assignment 4): rotate each element of A right by rotv_amt bits and
  // write the result to res.
  //
  // Hints:
  //   The elements are already split out into rotv_op_16h to rotv_op_2q.
  //   Only the low log2(width) bits of rotv_amt are meaningful for a given
  //   width. Larger amounts raise ILLEGAL_INSN in the decoder and never reach
  //   this module.
  //   Width mismatches are errors in the Verilator build; use a sized cast
  //   such as 16'(...) where an expression is wider than its destination.
  always_comb begin
    res = A;
    case (rotv_type)
      rotv_16h: begin
        // TODO: rotate the 16 elements of rotv_op_16h.
      end

      rotv_8s: begin
        // TODO: rotate the 8 elements of rotv_op_8s.
      end

      rotv_4d: begin
        // TODO: rotate the 4 elements of rotv_op_4d.
      end

      rotv_2q: begin
        // TODO: rotate the 2 elements of rotv_op_2q.
      end

      default: ;
    endcase
  end
endmodule
