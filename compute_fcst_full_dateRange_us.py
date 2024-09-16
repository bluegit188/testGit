#!/usr/bin/env python3

import sys
import subprocess


# Check command-line arguments

if len(sys.argv) != 4:
    print("Usage: compute_fcst_full_dateRange_us.py SYM(ES) 20220401 20220430")
    print("Compute historical fcsts_full (all inds) for a given symbol + dateRange (single thread)")
    sys.exit(1)

sym = sys.argv[1]

# Define file directory and filename
directory = "/home/jgeng/RawData/portara/JunfCC/CCFixRTH/"
filename = f"{directory}{sym}.txt"

# Read command-line arguments
start_date = sys.argv[2]
end_date = sys.argv[3]


# Function to read file into a list of rows
def read_file(filename):
    try:
        with open(filename, 'r') as infile:
            all_rows = infile.readlines()
            all_rows = [row.strip() for row in all_rows]  # Remove newline characters
        return all_rows
    except Exception as e:
        print(f"Couldn't open {filename}: {e}")
        sys.exit(1)


# Function to compute standard deviation (one pass)
def get_std(values):
    count = len(values)
    if count < 1:
        return 0

    x_sum = sum(values)
    x2_sum = sum([x**2 for x in values])

    if count > 1:
        var = (x2_sum - (x_sum * x_sum / count)) / (count - 1)
        return var**0.5
    return 0

# Function to emulate Math::Round's nearest function, but eliminate extra zeros from .4f notation
def nearest_junf(pow10, x):
    a = 10 ** pow10
    return round(x / a) * a

# Functions to find min and max
def min_value(x1, x2):
    return min(x1, x2)

def max_value(x1, x2):
    return max(x1, x2)

# Main logic
all_rows = read_file(filename)
OOs = []  # Placeholder for any needed processing (not detailed in the Perl code)


# Process each row in the file
for line_str in all_rows:
    line = line_str.split()  # Splitting on whitespace
    date, open_price, high, low, close, tc, vol, oi, sym, ym, spd, cum_spd = line


    # Filter rows based on the date range
    if date < start_date or date > end_date:
        continue

    # Example of adjusting cumSpd (if needed, commented out in the original Perl script)
    # open_price = float(open_price) - float(cum_spd)
    # high = float(high) - float(cum_spd)
    # low = float(low) - float(cum_spd)
    # close = float(close) - float(cum_spd)

    # Construct the command to run (single-threaded processing)
    cmd = f"bt1_fcst_prod_v96_full {date} {sym} {open_price} {spd} 0 > Logs/bySym/fcst_log.txt.{date}.{sym}"

    # Print the command and execute it
    print(f"cmd= {cmd}")
    subprocess.run(cmd, shell=True)


