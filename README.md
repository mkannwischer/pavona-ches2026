![Pavona logo](./doc/pavona-logo-lockup.svg#no-bg)

# Cryptographic Hardware-Software Co-Design using Pavona

This repository holds the hands-on material for the CHES 2026 tutorial "Cryptographic Hardware-Software Co-Design using the Pavona Open-Source Silicon Distribution".
It is a snapshot of [Pavona](https://github.com/pavona/pavona) with the tutorial exercises added on top.

| Assignment | Goal |
|------------|------|
| [0: Getting started](./ASSIGNMENT-0.md) | Run a first test on the Verilated chip |
| [1: ChaCha20 on ACC](./ASSIGNMENT-1.md) | Write the ChaCha20 quarter round in ACC assembly |
| [2: Vector rotation](./ASSIGNMENT-2.md) | Add `bn.rotv` to the ACC instruction set simulator |
| [3: ChaCha20 with `bn.rotv`](./ASSIGNMENT-3.md) | Use `bn.rotv` in ChaCha20 and measure the speedup |
| [4: `bn.rotv` in RTL](./ASSIGNMENT-4.md) (advanced) | Implement `bn.rotv` in the ACC RTL |

For everything else, see the [Pavona documentation](https://docs.pavona.org).

## License

Unless otherwise stated, everything in this repository is covered by the [Apache License, Version 2.0](./LICENSE).
