#!/usr/bin/env python3

import sys
import subprocess

DEBUG = 0

# Check if the correct number of arguments is provided
if len(sys.argv) != 5:
    print("Usage: compute_fcst_full_dateRange_multi_us.py list_sym startDate endDate N(8)")
    print("Compute historical fcsts_full (all inds) for a given symbol list + dateRange")
    print("It will process one symbol at a time; for each symbol, the dates are broken into N batches, and each batch is one thread.")
    sys.exit(1)


# Get command-line arguments
filename = sys.argv[1]  # list of symbols from portara text file
start_date = sys.argv[2]
end_date = sys.argv[3]
N = sys.argv[4]  # Number of batches/threads

# Try to open the symbol list file
try:
    with open(filename, 'r') as infile:
        # Loop through each line in the file
        for line in infile:
            # Remove any trailing newlines or whitespaces
            line = line.strip()

            # Get the symbol from the line
            sym = line.split()[0]

            # Construct the command to execute
            cmd1 = f"compute_fcst_full_dateRange_singleSymManager_us.pl {sym} {start_date} {end_date} {N}"

            # Print and execute the command
            print(cmd1)
            subprocess.run(cmd1, shell=True)

except FileNotFoundError:
    print(f"Couldn't open {filename}: File not found.")
    sys.exit(1)


