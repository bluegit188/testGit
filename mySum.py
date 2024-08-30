#!/usr/bin/env python3

import sys

def usage():
    print("Usage: mySum.py colX")
    sys.exit(1)

def main():
    if len(sys.argv) != 2:
        usage()

    col_no = int(sys.argv[1])

    if col_no < 1:
        print("Column number must be greater than 0.")
        usage()

    sum_value = 0
    count = 0

    for line in sys.stdin:
        line = line.rstrip()
        columns = line.split()

        if col_no <= len(columns):
            x = float(columns[col_no - 1])  # Convert to float for sum
            sum_value += x
            count += 1
        else:
            print(f"Column index {col_no} out of range in line: {line}", file=sys.stderr)

    print(f"sum= {sum_value} count= {count}")

if __name__ == "__main__":
    main()
