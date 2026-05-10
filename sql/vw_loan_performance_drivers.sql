-- Dashboard 3: Key Loan Performance Drivers
-- Identifies which loan and borrower attributes most strongly drive
-- performance outcomes, translated into actionable metrics.
--
-- Groups by grade x purpose x term to surface the combinations
-- with the highest default rates, best return ratios, and recovery patterns.
--
-- default_rate_pct  uses only completed loans in the denominator (NULLIF guard)
--                   so in-progress Current loans don't dilute the rate
-- avg_return_ratio  total collected / funded — values above 1.0 are profitable
-- avg_recovery_ratio recoveries / funded on defaulted loans — lender recoupment rate
--
-- Export: SELECT * FROM vw_loan_performance_drivers ORDER BY grade, purpose, term;

CREATE OR REPLACE VIEW vw_loan_performance_drivers AS
SELECT
    grade,
    purpose,
    term,

    COUNT(*)                                                                          AS total_loans,
    ROUND(SUM(funded_amnt)::NUMERIC,  0)                                              AS total_funded_amnt,
    ROUND(SUM(total_pymnt)::NUMERIC,  0)                                              AS total_collected,

    -- Default rate denominator is completed loans only
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END)       AS default_count,
    ROUND(
        SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END)
        * 100.0 / NULLIF(
            SUM(CASE WHEN loan_status IN ('Fully Paid', 'Charged Off', 'Default') THEN 1 ELSE 0 END), 0
        ), 2
    )                                                                                 AS default_rate_pct,

    -- How much was collected relative to what was funded (>1.0 = net positive)
    ROUND(
        AVG(CASE WHEN funded_amnt > 0 THEN total_pymnt / funded_amnt END)::NUMERIC, 4
    )                                                                                 AS avg_return_ratio,

    -- Of loans that defaulted, how much did the lender recover post-charge-off
    ROUND(
        AVG(CASE
            WHEN loan_status IN ('Charged Off', 'Default') AND funded_amnt > 0
            THEN recoveries / funded_amnt
        END)::NUMERIC, 4
    )                                                                                 AS avg_recovery_ratio,

    ROUND(AVG(int_rate)::NUMERIC,        2)                                           AS avg_int_rate,
    ROUND(AVG(loan_amnt)::NUMERIC,       0)                                           AS avg_loan_amnt,
    ROUND(AVG(total_rec_int)::NUMERIC,   0)                                           AS avg_interest_collected,
    ROUND(AVG(total_rec_prncp)::NUMERIC, 0)                                           AS avg_principal_collected

FROM loans
WHERE grade   IS NOT NULL
  AND purpose IS NOT NULL
  AND term    IS NOT NULL

GROUP BY grade, purpose, term;