# Assignment 4: Add `bn.rotv` to the ACC RTL (advanced)

Goal: implement the `bn.rotv` datapath in the ACC RTL.
This builds on [Assignment 2](./ASSIGNMENT-2.md): the tests assemble programs that use `bn.rotv` and check the RTL against your ISS model.

## Task

Decoding is already done.
[`acc_decoder.sv`](./hw/ip/acc/rtl/acc_decoder.sv) and [`acc_predecode.sv`](./hw/ip/acc/rtl/acc_predecode.sv) decode `bn.rotv`, raise `ILLEGAL_INSN` for an out-of-range `rot_bits`, and select `AluOpBignumRotv`.
The bignum ALU in [`acc_alu_bignum.sv`](./hw/ip/acc/rtl/acc_alu_bignum.sv) passes the source register, `rot_bits` and the element width (`alu_rotv_type_t` in [`acc_pkg.sv`](./hw/ip/acc/rtl/acc_pkg.sv)) to the `bnrotv_v1` module and uses its result.

Fill in the `TODO (Assignment 4)` in [`hw/ip/acc/rtl/bn_vec_core/bnrotv_v1.sv`](./hw/ip/acc/rtl/bn_vec_core/bnrotv_v1.sv), which computes `res` from `A`, `rotv_type` and `rotv_amt`.

## Test

Run the RTL in lockstep with the ISS on a program that uses every `bn.rotv` variant:

```sh
./bazelisk.sh test --test_output=errors //hw/ip/acc/dv/smoke_rotv:run_smoke_test
```

The test stops at the first instruction where the RTL and the ISS disagree.
The program is [`hw/ip/acc/dv/smoke_rotv/smoke_test.s`](./hw/ip/acc/dv/smoke_rotv/smoke_test.s).

Then run the same program on the Verilated Egret chip:

```sh
./bazelisk.sh test --test_output=errors //sw/device/tests:acc_rotv_test_sim_verilator_pqc_v1
```

This builds the whole chip and takes a long time.

## Measure area and timing

With Xilinx Vivado installed (see [Install Vivado](./doc/getting_started/install_vivado/README.md)), synthesize the bignum ALU without and with `bn.rotv`.
This step does not need a paid Vivado license.

```sh
./bazelisk.sh run //util:gen_synth -- --run_synthesis --top_module=acc_alu_bignum
./bazelisk.sh run //util:gen_synth -- --run_synthesis --top_module=acc_alu_bignum --flags=bnrotv
```

Then compare the FPGA resources and the maximum frequency of both:

```sh
./bazelisk.sh run //util:gen_synth -- --top_module=acc_alu_bignum
```

## Run on an FPGA

With a CW340 board and Vivado, build a bitstream that includes your RTL and run the same test on it.
Building the bitstream needs a paid Vivado license.

```sh
./bazelisk.sh test --test_output=errors //sw/device/tests:acc_rotv_test_fpga_cw340_pqc_v1_test_rom
```

See [FPGA Setup](./doc/getting_started/setup_fpga.md) for connecting the board.
