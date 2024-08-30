#!/usr/bin/env python3


import sys
from collections import defaultdict

def usage():
    print("Usage: check_duplicate.py file.txt colNo")
    sys.exit(1)

def main():
    if len(sys.argv) != 3:
        usage()

    filename = sys.argv[1]
    col_no = int(sys.argv[2])

    if col_no < 1:
        print("Column number must be greater than 0.")
        usage()

    # Open file and process the specified column
    counts = defaultdict(int)

    with open(filename, 'r') as infile:
        for line in infile:
            line = line.rstrip()
            columns = line.split()

            if col_no <= len(columns):
                value = columns[col_no - 1].strip()
                counts[value] += 1
            else:
                print(f"Column number {col_no} is out of range in line: {line}")

    # Print the counts of each value
    for key in sorted(counts.keys()):
        count = counts[key]
        if count > 1:
            print(f"{key}\t{count}")


if __name__ == "__main__":

    main()


