#!/usr/bin/env python3



import sys



def usage():

    print("Usage: mygetcols.py n1 n2 n3 5:7 ...")

    sys.exit(1)



def main():

    if len(sys.argv) < 2:

        usage()



    # Extract the column indices from arguments

    n = []

    for arg in sys.argv[1:]:

        tokens = arg.split(':')

        if len(tokens) == 1:

            n.append(int(tokens[0]))

        else:

            start, end = map(int, tokens)

            n.extend(range(start, end + 1))



    # Read from standard input

    for line in sys.stdin:

        line = line.rstrip()

        columns = line.split()



        result = []

        for index in n:

            if 1 <= index <= len(columns):

                result.append(columns[index - 1])



        # Join the result and print, removing any trailing space

        print(' '.join(result))



if __name__ == "__main__":

    main()


