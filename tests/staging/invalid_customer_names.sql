-- Ensure no customer names contain numbers
SELECT *
FROM {{ ref('stage_customer') }}
WHERE REGEXP_LIKE(Firstname, '[0-9]') OR REGEXP_LIKE(Lastname, '[0-9]')