-- Dashboard 2: Risk Tier Segmentation
-- Segments borrowers by grade x FICO tier x DTI bucket and compares
-- delinquency rates across groups.
--
-- Two distinct metrics are tracked:
--   default_rate_pct     Charged Off or Default as % of ALL loans in segment
--   delinquency_rate_pct Any adverse status (Late, Grace Period, Default, Charged Off)
--                        as % of ALL loans — captures stress in active loans too
--
-- Export: SELECT * FROM vw_risk_tier_delinquency ORDER BY grade, fico_tier, dti_bucket;
--
-- Tableau usage notes:
--   default_rate_pct, delinquency_rate_pct
--                     — use directly only when all three dimensions (grade, fico_tier, dti_bucket)
--                       are present in the view so no rows are being rolled up.
--                       When collapsing dimensions, use calculated fields instead:
--                       SUM([Default Count]) / SUM([Total Loans]) * 100
--                       SUM([Delinquent Count]) / SUM([Total Loans]) * 100
--   default_count, delinquent_count, total_loans — SUM aggregation
--   total_funded_amnt — SUM aggregation
--   avg_int_rate, avg_loan_amnt — AVG aggregation (pre-computed averages; SUM is meaningless)

CREATE OR REPLACE VIEW vw_risk_tier_delinquency AS
SELECT
    grade,

    CASE
        WHEN fico_range_low >= 750 THEN '1. Prime (750+)'
        WHEN fico_range_low >= 700 THEN '2. Near-Prime (700-749)'
        WHEN fico_range_low >= 650 THEN '3. Subprime (650-699)'
        ELSE                             '4. Deep Subprime (600-649)'
    END AS fico_tier,

    CASE
        WHEN dti <  10 THEN '1. Low (<10%)'
        WHEN dti <  20 THEN '2. Moderate (10-20%)'
        WHEN dti <  30 THEN '3. High (20-30%)'
        ELSE                '4. Very High (30%+)'
    END AS dti_bucket,

    COUNT(*)                                                                          AS total_loans,
    ROUND(SUM(funded_amnt)::NUMERIC, 0)                                               AS total_funded_amnt,

    -- Hard defaults only (terminal negative outcomes)
    SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END)       AS default_count,
    ROUND(
        SUM(CASE WHEN loan_status IN ('Charged Off', 'Default') THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*), 2
    )                                                                                 AS default_rate_pct,

    -- Broader delinquency (any adverse payment status)
    SUM(CASE WHEN loan_status IN (
        'Charged Off', 'Default',
        'Late (31-120 days)', 'Late (16-30 days)',
        'In Grace Period'
    ) THEN 1 ELSE 0 END)                                                              AS delinquent_count,
    ROUND(
        SUM(CASE WHEN loan_status IN (
            'Charged Off', 'Default',
            'Late (31-120 days)', 'Late (16-30 days)',
            'In Grace Period'
        ) THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                                                                 AS delinquency_rate_pct,

    ROUND(AVG(int_rate)::NUMERIC,  2)                                                 AS avg_int_rate,
    ROUND(AVG(loan_amnt)::NUMERIC, 0)                                                 AS avg_loan_amnt

FROM loans
WHERE grade         IS NOT NULL
  AND fico_range_low IS NOT NULL
  AND dti            IS NOT NULL

GROUP BY grade, fico_tier, dti_bucket;