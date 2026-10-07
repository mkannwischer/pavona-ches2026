#!/usr/bin/env python3
# Copyright lowRISC contributors (OpenTitan project).
# Copyright zeroRISC Inc & MPI-SP.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

import argparse
import random
import struct
from typing import TextIO, Optional

from Crypto.Cipher import ChaCha20

from shared.testgen import write_test_data, write_test_exp, write_test_dexp

NUM_GROUPS = 2  # default, matches chacha20_test.s
BLOCKS_PER_GROUP = 8
BLOCK_BYTES = 64

MASK32 = 0xffffffff


def gen_chacha20_test(
        seed: Optional[int], num_groups: int, routine: str,
        data_file: TextIO, exp_file: TextIO, dexp_file: TextIO) -> None:
    if seed is not None:
        random.seed(seed)

    total_bytes = num_groups * BLOCKS_PER_GROUP * BLOCK_BYTES

    key_words = [random.randint(0, MASK32) for _ in range(8)]
    key_bytes = b''.join(struct.pack('<I', w) for w in key_words)

    nonce_words = [random.randint(0, MASK32) for _ in range(3)]
    nonce_bytes = b''.join(struct.pack('<I', w) for w in nonce_words)

    counter = random.randint(0, MASK32 - BLOCKS_PER_GROUP * num_groups)
    counter_bytes = struct.pack('<I', counter)

    # A 12-byte nonce selects the RFC 8439 variant with a 32-bit counter.
    cipher = ChaCha20.new(key=key_bytes, nonce=nonce_bytes)
    cipher.seek(counter * BLOCK_BYTES)
    ks_bytes = cipher.encrypt(bytes(total_bytes))

    data = {
        'key': key_bytes,
        'nonce': nonce_bytes,
        'counter': counter_bytes,
        'num_groups': struct.pack('<I', num_groups),
    }
    dexp = {}

    if routine in ('both', 'keystream'):
        dexp['ks'] = ks_bytes

    if routine in ('both', 'xor'):
        pt_bytes = bytes(random.randint(0, 255) for _ in range(total_bytes))
        data['pt'] = pt_bytes
        dexp['ct'] = bytes(p ^ k for p, k in zip(pt_bytes, ks_bytes))

    write_test_data(data, data_file)

    # x20 must be zero: assembly and generator group counts must match.
    write_test_exp({'x20': struct.pack('<I', 0)}, exp_file)

    write_test_dexp(dexp, dexp_file)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--seed',
                        type=int,
                        required=False,
                        help=('Seed value for pseudorandomness.'))
    parser.add_argument('--num-groups',
                        type=int,
                        default=NUM_GROUPS,
                        help=('Number of 8-block (512-byte) groups; must '
                              'match the assembly test\'s NUM_GROUPS.'))
    parser.add_argument('--routine',
                        choices=['both', 'keystream', 'xor'],
                        default='both',
                        help=('Which output to check against: ks, ct, or '
                              'both.'))
    parser.add_argument('data',
                        metavar='FILE',
                        type=argparse.FileType('w'),
                        help=('Output file for input DMEM values.'))
    parser.add_argument('exp',
                        metavar='FILE',
                        type=argparse.FileType('w'),
                        help=('Output file for expected register values.'))
    parser.add_argument('dexp',
                        metavar='FILE',
                        type=argparse.FileType('w'),
                        help=('Output file for expected DMEM values.'))
    args = parser.parse_args()

    with args.data, args.exp, args.dexp:
        gen_chacha20_test(args.seed, args.num_groups, args.routine,
                          args.data, args.exp, args.dexp)
