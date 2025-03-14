SELECT 
    customer_id, 
    MIN(payment_month_clean) AS first_fiscal_year
FROM public.stg_transactions
GROUP BY customer_id
