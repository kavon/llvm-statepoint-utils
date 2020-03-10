#!/usr/bin/env bash

# a script used by Travis to run the test program

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

set -ex

pushd $DIR

OPT_FLAG="-O0 -g" make all
./a.out > output.txt
grep 'fib(35) = 9227465' < output.txt
make clean


OPT_FLAG="-O3 -DNDEBUG" make all
./a.out > output.txt
grep 'fib(35) = 9227465' < output.txt
make clean
