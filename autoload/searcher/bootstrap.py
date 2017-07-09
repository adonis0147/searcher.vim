#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import re

def is_case_sensitive(argv_list, options):
	keyword = argv_list[-2]
	ignore_case, case_sensitive, smart_case = False, False, False
	for argv in argv_list[:-2]:
		if argv in options['ignore-case']:
			ignore_case = True
		elif argv in options['case-sensitive']:
			case_sensitive = True
		elif argv in options['smart-case']:
			smart_case = True

	if case_sensitive:
		return True
	elif ignore_case:
		return False
	elif smart_case:
		return not keyword.islower()
	return True

def parse(msg, files, index, indent=2):
	text = []
	separator = ' ' * indent
	pos = msg.rfind('\n') + 1
	lines = msg[:pos].splitlines()
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
	return '\n'.join(text), msg[pos:]

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

