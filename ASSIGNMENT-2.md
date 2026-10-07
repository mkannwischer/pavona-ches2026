# Assignment 2: Add vector rotation to ACC

Goal: add a vector rotate instruction, `bn.rotv`, to the ACC ISA description and instruction set simulator (ISS).

## The instruction

```
bn.rotv<type> <wrd>, <wrs1>, <rot_bits>
```

`bn.rotv` rotates each element of `wrs1` right by `rot_bits` bits and writes the result to `wrd`.
Bits do not cross element boundaries, and flags are unchanged.

| `<type>` | Elements | Legal `rot_bits` |
|----------|----------|------------------|
| `.16h` | 16 × 16 bits | 0 to 15 |
| `.8s` | 8 × 32 bits | 0 to 31 |
| `.4d` | 4 × 64 bits | 0 to 63 |
| `.2q` | 2 × 128 bits | 0 to 127 |

`rot_bits = 0` copies the source.
A `rot_bits` that is not smaller than the element width raises `ILLEGAL_INSN`.
Like the other vector instructions, `bn.rotv` is only available when the PQC extension is enabled.

`bn.rotv` uses the same major opcode as [`bn.trn`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bntrn) and is distinguished from it by `funct2` (bits 13:12).
Like the immediate of [`bn.rshi`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnrshi), `rot_bits` is split: bits 6 to 1 go into bits 30:25 and bit 0 goes into bit 14.

| 31 | 30:25 | 24:23 | 22:20 | 19:15 | 14 | 13:12 | 11:7 | 6:0 |
|----|-------|-------|-------|-------|----|-------|------|-----|
| `0` | `rot_bits[6:1]` | `type` | unused | `wrs1` | `rot_bits[0]` | `11` | `wrd` | `custom6` (`1011111`) |

`type` is 0 for `.16h`, 1 for `.8s`, 2 for `.4d` and 3 for `.2q`.

## Task

Each of these files has a commented-out skeleton for `bn.rotv`, marked `TODO (Assignment 2)`:

- [`hw/ip/acc/data/enc-schemes.yml`](./hw/ip/acc/data/enc-schemes.yml): the encoding scheme
- [`hw/ip/acc/data/bignum-insns.yml`](./hw/ip/acc/data/bignum-insns.yml): the instruction, its operands and its encoding
- [`hw/ip/acc/dv/accsim/sim/insn.py`](./hw/ip/acc/dv/accsim/sim/insn.py): the ISS model

Uncomment the skeletons and fill in the `TODO`s, in this order.
The assembler and the ISS read the instruction from the YAML files, and `insn.py` fails to load until `bn.rotv` is there.
[`bn.shv`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnshv) and [`bn.trn`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bntrn) are good examples in all three files.

Your model is done when the tests in [`sw/acc/crypto/tests/bnrotv/`](./sw/acc/crypto/tests/bnrotv/) pass:

```sh
./bazelisk.sh test --test_output=errors //sw/acc/crypto/tests/bnrotv:all
```

`bnrotv_test` checks every element width, and `bnrotv_illegal_test` checks that an out-of-range `rot_bits` raises `ILLEGAL_INSN`.
