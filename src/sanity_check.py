import os
from dotenv import load_dotenv
from sqlalchemy import create_engine, text

load_dotenv()

engine = create_engine(
    f"postgresql+psycopg2://{os.getenv('PGUSER')}:{os.getenv('PGPASSWORD')}"
    f"@{os.getenv('PGHOST')}:{os.getenv('PGPORT')}/{os.getenv('PGDATABASE')}"
)

checks = {
    "Row count":                 "SELECT COUNT(*) FROM loans",
    "Distinct loan_status":      "SELECT DISTINCT loan_status FROM loans ORDER BY 1",
    "Distinct grade":            "SELECT DISTINCT grade FROM loans ORDER BY 1",
    "Distinct term":             "SELECT DISTINCT term FROM loans ORDER BY 1",
    "int_rate range":            "SELECT ROUND(MIN(int_rate)::NUMERIC,2), ROUND(MAX(int_rate)::NUMERIC,2) FROM loans",
    "revol_util range":          "SELECT ROUND(MIN(revol_util)::NUMERIC,2), ROUND(MAX(revol_util)::NUMERIC,2) FROM loans",
    "fico_range_low min/max":    "SELECT MIN(fico_range_low), MAX(fico_range_low) FROM loans",
    "annual_inc max":            "SELECT MAX(annual_inc) FROM loans",
    "NULLs in key columns":      """
                                    SELECT
                                        SUM(CASE WHEN loan_status  IS NULL THEN 1 ELSE 0 END) AS loan_status_nulls,
                                        SUM(CASE WHEN grade        IS NULL THEN 1 ELSE 0 END) AS grade_nulls,
                                        SUM(CASE WHEN fico_range_low IS NULL THEN 1 ELSE 0 END) AS fico_nulls,
                                        SUM(CASE WHEN dti          IS NULL THEN 1 ELSE 0 END) AS dti_nulls,
                                        SUM(CASE WHEN annual_inc   IS NULL THEN 1 ELSE 0 END) AS annual_inc_nulls,
                                        SUM(CASE WHEN int_rate     IS NULL THEN 1 ELSE 0 END) AS int_rate_nulls
                                    FROM loans
                                 """,
    "% signs in int_rate":       "SELECT COUNT(*) FROM loans WHERE CAST(int_rate AS TEXT) LIKE '%!%%' ESCAPE '!'",
    "View 1 row count":          "SELECT COUNT(*) FROM vw_borrower_default_profile",
    "View 2 row count":          "SELECT COUNT(*) FROM vw_risk_tier_delinquency",
    "View 3 row count":          "SELECT COUNT(*) FROM vw_loan_performance_drivers",
    "View 2 delinq >= default":  "SELECT COUNT(*) FROM vw_risk_tier_delinquency WHERE delinquency_rate_pct < default_rate_pct",
    "View 1 rates 0-100":        "SELECT COUNT(*) FROM vw_borrower_default_profile WHERE default_rate_pct < 0 OR default_rate_pct > 100",
    "View 3 return ratio range": "SELECT ROUND(MIN(avg_return_ratio)::NUMERIC,4), ROUND(MAX(avg_return_ratio)::NUMERIC,4) FROM vw_loan_performance_drivers",
}

with engine.connect() as conn:
    for label, query in checks.items():
        result = conn.execute(text(query)).fetchall()
        print(f"\n--- {label} ---")
        for row in result:
            print(" ", row)