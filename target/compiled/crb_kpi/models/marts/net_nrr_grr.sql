SELECT 
    SUM(CASE WHEN payment_month_clean >= DATEADD(YEAR, -1, CURRENT_DATE) THEN revenue ELSE 0 END) AS current_revenue,
    SUM(CASE WHEN payment_month_clean < DATEADD(YEAR, -1, CURRENT_DATE) THEN revenue ELSE 0 END) AS previous_revenue,
    (SUM(CASE WHEN payment_month_clean >= DATEADD(YEAR, -1, CURRENT_DATE) THEN revenue ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN payment_month_clean < DATEADD(YEAR, -1, CURRENT_DATE) THEN revenue ELSE 0 END), 0)) AS NRR,
    (SUM(CASE WHEN payment_month_clean >= DATEADD(YEAR, -1, CURRENT_DATE) THEN revenue ELSE 0 END) * 1.0 /
     NULLIF(SUM(CASE WHEN payment_month_clean >= DATEADD(YEAR, -1, CURRENT_DATE) THEN revenue ELSE 0 END), 0)) AS GRR
FROM public.stg_transactions