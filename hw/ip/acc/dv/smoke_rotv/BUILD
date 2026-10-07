# Copyright lowRISC contributors (OpenTitan project).
# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("@rules_shell//shell:sh_test.bzl", "sh_test")
load("//rules:acc.bzl", "acc_binary")
load("//rules:fusesoc.bzl", "fusesoc_build")

package(default_visibility = ["//visibility:public"])

MODE = {
    "v1": ["--flag", "bnrotv"],
}

acc_binary(
    name = "smoke_test",
    srcs = [
        "smoke_test.s",
    ],
    args = [
    ],
)

[
    fusesoc_build(
        name = "verilator_acc_" + version,
        srcs = [
            "//hw:dpi_files",
            "//hw:dv_common_files",
            "//hw:rtl_files",
            "//hw:verilator_files",
            "//hw/ip/acc:sim_cc_files",
            "//hw/ip/acc:sim_cores",
            "//hw/ip/acc:sim_dpi_files",
            "//hw/ip/acc:sim_lint_files",
            "//hw/ip/acc:sim_rtl_files",
        ],
        cores = [
            "//hw:cores",
        ],
        data = ["//hw/ip/acc:rtl_files"],
        make_options = "//hw:make_options",
        output_groups = {
            "binary": [
                "lowrisc_ip_acc_top_sim_0.1/sim-verilator/Vacc_top_sim",
            ],
        },
        pre_system_flags = ["--flag", "pqc"] + flags + [
            "--mapping=lowrisc:prim_generic:all:0.1",
        ],
        systems = ["lowrisc:ip:acc_top_sim"],
        tags = [
            "manual",
            "verilator",
        ],
        target = "sim",
        verilator_options = "//hw:verilator_options",
    )
    for version, flags in MODE.items()
]

[
    filegroup(
        name = "verilator_acc_bin_" + version,
        srcs = [":verilator_acc_" + version],
        output_group = "binary",
    )
    for version in MODE.keys()
]

filegroup(
    name = "smoke_test_elf",
    srcs = [":smoke_test"],
    output_group = "elf",
)

[
    sh_test(
        name = "run_smoke_test_" + version,
        size = "small",
        srcs = ["//hw/ip/acc/util:run_smoke_test.sh"],
        args = [
            "$(rootpath :verilator_acc_bin_{})".format(version),
            "$(rootpath :smoke_test_elf)",
            "$(rootpath smoke_expected.txt)",
            "$(rootpath //hw/ip/acc/dv/accsim:stepped)",
        ],
        data = [
            "smoke_expected.txt",
            ":smoke_test_elf",
            ":verilator_acc_bin_" + version,
            "//hw/ip/acc/dv/accsim:stepped",
        ],
        tags = [
            "manual",
            "verilator",
        ],
    )
    for version in MODE.keys()
]

# Runs the smoke test against every rotator version.
test_suite(
    name = "run_smoke_test",
    tags = [
        "manual",
        "verilator",
    ],
    tests = [":run_smoke_test_" + version for version in MODE.keys()],
)
