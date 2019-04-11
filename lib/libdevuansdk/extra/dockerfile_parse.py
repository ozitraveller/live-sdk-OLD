#!/usr/bin/env python
# Copyright (c) 2018 Dyne.org Foundation
# libdevuansdk is maintained by Ivan J. <parazyd@dyne.org>
#
# This file is part of libdevuansdk
#
# This source code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this source code. If not, see <http://www.gnu.org/licenses/>.
"""
Dockerfile parser module
"""
from argparse import ArgumentParser
from sys import stdin
import json
import re


def rstrip_backslash(line):
    """
    Strip backslashes from end of line
    """
    line = line.rstrip()
    if line.endswith('\\'):
        return line[:-1]
    return line


def parse_instruction(inst):
    """
    Method for translating Dockerfile instructions to shell script
    """
    ins = inst['instruction'].upper()
    val = inst['value']

    # Valid Dockerfile instructions
    cmds = ['ADD', 'ARG', 'CMD', 'COPY', 'ENTRYPOINT', 'ENV', 'EXPOSE', 'FROM',
            'HEALTHCHECK', 'LABEL', 'MAINTAINER', 'ONBUILD', 'RUN', 'SHELL',
            'STOPSIGNAL', 'USER', 'VOLUME', 'WORKDIR']

    if ins == 'ADD':
        cmds.remove(ins)
        val = val.replace('$', '\\$')
        args = val.split(' ')
        return 'wget -O %s %s\n' % (args[1], args[0])

    elif ins == 'ARG':
        cmds.remove(ins)
        return '%s\n' % val

    elif ins == 'ENV':
        cmds.remove(ins)
        if '=' not in val:
            val = val.replace(' ', '=', 1)
        return 'export %s\n' % val

    elif ins == 'RUN':
        cmds.remove(ins)
        # Replace `` with $()
        while '`' in val:
            val = val.replace('`', '"$(', 1)
            val = val.replace('`', ')"', 1)
        return '%s\n' % val.replace('$', '\\$')

    elif ins == 'WORKDIR':
        cmds.remove(ins)
        return 'mkdir -p %s && cd %s\n' % (val, val)

    elif ins in cmds:
        # TODO: Look at CMD being added to /etc/rc.local
        return '#\n# %s not implemented\n# Instruction: %s %s\n#\n' % \
            (ins, ins, val)


def main():
    """
    Main parsing routine
    """
    parser = ArgumentParser()
    parser.add_argument('-j', '--json', action='store_true',
                        help='output the data as a JSON structure')
    parser.add_argument('-s', '--shell', action='store_true',
                        help='output the data as a shell script (default)')
    parser.add_argument('--keeptabs', action='store_true',
                        help='do not replace \\t (tabs) in the strings')
    parser.add_argument('Dockerfile')
    args = parser.parse_args()

    if args.Dockerfile != '-':
        with open(args.Dockerfile) as file:
            data = file.read().splitlines()
    else:
        data = stdin.read().splitlines()

    instre = re.compile(r'^\s*(\w+)\s+(.*)$')
    contre = re.compile(r'^.*\\\s*$')
    commentre = re.compile(r'^\s*#')

    instructions = []
    lineno = -1
    in_continuation = False
    cur_inst = {}

    for line in data:
        lineno += 1
        if commentre.match(line):
            continue
        if not in_continuation:
            rematch = instre.match(line)
            if not rematch:
                continue
            cur_inst = {
                'instruction': rematch.groups()[0].upper(),
                'value': rstrip_backslash(rematch.groups()[1]),
            }
        else:
            if cur_inst['value']:
                cur_inst['value'] += rstrip_backslash(line)
            else:
                cur_inst['value'] = rstrip_backslash(line.lstrip())

        in_continuation = contre.match(line)
        if not in_continuation and cur_inst is not None:
            if not args.keeptabs:
                cur_inst['value'] = cur_inst['value'].replace('\t', '')
            instructions.append(cur_inst)

    if args.json:
        print(json.dumps(instructions))
        return

    # Default to shell script output
    script = '#!/bin/sh\n'
    for i in instructions:
        script += parse_instruction(i)
    print(script)


if __name__ == '__main__':
    main()
