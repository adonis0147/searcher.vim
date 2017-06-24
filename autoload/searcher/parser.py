#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

def parse(lines, files, index, indent=2):
	text = []
	separator = ' ' * indent
	for line in lines:
		tokens = re.split(r'([-:]\d+[-:])', line)
		if len(tokens) == 1:
			write_line(tokens[0], text, files, index)
		else:
			filename, content = _parse(tokens, separator)
			if not files or filename != files[-1]:
				if files:
					write_line('', text, files, index)
				files.append(filename)
				write_line(filename, text, files, index)
			write_line(content, text, files, index)
	return '\n'.join(text)

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

def write_line(content, text, files, index):
	text.append(content)
	index.append(len(files) - 1)

