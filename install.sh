#!/bin/sh

root=`pwd`

cd ./searcher
python setup.py build

target=`find . | grep -P 'searcher.(so|dll|pyd)'`

mv $target $root/autoload/searcher

