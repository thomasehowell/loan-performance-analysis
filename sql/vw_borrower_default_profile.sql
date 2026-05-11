-- Dashboard 1: Borrower Risk Profile
-- Evaluates how income, credit profile, and DTI impact default outcomes.
--
-- Filtered to completed loans only (Fully Paid / Charged Off / Default)
-- so default_rate_pct reflects resolved outcomes, not in-progress loans.
--
-- Export: SELECT * FROM vw_borrower_default_profile ORDER BY fico_tier, income_bracket, dti_bucket;

CREATE OR REPLACE VIEW vw_borrower_default_profile AS
SELECT
    CASE
        WHEN fico_range_low >= 750 THEN '1. Prime (750+)'
        WHEN fico_range_low >= 700 THEN '2. Near-Prime (700-749)'
        WHEN fico_range_low >= 650 THEN '3. Subprime (650-699)'
        ELSE                             '4. Deep Subprime (600-649)'
    END AS fico_tier,

    CASE
        WHEN annual_inc <  30000  THEN '1. <$30K'
        WHEN annual_inc <  60000  THEN '2. $30K-$60K'
        WHEN annual_inc <  100000 THEN '3. $60K-$100K'
        WHEN annual_inc <  150000 THEN '4. $100K-$150K'
        ELSE                           '5. $150K+'
    END AS income_bracket,

    CASE
        WHEN dti <  10 THEN '1. Low (<10%)'
        WHEN dti <  20 THEN '2. Moderate (10-20%)'
        WHEN dti <  30 THEN '3. High (20-30%)'
        ELSE                '4. Very High (30%+)'
    END AS dti_bucket,

    COUNT(*)                                                                          AS total_loans,
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END)       AS default_count,
    ROUND(
        SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                                                                 AS default_rate_pct,
    ROUND(AVG(fico_range_low)::NUMERIC,  1)                                           AS avg_fico,
    ROUND(AVG(annual_inc)::NUMERIC,      0)                                           AS avg_annual_inc,
    ROUND(AVG(dti)::NUMERIC,             2)                                           AS avg_dti,
    ROUND(AVG(int_rate)::NUMERIC,        2)                                           AS avg_int_rate,
    ROUND(AVG(loan_amnt)::NUMERIC,       0)                                           AS avg_loan_amnt,
    ROUND(AVG(total_pymnt)::NUMERIC,     0)                                           AS avg_total_pymnt

FROM loans
WHERE loan_status   IN ('Fully Paid', 'Charged Off', 'Default')
  AND fico_range_low IS NOT NULL
  AND annual_inc     IS NOT NULL
  AND dti            IS NOT NULL
  AND annual_inc     < 500000  -- exclude extreme income outliers that skew brackets

GROUP BY fico_tier, income_bracket, dti_bucket;