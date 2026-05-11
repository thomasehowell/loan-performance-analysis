# Loan Performance Analysis

## 1. Project Scope

**Target Audience:** Data analysts, credit risk professionals, and hiring reviewers evaluating end-to-end analytical capability.

**Business Problem:** Lenders need to understand which borrower characteristics drive loan default and poor repayment outcomes. With hundreds of attributes available at origination, the challenge is identifying the signals that actually matter and translating them into actionable risk segmentation.

**Objectives:**
- Evaluate how borrower characteristics (income, credit profile, DTI) impact default and repayment outcomes
- Segment borrowers by risk tier and compare delinquency rates across groups
- Identify key drivers of loan performance and translate findings into actionable insights

**Business Value:** Clear risk segmentation enables better underwriting decisions, more accurate pricing of credit risk, and earlier identification of at-risk borrowers.

**Deliverables:**
- PostgreSQL database containing cleaned, analysis-ready loan data (30 columns selected from 151)
- SQL views pre-aggregating key metrics for each analytical question
- Three Tableau dashboards: Borrower Risk Profile, Risk Tier Segmentation, Key Performance Drivers

## 2. Results Overview

*To be completed after analysis.*

## 3. Dataset Overview

**Source:** [LendingClub Dataset Full 2007–2018 via Kaggle](https://www.kaggle.com/datasets/panchammahto/lendingclub-dataset-full-2007-to-2018)

**Size:** ~1.6 GB, 151 columns, 2,260,668 loan records (post-cleaning)

**Key variable groups retained for analysis:**

| Group | Examples |
|---|---|
| Borrower profile | `annual_inc`, `dti`, `emp_length`, `home_ownership` |
| Credit profile | `fico_range_low/high`, `revol_util`, `delinq_2yrs`, `pub_rec` |
| Loan terms | `loan_amnt`, `int_rate`, `grade`, `sub_grade`, `term`, `purpose` |
| Performance / outcome | `loan_status`, `total_pymnt`, `recoveries`, `out_prncp` |

The raw CSV is excluded from version control due to size. See **Section 6** for download instructions.

**Notable data characteristics:**
- FICO scores range from 610–850 in this dataset — the bottom tier (<600) is empty
- `loan_status` contains 7 distinct values post-cleaning: Fully Paid, Charged Off, Default, Current, In Grace Period, Late (16-30 days), Late (31-120 days)
- `int_rate` and `revol_util` are stored as percentage strings in the raw CSV and converted to floats during ETL
- `term` is stored as " 36 months" / " 60 months" in the raw CSV and converted to integers during ETL

## 4. Major Project Steps

1. Exploratory data analysis (EDA) — column profiling, null rates, distribution review
2. ETL — Python script reads raw CSV in 50,000-row chunks, selects 30 columns, cleans types, loads to PostgreSQL
3. SQL — indexes for query performance, three analytical views aggregated for Tableau
4. CSV export — Python script queries each view and writes to `data/processed/`
5. Tableau — three dashboards built from the exported CSVs
6. Documentation and GitHub publication

## 5. Project Structure

```
loan_performance_analysis_april_may_2025/
├── data/
│   ├── raw/                                  # Raw CSV (excluded from git — see Section 6)
│   ├── interim/                              # Intermediate outputs
│   └── processed/
│       ├── borrower_default_profile.csv      # Tableau Dashboard 1
│       ├── risk_tier_delinquency.csv         # Tableau Dashboard 2
│       └── loan_performance_drivers.csv      # Tableau Dashboard 3
├── notebooks/
│   └── EDA.ipynb                             # Exploratory data analysis
├── sql/
│   ├── schema.sql                            # Indexes and column reference
│   ├── vw_borrower_default_profile.sql       # Dashboard 1 view
│   ├── vw_risk_tier_delinquency.sql          # Dashboard 2 view
│   └── vw_loan_performance_drivers.sql       # Dashboard 3 view
├── src/
│   ├── etl_load.py                           # Loads raw CSV into PostgreSQL
│   ├── export_views.py                       # Exports SQL views to CSVs
│   └── sanity_check.py                       # Data integrity checks against the DB and views
├── reports/
│   ├── figures/                              # Chart exports
│   └── tables/                              # Summary tables
├── .env                                      # Local DB credentials (excluded from git)
├── .gitignore
└── README.md
```

## 6. How to Recreate This Project

### Prerequisites
- Python 3.9+
- PostgreSQL 14+
- Tableau Desktop or Tableau Public
- Python packages: `pandas`, `sqlalchemy`, `psycopg2-binary`, `python-dotenv`

```bash
pip install pandas sqlalchemy psycopg2-binary python-dotenv
```

### Steps

All scripts must be run from the **project root**, not from inside `src/`.

1. **Download the raw data** from [Kaggle — LendingClub Dataset Full 2007–2018](https://www.kaggle.com/datasets/panchammahto/lendingclub-dataset-full-2007-to-2018) and place the file at `data/raw/accepted_2007_to_2018Q4.csv`

2. **Configure your database** — create a `.env` file in the project root:
   ```
   PGUSER=your_user
   PGPASSWORD=your_password
   PGHOST=localhost
   PGPORT=5432
   PGDATABASE=your_database
   ```

3. **Run the ETL script** to load data into PostgreSQL (~5–15 minutes):
   ```bash
   python src/etl_load.py
   ```

4. **Run the SQL files** in pgAdmin or psql in this order:
   ```
   sql/schema.sql
   sql/vw_borrower_default_profile.sql
   sql/vw_risk_tier_delinquency.sql
   sql/vw_loan_performance_drivers.sql
   ```

5. **Export the views to CSV** for Tableau:
   ```bash
   python src/export_views.py
   ```

6. **Open Tableau** and connect to the CSVs in `data/processed/`

## 7. Conclusion

*To be completed after analysis.*