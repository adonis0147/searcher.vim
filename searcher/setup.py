#!/usr/bin/env python
# -*- coding: utf-8 -*-

from distutils.core import setup, Extension

module = Extension('searcher', sources = ['searcher.cc'],
        extra_compile_args = ['--std=c++11'])

setup(name        = 'searcher',
      version     = '0.1',
      description = 'call searcher and parse the result',
      ext_modules = [module])

