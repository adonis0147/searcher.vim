#!/usr/bin/env python

import os
import re
import subprocess

def run(cmd, indent):
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE)
    return parse(p.stdout, indent)

def parse(result, indent):
    text, files, index = [], [], {}
    next_paragraph = True
    for i, line in enumerate(result):
        tokens = re.split('([-:]\d+[-:])', line)
        if len(tokens) == 1:
            next_paragraph = True
            text.append('%s\n' % tokens[0].rstrip())
            index[len(text)] = len(files) - 1
        else:
            filename, content = parse_tokens(tokens, indent)
            if next_paragraph:
                if len(files) == 0 or filename != files[-1]:
                    files.append(filename)
                    if len(text) != 0:
                        text[-1] = '\n'
                    text.append('%s\n' % filename)
                    index[len(text)] = len(files) - 1
                next_paragraph = False
            text.append(content)
            index[len(text)] = len(files) - 1
    return ''.join(text), files, index

def parse_tokens(tokens, indent):
    if len(tokens) == 3:
        filename = ''.join(tokens[:-2])
        content = '%s%s%s\n' % (tokens[-2][1:], ' ' * indent, tokens[-1].rstrip())
    else:
        for i in xrange(1, len(tokens), 2):
            filename = ''.join(tokens[:i])
            if os.path.isfile(filename):
                tokens[i] = tokens[i][1:] + ' ' * indent
                tokens[-1] = tokens[-1].rstrip() + '\n'
                content = ''.join(tokens[i:])
                return filename, content
    return filename, content

