# Assignment 0: Getting started

Goal: run a first test on the Verilated Egret chip.

Install the dependencies as described in [Pavona 101](./doc/getting_started/README.md), then run:

```sh
./bazelisk.sh test //sw/device/tests:uart_smoketest_sim_verilator
```

The first run builds the Verilated chip model and takes a while.
