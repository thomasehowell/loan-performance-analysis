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
- PostgreSQL database containing cleaned, analysis-ready loan data (~30 columns selected from 151)
- SQL views pre-aggregating key metrics for each analytical question
- Three Tableau dashboards: Borrower Risk Profile, Risk Tier Segmentation, Key Performance Drivers

## 2. Results Overview

*To be completed after analysis.*

## 3. Dataset Overview

**Source:** [LendingClub Dataset Full 2007–2018 via Kaggle](https://www.kaggle.com/datasets/panchammahto/lendingclub-dataset-full-2007-to-2018)

**Size:** ~1.6 GB, 151 columns, approximately 2.2 million loan records

**Key variable groups retained for analysis:**

| Group | Examples |
|---|---|
| Borrower profile | `annual_inc`, `dti`, `emp_length`, `home_ownership` |
| Credit profile | `fico_range_low/high`, `revol_util`, `delinq_2yrs`, `pub_rec` |
| Loan terms | `loan_amnt`, `int_rate`, `grade`, `sub_grade`, `term`, `purpose` |
| Performance / outcome | `loan_status`, `total_pymnt`, `recoveries`, `out_prncp` |

The raw CSV is excluded from version control due to size. See **Section 6** for download instructions.

## 4. Major Project Steps

1. Exploratory data analysis (EDA) — column profiling, null rates, distribution review
2. ETL — Python script reads raw CSV in chunks, selects relevant columns, loads to PostgreSQL
3. SQL — schema definition, data cleaning views, analytical aggregation views
4. Tableau — three dashboards built from exported CSV views
5. Documentation and GitHub publication

## 5. Project Structure

```
loan_performance_analysis_april_may_2025/
├── data/
│   ├── raw/              # Raw CSV (excluded from git — see Section 6)
│   ├── interim/          # Intermediate outputs
│   └── processed/        # Aggregated CSVs exported for Tableau
├── notebooks/
│   └── EDA.ipynb         # Exploratory data analysis
├── sql/                  # Schema DDL and analytical views
├── src/                  # Python ETL scripts
├── reports/
│   ├── figures/          # Chart exports
│   └── tables/           # Summary tables
├── .env                  # Local DB credentials (excluded from git)
├── .gitignore
└── README.md
```

## 6. How to Recreate This Project

### Prerequisites
- Python 3.9+
- PostgreSQL 14+
- Tableau Desktop or Tableau Public
- Python packages: `pandas`, `sqlalchemy`, `psycopg2-binary`, `python-dotenv`

### Steps

1. **Download the raw data** from [Kaggle — LendingClub Dataset Full 2007–2018](https://www.kaggle.com/datasets/panchammahto/lendingclub-dataset-full-2007-to-2018) and place the file at `data/raw/accepted_2007_to_2018Q4.csv`

2. **Configure your database** — create a `.env` file in the project root:
   ```
   PGUSER=your_user
   PGPASSWORD=your_password
   PGHOST=localhost
   PGPORT=5432
   PGDATABASE=your_database
   ```

3. **Run the ETL script** to load data into PostgreSQL:
   ```bash
   python src/etl_load.py
   ```

4. **Run SQL views** in `sql/` to create analytical aggregations

5. **Export CSVs** from the views into `data/processed/`

6. **Open Tableau** and connect to the CSVs in `data/processed/`

## 7. Conclusion

*To be completed after analysis.*