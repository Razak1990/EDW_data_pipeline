{{ config(
    materialized = 'view',
    post_hook = [
      "truncate table staging.customer_landing",
      
      "COPY INTO staging.customer_landing
       FROM @DBT_DB.DBO.SNOWFLAKE_External_Area
       FILE_FORMAT = (FORMAT_NAME = 'DBT_DB.DBO.CSV_FILE_FORMAT')
       ON_ERROR = 'CONTINUE'
       PATTERN = '.*Customers.*'",

      "COPY INTO staging.customer_landing_rejected
       FROM @DBT_DB.DBO.SNOWFLAKE_External_Area
       FILE_FORMAT = (FORMAT_NAME = 'DBT_DB.DBO.CSV_FILE_FORMAT', ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
       ON_ERROR = 'CONTINUE'
       PATTERN = '.*Customers.*'
       VALIDATION_MODE = RETURN_ALL_ERRORS"
    ]
) }}

SELECT 'Triggered COPY INTO hooks' AS message