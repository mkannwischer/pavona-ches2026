# Assignment 3: Accelerate ChaCha20 with `bn.rotv`

Goal: use your `bn.rotv` from [Assignment 2](./ASSIGNMENT-2.md) in the ChaCha20 quarter round and measure the speedup.

## Task

Fill in the `TODO (Assignment 3)` in [`sw/acc/crypto/chacha20/quarterround_rotv.s`](./sw/acc/crypto/chacha20/quarterround_rotv.s): the same quarter round as in [Assignment 1](./ASSIGNMENT-1.md), with a single `bn.rotv.8s` for each rotation.
The `bn.rotv` variant of [`chacha20.s`](./sw/acc/crypto/chacha20/chacha20.s) calls it instead of `quarterround`.
ChaCha20 rotates left and `bn.rotv` rotates right: `x <<< n = x >>> (32 - n)`.

Check that the output does not change:

```sh
./bazelisk.sh test --test_output=errors \
    //sw/acc/crypto/tests/chacha20:quarterround_rotv_test \
    //sw/acc/crypto/tests/chacha20:chacha20_rotv_test0 \
    //sw/acc/crypto/tests/chacha20:chacha20_kat_rotv_test
```

## Measure

Compare the cycle counts of both variants on 8 KiB of keystream:

```sh
./bazelisk.sh test --test_output=all \
    //sw/acc/crypto/tests/chacha20:chacha20_keystream_g16_test0 \
    //sw/acc/crypto/tests/chacha20:chacha20_rotv_keystream_g16_test0
```

Each test reports the cycles for the whole run; divide by 8192 for cycles per byte.
