# Assignment 1: ChaCha20 on ACC

Goal: write the vectorized ChaCha20 quarter round ([RFC 8439](https://www.rfc-editor.org/info/rfc8439/), Section 2.1) in ACC assembly.

## Design

ChaCha20 produces its keystream in blocks of 64 bytes.
Each block is computed from a state of 16 32-bit words: four constants, eight key words, the block counter and three nonce words.
The ACC implementation computes eight blocks with consecutive counters at once, one block per 32-bit lane of the 256-bit wide registers.
A wide register therefore holds the same state word of all eight blocks.

[`sw/acc/crypto/chacha20/`](./sw/acc/crypto/chacha20/) contains:

| File | Contents |
|------|----------|
| [`chacha20.s`](./sw/acc/crypto/chacha20/chacha20.s) | `chacha20_keystream` and `chacha20_xor` |
| [`quarterround.s`](./sw/acc/crypto/chacha20/quarterround.s) | `quarterround`, which you write |
| [`chacha20_consts.s`](./sw/acc/crypto/chacha20/chacha20_consts.s) | Constants and a scratch area for the state in DMEM |

`chacha20_keystream` generates the keystream in groups of eight blocks (512 bytes):

1. Set up the state in DMEM: each state word is broadcast across the eight lanes, and the counter row holds `counter + 0` to `counter + 7`.
2. For each group, load state word `i` into `w(16 + i)`.
3. Run 10 double rounds.
   Each double round is a column round and a diagonal round of four quarter rounds each.
   For each quarter round, copy the four state words into `w0` to `w3`, call `quarterround`, and copy them back.
4. Add the original state and transpose the result with `bn.trn`, so that each block's 64 bytes are contiguous in the output.
5. Advance the counters by eight.

`chacha20_xor` calls `chacha20_keystream` and XORs the keystream into the input.

## Task

On entry to `quarterround`, `w0` to `w3` hold `a`, `b`, `c` and `d`; write the result back to the same registers.
You may use `w4` to `w15` as scratch.
Leave `w16` to `w31` and the GPRs untouched: [`chacha20.s`](./sw/acc/crypto/chacha20/chacha20.s) keeps its state and pointers there.
ACC has no vector rotate; build one from `bn.shv.8s` and `bn.or`.

Useful instructions:

- [`bn.addv`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnaddv): lane-wise addition
- [`bn.xor`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnxor): bitwise XOR
- [`bn.or`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnor): bitwise OR
- [`bn.shv`](https://docs.pavona.org/book/hw/ip/acc/doc/isa.html#bnshv): lane-wise shift

Fill in the `TODO (Assignment 1)` in [`sw/acc/crypto/chacha20/quarterround.s`](./sw/acc/crypto/chacha20/quarterround.s) and run:

```sh
./bazelisk.sh test --test_output=errors //sw/acc/crypto/tests/chacha20:quarterround_test
```

To see every executed instruction, add `trace = True` to the test target in [`sw/acc/crypto/tests/chacha20/BUILD`](./sw/acc/crypto/tests/chacha20/BUILD) and use `--test_output=all`.

## Assignment 1b: Going further

Profile the full cipher in [`sw/acc/crypto/chacha20/chacha20.s`](./sw/acc/crypto/chacha20/chacha20.s):

```sh
./bazelisk.sh test --test_output=all //sw/acc/crypto/tests/chacha20:chacha20_keystream_g16_test0
```

Each `quarterround` call costs ten instructions on top of the quarter round itself: eight register copies, the call and the return.
Make it faster by inlining the quarter round on the state registers `w16` to `w31`, and check that the output does not change:

```sh
./bazelisk.sh test --test_output=errors \
    //sw/acc/crypto/tests/chacha20:chacha20_test0 \
    //sw/acc/crypto/tests/chacha20:chacha20_kat_test
```

## Reference

- [ACC ISA Guide](./hw/ip/acc/doc/isa.md)
- [Writing ACC software](./doc/contributing/sw/acc_sw.md)
