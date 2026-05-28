DBI::dbGetQuery(con, "
  SELECT MIN(CAST(datetime_entry AS TIMESTAMP)) AS first_entry_date
  FROM maternal_core
  WHERE is_abnormal_resp_rate IS NOT NULL
    AND TRIM(is_abnormal_resp_rate) != ''
")
