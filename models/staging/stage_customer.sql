{{ config(materialized = 'incremental', unique_key = 'customerID') }}

-- Ensure this model waits for load_product_landing to finish
{% set _ = ref('load_customer_landing') %}

WITH source_data AS (
  SELECT 
    customerID,
    Firstname,
    Lastname,
    Birthdate,
    City,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    CURRENT_TIMESTAMP() AS CreatedDate  -- This will be overridden for updates later
  FROM {{ source('staging', 'customer_landing') }}
),

-- Only for updates (existing rows)
updates AS (
  SELECT 
    s.customerID,
    s.Firstname,
    s.Lastname,
    s.Birthdate,
    s.City,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    s.CreatedDate  -- preserve existing created date
  FROM source_data s
  JOIN {{ this }} AS existing
    ON s.customerID = existing.customerID
),

-- Only for inserts (new rows)
inserts AS (
  SELECT 
    s.customerID,
    s.Firstname,
    s.Lastname,
    s.Birthdate,
    s.City,
    CURRENT_TIMESTAMP() AS lastmodefieddate,
    CURRENT_TIMESTAMP() AS CreatedDate
  FROM source_data s
  LEFT JOIN {{ this }} t
    ON s.customerID = t.customerID
  WHERE t.customerID IS NULL
)

SELECT * FROM updates
UNION ALL
SELECT * FROM inserts