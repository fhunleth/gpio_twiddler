#!/bin/bash

set -e

csvfiles=$(ls *.csv)

for file in $csvfiles; do
    echo Processing $file...

    ./analyze.exs $file >> new_results.txt
done
