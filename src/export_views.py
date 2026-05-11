import os
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

load_dotenv()

OUTPUT_DIR = Path("data/processed")

VIEWS = {
    "borrower_default_profile":  "SELECT * FROM vw_borrower_default_profile  ORDER BY fico_tier, income_bracket, dti_bucket",
    "risk_tier_delinquency":     "SELECT * FROM vw_risk_tier_delinquency     ORDER BY grade, fico_tier, dti_bucket",
    "loan_performance_drivers":  "SELECT * FROM vw_loan_performance_drivers  ORDER BY grade, purpose, term",
}


def main():
    engine = create_engine(
        f"postgresql+psycopg2://{os.getenv('PGUSER')}:{os.getenv('PGPASSWORD')}"
        f"@{os.getenv('PGHOST')}:{os.getenv('PGPORT')}/{os.getenv('PGDATABASE')}"
    )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    for name, query in VIEWS.items():
        out_path = OUTPUT_DIR / f"{name}.csv"
        df = pd.read_sql(query, engine)
        df.to_csv(out_path, index=False)
        print(f"  {name}.csv — {len(df):,} rows -> {out_path}")

    print("\nDone.")


if __name__ == "__main__":
    main()