#!/usr/bin/env python3

import sys
import math
from datetime import datetime, timedelta
import threading
import subprocess



# Ensure the correct number of arguments is provided

if len(sys.argv) != 5:
    print("Usage: compute_fcst_full_dateRange_singleSymManager_us.py SYM(ES) 20220401 20220430 N(8)")
    print("Compute historical fcsts_full (all inds) for a given symbol+dateRange, using multi-threads.")
    print("N= break dates into N blocks and each block is one process.")
    sys.exit(1)

sym = sys.argv[1]
start_date = sys.argv[2]
end_date = sys.argv[3]
N = int(sys.argv[4])


# Get the dates (excluding weekends)
def get_weekdays_vec(start_date, end_date):
    date_list = []
    current_date = datetime.strptime(start_date, '%Y%m%d')
    end_date = datetime.strptime(end_date, '%Y%m%d')

    while current_date <= end_date:
        if current_date.weekday() < 5:  # 0-4 are Monday to Friday
            date_list.append(current_date.strftime('%Y%m%d'))
        current_date += timedelta(days=1)

    return date_list

dates_vec = get_weekdays_vec(start_date, end_date)
NDays = len(dates_vec)


# Create blocks
NFold = N
block_size = math.ceil(NDays / NFold)

print(f"{sym} startDate={start_date} endDate={end_date} NFolds={N} NDays={NDays}, blockSize={block_size}")

# Function for each thread
def run_command(sym, loc_start_date, loc_end_date):
    cmd = f"compute_fcst_full_dateRange_us.py {sym} {loc_start_date} {loc_end_date} > tmp_log.txt.{sym}.{loc_start_date}.{loc_end_date}"
    print(f"cmd= {cmd}")
    subprocess.run(cmd, shell=True)


# Loop through blocks and create threads

threads = []
for i in range(1, N + 1):
    loc_start = block_size * (i - 1)
    if loc_start > NDays - 1:
        continue
    loc_end = min(loc_start + block_size - 1, NDays - 1)
    loc_start_date = dates_vec[loc_start]
    loc_end_date = dates_vec[loc_end]



    # Create a thread for the command
    thr = threading.Thread(target=run_command, args=(sym, loc_start_date, loc_end_date))
    threads.append(thr)
    thr.start()


# Wait for all threads to complete
for thr in threads:
    thr.join()


