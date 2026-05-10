-- loans table is created automatically by src/etl_load.py.
-- Run this file once after the ETL completes to add indexes.

-- Column reference
-- -------------------------------------------------------------------------
-- loan_amnt          FLOAT   Requested loan amount
-- funded_amnt        FLOAT   Actually funded amount
-- term               BIGINT  Repayment term in months (36 or 60)
-- int_rate           FLOAT   Annual interest rate (e.g. 12.50)
-- installment        FLOAT   Fixed monthly payment amount
-- grade              TEXT    LendingClub risk grade (A through G)
-- sub_grade          TEXT    Granular grade (A1 through G5)
-- purpose            TEXT    Borrower-stated loan purpose
-- issue_d            TIMESTAMP Month the loan was issued
-- emp_length         TEXT    Employment tenure (< 1 year to 10+ years)
-- home_ownership     TEXT    RENT / OWN / MORTGAGE / OTHER
-- annual_inc         FLOAT   Self-reported annual income
-- verification_status TEXT   Income verification level
-- addr_state         TEXT    Borrower state of residence
-- dti                FLOAT   Debt-to-income ratio
-- delinq_2yrs        FLOAT   30+ day delinquencies in past 2 years
-- fico_range_low     FLOAT   Lower bound of FICO score at origination
-- fico_range_high    FLOAT   Upper bound of FICO score at origination
-- open_acc           FLOAT   Number of open credit lines
-- pub_rec            FLOAT   Number of derogatory public records
-- revol_util         FLOAT   Revolving credit utilization rate
-- total_acc          FLOAT   Total credit lines ever opened
-- loan_status        TEXT    Current loan state (Fully Paid, Charged Off, etc.)
-- out_prncp          FLOAT   Outstanding principal remaining
-- total_pymnt        FLOAT   Total amount paid to date
-- total_rec_prncp    FLOAT   Principal recovered to date
-- total_rec_int      FLOAT   Interest recovered to date
-- recoveries         FLOAT   Post-charge-off recovery amount
-- last_pymnt_amnt    FLOAT   Most recent payment amount
-- last_pymnt_d       TIMESTAMP Date of most recent payment
-- -------------------------------------------------------------------------

-- loan_status distinct values (post-ETL cleaning):
--   Fully Paid        Loan repaid in full
--   Charged Off       Lender wrote off the debt as a loss
--   Default           Borrower stopped paying, pre-charge-off
--   Current           Active loan, payments up to date
--   In Grace Period   Payment overdue but within grace window
--   Late (16-30 days) 16-30 days past due
--   Late (31-120 days) 31-120 days past due

CREATE INDEX IF NOT EXISTS idx_loans_grade        ON loans(grade);
CREATE INDEX IF NOT EXISTS idx_loans_loan_status  ON loans(loan_status);
CREATE INDEX IF NOT EXISTS idx_loans_issue_d      ON loans(issue_d);
CREATE INDEX IF NOT EXISTS idx_loans_fico_low     ON loans(fico_range_low);
CREATE INDEX IF NOT EXISTS idx_loans_purpose      ON loans(purpose);
CREATE INDEX IF NOT EXISTS idx_loans_term         ON loans(term);