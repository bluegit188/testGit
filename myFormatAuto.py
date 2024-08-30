#!/usr/bin/env python3


import sys

def usage():
    print("Usage: myFormatAuto.py isHeader [opt:leftJustify=0]")
    print("       Format the output based on max width of each column")
    print("       Leftjustify: default=0, 1=left justify")
    print("       Output: formatted input")
    sys.exit(1)


def main():

    if len(sys.argv) < 2 or len(sys.argv) > 3:
        usage()

    is_header = sys.argv[1]
    is_left = 0

    if len(sys.argv) == 3:
       is_left = int(sys.argv[2])

    lines = []
    column_widths = {}
    column_count = 0

    for line in sys.stdin:
        line = line.rstrip()
        columns = line.split()
        lines.append(line)
        column_count = len(columns)

        for i, column in enumerate(columns):
            col_no = i + 1
            col_length = len(column)
            if col_no not in column_widths:
                column_widths[col_no] = col_length
            else:
                if col_length > column_widths[col_no]:
                    column_widths[col_no] = col_length


    # Format and print the output
    for line in lines:
        columns = line.split()
        formatted_line = ""

        for i, column in enumerate(columns):
            col_no = i + 1
            width = column_widths[col_no] + 1

            if is_left:
                formatted_line += f"{column:<{width}}"
            else:
                formatted_line += f"{column:>{width}}"

        print(formatted_line)

if __name__ == "__main__":

    main()


