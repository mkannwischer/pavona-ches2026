#!/usr/bin/env python3
# Copyright Ruben Niederhagen and Hoang Nguyen Hien Pham - authors of
# "Improving ML-KEM & ML-DSA on OpenTitan - Efficient Multiplication Vector Instructions for acc"
# (https://eprint.iacr.org/2025/2028)
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import subprocess
import os
import sys
import argparse
from tabulate import tabulate

OUTDIR_VIVADO = "reports/FPGA-Vivado"

def extract_util_fpga(filepath):
    """Extract utilization information from FPGA utilization reports.
    """
    util_data = {
        "Slice LUTs": None,
        "DSPs": None,
        "CARRY4": None,
        "Slice Registers": None,
        "Block RAM Tile": None,
        "Fmax": None,
    }

    try:
        with open(filepath + "/utilization.txt", "r") as f:
            for line in f:
                for key in util_data.keys():
                    if f"| {key}" in line:
                        util_data[key] = float(line.split("|")[2].strip())
    except FileNotFoundError:
        pass

    try:
        with open(filepath + "/summary.txt", "r") as f:
            for line in f:
                for key in util_data.keys():
                    # Extract values for specific components
                    if key in line:
                        util_data[key] = float(line.split(" ")[1].strip())
    except FileNotFoundError:
        pass

    return util_data


def report_dirname(top, flags=None):
    """Build the report directory name for a top module and its flag variant.
    """
    if flags:
        return top + "_" + "_".join(flags)
    return top


def discover_report_dirs():
    """List every available report directory, sorted by name.
    """
    try:
        return sorted(e.name for e in os.scandir(OUTDIR_VIVADO) if e.is_dir())
    except FileNotFoundError:
        return []


def extract_all(dirname):
    """Extract synthesis numbers for one FPGA report directory.
    """
    data = [dirname]
    result = extract_util_fpga(f"{OUTDIR_VIVADO}/{dirname}")
    data += list(result.values())
    return data


def report(data):
    """Put collected data to a table.
    """
    headers = ["topmodule"]
    floatfmt = [""]

    headers += ["LUT", "DSP", "CARRY4", "FF", "BRAM", "Fmax"]
    floatfmt += ["g", "g", "g", "g", "g", "g"]

    print(tabulate(data, headers, tablefmt="orgtbl", floatfmt=floatfmt,
                   missingval="---"))


def run_synthesis(top, outdir, flags=None, fusesoc="fusesoc"):
    """Run FPGA/ASIC synthesis with given tool and top module.
    """
    fusesoc_flags = ""
    if flags is not None:
        fusesoc_flags = ' '.join('--flag ' + flag for flag in flags)

    cmd = (
        f"{fusesoc} --cores-root . run --target=sta {fusesoc_flags} --no-export "
        f"--tool=vivado --setup --mapping=lowrisc:prim_generic:all:0.1 lowrisc:ip:acc:0.1 && "
        f"mkdir -p {outdir} && cd build/lowrisc_ip_acc_0.1/sta-vivado && "
        f"vivado -mode batch -source vivado.tcl -notrace -tclargs --top_module {top} "
        f"--start_freq 10 --outdir ../../../{outdir}"
    )

    print(f"Command: {cmd}")
    subprocess.run(cmd, shell=True, check=True)


def main():
    parser = argparse.ArgumentParser(
        description="Python script for running FPGA and ASIC synthesis"
    )
    parser.add_argument(
        "--run_synthesis",
        action="store_true",
        default=False,
        help="Run synthesis for --top_module/--flags and report on it. Without "
             "this, report on every available report directory. (default: False)"
    )
    parser.add_argument(
        "--flags",
        type=str,
        default=None,
        help="Comma-separated list of flags for module variants. "
             "Only used with --run_synthesis."
    )
    parser.add_argument(
        "--fusesoc",
        type=str,
        default="fusesoc",
        help="fusesoc executable. Supplied automatically under `bazel run`. "
             "(default: fusesoc)"
    )
    parser.add_argument(
        "--top_module",
        type=str,
        default=None,
        help="With --run_synthesis: top-level hardware module to be synthesized "
             "(default: acc_alu_bignum). Without: only report on report "
             "directories whose name starts with this (default: all)."
    )

    args = parser.parse_args()

    # Resolve fusesoc before the chdir; the path is relative to the runfiles
    # tree. Then work in the source tree, not the sandbox.
    fusesoc = args.fusesoc
    if os.path.exists(fusesoc):
        fusesoc = os.path.abspath(fusesoc)
    workspace = os.environ.get("BUILD_WORKSPACE_DIRECTORY")
    if workspace:
        os.chdir(workspace)

    print(f"run_synthesis: {args.run_synthesis}")

    if args.run_synthesis:
        top = args.top_module or "acc_alu_bignum"
        flags = args.flags.split(",") if args.flags else None
        dirnames = [report_dirname(top, flags)]
        print(f"top_module: {top}")
        run_synthesis(top, f"{OUTDIR_VIVADO}/{dirnames[0]}", flags, fusesoc)
    else:
        dirnames = discover_report_dirs()
        if args.top_module:
            dirnames = [d for d in dirnames if d.startswith(args.top_module)]
        if not dirnames:
            print(f"No matching report directories found in {OUTDIR_VIVADO}",
                  file=sys.stderr)
            return 1

    data = [extract_all(dirname) for dirname in dirnames]

    report(data)
    return 0


if __name__ == "__main__":
    sys.exit(main())
