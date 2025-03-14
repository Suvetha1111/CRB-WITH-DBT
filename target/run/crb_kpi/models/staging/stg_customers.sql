
  create or replace   view CRBFITNESS.PUBLIC.stg_customers
  
   as (
    WITH raw AS (
    SELECT * FROM public.customers
    WHERE customer_id IS NOT NULL  -- Remove rows where customer_id is NULL
      AND customername IS NOT NULL -- Remove rows where customername is NULL
)
SELECT 
    customer_id,
    COALESCE(TRIM(LOWER(customername)), 'Unknown') AS customer_name_clean -- Handle NULLs
FROM raw
  );

