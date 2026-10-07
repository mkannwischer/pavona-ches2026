# Copyright lowRISC contributors (OpenTitan project).
# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "bitstream",
    testonly = True,
    srcs = select({
        "//hw/bitstream:bitstream_skip": ["//hw/bitstream/universal:none"],
        "//hw/bitstream:bitstream_vivado": ["//hw/bitstream/vivado:fpga_cw340_pqc_test_rom"],
        "//hw/bitstream:bitstream_gcp_splice": ["@bitstreams//:chip_egret_cw340_pqc_bitstream"],
        "//conditions:default": ["@bitstreams//:chip_egret_cw340_pqc_bitstream"],
    }),
    tags = ["manual"],
)

filegroup(
    name = "mmi",
    testonly = True,
    srcs = select({
        "//hw/bitstream:bitstream_skip": ["//hw/bitstream/universal:none"],
        "//hw/bitstream:bitstream_vivado": ["//hw/bitstream/vivado:cw340_pqc_mmi"],
        "//hw/bitstream:bitstream_gcp_splice": ["@bitstreams//:chip_egret_cw340_pqc_mmi"],
        "//conditions:default": ["@bitstreams//:chip_egret_cw340_pqc_mmi"],
    }),
    tags = ["manual"],
)

# PQC bitstream with bn.rotv: _v1 (bnrotv_v1). There is no cached bitstream for it, so it is
# always built locally with Vivado (unless bitstream=skip).
[
    filegroup(
        name = "bitstream" + version,
        testonly = True,
        srcs = select({
            "//hw/bitstream:bitstream_skip": ["//hw/bitstream/universal:none"],
            "//conditions:default": ["//hw/bitstream/vivado:fpga_cw340_pqc{}_test_rom".format(version)],
        }),
        tags = ["manual"],
    )
    for version in ["_v1"]
]

[
    filegroup(
        name = "mmi" + version,
        testonly = True,
        srcs = select({
            "//hw/bitstream:bitstream_skip": ["//hw/bitstream/universal:none"],
            "//conditions:default": ["//hw/bitstream/vivado:cw340_pqc{}_mmi".format(version)],
        }),
        tags = ["manual"],
    )
    for version in ["_v1"]
]
