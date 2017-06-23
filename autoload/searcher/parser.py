#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

def parse(msg, last_filename, num_files, indent=2):
	files, text, index = [], [], []
	separator = ' ' * indent
	lines = msg.splitlines()
	for line in lines:
		tokens = re.split(r'([-:]\d+[-:])', line)
		if len(tokens) == 1:
			write_line(tokens[0], text, index, num_files)
		else:
			filename, content = _parse(tokens, separator)
			if filename != last_filename:
				if num_files > 0:
					write_line('', text, index, num_files)
				files.append(filename)
				last_filename = filename
				num_files += 1
				write_line(filename, text, index, num_files)
			write_line(content, text, index, num_files)
	return '\n'.join(text), files, index

def _parse(tokens, separator):
	if len(tokens) == 3:
		filename, content = tokens[0], '%s%s%s' % (tokens[1][1:], separator, tokens[2])
	else:
		filename = tokens[0]
		i = 0
		while not os.path.isfile(filename) and i + 2 < len(tokens) - 1:
			filename = '%s%s%s' % (filename, tokens[i + 1], tokens[i + 2])
			i += 2
		i += 1
		if i < len(tokens) - 1:
			content = '%s%s%s' % (tokens[i][1:], separator, ''.join(tokens[i + 1:]))
	return filename, content

def write_line(content, text, index, num_files):
	text.append(content)
	index.append(num_files - 1)

