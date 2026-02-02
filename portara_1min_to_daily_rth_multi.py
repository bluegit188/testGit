#!~/.conda/envs/research/bin/python
# coding: utf-8

#!/usr/bin/env python


import re
import sys
import importlib
import polars as pl
import pandas as pd
from concurrent.futures import ProcessPoolExecutor

# --------------------------------------------------------------------
# 1. Setup
# --------------------------------------------------------------------
#pl.enable_string_cache()

#sys.path.append(r"/home/jgeng/notebooks/junfei_lib/utils")
#import junfei_utils as jutil
#importlib.reload(jutil)

# File paths for windows
#PATHS = {
#    "sym_map": r"C:\Portara Data\list_sym_map",
#    "session_times": r"C:\Portara Data\JunfSessionSetUp\Portara Charts\Session Times\JunfRTHSessionTimes.tmp",
#    "multi_sessions": r"C:\Portara Data\JunfSessionSetUp\Portara Charts\MultiSessions\MultiSessions.txt",
#    "onemin_path": r"C:\Portara Data\Futures\Continuous Contracts\Intraday Database\1 Minute 24Hr\\",
#}

# File paths for linux
PATHS = {
    "sym_map": r"/home/jgeng/transfer/Prod2/portara_configs/list_sym_map",
    "session_times": r"/home/jgeng/transfer/Prod2/portara_configs/JunfRTHSessionTimes.tmp",
    "multi_sessions": r"/home/jgeng/transfer/Prod2/portara_configs/MultiSessions.txt",
    #"onemin_path": r"/mnt/wbox1/portara/Futures/Continuous Contracts/Intraday Database/1 Minute 24Hr/",
    "onemin_path": r"/home/jgeng/transfer/wbox1_1min_data/",    
    "output_path": r"CCFixRTH/",
}
#print(PATHS)

# --------------------------------------------------------------------
# 2. Symbol map
# --------------------------------------------------------------------
def load_sym_map() -> pl.DataFrame:
    return (
        pl.read_csv(
            PATHS["sym_map"],
            separator=" ",
            has_header=False,
            quote_char='"',
            schema_overrides={"column_1": pl.Categorical, "column_2": pl.Categorical},
        )
        .rename({"column_1": "SYMUser", "column_2": "SYMPort"})
    )

def get_sym_port(sym_map: pl.DataFrame, cur_sym_user: str) -> str | None:
    res = sym_map.filter(pl.col("SYMUser") == cur_sym_user).select("SYMPort")
    return res.item() if res.height > 0 else None

# --------------------------------------------------------------------
# 3. Session times
# --------------------------------------------------------------------
def build_trading_hours(sym_map: pl.DataFrame) -> pl.DataFrame:
    session_times = (
        pl.read_csv(PATHS["session_times"], separator=",", has_header=False)
        .select([
            pl.col("column_1").cast(pl.Categorical).alias("SYMPort"),
            pl.col("column_7").alias("open_time_loc"),
            pl.col("column_8").alias("close_time_loc"),
        ])
        .filter(pl.col("open_time_loc").is_not_null() & pl.col("close_time_loc").is_not_null())
    )

    multi_session_times = (
        pl.read_csv(PATHS["multi_sessions"], separator=",", has_header=False)
        .select([
            pl.col("column_1").cast(pl.Categorical).alias("SYMPort"),
            pl.col("column_2").alias("DATE"),
            pl.col("column_7").alias("open_time_loc"),
            pl.col("column_8").alias("close_time_loc"),
        ])
    )

    with pl.StringCache():
        multi = multi_session_times.sort(["SYMPort", "DATE"]).with_columns(
            pl.col("DATE").cast(pl.Utf8).str.strptime(pl.Date, "%Y%m%d").alias("start_date")
        )
        multi = multi.with_columns([
            pl.col("start_date")
            .shift(-1)
            .over("SYMPort")
            .fill_null(pl.lit("2050-01-01").str.strptime(pl.Date, "%Y-%m-%d"))
            .alias("end_date")
        ]).select(["SYMPort", "start_date", "end_date", "open_time_loc", "close_time_loc"])

        symbols_in_multi = multi["SYMPort"].unique().to_list()
        fallback = session_times.filter(~pl.col("SYMPort").is_in(symbols_in_multi))
        fallback = fallback.with_columns([
            pl.lit("1980-01-01").str.strptime(pl.Date, "%Y-%m-%d").alias("start_date"),
            pl.lit("2050-01-01").str.strptime(pl.Date, "%Y-%m-%d").alias("end_date")
        ]).select(["SYMPort", "start_date", "end_date", "open_time_loc", "close_time_loc"])

        trading_hours = pl.concat([multi, fallback]).sort(["SYMPort", "start_date"])
        trading_hours = trading_hours.with_columns(
            pl.when(pl.col("end_date") != pl.lit("2050-01-01").str.strptime(pl.Date, "%Y-%m-%d"))
            .then(pl.col("end_date") - pl.duration(days=1))
            .otherwise(pl.col("end_date"))
            .alias("end_date")
        )

    return trading_hours.join(sym_map, on="SYMPort", how="left")

# --------------------------------------------------------------------
# 4. Read Portara 1-min file
# --------------------------------------------------------------------
def read_portara_onemin_file(file:str) -> pl.DataFrame:
    schema = {
        "Date": pl.Utf8,
        "Time": pl.Utf8,
        "Open": pl.Float64,
        "High": pl.Float64,
        "Low": pl.Float64,
        "Close": pl.Float64,
        "TradeVolume": pl.Int32,
        "Volume": pl.Int32,
        "OpenInterest": pl.Int32,
        "Contract": pl.Utf8,
        "UnadjustedClose": pl.Float64,
        "Spread": pl.Float64,
        "CumulativeSpread": pl.Float64,
    }
    df = pl.read_csv(file, separator=",", schema=schema, has_header=True)
    return df.with_columns(
        pl.concat_str([pl.col("Date"), pl.col("Time")], separator=" ")
        .str.strptime(pl.Datetime, "%Y%m%d %H%M")
        .alias("datetime")
    )

# --------------------------------------------------------------------
# 5. Contract parsing (vectorized)
# --------------------------------------------------------------------
def add_contract_columns(df: pl.DataFrame, cur_sym_user: str) -> pl.DataFrame:
    return df.with_columns([
        pl.col("Contract").str.extract(r"^([A-Z]+)", 1).cast(pl.Categorical).alias("SYMPort2"),
        pl.col("Contract").str.extract(r"^[A-Z]+([0-9]+[A-Z])", 1).alias("ym"),
        pl.lit(cur_sym_user).cast(pl.Categorical).alias("SYMUser"),
        pl.col("Date").str.strptime(pl.Date, "%Y%m%d").alias("date"),
        pl.col("Time").cast(pl.Int32)
    ])

# --------------------------------------------------------------------
# 6. Price adjustments
# --------------------------------------------------------------------
def add_forward_adjusted_prices(df: pl.DataFrame) -> pl.DataFrame:
    cumSpd0 = df.select(pl.col("CumulativeSpread").first()).item()
    df = df.with_columns((cumSpd0 - pl.col("CumulativeSpread")).alias("cumSpd"))
    df = df.with_columns(
        (pl.col("cumSpd") - pl.col("cumSpd").shift(1))
        .fill_null(0)
        .alias("spd")
    )
    return df.with_columns([
        (pl.col(c) - pl.col("CumulativeSpread")).alias(f"{c}_unadj")
        for c in ["Open", "High", "Low", "Close"]
    ])


# --------------------------------------------------------------------
# 7. Filter by trading hours
# --------------------------------------------------------------------
def filter_by_trading_hours(df: pl.DataFrame, trading_hours: pl.DataFrame, cur_sym_user: str) -> pl.DataFrame:
    cur_trading_hours = trading_hours.filter(pl.col("SYMUser") == cur_sym_user)
    return (
        df.join_asof(cur_trading_hours, left_on="date", right_on="start_date", strategy="backward")
        .filter(
            (pl.col("date") >= pl.col("start_date")) &
            (pl.col("date") <= pl.col("end_date")) &
            (pl.col("Time") > pl.col("open_time_loc")) &
            (pl.col("Time") <= pl.col("close_time_loc"))
        )
    )

# --------------------------------------------------------------------
# 8. Collapse to daily OHLC
# --------------------------------------------------------------------
def collapse_to_daily(df_filtered: pl.DataFrame) -> pl.DataFrame:
    return (
        df_filtered
        .group_by(["SYMUser", "date"], maintain_order=True)
        .agg(
            pl.col("Open_unadj").first().alias("open"),
            pl.col("High_unadj").max().alias("high"),
            pl.col("Low_unadj").min().alias("low"),
            pl.col("Close_unadj").last().alias("close"),
            pl.col("cumSpd").first().alias("cumSpd"),
            pl.col("ym").first().alias("ym"),
            pl.col("TradeVolume").sum().alias("tv"),
            pl.col("Volume").first().alias("volume"),
            pl.col("OpenInterest").first().alias("oi"),
            pl.col("Time").min().alias("open_time"),
            pl.col("Time").max().alias("close_time"),
            pl.len().alias("bar_count"),
        )
        #.filter(pl.col("bar_count") >= 60)   # filter out days with less than 60 bars
        .filter(
            pl.when(pl.col("date") > pl.date(2007, 8, 1))
              .then(pl.col("bar_count") >= 60)
              .otherwise(pl.col("bar_count") >= 10)
        )
         # remove weekends Sat=6/ Sun=7: CL can trade on Sat in early times
        .filter(pl.col("date").dt.weekday() <= 5)
        .with_columns([
            (pl.col("cumSpd") - pl.col("cumSpd").shift(1)).alias("spd"),
            pl.col("date").dt.strftime("%Y%m%d").alias("date"),
            pl.col("SYMUser").alias("SYM"),
        ])
        .drop_nulls()
    )
    
# --------------------------------------------------------------------
# 9. Rounding helper
# --------------------------------------------------------------------
def nearest_junf_expr(col, pow10):
    a = 10 ** pow10
    y = ((col / a).round() * a)
    if pow10 < 0:
        y = y.round(-pow10)
        y = pl.when(y % 1 == 0).then(y.cast(pl.Int64)).otherwise(y)
    return y

# --------------------------------------------------------------------
# 10. Main processing function
# --------------------------------------------------------------------
def process_symbol(cur_sym_user: str) -> pl.DataFrame:
    print(cur_sym_user)
    pl.enable_string_cache()
    sym_map = load_sym_map()
    cur_sym_port = get_sym_port(sym_map, cur_sym_user)
    trading_hours = build_trading_hours(sym_map)

    # adjust cur_sum_port: e.g, nDD underlying is DD for (DAX)
    if cur_sym_port and cur_sym_port[0] in ("a", "e", "n"):
        cur_sym_port_raw = cur_sym_port[1:]
    else:
        cur_sym_port_raw = cur_sym_port
 
    
    df = read_portara_onemin_file(PATHS["onemin_path"] + f"{cur_sym_port_raw}.001")
    
    df = add_contract_columns(df, cur_sym_user)
    df = add_forward_adjusted_prices(df)
    df = filter_by_trading_hours(df, trading_hours, cur_sym_user)
    daily = collapse_to_daily(df)

    cols_to_round = ["open", "high", "low", "close", "spd", "cumSpd"]
    daily = daily.with_columns([
        nearest_junf_expr(pl.col(c), -6).alias(c) for c in cols_to_round
    ])

    daily = daily.select([
        "date", "open", "high", "low", "close", "tv", "volume",
        "oi", "SYM","ym", "spd", "cumSpd", "open_time", "close_time"
    ])
    output_path=PATHS["output_path"]
    daily.write_csv(f"{output_path}{cur_sym_user}.txt", separator=" ", include_header=False)
    return daily




def process_symbols_multi(symbols: list[str], max_workers: int = 5) -> list[pl.DataFrame]:
    """
    Run process_symbol in parallel across multiple symbols.
    Returns a list of daily DataFrames.
    """
    pl.enable_string_cache()
    #results = []
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(process_symbol, symbols))
    return results



def main():
    if len(sys.argv) != 2:
        sys.exit(
            f"Usage: python {sys.argv[0]} list_sym\n"
            "       list_sym is the symbol list (one column, ES, CL, NQ etc).\n"
        )

    # Read symbol list (assume one column, no header)
    list_sym = pd.read_csv(sys.argv[1], sep=' ',header=None)
    symbols = list_sym.iloc[:, 0].tolist()
    #symbols = ["ES", "NQ", "CL", "GC"]

    #print(symbols)

    
    # Run in parallel
    MAX_WORKERS=8
    results = process_symbols_multi(symbols,max_workers=MAX_WORKERS)

    # Optional: print summary
    #for sym, df in zip(symbols, results):
    #    print(f"Processed {sym}, rows: {df.height}")
    

    # serially process
    #results = [process_symbol(sym) for sym in symbols]
    #process_symbol(sym) for sym in symbols]
    

if __name__ == "__main__":

    main()

