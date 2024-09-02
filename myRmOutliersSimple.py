#!/usr/bin/env python3

import sys


# Check for the correct number of arguments
if len(sys.argv) != 6:
    sys.exit(
        "Usage: myRmOutliersSimple.py isHeader colX minX maxX opt=0/1\n"
        "opt=0: remove rows where x is outside of min/max, exclusive\n"
        "opt=1: keep rows where x is within min/max, inclusive"
    )


is_header = int(sys.argv[1])
col_x = int(sys.argv[2]) - 1  # Adjust for 0-based indexing in Python
min_x = float(sys.argv[3])
max_x = float(sys.argv[4])
opt = int(sys.argv[5])


count = 0

# Reading from standard input
for line in sys.stdin:
    line = line.strip()
    count += 1

    if is_header == 1 and count == 1:  # Print header if isHeader is set
        print(line)
        continue

    line_split = line.split()
    x = float(line_split[col_x])

    if opt == 0:
        if x > max_x or x < min_x:
            print(line)
    else:
        if min_x <= x <= max_x:
            print(line)


