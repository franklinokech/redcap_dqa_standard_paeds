missing_is_airway_not_patent AS (
  -- Missing is_airway_not_patent
  SELECT
    record_id,
    datetime_entry,
    'is_airway_not_patent' AS variable,
    'Missing is_airway_not_patent' AS issue,
    is_airway_not_patent AS current_value
  FROM maternal_core
  WHERE (is_airway_not_patent IS NULL OR TRIM(is_airway_not_patent) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),



then add to union all
SELECT * FROM missing_is_airway_not_patent
