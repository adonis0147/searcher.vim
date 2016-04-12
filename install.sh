#!/bin/sh

root=`pwd`

cd ./searcher
python setup.py build

target=`find . | grep -E 'searcher\.(so|dll|pyd)'`

mv $target $root/autoload/searcher

