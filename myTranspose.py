#!/usr/bin/env python3



import sys



def usage():

    print("Usage: myTranspose")

    print("Transpose a matrix and print to screen")

    sys.exit(1)



def main():

    # Read all lines from stdin

    data_rows = [line.strip() for line in sys.stdin]

    ysize = len(data_rows)

    

    if ysize == 0:

        print("No input data provided.")

        sys.exit(1)



    # Split the first row to determine the number of columns (xsize)

    first_row = data_rows[0].split()

    xsize = len(first_row)



    # Create the matrix

    matrix = []

    for row in data_rows:

        matrix.append(row.split())



    # Transpose and print the matrix

    for i in range(xsize):

        str_out = " ".join(matrix[j][i] for j in range(ysize))

        print(str_out)



if __name__ == "__main__":

    main()


