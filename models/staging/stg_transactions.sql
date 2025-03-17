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
   TO_DATE(payment_month ,'DD-MM-YYYY') AS payment_month_clean, -- Convert VARCHAR to DATE
FROM raw
