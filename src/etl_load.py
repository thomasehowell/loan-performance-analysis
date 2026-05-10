import os
import time
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

RAW_CSV = Path("data/raw/accepted_2007_to_2018Q4.csv")
CHUNK_SIZE = 50_000
TABLE_NAME = "loans"

COLUMNS = [
    # Loan terms
    "loan_amnt", "funded_amnt", "term", "int_rate", "installment",
    "grade", "sub_grade", "purpose", "issue_d",
    # Borrower profile
    "emp_length", "home_ownership", "annual_inc", "verification_status", "addr_state",
    # Credit profile
    "dti", "delinq_2yrs", "fico_range_low", "fico_range_high",
    "open_acc", "pub_rec", "revol_util", "total_acc",
    # Performance / outcome
    "loan_status", "out_prncp", "total_pymnt", "total_rec_prncp",
    "total_rec_int", "recoveries", "last_pymnt_amnt", "last_pymnt_d",
]

# Normalize messy loan_status values down to clean categories
LOAN_STATUS_MAP = {
    "Does not meet the credit policy. Status:Fully Paid": "Fully Paid",
    "Does not meet the credit policy. Status:Charged Off": "Charged Off",
}


def clean_chunk(df: pd.DataFrame) -> pd.DataFrame:
    # Strip % and convert to float
    for col in ("int_rate", "revol_util"):
        df[col] = pd.to_numeric(
            df[col].astype(str).str.replace("%", "", regex=False).str.strip(),
            errors="coerce",
        )

    # " 36 months" -> 36
    df["term"] = (
        df["term"].astype(str)
        .str.extract(r"(\d+)")[0]
        .pipe(pd.to_numeric, errors="coerce")
        .astype("Int64")
    )

    # "Jan-2018" -> date
    for col in ("issue_d", "last_pymnt_d"):
        df[col] = pd.to_datetime(df[col], format="%b-%Y", errors="coerce")

    # Normalize loan_status
    df["loan_status"] = df["loan_status"].replace(LOAN_STATUS_MAP)

    # Drop rows where every column is null (trailing summary rows in the CSV)
    df = df.dropna(how="all")

    return df


def main():
    engine = create_engine(
        f"postgresql+psycopg2://{os.getenv('PGUSER')}:{os.getenv('PGPASSWORD')}"
        f"@{os.getenv('PGHOST')}:{os.getenv('PGPORT')}/{os.getenv('PGDATABASE')}"
    )

    start = time.time()
    total_rows = 0

    print(f"Loading '{RAW_CSV}' -> PostgreSQL table '{TABLE_NAME}'")
    print(f"Columns: {len(COLUMNS)} | Chunk size: {CHUNK_SIZE:,}\n")

    for i, chunk in enumerate(
        pd.read_csv(RAW_CSV, usecols=COLUMNS, chunksize=CHUNK_SIZE, low_memory=False)
    ):
        chunk = clean_chunk(chunk)
        chunk.to_sql(
            TABLE_NAME,
            engine,
            if_exists="replace" if i == 0 else "append",
            index=False,
            method="multi",
        )
        total_rows += len(chunk)
        elapsed = time.time() - start
        print(f"  chunk {i + 1:>3} | {total_rows:>10,} rows | {elapsed:>6.0f}s elapsed")

    print(f"\nDone. {total_rows:,} rows loaded in {time.time() - start:.0f}s.")


if __name__ == "__main__":
    main()