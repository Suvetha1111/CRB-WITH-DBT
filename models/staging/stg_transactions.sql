WITH raw AS (
    SELECT * FROM public.transactions
    WHERE customer_id IS NOT NULL  
      AND product_id IS NOT NULL  
      AND revenue IS NOT NULL  
      AND payment_month IS NOT NULL  
)
SELECT 
    customer_id,
    product_id,
    CAST(COALESCE(revenue, 0) AS FLOAT) AS revenue,  -- Handle NULL revenue
    TO_TIMESTAMP(RIGHT(payment_month, 4) || '-' || SUBSTR(payment_month, 4, 2), 'YYYY-MM') AS payment_month_clean  -- Convert VARCHAR to TIMESTAMP
FROM raw
