# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@rules_python//python:defs.bzl", "py_binary")
load("@ot_python_deps//:requirements.bzl", "requirement")
load("//rules:acc.bzl", "acc_sim_test", "acc_autogen_sim_test")

package(default_visibility = ["//visibility:public"])

NTESTS = 10
STATS = True

py_binary(
    name = "chacha20_testgen",
    srcs = ["chacha20_testgen.py"],
    imports = [
        "../../../../../hw/ip/acc/util",
    ],
    deps = [
        "//hw/ip/acc/util/shared:testgen",
        requirement("pycryptodome"),
    ],
)

# (name infix, copts, chacha20-package deps) for each implementation.
VARIANTS = [
    ("", [], ["chacha20", "quarterround"]),
    ("rotv_", ["-DCHACHA20_ROTV"], ["chacha20_rotv", "quarterround_rotv"]),
]

[
    acc_autogen_sim_test(
        name = "chacha20_%stest%d" % (infix, i),
        srcs = ["chacha20_test.s"],
        copts = copts,
        pqc = True,
        seed = i,
        stats = STATS,
        testgen = ":chacha20_testgen",
        deps = ["//sw/acc/crypto/chacha20:" + d for d in deps] + [
            "//sw/acc/crypto/chacha20:consts",
        ],
    )
    for infix, copts, deps in VARIANTS
    for i in range(NTESTS)
]

# (group count, label). Explicit padding keeps target names sorted;
# Starlark's % operator has no width modifiers.
BENCH_GROUPS = [
    (1, "01"),
    (2, "02"),
    (8, "08"),
    (16, "16"),
]

# Cycle counts by message size for bench/acc/{collect_stats.sh,analyze_stats.py}.
# One seed per size; cycle counts do not depend on input values.
[
    acc_autogen_sim_test(
        name = "chacha20_%s%s_g%s_test0" % (infix, routine, label),
        srcs = ["chacha20_bench_test.s"],
        copts = copts + ["-DNUM_GROUPS=%d" % n] + (["-DBENCH_XOR"] if routine == "xor" else []),
        pqc = True,
        seed = 0,
        stats = STATS,
        testgen = ":chacha20_testgen",
        testgen_args = ["--num-groups", str(n), "--routine", routine],
        deps = ["//sw/acc/crypto/chacha20:" + d for d in deps] + [
            "//sw/acc/crypto/chacha20:consts",
        ],
    )
    for infix, copts, deps in VARIANTS
    for routine in ["keystream", "xor"]
    for n, label in BENCH_GROUPS
]

[
    acc_sim_test(
        name = "chacha20_kat_%stest" % infix,
        srcs = ["chacha20_kat_test.s"],
        copts = copts,
        dexp = "chacha20_kat_test.dexp",
        pqc = True,
        deps = ["//sw/acc/crypto/chacha20:" + d for d in deps] + [
            "//sw/acc/crypto/chacha20:consts",
        ],
    )
    for infix, copts, deps in VARIANTS
]

acc_sim_test(
    name = "quarterround_test",
    srcs = ["quarterround_test.s"],
    exp = "quarterround_test.exp",
    pqc = True,
    deps = [
        "//sw/acc/crypto/chacha20:quarterround",
    ],
)

acc_sim_test(
    name = "quarterround_rotv_test",
    srcs = ["quarterround_test.s"],
    copts = ["-DCHACHA20_ROTV"],
    exp = "quarterround_test.exp",
    pqc = True,
    deps = [
        "//sw/acc/crypto/chacha20:quarterround_rotv",
    ],
)
