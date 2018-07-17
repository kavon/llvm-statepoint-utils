#!/usr/bin/env bash

# a script used by Travis to run the test program

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

set -ex

pushd $DIR

make all
./a.out > output.txt

grep 'fib(35) = 9227465' < output.txt
