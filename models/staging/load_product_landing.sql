{{ config(
    materialized = 'view',
    post_hook = [
      "truncate table staging.product_landing",
      
      "COPY INTO staging.product_landing
       FROM @DBT_DB.DBO.SNOWFLAKE_External_Area
       FILE_FORMAT = (FORMAT_NAME = 'DBT_DB.DBO.CSV_FILE_FORMAT')
       ON_ERROR = 'CONTINUE'
       PATTERN = '.*Products.*'",

      "COPY INTO staging.product_landing_rejected
       FROM @DBT_DB.DBO.SNOWFLAKE_External_Area
       FILE_FORMAT = (FORMAT_NAME = 'DBT_DB.DBO.CSV_FILE_FORMAT', ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE)
       ON_ERROR = 'CONTINUE'
       PATTERN = '.*Products.*'
       VALIDATION_MODE = RETURN_ALL_ERRORS"
    ]
) }}

SELECT 'Triggered COPY INTO hooks' AS message