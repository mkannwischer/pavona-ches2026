# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

load("//rules:acc.bzl", "acc_library")

package(default_visibility = ["//visibility:public"])

acc_library(
    name = "consts",
    srcs = ["chacha20_consts.s"],
)

acc_library(
    name = "quarterround",
    srcs = ["quarterround.s"],
)

acc_library(
    name = "quarterround_rotv",
    srcs = ["quarterround_rotv.s"],
)

acc_library(
    name = "chacha20",
    srcs = ["chacha20.s"],
)

acc_library(
    name = "chacha20_rotv",
    srcs = ["chacha20.s"],
    copts = ["-DCHACHA20_ROTV"],
)
