# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:acc.bzl", "acc_sim_test")

package(default_visibility = ["//visibility:public"])

acc_sim_test(
    name = "bnrotv_test",
    srcs = ["bnrotv_test.s"],
    exp = "bnrotv_test.exp",
    pqc = True,
)

acc_sim_test(
    name = "bnrotv_illegal_test",
    srcs = ["bnrotv_illegal_test.s"],
    exp = "bnrotv_illegal_test.exp",
    pqc = True,
)
