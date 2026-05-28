con <- DBI::dbConnect(
  duckdb::duckdb(),
  dbdir = here::here("cin_maternal", "data", "processed", "maternal.duckdb")
)

start_date <- "2025-09-08"
end_date   <- "2026-05-27"

df_issues <- DBI::dbGetQuery(con, glue::glue("
  WITH

    -- document_source checks
    missing_document_source AS (
      SELECT
        record_id,
        datetime_entry,
        'document_source' AS variable,
        'Missing document_source' AS issue,
        document_source AS current_value
      FROM maternal_core
      WHERE (document_source IS NULL OR TRIM(document_source) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-08 10:47:19'
    ),

    -- hosp_id checks
    missing_hosp_id AS (
      SELECT
        record_id,
        datetime_entry,
        'hosp_id' AS variable,
        'Missing hosp_id' AS issue,
        hosp_id AS current_value
      FROM maternal_core
      WHERE (hosp_id IS NULL OR TRIM(hosp_id) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- admission_type checks
    missing_admission_type AS (
      SELECT
        record_id,
        datetime_entry,
        'admission_type' AS variable,
        'Missing admission_type' AS issue,
        admission_type AS current_value
      FROM maternal_core
      WHERE (admission_type IS NULL OR TRIM(admission_type) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- mother_ip_no checks
    missing_mother_ip_no AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_ip_no' AS variable,
        'Missing mother_ip_no' AS issue,
        mother_ip_no AS current_value
      FROM maternal_core
      WHERE (mother_ip_no IS NULL OR TRIM(mother_ip_no) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- mother_age checks
    missing_mother_age AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_age' AS variable,
        'Missing mother_age' AS issue,
        mother_age AS current_value
      FROM maternal_core
      WHERE (mother_age IS NULL OR TRIM(mother_age) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    invalid_mother_age AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_age' AS variable,
        'mother_age out of range (10-60)' AS issue,
        mother_age AS current_value
      FROM maternal_core
      WHERE mother_age IS NOT NULL
        AND TRIM(mother_age) != ''
        AND (TRY_CAST(mother_age AS INTEGER) < 10 OR TRY_CAST(mother_age AS INTEGER) > 60)
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- mother_county checks
    missing_mother_county AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_county' AS variable,
        'Missing mother_county' AS issue,
        mother_county AS current_value
      FROM maternal_core
      WHERE (mother_county IS NULL OR TRIM(mother_county) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- mother_subcounty checks
    missing_mother_subcounty AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_subcounty' AS variable,
        'Missing mother_subcounty' AS issue,
        mother_subcounty AS current_value
      FROM maternal_core
      WHERE (mother_subcounty IS NULL OR TRIM(mother_subcounty) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- admission_date checks
    missing_admission_date AS (
      SELECT
        record_id,
        datetime_entry,
        'admission_date' AS variable,
        'Missing admission_date' AS issue,
        admission_date AS current_value
      FROM maternal_core
      WHERE (admission_date IS NULL OR TRIM(admission_date) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    future_admission_date AS (
      SELECT
        record_id,
        datetime_entry,
        'admission_date' AS variable,
        'Future admission_date' AS issue,
        admission_date AS current_value
      FROM maternal_core
      WHERE admission_date IS NOT NULL
        AND TRIM(admission_date) != ''
        AND TRY_CAST(admission_date AS DATE) > CURRENT_DATE
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- admission_time checks
    missing_admission_time AS (
      SELECT
        record_id,
        datetime_entry,
        'admission_time' AS variable,
        'Missing admission_time' AS issue,
        admission_time AS current_value
      FROM maternal_core
      WHERE (admission_time IS NULL OR TRIM(admission_time) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- admission_time_unit checks
    missing_admission_time_unit AS (
      SELECT
        record_id,
        datetime_entry,
        'admission_time_unit' AS variable,
        'Missing admission_time_unit' AS issue,
        admission_time_unit AS current_value
      FROM maternal_core
      WHERE (admission_time_unit IS NULL OR TRIM(admission_time_unit) = '')
        AND admission_time IS NOT NULL
        AND TRIM(admission_time) != ''
        AND TRIM(admission_time) != 'NI'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- mother_residence checks
    missing_mother_residence AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_residence' AS variable,
        'Missing mother_residence' AS issue,
        mother_residence AS current_value
      FROM maternal_core
      WHERE (mother_residence IS NULL OR TRIM(mother_residence) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- marriage_status checks
    missing_marriage_status AS (
      SELECT
        record_id,
        datetime_entry,
        'marriage_status' AS variable,
        'Missing marriage_status' AS issue,
        marriage_status AS current_value
      FROM maternal_core
      WHERE (marriage_status IS NULL OR TRIM(marriage_status) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- education_level checks
    missing_education_level AS (
      SELECT
        record_id,
        datetime_entry,
        'education_level' AS variable,
        'Missing education_level' AS issue,
        education_level AS current_value
      FROM maternal_core
      WHERE (education_level IS NULL OR TRIM(education_level) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- nationality checks
    -- missing_nationality AS (
    --   SELECT
    --     record_id,
    --     datetime_entry,
    --     'nationality' AS variable,
    --     'Missing nationality' AS issue,
    --     nationality AS current_value
    --   FROM maternal_core
    --   WHERE (nationality IS NULL OR TRIM(nationality) = '')
    --     AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    -- ),

    -- mother_occupation checks
    missing_mother_occupation AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_occupation' AS variable,
        'Missing mother_occupation' AS issue,
        mother_occupation AS current_value
      FROM maternal_core
      WHERE (mother_occupation IS NULL OR TRIM(mother_occupation) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    missing_mother_occupation_other AS (
      SELECT
        record_id,
        datetime_entry,
        'mother_occupation_other' AS variable,
        'Missing mother_occupation_other' AS issue,
        mother_occupation_other AS current_value
      FROM maternal_core
      WHERE (mother_occupation_other IS NULL OR TRIM(mother_occupation_other) = '')
        AND mother_occupation IS NOT NULL
        AND TRIM(mother_occupation) = 'OTH'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2026-04-10 18:15:23'
    ),

    -- payment_method checks
    missing_payment_method AS (
      SELECT
        record_id,
        datetime_entry,
        'payment_method' AS variable,
        'Missing payment_method' AS issue,
        payment_method AS current_value
      FROM maternal_core
      WHERE (payment_method IS NULL OR TRIM(payment_method) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    missing_payment_other AS (
      SELECT
        record_id,
        datetime_entry,
        'payment_other' AS variable,
        'Missing payment_other' AS issue,
        payment_other AS current_value
      FROM maternal_core
      WHERE (payment_other IS NULL OR TRIM(payment_other) = '')
        AND payment_method IS NOT NULL
        AND TRIM(payment_method) = 'OTH'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-05 14:47:49'
    ),

    -- is_referral checks
    missing_is_referral AS (
      SELECT
        record_id,
        datetime_entry,
        'is_referral' AS variable,
        'Missing is_referral' AS issue,
        is_referral AS current_value
      FROM maternal_core
      WHERE (is_referral IS NULL OR TRIM(is_referral) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- referral checks
    missing_referral_type AS (
      SELECT
        record_id,
        datetime_entry,
        'referral_type' AS variable,
        'Missing referral_type' AS issue,
        referral_type AS current_value
      FROM maternal_core
      WHERE (referral_type IS NULL OR TRIM(referral_type) = '')
        AND is_referral IS NOT NULL
        AND TRIM(is_referral) = '1'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
    ),

    missing_referring_facility_level AS (
      SELECT
        record_id,
        datetime_entry,
        'referring_facility_level' AS variable,
        'Missing referring_facility_level' AS issue,
        referring_facility_level AS current_value
      FROM maternal_core
      WHERE (referring_facility_level IS NULL OR TRIM(referring_facility_level) = '')
        AND is_referral IS NOT NULL
        AND TRIM(is_referral) = '1'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
    ),

    missing_referring_facility_name AS (
      SELECT
        record_id,
        datetime_entry,
        'referring_facility_name' AS variable,
        'Missing referring_facility_name' AS issue,
        referring_facility_name AS current_value
      FROM maternal_core
      WHERE (referring_facility_name IS NULL OR TRIM(referring_facility_name) = '')
        AND is_referral IS NOT NULL
        AND TRIM(is_referral) = '1'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
    ),

    missing_referring_facility_other AS (
      SELECT
        record_id,
        datetime_entry,
        'referring_facility_other' AS variable,
        'Missing referring_facility_other' AS issue,
        referring_facility_other AS current_value
      FROM maternal_core
      WHERE (referring_facility_other IS NULL OR TRIM(referring_facility_other) = '')
        AND referring_facility_name IS NOT NULL
        AND TRIM(referring_facility_name) = 'OTH'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-12 10:05:50'
    ),

    -- is_consented checks
    missing_is_consented AS (
      SELECT
        record_id,
        datetime_entry,
        'is_consented' AS variable,
        'Missing is_consented' AS issue,
        is_consented AS current_value
      FROM maternal_core
      WHERE (is_consented IS NULL OR TRIM(is_consented) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 00:00:00'
    ),

    -- study_id checks
    missing_study_id AS (
      SELECT
        record_id,
        datetime_entry,
        'study_id' AS variable,
        'Missing study_id' AS issue,
        study_id AS current_value
      FROM maternal_core
      WHERE (study_id IS NULL OR TRIM(study_id) = '')
        AND is_consented = '1'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-10 09:44:07'
    ),

    invalid_study_id AS (
      SELECT
        record_id,
        datetime_entry,
        'study_id' AS variable,
        'study_id does not match expected format' AS issue,
        study_id AS current_value
      FROM maternal_core
      WHERE study_id IS NOT NULL
        AND TRIM(study_id) != ''
        AND is_consented = '1'
        AND NOT (
          regexp_matches(study_id, '^(LC|CG)-72-[0-9]+-[0-9]+$')
          OR
          regexp_matches(study_id, '^(LC|CG)-72[0-9]{{5,}}$')
        )
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-10 09:44:07'
    ),

    -- registering_clerk checks
    missing_registering_clerk AS (
      SELECT
        record_id,
        datetime_entry,
        'registering_clerk' AS variable,
        'Missing registering_clerk' AS issue,
        registering_clerk AS current_value
      FROM maternal_core
      WHERE (registering_clerk IS NULL OR TRIM(registering_clerk) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- date_clerking checks
    missing_date_clerking AS (
      SELECT
        record_id,
        datetime_entry,
        'date_clerking' AS variable,
        'Missing date_clerking' AS issue,
        date_clerking AS current_value
      FROM maternal_core
      WHERE (date_clerking IS NULL OR TRIM(date_clerking) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    future_date_clerking AS (
      SELECT
        record_id,
        datetime_entry,
        'date_clerking' AS variable,
        'Future date_clerking' AS issue,
        date_clerking AS current_value
      FROM maternal_core
      WHERE date_clerking IS NOT NULL
        AND TRIM(date_clerking) != ''
        AND TRY_CAST(date_clerking AS DATE) > CURRENT_DATE
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    early_date_clerking AS (
      SELECT
        record_id,
        datetime_entry,
        'date_clerking' AS variable,
        'date_clerking is before admission_date' AS issue,
        date_clerking AS current_value
      FROM maternal_core
      WHERE date_clerking IS NOT NULL
        AND TRIM(date_clerking) != ''
        AND admission_date IS NOT NULL
        AND TRIM(admission_date) != ''
        AND TRY_CAST(date_clerking AS DATE) < TRY_CAST(admission_date AS DATE)
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    -- time_clerking checks
    missing_time_clerking AS (
      SELECT
        record_id,
        datetime_entry,
        'time_clerking' AS variable,
        'Missing time_clerking' AS issue,
        time_clerking AS current_value
      FROM maternal_core
      WHERE (time_clerking IS NULL OR TRIM(time_clerking) = '')
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

    invalid_time_clerking AS (
      SELECT
        record_id,
        datetime_entry,
        'time_clerking' AS variable,
        'Invalid time_clerking format (expected HH:MM 12hr or 24hr)' AS issue,
        time_clerking AS current_value
      FROM maternal_core
      WHERE time_clerking IS NOT NULL
        AND TRIM(time_clerking) != ''
        AND TRIM(time_clerking) != 'NI'
        AND NOT (
          regexp_matches(TRIM(time_clerking), '^(0?[1-9]|1[0-2]):[0-5][0-9]$')
          OR
          regexp_matches(TRIM(time_clerking), '^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
        )
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

  missing_clerking_time_unit AS (
      -- Missing clerking_time_unit when time_clerking is present and not NI
      SELECT
        record_id,
        datetime_entry,
        'clerking_time_unit' AS variable,
        'Missing clerking_time_unit' AS issue,
        clerking_time_unit AS current_value
      FROM maternal_core
      WHERE (clerking_time_unit IS NULL OR TRIM(clerking_time_unit) = '')
        AND time_clerking IS NOT NULL
        AND TRIM(time_clerking) != ''
        AND TRIM(time_clerking) != 'NI'
        AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
    ),

      missing_adm_resp_rate AS (
    -- Missing adm_resp_rate
    SELECT
      record_id,
      datetime_entry,
      'adm_resp_rate' AS variable,
      'Missing adm_resp_rate' AS issue,
      adm_resp_rate AS current_value
    FROM maternal_core
    WHERE (adm_resp_rate IS NULL OR TRIM(adm_resp_rate) = '')
      AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
  ),

  invalid_adm_resp_rate AS (
    -- Out of range: expected 8-30 bpm
    SELECT
      record_id,
      datetime_entry,
      'adm_resp_rate' AS variable,
      'adm_resp_rate out of range (expected 8-30 bpm)' AS issue,
      adm_resp_rate AS current_value
    FROM maternal_core
    WHERE adm_resp_rate IS NOT NULL
      AND TRIM(adm_resp_rate) != ''
      AND TRIM(adm_resp_rate) != 'NI'
      AND (
        TRY_CAST(adm_resp_rate AS INTEGER) IS NULL
        OR TRY_CAST(adm_resp_rate AS INTEGER) < 8
        OR TRY_CAST(adm_resp_rate AS INTEGER) > 30
      )
      AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
  ),

  missing_adm_bp_systolic AS (
  -- Missing adm_bp_systolic
  SELECT
    record_id,
    datetime_entry,
    'adm_bp_systolic' AS variable,
    'Missing adm_bp_systolic' AS issue,
    adm_bp_systolic AS current_value
  FROM maternal_core
  WHERE (adm_bp_systolic IS NULL OR TRIM(adm_bp_systolic) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_adm_bp_systolic AS (
  -- Out of range: expected 50-300 mm Hg
  SELECT
    record_id,
    datetime_entry,
    'adm_bp_systolic' AS variable,
    'adm_bp_systolic out of range (expected 50-300 mm Hg)' AS issue,
    adm_bp_systolic AS current_value
  FROM maternal_core
  WHERE adm_bp_systolic IS NOT NULL
    AND TRIM(adm_bp_systolic) != ''
    AND TRIM(adm_bp_systolic) != 'NI'
    AND (
      TRY_CAST(adm_bp_systolic AS INTEGER) IS NULL
      OR TRY_CAST(adm_bp_systolic AS INTEGER) < 50
      OR TRY_CAST(adm_bp_systolic AS INTEGER) > 300
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_adm_bp_diastolic AS (
  -- Missing adm_bp_diastolic
  SELECT
    record_id,
    datetime_entry,
    'adm_bp_diastolic' AS variable,
    'Missing adm_bp_diastolic' AS issue,
    adm_bp_diastolic AS current_value
  FROM maternal_core
  WHERE (adm_bp_diastolic IS NULL OR TRIM(adm_bp_diastolic) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_adm_bp_diastolic AS (
  -- Out of range: expected 30-200 mm Hg (extended to capture extremes)
  SELECT
    record_id,
    datetime_entry,
    'adm_bp_diastolic' AS variable,
    'adm_bp_diastolic out of range (expected 30-200 mm Hg)' AS issue,
    adm_bp_diastolic AS current_value
  FROM maternal_core
  WHERE adm_bp_diastolic IS NOT NULL
    AND TRIM(adm_bp_diastolic) != ''
    AND TRIM(adm_bp_diastolic) != 'NI'
    AND (
      TRY_CAST(adm_bp_diastolic AS INTEGER) IS NULL
      OR TRY_CAST(adm_bp_diastolic AS INTEGER) < 30
      OR TRY_CAST(adm_bp_diastolic AS INTEGER) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_adm_heart_rate AS (
  -- Missing adm_heart_rate
  SELECT
    record_id,
    datetime_entry,
    'adm_heart_rate' AS variable,
    'Missing adm_heart_rate' AS issue,
    adm_heart_rate AS current_value
  FROM maternal_core
  WHERE (adm_heart_rate IS NULL OR TRIM(adm_heart_rate) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_adm_heart_rate AS (
  -- Out of range: expected 20-200 /min (extended to capture extremes)
  SELECT
    record_id,
    datetime_entry,
    'adm_heart_rate' AS variable,
    'adm_heart_rate out of range (expected 20-200 /min)' AS issue,
    adm_heart_rate AS current_value
  FROM maternal_core
  WHERE adm_heart_rate IS NOT NULL
    AND TRIM(adm_heart_rate) != ''
    AND TRIM(adm_heart_rate) != 'NI'
    AND (
      TRY_CAST(adm_heart_rate AS INTEGER) IS NULL
      OR TRY_CAST(adm_heart_rate AS INTEGER) < 20
      OR TRY_CAST(adm_heart_rate AS INTEGER) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_adm_spo2 AS (
  -- Missing adm_spo2
  SELECT
    record_id,
    datetime_entry,
    'adm_spo2' AS variable,
    'Missing adm_spo2' AS issue,
    adm_spo2 AS current_value
  FROM maternal_core
  WHERE (adm_spo2 IS NULL OR TRIM(adm_spo2) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_adm_spo2 AS (
  -- Out of range: expected 50-100 % (extended to capture extremes)
  SELECT
    record_id,
    datetime_entry,
    'adm_spo2' AS variable,
    'adm_spo2 out of range (expected 50-100 %)' AS issue,
    adm_spo2 AS current_value
  FROM maternal_core
  WHERE adm_spo2 IS NOT NULL
    AND TRIM(adm_spo2) != ''
    AND TRIM(adm_spo2) != 'NI'
    AND (
      TRY_CAST(adm_spo2 AS INTEGER) IS NULL
      OR TRY_CAST(adm_spo2 AS INTEGER) < 50
      OR TRY_CAST(adm_spo2 AS INTEGER) > 100
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_adm_temp AS (
  -- Missing adm_temp
  SELECT
    record_id,
    datetime_entry,
    'adm_temp' AS variable,
    'Missing adm_temp' AS issue,
    adm_temp AS current_value
  FROM maternal_core
  WHERE (adm_temp IS NULL OR TRIM(adm_temp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_adm_temp AS (
  -- Out of range: expected 30-45 °C (extended to capture extremes)
  SELECT
    record_id,
    datetime_entry,
    'adm_temp' AS variable,
    'adm_temp out of range (expected 30-45 °C)' AS issue,
    adm_temp AS current_value
  FROM maternal_core
  WHERE adm_temp IS NOT NULL
    AND TRIM(adm_temp) != ''
    AND TRIM(adm_temp) != 'NI'
    AND TRIM(adm_temp) != 'ND'
    AND (
      TRY_CAST(adm_temp AS DOUBLE) IS NULL
      OR TRY_CAST(adm_temp AS DOUBLE) < 30
      OR TRY_CAST(adm_temp AS DOUBLE) > 45
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

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

missing_is_abnormal_resp_rate AS (
  -- Missing is_abnormal_resp_rate
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_resp_rate' AS variable,
    'Missing is_abnormal_resp_rate' AS issue,
    is_abnormal_resp_rate AS current_value
  FROM maternal_core
  WHERE (is_abnormal_resp_rate IS NULL OR TRIM(is_abnormal_resp_rate) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_vaginal_bleeding AS (
  -- Missing is_vaginal_bleeding
  SELECT
    record_id,
    datetime_entry,
    'is_vaginal_bleeding' AS variable,
    'Missing is_vaginal_bleeding' AS issue,
    is_vaginal_bleeding AS current_value
  FROM maternal_core
  WHERE (is_vaginal_bleeding IS NULL OR TRIM(is_vaginal_bleeding) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_abnormal_temp AS (
  -- Missing is_abnormal_temp
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_temp' AS variable,
    'Missing is_abnormal_temp' AS issue,
    is_abnormal_temp AS current_value
  FROM maternal_core
  WHERE (is_abnormal_temp IS NULL OR TRIM(is_abnormal_temp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_unconscious AS (
  -- Missing is_unconscious
  SELECT
    record_id,
    datetime_entry,
    'is_unconscious' AS variable,
    'Missing is_unconscious' AS issue,
    is_unconscious AS current_value
  FROM maternal_core
  WHERE (is_unconscious IS NULL OR TRIM(is_unconscious) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_convulsing AS (
  -- Missing is_convulsing
  SELECT
    record_id,
    datetime_entry,
    'is_convulsing' AS variable,
    'Missing is_convulsing' AS issue,
    is_convulsing AS current_value
  FROM maternal_core
  WHERE (is_convulsing IS NULL OR TRIM(is_convulsing) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_epigastric_pain AS (
  -- Missing is_epigastric_pain
  SELECT
    record_id,
    datetime_entry,
    'is_epigastric_pain' AS variable,
    'Missing is_epigastric_pain' AS issue,
    is_epigastric_pain AS current_value
  FROM maternal_core
  WHERE (is_epigastric_pain IS NULL OR TRIM(is_epigastric_pain) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_abnormal_heart_rate AS (
  -- Missing is_abnormal_heart_rate
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_heart_rate' AS variable,
    'Missing is_abnormal_heart_rate' AS issue,
    is_abnormal_heart_rate AS current_value
  FROM maternal_core
  WHERE (is_abnormal_heart_rate IS NULL OR TRIM(is_abnormal_heart_rate) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_abnormal_f_heart_rate AS (
  -- Missing is_abnormal_f_heart_rate
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_f_heart_rate' AS variable,
    'Missing is_abnormal_f_heart_rate' AS issue,
    is_abnormal_f_heart_rate AS current_value
  FROM maternal_core
  WHERE (is_abnormal_f_heart_rate IS NULL OR TRIM(is_abnormal_f_heart_rate) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_headache AS (
  -- Missing is_headache
  SELECT
    record_id,
    datetime_entry,
    'is_headache' AS variable,
    'Missing is_headache' AS issue,
    is_headache AS current_value
  FROM maternal_core
  WHERE (is_headache IS NULL OR TRIM(is_headache) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_abnormal_systolic_bp AS (
  -- Missing is_abnormal_systolic_bp
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_systolic_bp' AS variable,
    'Missing is_abnormal_systolic_bp' AS issue,
    is_abnormal_systolic_bp AS current_value
  FROM maternal_core
  WHERE (is_abnormal_systolic_bp IS NULL OR TRIM(is_abnormal_systolic_bp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_dysponea AS (
  -- Missing is_dysponea
  SELECT
    record_id,
    datetime_entry,
    'is_dysponea' AS variable,
    'Missing is_dysponea' AS issue,
    is_dysponea AS current_value
  FROM maternal_core
  WHERE (is_dysponea IS NULL OR TRIM(is_dysponea) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_rom_gt_18h AS (
  -- Missing is_rom_gt_18h
  SELECT
    record_id,
    datetime_entry,
    'is_rom_gt_18h' AS variable,
    'Missing is_rom_gt_18h' AS issue,
    is_rom_gt_18h AS current_value
  FROM maternal_core
  WHERE (is_rom_gt_18h IS NULL OR TRIM(is_rom_gt_18h) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_abnormal_diastolic_bp AS (
  -- Missing is_abnormal_diastolic_bp
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_diastolic_bp' AS variable,
    'Missing is_abnormal_diastolic_bp' AS issue,
    is_abnormal_diastolic_bp AS current_value
  FROM maternal_core
  WHERE (is_abnormal_diastolic_bp IS NULL OR TRIM(is_abnormal_diastolic_bp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_visual_impairment AS (
  -- Missing is_visual_impairment
  SELECT
    record_id,
    datetime_entry,
    'is_visual_impairment' AS variable,
    'Missing is_visual_impairment' AS issue,
    is_visual_impairment AS current_value
  FROM maternal_core
  WHERE (is_visual_impairment IS NULL OR TRIM(is_visual_impairment) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_body_swelling AS (
  -- Missing is_body_swelling
  SELECT
    record_id,
    datetime_entry,
    'is_body_swelling' AS variable,
    'Missing is_body_swelling' AS issue,
    is_body_swelling AS current_value
  FROM maternal_core
  WHERE (is_body_swelling IS NULL OR TRIM(is_body_swelling) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_rom_early AS (
  -- Missing is_rom_early
  SELECT
    record_id,
    datetime_entry,
    'is_rom_early' AS variable,
    'Missing is_rom_early' AS issue,
    is_rom_early AS current_value
  FROM maternal_core
  WHERE (is_rom_early IS NULL OR TRIM(is_rom_early) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_other_obs_emergency AS (
  -- Missing is_other_obs_emergency
  SELECT
    record_id,
    datetime_entry,
    'is_other_obs_emergency' AS variable,
    'Missing is_other_obs_emergency' AS issue,
    is_other_obs_emergency AS current_value
  FROM maternal_core
  WHERE (is_other_obs_emergency IS NULL OR TRIM(is_other_obs_emergency) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_name_triaging_clinician AS (
  -- Missing name_triaging_clinician
  SELECT
    record_id,
    datetime_entry,
    'name_triaging_clinician' AS variable,
    'Missing name_triaging_clinician' AS issue,
    name_triaging_clinician AS current_value
  FROM maternal_core
  WHERE (name_triaging_clinician IS NULL OR TRIM(name_triaging_clinician) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_date_triaging AS (
  -- Missing date_triaging
  SELECT
    record_id,
    datetime_entry,
    'date_triaging' AS variable,
    'Missing date_triaging' AS issue,
    date_triaging AS current_value
  FROM maternal_core
  WHERE (date_triaging IS NULL OR TRIM(date_triaging) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

future_date_triaging AS (
  -- Future date_triaging
  SELECT
    record_id,
    datetime_entry,
    'date_triaging' AS variable,
    'Future date_triaging' AS issue,
    date_triaging AS current_value
  FROM maternal_core
  WHERE date_triaging IS NOT NULL
    AND TRIM(date_triaging) != ''
    AND TRY_CAST(date_triaging AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_time_triaging AS (
  -- Missing time_triaging
  SELECT
    record_id,
    datetime_entry,
    'time_triaging' AS variable,
    'Missing time_triaging' AS issue,
    time_triaging AS current_value
  FROM maternal_core
  WHERE (time_triaging IS NULL OR TRIM(time_triaging) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_time_triaging AS (
  -- Invalid time_triaging format (expected HH:MM 12hr or 24hr)
  SELECT
    record_id,
    datetime_entry,
    'time_triaging' AS variable,
    'Invalid time_triaging format (expected HH:MM 12hr or 24hr)' AS issue,
    time_triaging AS current_value
  FROM maternal_core
  WHERE time_triaging IS NOT NULL
    AND TRIM(time_triaging) != ''
    AND TRIM(time_triaging) != 'NI'
    AND NOT (
      regexp_matches(TRIM(time_triaging), '^(0?[1-9]|1[0-2]):[0-5][0-9]$')
      OR
      regexp_matches(TRIM(time_triaging), '^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_triaging_time_unit AS (
  -- Missing triaging_time_unit when time_triaging is present and not NI
  SELECT
    record_id,
    datetime_entry,
    'triaging_time_unit' AS variable,
    'Missing triaging_time_unit' AS issue,
    triaging_time_unit AS current_value
  FROM maternal_core
  WHERE (triaging_time_unit IS NULL OR TRIM(triaging_time_unit) = '')
    AND time_triaging IS NOT NULL
    AND TRIM(time_triaging) != ''
    AND TRIM(time_triaging) != 'NI'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_date_lmp_complete_status AS (
  -- Missing date_lmp_complete_status
  SELECT
    record_id,
    datetime_entry,
    'date_lmp_complete_status' AS variable,
    'Missing date_lmp_complete_status' AS issue,
    date_lmp_complete_status AS current_value
  FROM maternal_core
  WHERE (date_lmp_complete_status IS NULL OR TRIM(date_lmp_complete_status) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_date_lmp AS (
  -- Missing date_lmp
  SELECT
    record_id,
    datetime_entry,
    'date_lmp' AS variable,
    'Missing date_lmp' AS issue,
    date_lmp AS current_value
  FROM maternal_core
  WHERE (date_lmp IS NULL OR TRIM(date_lmp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

future_date_lmp AS (
  -- Future date_lmp
  SELECT
    record_id,
    datetime_entry,
    'date_lmp' AS variable,
    'Future date_lmp' AS issue,
    date_lmp AS current_value
  FROM maternal_core
  WHERE date_lmp IS NOT NULL
    AND TRIM(date_lmp) != ''
    AND TRY_CAST(date_lmp AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

date_lmp_after_admission AS (
  -- date_lmp cannot be after admission_date
  SELECT
    record_id,
    datetime_entry,
    'date_lmp' AS variable,
    'date_lmp is after admission_date (LMP should be before admission)' AS issue,
    date_lmp AS current_value
  FROM maternal_core
  WHERE date_lmp IS NOT NULL
    AND TRIM(date_lmp) != ''
    AND admission_date IS NOT NULL
    AND TRIM(admission_date) != ''
    AND TRY_CAST(date_lmp AS DATE) > TRY_CAST(admission_date AS DATE)
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_date_edd_complete_status AS (
  -- Missing date_edd_complete_status
  SELECT
    record_id,
    datetime_entry,
    'date_edd_complete_status' AS variable,
    'Missing date_edd_complete_status' AS issue,
    date_edd_complete_status AS current_value
  FROM maternal_core
  WHERE (date_edd_complete_status IS NULL OR TRIM(date_edd_complete_status) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_date_edd AS (
  -- Missing date_edd
  SELECT
    record_id,
    datetime_entry,
    'date_edd' AS variable,
    'Missing date_edd' AS issue,
    date_edd AS current_value
  FROM maternal_core
  WHERE (date_edd IS NULL OR TRIM(date_edd) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

-- future_date_edd AS (
  -- Future date_edd
  -- SELECT
   -- record_id,
   -- datetime_entry,
    -- 'date_edd' AS variable,
  --  'Future date_edd' AS issue,
   -- date_edd AS current_value
--  FROM maternal_core
--  WHERE date_edd IS NOT NULL
 --   AND TRIM(date_edd) != ''
 --   AND TRY_CAST(date_edd AS DATE) > CURRENT_DATE
 --   AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
--),

date_edd_before_lmp AS (
  -- date_edd cannot be before LMP
  SELECT
    record_id,
    datetime_entry,
    'date_edd' AS variable,
    'date_edd is before date_lmp (EDD should be after LMP)' AS issue,
    date_edd AS current_value
  FROM maternal_core
  WHERE date_edd IS NOT NULL
    AND TRIM(date_edd) != ''
    AND date_lmp IS NOT NULL
    AND TRIM(date_lmp) != ''
    AND TRY_CAST(date_edd AS DATE) < TRY_CAST(date_lmp AS DATE)
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_parity_birth AS (
  -- Missing parity_birth
  SELECT
    record_id,
    datetime_entry,
    'parity_birth' AS variable,
    'Missing parity_birth' AS issue,
    parity_birth AS current_value
  FROM maternal_core
  WHERE (parity_birth IS NULL OR TRIM(parity_birth) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_parity_birth AS (
  -- parity_birth out of range (expected 0-15)
  SELECT
    record_id,
    datetime_entry,
    'parity_birth' AS variable,
    'parity_birth out of range (expected 0-15)' AS issue,
    parity_birth AS current_value
  FROM maternal_core
  WHERE parity_birth IS NOT NULL
    AND TRIM(parity_birth) != ''
    AND TRIM(parity_birth) != 'NI'
    AND (
      TRY_CAST(parity_birth AS INTEGER) IS NULL
      OR TRY_CAST(parity_birth AS INTEGER) < 0
      OR TRY_CAST(parity_birth AS INTEGER) > 15
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_parity_miscarriages AS (
  -- Missing parity_miscarriages
  SELECT
    record_id,
    datetime_entry,
    'parity_miscarriages' AS variable,
    'Missing parity_miscarriages' AS issue,
    parity_miscarriages AS current_value
  FROM maternal_core
  WHERE (parity_miscarriages IS NULL OR TRIM(parity_miscarriages) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_parity_miscarriages AS (
  -- parity_miscarriages out of range (expected 0-15)
  SELECT
    record_id,
    datetime_entry,
    'parity_miscarriages' AS variable,
    'parity_miscarriages out of range (expected 0-15)' AS issue,
    parity_miscarriages AS current_value
  FROM maternal_core
  WHERE parity_miscarriages IS NOT NULL
    AND TRIM(parity_miscarriages) != ''
    AND TRIM(parity_miscarriages) != 'NI'
    AND (
      TRY_CAST(parity_miscarriages AS INTEGER) IS NULL
      OR TRY_CAST(parity_miscarriages AS INTEGER) < 0
      OR TRY_CAST(parity_miscarriages AS INTEGER) > 15
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_gravid_count AS (
  -- Missing gravid_count
  SELECT
    record_id,
    datetime_entry,
    'gravid_count' AS variable,
    'Missing gravid_count' AS issue,
    gravid_count AS current_value
  FROM maternal_core
  WHERE (gravid_count IS NULL OR TRIM(gravid_count) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_gravid_count AS (
  -- gravid_count out of range (expected 1-20)
  SELECT
    record_id,
    datetime_entry,
    'gravid_count' AS variable,
    'gravid_count out of range (expected 1-20)' AS issue,
    gravid_count AS current_value
  FROM maternal_core
  WHERE gravid_count IS NOT NULL
    AND TRIM(gravid_count) != ''
    AND TRIM(gravid_count) != 'NI'
    AND (
      TRY_CAST(gravid_count AS INTEGER) IS NULL
      OR TRY_CAST(gravid_count AS INTEGER) < 1
      OR TRY_CAST(gravid_count AS INTEGER) > 20
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_attended_anc AS (
  -- Missing is_attended_anc
  SELECT
    record_id,
    datetime_entry,
    'is_attended_anc' AS variable,
    'Missing is_attended_anc' AS issue,
    is_attended_anc AS current_value
  FROM maternal_core
  WHERE (is_attended_anc IS NULL OR TRIM(is_attended_anc) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_date_first_anc AS (
  -- Missing date_first_anc (only when is_attended_anc = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_first_anc' AS variable,
    'Missing date_first_anc (attended ANC but no date recorded)' AS issue,
    date_first_anc AS current_value
  FROM maternal_core
  WHERE (date_first_anc IS NULL OR TRIM(date_first_anc) = '')
    AND is_attended_anc = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

future_date_first_anc AS (
  -- Future date_first_anc (only when is_attended_anc = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_first_anc' AS variable,
    'Future date_first_anc' AS issue,
    date_first_anc AS current_value
  FROM maternal_core
  WHERE date_first_anc IS NOT NULL
    AND TRIM(date_first_anc) != ''
    AND is_attended_anc = '1'
    AND TRY_CAST(date_first_anc AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

date_first_anc_after_admission AS (
  -- date_first_anc cannot be after admission_date (only when is_attended_anc = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_first_anc' AS variable,
    'date_first_anc is after admission_date (ANC should occur before admission)' AS issue,
    date_first_anc AS current_value
  FROM maternal_core
  WHERE date_first_anc IS NOT NULL
    AND TRIM(date_first_anc) != ''
    AND is_attended_anc = '1'
    AND admission_date IS NOT NULL
    AND TRIM(admission_date) != ''
    AND TRY_CAST(date_first_anc AS DATE) > TRY_CAST(admission_date AS DATE)
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_anc_clinic_name AS (
  -- Missing anc_clinic_name (only when is_attended_anc = '1')
  SELECT
    record_id,
    datetime_entry,
    'anc_clinic_name' AS variable,
    'Missing anc_clinic_name (attended ANC but no clinic name recorded)' AS issue,
    anc_clinic_name AS current_value
  FROM maternal_core
  WHERE (anc_clinic_name IS NULL OR TRIM(anc_clinic_name) = '')
    AND is_attended_anc = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_anc_clinic_name_other AS (
  -- Missing anc_clinic_name_other when anc_clinic_name = 'OTH'
  SELECT
    record_id,
    datetime_entry,
    'anc_clinic_name_other' AS variable,
    'Missing anc_clinic_name_other (clinic name = Other but no specification)' AS issue,
    anc_clinic_name_other AS current_value
  FROM maternal_core
  WHERE (anc_clinic_name_other IS NULL OR TRIM(anc_clinic_name_other) = '')
    AND is_attended_anc = '1'
    AND anc_clinic_name IS NOT NULL
    AND TRIM(anc_clinic_name) = 'OTH'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_count_anc_visits AS (
  -- Missing count_anc_visits (only when is_attended_anc = '1')
  SELECT
    record_id,
    datetime_entry,
    'count_anc_visits' AS variable,
    'Missing count_anc_visits (attended ANC but no visit count recorded)' AS issue,
    count_anc_visits AS current_value
  FROM maternal_core
  WHERE (count_anc_visits IS NULL OR TRIM(count_anc_visits) = '')
    AND is_attended_anc = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_count_anc_visits AS (
  -- count_anc_visits out of range (expected 1-20)
  SELECT
    record_id,
    datetime_entry,
    'count_anc_visits' AS variable,
    'count_anc_visits out of range (expected 1-20 visits)' AS issue,
    count_anc_visits AS current_value
  FROM maternal_core
  WHERE count_anc_visits IS NOT NULL
    AND TRIM(count_anc_visits) != ''
    AND TRIM(count_anc_visits) != 'NI'
    AND is_attended_anc = '1'
    AND (
      TRY_CAST(count_anc_visits AS INTEGER) IS NULL
      OR TRY_CAST(count_anc_visits AS INTEGER) < 1
      OR TRY_CAST(count_anc_visits AS INTEGER) > 20
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),
missing_is_anc_us AS (
  -- Missing is_anc_us
  SELECT
    record_id,
    datetime_entry,
    'is_anc_us' AS variable,
    'Missing is_anc_us' AS issue,
    is_anc_us AS current_value
  FROM maternal_core
  WHERE (is_anc_us IS NULL OR TRIM(is_anc_us) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_date_anc_us_first AS (
  -- Missing date_anc_us_first (only when is_anc_us = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_anc_us_first' AS variable,
    'Missing date_anc_us_first (ANC ultrasound = Yes but no date recorded)' AS issue,
    date_anc_us_first AS current_value
  FROM maternal_core
  WHERE (date_anc_us_first IS NULL OR TRIM(date_anc_us_first) = '')
    AND is_anc_us = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

future_date_anc_us_first AS (
  -- Future date_anc_us_first (only when is_anc_us = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_anc_us_first' AS variable,
    'Future date_anc_us_first' AS issue,
    date_anc_us_first AS current_value
  FROM maternal_core
  WHERE date_anc_us_first IS NOT NULL
    AND TRIM(date_anc_us_first) != ''
    AND is_anc_us = '1'
    AND TRY_CAST(date_anc_us_first AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

date_anc_us_first_after_admission AS (
  -- date_anc_us_first cannot be after admission_date (only when is_anc_us = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_anc_us_first' AS variable,
    'date_anc_us_first is after admission_date (ANC ultrasound should occur before admission)' AS issue,
    date_anc_us_first AS current_value
  FROM maternal_core
  WHERE date_anc_us_first IS NOT NULL
    AND TRIM(date_anc_us_first) != ''
    AND is_anc_us = '1'
    AND admission_date IS NOT NULL
    AND TRIM(admission_date) != ''
    AND TRY_CAST(date_anc_us_first AS DATE) > TRY_CAST(admission_date AS DATE)
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_gestation AS (
  -- Missing gestation
  SELECT
    record_id,
    datetime_entry,
    'gestation' AS variable,
    'Missing gestation' AS issue,
    gestation AS current_value
  FROM maternal_core
  WHERE (gestation IS NULL OR TRIM(gestation) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_gestation AS (
  -- gestation out of range (expected 1-45 weeks)
  SELECT
    record_id,
    datetime_entry,
    'gestation' AS variable,
    'gestation out of range (expected 1-45 weeks)' AS issue,
    gestation AS current_value
  FROM maternal_core
  WHERE gestation IS NOT NULL
    AND TRIM(gestation) != ''
    AND TRIM(gestation) != 'NI'
    AND (
      TRY_CAST(gestation AS INTEGER) IS NULL
      OR TRY_CAST(gestation AS INTEGER) < 1
      OR TRY_CAST(gestation AS INTEGER) > 45
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_gest_lmp AS (
  -- Missing is_gest_lmp
  SELECT
    record_id,
    datetime_entry,
    'is_gest_lmp' AS variable,
    'Missing is_gest_lmp' AS issue,
    is_gest_lmp AS current_value
  FROM maternal_core
  WHERE (is_gest_lmp IS NULL OR TRIM(is_gest_lmp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_gestation_from_lmp AS (
  -- Missing gestation_from_lmp (only when is_gest_lmp = '1')
  SELECT
    record_id,
    datetime_entry,
    'gestation_from_lmp' AS variable,
    'Missing gestation_from_lmp (gestation from LMP = Yes but no value recorded)' AS issue,
    gestation_from_lmp AS current_value
  FROM maternal_core
  WHERE (gestation_from_lmp IS NULL OR TRIM(gestation_from_lmp) = '')
    AND is_gest_lmp = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-08-05 09:42:05'
),

invalid_gestation_from_lmp AS (
  -- gestation_from_lmp out of range (expected 1-45 weeks)
  SELECT
    record_id,
    datetime_entry,
    'gestation_from_lmp' AS variable,
    'gestation_from_lmp out of range (expected 1-45 weeks)' AS issue,
    gestation_from_lmp AS current_value
  FROM maternal_core
  WHERE gestation_from_lmp IS NOT NULL
    AND TRIM(gestation_from_lmp) != ''
    AND TRIM(gestation_from_lmp) != 'NI'
    AND is_gest_lmp = '1'
    AND (
      TRY_CAST(gestation_from_lmp AS INTEGER) IS NULL
      OR TRY_CAST(gestation_from_lmp AS INTEGER) < 1
      OR TRY_CAST(gestation_from_lmp AS INTEGER) > 45
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-08-05 09:42:05'
),


missing_is_gest_us AS (
  -- Missing is_gest_us
  SELECT
    record_id,
    datetime_entry,
    'is_gest_us' AS variable,
    'Missing is_gest_us' AS issue,
    is_gest_us AS current_value
  FROM maternal_core
  WHERE (is_gest_us IS NULL OR TRIM(is_gest_us) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_gestation_from_us AS (
  -- Missing gestation_from_us (only when is_gest_us = '1')
  SELECT
    record_id,
    datetime_entry,
    'gestation_from_us' AS variable,
    'Missing gestation_from_us (gestation from U/S = Yes but no value recorded)' AS issue,
    gestation_from_us AS current_value
  FROM maternal_core
  WHERE (gestation_from_us IS NULL OR TRIM(gestation_from_us) = '')
    AND is_gest_us = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-08-05 10:03:26'
),

invalid_gestation_from_us AS (
  -- gestation_from_us out of range (expected 1-45 weeks)
  SELECT
    record_id,
    datetime_entry,
    'gestation_from_us' AS variable,
    'gestation_from_us out of range (expected 1-45 weeks)' AS issue,
    gestation_from_us AS current_value
  FROM maternal_core
  WHERE gestation_from_us IS NOT NULL
    AND TRIM(gestation_from_us) != ''
    AND TRIM(gestation_from_us) != 'NI'
    AND is_gest_us = '1'
    AND (
      TRY_CAST(gestation_from_us AS INTEGER) IS NULL
      OR TRY_CAST(gestation_from_us AS INTEGER) < 1
      OR TRY_CAST(gestation_from_us AS INTEGER) > 45
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-08-05 10:03:26'
),


missing_is_pocus_used AS (
  -- Missing is_pocus_used
  SELECT
    record_id,
    datetime_entry,
    'is_pocus_used' AS variable,
    'Missing is_pocus_used' AS issue,
    is_pocus_used AS current_value
  FROM maternal_core
  WHERE (is_pocus_used IS NULL OR TRIM(is_pocus_used) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_mother_weight_kg AS (
  -- Missing mother_weight_kg
  SELECT
    record_id,
    datetime_entry,
    'mother_weight_kg' AS variable,
    'Missing mother_weight_kg' AS issue,
    mother_weight_kg AS current_value
  FROM maternal_core
  WHERE (mother_weight_kg IS NULL OR TRIM(mother_weight_kg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_mother_weight_kg AS (
  -- mother_weight_kg out of range (expected 30-200 kg)
  SELECT
    record_id,
    datetime_entry,
    'mother_weight_kg' AS variable,
    'mother_weight_kg out of range (expected 30-200 kg)' AS issue,
    mother_weight_kg AS current_value
  FROM maternal_core
  WHERE mother_weight_kg IS NOT NULL
    AND TRIM(mother_weight_kg) != ''
    AND TRIM(mother_weight_kg) != 'NI'
    AND TRIM(mother_weight_kg) != 'ND'
    AND (
      TRY_CAST(mother_weight_kg AS DOUBLE) IS NULL
      OR TRY_CAST(mother_weight_kg AS DOUBLE) < 30
      OR TRY_CAST(mother_weight_kg AS DOUBLE) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_mother_height_cm AS (
  -- Missing mother_height_cm
  SELECT
    record_id,
    datetime_entry,
    'mother_height_cm' AS variable,
    'Missing mother_height_cm' AS issue,
    mother_height_cm AS current_value
  FROM maternal_core
  WHERE (mother_height_cm IS NULL OR TRIM(mother_height_cm) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_mother_height_cm AS (
  -- mother_height_cm out of range (expected 100-220 cm)
  SELECT
    record_id,
    datetime_entry,
    'mother_height_cm' AS variable,
    'mother_height_cm out of range (expected 100-220 cm)' AS issue,
    mother_height_cm AS current_value
  FROM maternal_core
  WHERE mother_height_cm IS NOT NULL
    AND TRIM(mother_height_cm) != ''
    AND TRIM(mother_height_cm) != 'NI'
    AND TRIM(mother_height_cm) != 'ND'
    AND (
      TRY_CAST(mother_height_cm AS DOUBLE) IS NULL
      OR TRY_CAST(mother_height_cm AS DOUBLE) < 100
      OR TRY_CAST(mother_height_cm AS DOUBLE) > 220
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_mother_bmi AS (
  -- Missing mother_bmi
  SELECT
    record_id,
    datetime_entry,
    'mother_bmi' AS variable,
    'Missing mother_bmi' AS issue,
    mother_bmi AS current_value
  FROM maternal_core
  WHERE (mother_bmi IS NULL OR TRIM(mother_bmi) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_mother_bmi AS (
  -- mother_bmi out of range (expected 12-60)
  SELECT
    record_id,
    datetime_entry,
    'mother_bmi' AS variable,
    'mother_bmi out of range (expected 12-60)' AS issue,
    mother_bmi AS current_value
  FROM maternal_core
  WHERE mother_bmi IS NOT NULL
    AND TRIM(mother_bmi) != ''
    AND TRIM(mother_bmi) != 'NI'
    AND TRIM(mother_bmi) != 'ND'
    AND (
      TRY_CAST(mother_bmi AS DOUBLE) IS NULL
      OR TRY_CAST(mother_bmi AS DOUBLE) < 12
      OR TRY_CAST(mother_bmi AS DOUBLE) > 60
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_muac AS (
  -- Missing muac
  SELECT
    record_id,
    datetime_entry,
    'muac' AS variable,
    'Missing muac' AS issue,
    muac AS current_value
  FROM maternal_core
  WHERE (muac IS NULL OR TRIM(muac) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-13 13:46:09'
),

invalid_muac AS (
  -- muac out of range (expected 10-50 cm)
  SELECT
    record_id,
    datetime_entry,
    'muac' AS variable,
    'muac out of range (expected 10-50 cm)' AS issue,
    muac AS current_value
  FROM maternal_core
  WHERE muac IS NOT NULL
    AND TRIM(muac) != ''
    AND TRIM(muac) != 'NI'
    AND TRIM(muac) != 'ND'
    AND (
      TRY_CAST(muac AS DOUBLE) IS NULL
      OR TRY_CAST(muac AS DOUBLE) < 10
      OR TRY_CAST(muac AS DOUBLE) > 50
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-13 13:46:09'
),


missing_is_lower_abd_pain AS (
  -- Missing is_lower_abd_pain
  SELECT
    record_id,
    datetime_entry,
    'is_lower_abd_pain' AS variable,
    'Missing is_lower_abd_pain' AS issue,
    is_lower_abd_pain AS current_value
  FROM maternal_core
  WHERE (is_lower_abd_pain IS NULL OR TRIM(is_lower_abd_pain) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_off_vag_discharge AS (
  -- Missing is_off_vag_discharge
  SELECT
    record_id,
    datetime_entry,
    'is_off_vag_discharge' AS variable,
    'Missing is_off_vag_discharge' AS issue,
    is_off_vag_discharge AS current_value
  FROM maternal_core
  WHERE (is_off_vag_discharge IS NULL OR TRIM(is_off_vag_discharge) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_diff_breathing AS (
  -- Missing is_diff_breathing
  SELECT
    record_id,
    datetime_entry,
    'is_diff_breathing' AS variable,
    'Missing is_diff_breathing' AS issue,
    is_diff_breathing AS current_value
  FROM maternal_core
  WHERE (is_diff_breathing IS NULL OR TRIM(is_diff_breathing) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_abd_pain_other AS (
  -- Missing is_abd_pain_other
  SELECT
    record_id,
    datetime_entry,
    'is_abd_pain_other' AS variable,
    'Missing is_abd_pain_other' AS issue,
    is_abd_pain_other AS current_value
  FROM maternal_core
  WHERE (is_abd_pain_other IS NULL OR TRIM(is_abd_pain_other) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_screen_tb AS (
  -- Missing is_screen_tb
  SELECT
    record_id,
    datetime_entry,
    'is_screen_tb' AS variable,
    'Missing is_screen_tb' AS issue,
    is_screen_tb AS current_value
  FROM maternal_core
  WHERE (is_screen_tb IS NULL OR TRIM(is_screen_tb) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_chest_pain AS (
  -- Missing is_chest_pain
  SELECT
    record_id,
    datetime_entry,
    'is_chest_pain' AS variable,
    'Missing is_chest_pain' AS issue,
    is_chest_pain AS current_value
  FROM maternal_core
  WHERE (is_chest_pain IS NULL OR TRIM(is_chest_pain) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_weight_loss AS (
  -- Missing is_weight_loss
  SELECT
    record_id,
    datetime_entry,
    'is_weight_loss' AS variable,
    'Missing is_weight_loss' AS issue,
    is_weight_loss AS current_value
  FROM maternal_core
  WHERE (is_weight_loss IS NULL OR TRIM(is_weight_loss) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_reduced_f_movements AS (
  -- Missing is_reduced_f_movements
  SELECT
    record_id,
    datetime_entry,
    'is_reduced_f_movements' AS variable,
    'Missing is_reduced_f_movements' AS issue,
    is_reduced_f_movements AS current_value
  FROM maternal_core
  WHERE (is_reduced_f_movements IS NULL OR TRIM(is_reduced_f_movements) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_vomiting AS (
  -- Missing is_vomiting
  SELECT
    record_id,
    datetime_entry,
    'is_vomiting' AS variable,
    'Missing is_vomiting' AS issue,
    is_vomiting AS current_value
  FROM maternal_core
  WHERE (is_vomiting IS NULL OR TRIM(is_vomiting) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_visual_changes AS (
  -- Missing is_visual_changes
  SELECT
    record_id,
    datetime_entry,
    'is_visual_changes' AS variable,
    'Missing is_visual_changes' AS issue,
    is_visual_changes AS current_value
  FROM maternal_core
  WHERE (is_visual_changes IS NULL OR TRIM(is_visual_changes) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_fever AS (
  -- Missing is_fever
  SELECT
    record_id,
    datetime_entry,
    'is_fever' AS variable,
    'Missing is_fever' AS issue,
    is_fever AS current_value
  FROM maternal_core
  WHERE (is_fever IS NULL OR TRIM(is_fever) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_painful_urination AS (
  -- Missing is_painful_urination
  SELECT
    record_id,
    datetime_entry,
    'is_painful_urination' AS variable,
    'Missing is_painful_urination' AS issue,
    is_painful_urination AS current_value
  FROM maternal_core
  WHERE (is_painful_urination IS NULL OR TRIM(is_painful_urination) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_cough_lt_2_wks AS (
  -- Missing is_cough_lt_2_wks
  SELECT
    record_id,
    datetime_entry,
    'is_cough_lt_2_wks' AS variable,
    'Missing is_cough_lt_2_wks' AS issue,
    is_cough_lt_2_wks AS current_value
  FROM maternal_core
  WHERE (is_cough_lt_2_wks IS NULL OR TRIM(is_cough_lt_2_wks) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_cough_gt_or_equal_2_wks AS (
  -- Missing is_cough_gt_or_equal_2_wks
  SELECT
    record_id,
    datetime_entry,
    'is_cough_gt_or_equal_2_wks' AS variable,
    'Missing is_cough_gt_or_equal_2_wks' AS issue,
    is_cough_gt_or_equal_2_wks AS current_value
  FROM maternal_core
  WHERE (is_cough_gt_or_equal_2_wks IS NULL OR TRIM(is_cough_gt_or_equal_2_wks) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_drainage_of_amn_fluid AS (
  -- Missing is_drainage_of_amn_fluid
  SELECT
    record_id,
    datetime_entry,
    'is_drainage_of_amn_fluid' AS variable,
    'Missing is_drainage_of_amn_fluid' AS issue,
    is_drainage_of_amn_fluid AS current_value
  FROM maternal_core
  WHERE (is_drainage_of_amn_fluid IS NULL OR TRIM(is_drainage_of_amn_fluid) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_oedema AS (
  -- Missing is_oedema
  SELECT
    record_id,
    datetime_entry,
    'is_oedema' AS variable,
    'Missing is_oedema' AS issue,
    is_oedema AS current_value
  FROM maternal_core
  WHERE (is_oedema IS NULL OR TRIM(is_oedema) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_other_complaint AS (
  -- Missing is_other_complaint
  SELECT
    record_id,
    datetime_entry,
    'is_other_complaint' AS variable,
    'Missing is_other_complaint' AS issue,
    is_other_complaint AS current_value
  FROM maternal_core
  WHERE (is_other_complaint IS NULL OR TRIM(is_other_complaint) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_date_drainage_of_amn_fluid AS (
  -- Missing date_drainage_of_amn_fluid (only when is_drainage_of_amn_fluid = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_drainage_of_amn_fluid' AS variable,
    'Missing date_drainage_of_amn_fluid (drainage of amniotic fluid = Yes but no date recorded)' AS issue,
    date_drainage_of_amn_fluid AS current_value
  FROM maternal_core
  WHERE (date_drainage_of_amn_fluid IS NULL OR TRIM(date_drainage_of_amn_fluid) = '')
    AND is_drainage_of_amn_fluid = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
),

future_date_drainage_of_amn_fluid AS (
  -- Future date_drainage_of_amn_fluid (only when is_drainage_of_amn_fluid = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_drainage_of_amn_fluid' AS variable,
    'Future date_drainage_of_amn_fluid' AS issue,
    date_drainage_of_amn_fluid AS current_value
  FROM maternal_core
  WHERE date_drainage_of_amn_fluid IS NOT NULL
    AND TRIM(date_drainage_of_amn_fluid) != ''
    AND is_drainage_of_amn_fluid = '1'
    AND TRY_CAST(date_drainage_of_amn_fluid AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
),

date_drainage_after_admission AS (
  -- date_drainage_of_amn_fluid cannot be after admission_date
  SELECT
    record_id,
    datetime_entry,
    'date_drainage_of_amn_fluid' AS variable,
    'date_drainage_of_amn_fluid is after admission_date (drainage should occur before admission)' AS issue,
    date_drainage_of_amn_fluid AS current_value
  FROM maternal_core
  WHERE date_drainage_of_amn_fluid IS NOT NULL
    AND TRIM(date_drainage_of_amn_fluid) != ''
    AND is_drainage_of_amn_fluid = '1'
    AND admission_date IS NOT NULL
    AND TRIM(admission_date) != ''
    AND TRY_CAST(date_drainage_of_amn_fluid AS DATE) > TRY_CAST(admission_date AS DATE)
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
),


missing_time_drainage_of_amn_fluid AS (
  -- Missing time_drainage_of_amn_fluid (only when is_drainage_of_amn_fluid = '1')
  SELECT
    record_id,
    datetime_entry,
    'time_drainage_of_amn_fluid' AS variable,
    'Missing time_drainage_of_amn_fluid (drainage of amniotic fluid = Yes but no time recorded)' AS issue,
    time_drainage_of_amn_fluid AS current_value
  FROM maternal_core
  WHERE (time_drainage_of_amn_fluid IS NULL OR TRIM(time_drainage_of_amn_fluid) = '')
    AND is_drainage_of_amn_fluid = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
),

invalid_time_drainage_of_amn_fluid AS (
  -- Invalid time_drainage_of_amn_fluid format (expected HH:MM 12hr or 24hr)
  SELECT
    record_id,
    datetime_entry,
    'time_drainage_of_amn_fluid' AS variable,
    'Invalid time_drainage_of_amn_fluid format (expected HH:MM 12hr or 24hr)' AS issue,
    time_drainage_of_amn_fluid AS current_value
  FROM maternal_core
  WHERE time_drainage_of_amn_fluid IS NOT NULL
    AND TRIM(time_drainage_of_amn_fluid) != ''
    AND TRIM(time_drainage_of_amn_fluid) != 'NI'
    AND is_drainage_of_amn_fluid = '1'
    AND NOT (
      regexp_matches(TRIM(time_drainage_of_amn_fluid), '^(0?[1-9]|1[0-2]):[0-5][0-9]$')
      OR
      regexp_matches(TRIM(time_drainage_of_amn_fluid), '^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
),

missing_time_drainage_units AS (
  -- Missing time_drainage_units when time_drainage_of_amn_fluid is present and not NI
  SELECT
    record_id,
    datetime_entry,
    'time_drainage_units' AS variable,
    'Missing time_drainage_units' AS issue,
    time_drainage_units AS current_value
  FROM maternal_core
  WHERE (time_drainage_units IS NULL OR TRIM(time_drainage_units) = '')
    AND time_drainage_of_amn_fluid IS NOT NULL
    AND TRIM(time_drainage_of_amn_fluid) != ''
    AND TRIM(time_drainage_of_amn_fluid) != 'NI'
    AND is_drainage_of_amn_fluid = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-06 12:24:54'
),


-- missing_oedema_location_oth AS (
  -- Missing oedema_location_oth (only when oedema_location___999 = '1')
 -- SELECT
  --  record_id,
  --  datetime_entry,
   -- 'oedema_location_oth' AS variable,
  --  'Missing oedema_location_oth (oedema location = Other but no specification)' AS issue,
  --  oedema_location_oth AS current_value
  -- FROM maternal_core
  -- WHERE (oedema_location_oth IS NULL OR TRIM(oedema_location_oth) = '')
   -- AND oedema_location___999 = '1'
   -- AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
-- ),


missing_other_complaints_specify AS (
  -- Missing other_complaints specification (only when is_other_complaint = '1')
  SELECT
    record_id,
    datetime_entry,
    'other_complaints' AS variable,
    'Missing other_complaints specification (other complaint = Yes but no details provided)' AS issue,
    other_complaints AS current_value
  FROM maternal_core
  WHERE (other_complaints IS NULL OR TRIM(other_complaints) = '')
    AND is_other_complaint = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-13 15:57:06'
),


missing_hb_booking_level AS (
  -- Missing hb_booking_level
  SELECT
    record_id,
    datetime_entry,
    'hb_booking_level' AS variable,
    'Missing hb_booking_level' AS issue,
    hb_booking_level AS current_value
  FROM maternal_core
  WHERE (hb_booking_level IS NULL OR TRIM(hb_booking_level) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_hb_booking_level AS (
  -- hb_booking_level out of range (expected 5-20 g/dL)
  SELECT
    record_id,
    datetime_entry,
    'hb_booking_level' AS variable,
    'hb_booking_level out of range (expected 5-20 g/dL)' AS issue,
    hb_booking_level AS current_value
  FROM maternal_core
  WHERE hb_booking_level IS NOT NULL
    AND TRIM(hb_booking_level) != ''
    AND TRIM(hb_booking_level) != 'NI'
    AND TRIM(hb_booking_level) != 'ND'
    AND (
      TRY_CAST(hb_booking_level AS DOUBLE) IS NULL
      OR TRY_CAST(hb_booking_level AS DOUBLE) < 5
      OR TRY_CAST(hb_booking_level AS DOUBLE) > 20
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_date_booking_hb AS (
  -- Missing date_booking_hb
  SELECT
    record_id,
    datetime_entry,
    'date_booking_hb' AS variable,
    'Missing date_booking_hb' AS issue,
    date_booking_hb AS current_value
  FROM maternal_core
  WHERE (date_booking_hb IS NULL OR TRIM(date_booking_hb) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

future_date_booking_hb AS (
  -- Future date_booking_hb
  SELECT
    record_id,
    datetime_entry,
    'date_booking_hb' AS variable,
    'Future date_booking_hb' AS issue,
    date_booking_hb AS current_value
  FROM maternal_core
  WHERE date_booking_hb IS NOT NULL
    AND TRIM(date_booking_hb) != ''
    AND TRY_CAST(date_booking_hb AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

date_booking_hb_after_admission AS (
  -- date_booking_hb cannot be after admission_date
  SELECT
    record_id,
    datetime_entry,
    'date_booking_hb' AS variable,
    'date_booking_hb is after admission_date (booking Hb should be measured before admission)' AS issue,
    date_booking_hb AS current_value
  FROM maternal_core
  WHERE date_booking_hb IS NOT NULL
    AND TRIM(date_booking_hb) != ''
    AND admission_date IS NOT NULL
    AND TRIM(admission_date) != ''
    AND TRY_CAST(date_booking_hb AS DATE) > TRY_CAST(admission_date AS DATE)
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_rbs_current_level AS (
  -- Missing rbs_current_level
  SELECT
    record_id,
    datetime_entry,
    'rbs_current_level' AS variable,
    'Missing rbs_current_level' AS issue,
    rbs_current_level AS current_value
  FROM maternal_core
  WHERE (rbs_current_level IS NULL OR TRIM(rbs_current_level) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_rbs_current_level AS (
  -- rbs_current_level out of range (expected 2-30 mmol/L)
  SELECT
    record_id,
    datetime_entry,
    'rbs_current_level' AS variable,
    'rbs_current_level out of range (expected 2-30 mmol/L)' AS issue,
    rbs_current_level AS current_value
  FROM maternal_core
  WHERE rbs_current_level IS NOT NULL
    AND TRIM(rbs_current_level) != ''
    AND TRIM(rbs_current_level) != 'NI'
    AND TRIM(rbs_current_level) != 'ND'
    AND (
      TRY_CAST(rbs_current_level AS DOUBLE) IS NULL
      OR TRY_CAST(rbs_current_level AS DOUBLE) < 2
      OR TRY_CAST(rbs_current_level AS DOUBLE) > 30
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_platelets_count AS (
  -- Missing platelets_count
  SELECT
    record_id,
    datetime_entry,
    'platelets_count' AS variable,
    'Missing platelets_count' AS issue,
    platelets_count AS current_value
  FROM maternal_core
  WHERE (platelets_count IS NULL OR TRIM(platelets_count) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_platelets_count AS (
  -- platelets_count out of range (expected 20-999 x10^9/L)
  SELECT
    record_id,
    datetime_entry,
    'platelets_count' AS variable,
    'platelets_count out of range (expected 20-999 x10^9/L)' AS issue,
    platelets_count AS current_value
  FROM maternal_core
  WHERE platelets_count IS NOT NULL
    AND TRIM(platelets_count) != ''
    AND TRIM(platelets_count) != 'NI'
    AND TRIM(platelets_count) != 'ND'
    AND (
      TRY_CAST(platelets_count AS INTEGER) IS NULL
      OR TRY_CAST(platelets_count AS INTEGER) < 20
      OR TRY_CAST(platelets_count AS INTEGER) > 1000
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_wbc_count AS (
  -- Missing wbc_count
  SELECT
    record_id,
    datetime_entry,
    'wbc_count' AS variable,
    'Missing wbc_count' AS issue,
    wbc_count AS current_value
  FROM maternal_core
  WHERE (wbc_count IS NULL OR TRIM(wbc_count) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_wbc_count AS (
  -- wbc_count out of range (expected 2-50 x10^9/L)
  SELECT
    record_id,
    datetime_entry,
    'wbc_count' AS variable,
    'wbc_count out of range (expected 2-50 x10^9/L)' AS issue,
    wbc_count AS current_value
  FROM maternal_core
  WHERE wbc_count IS NOT NULL
    AND TRIM(wbc_count) != ''
    AND TRIM(wbc_count) != 'NI'
    AND TRIM(wbc_count) != 'ND'
    AND (
      TRY_CAST(wbc_count AS DOUBLE) IS NULL
      OR TRY_CAST(wbc_count AS DOUBLE) < 2
      OR TRY_CAST(wbc_count AS DOUBLE) > 50
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_malaria_rdt AS (
  -- Missing is_malaria_rdt
  SELECT
    record_id,
    datetime_entry,
    'is_malaria_rdt' AS variable,
    'Missing is_malaria_rdt' AS issue,
    is_malaria_rdt AS current_value
  FROM maternal_core
  WHERE (is_malaria_rdt IS NULL OR TRIM(is_malaria_rdt) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_blood_group_gxm AS (
  -- Missing blood_group_gxm
  SELECT
    record_id,
    datetime_entry,
    'blood_group_gxm' AS variable,
    'Missing blood_group_gxm' AS issue,
    blood_group_gxm AS current_value
  FROM maternal_core
  WHERE (blood_group_gxm IS NULL OR TRIM(blood_group_gxm) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_blood_group_rh_gxm AS (
  -- Missing blood_group_rh_gxm
  SELECT
    record_id,
    datetime_entry,
    'blood_group_rh_gxm' AS variable,
    'Missing blood_group_rh_gxm' AS issue,
    blood_group_rh_gxm AS current_value
  FROM maternal_core
  WHERE (blood_group_rh_gxm IS NULL OR TRIM(blood_group_rh_gxm) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_anti_d_given AS (
  -- Missing is_anti_d_given (only when blood_group_rh_gxm = '0' i.e., Rh negative)
  SELECT
    record_id,
    datetime_entry,
    'is_anti_d_given' AS variable,
    'Missing is_anti_d_given (Rhesus negative but Anti D given status not recorded)' AS issue,
    is_anti_d_given AS current_value
  FROM maternal_core
  WHERE (is_anti_d_given IS NULL OR TRIM(is_anti_d_given) = '')
    AND blood_group_rh_gxm = '0'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-15 13:52:08'
),


missing_is_hiv_test_done AS (
  -- Missing is_hiv_test_done
  SELECT
    record_id,
    datetime_entry,
    'is_hiv_test_done' AS variable,
    'Missing is_hiv_test_done' AS issue,
    is_hiv_test_done AS current_value
  FROM maternal_core
  WHERE (is_hiv_test_done IS NULL OR TRIM(is_hiv_test_done) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_hiv_test_result AS (
  -- Missing hiv_test_result (only when is_hiv_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'hiv_test_result' AS variable,
    'Missing hiv_test_result (HIV test done = Yes but no result recorded)' AS issue,
    hiv_test_result AS current_value
  FROM maternal_core
  WHERE (hiv_test_result IS NULL OR TRIM(hiv_test_result) = '')
    AND is_hiv_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_date_hiv_test_done AS (
  -- Missing date_hiv_test_done (only when is_hiv_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_hiv_test_done' AS variable,
    'Missing date_hiv_test_done (HIV test done = Yes but no date recorded)' AS issue,
    date_hiv_test_done AS current_value
  FROM maternal_core
  WHERE (date_hiv_test_done IS NULL OR TRIM(date_hiv_test_done) = '')
    AND is_hiv_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

future_date_hiv_test_done AS (
  -- Future date_hiv_test_done (only when is_hiv_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_hiv_test_done' AS variable,
    'Future date_hiv_test_done' AS issue,
    date_hiv_test_done AS current_value
  FROM maternal_core
  WHERE date_hiv_test_done IS NOT NULL
    AND TRIM(date_hiv_test_done) != ''
    AND is_hiv_test_done = '1'
    AND TRY_CAST(date_hiv_test_done AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_current_hb_done AS (
  -- Missing is_current_hb_done
  SELECT
    record_id,
    datetime_entry,
    'is_current_hb_done' AS variable,
    'Missing is_current_hb_done' AS issue,
    is_current_hb_done AS current_value
  FROM maternal_core
  WHERE (is_current_hb_done IS NULL OR TRIM(is_current_hb_done) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_current_hb AS (
  -- Missing current_hb (only when is_current_hb_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'current_hb' AS variable,
    'Missing current_hb (current Hb done = Yes but no value recorded)' AS issue,
    current_hb AS current_value
  FROM maternal_core
  WHERE (current_hb IS NULL OR TRIM(current_hb) = '')
    AND is_current_hb_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 14:57:54'
),

invalid_current_hb AS (
  -- current_hb out of range (expected 5-20 g/dL)
  SELECT
    record_id,
    datetime_entry,
    'current_hb' AS variable,
    'current_hb out of range (expected 5-20 g/dL)' AS issue,
    current_hb AS current_value
  FROM maternal_core
  WHERE current_hb IS NOT NULL
    AND TRIM(current_hb) != ''
    AND TRIM(current_hb) != 'NI'
    AND TRIM(current_hb) != 'ND'
    AND is_current_hb_done = '1'
    AND (
      TRY_CAST(current_hb AS DOUBLE) IS NULL
      OR TRY_CAST(current_hb AS DOUBLE) < 5
      OR TRY_CAST(current_hb AS DOUBLE) > 20
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 14:57:54'
),


missing_date_current_hb AS (
  -- Missing date_current_hb (only when is_current_hb_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_current_hb' AS variable,
    'Missing date_current_hb (current Hb done = Yes but no date recorded)' AS issue,
    date_current_hb AS current_value
  FROM maternal_core
  WHERE (date_current_hb IS NULL OR TRIM(date_current_hb) = '')
    AND is_current_hb_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 14:57:54'
),

future_date_current_hb AS (
  -- Future date_current_hb (only when is_current_hb_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_current_hb' AS variable,
    'Future date_current_hb' AS issue,
    date_current_hb AS current_value
  FROM maternal_core
  WHERE date_current_hb IS NOT NULL
    AND TRIM(date_current_hb) != ''
    AND is_current_hb_done = '1'
    AND TRY_CAST(date_current_hb AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 14:57:54'
),


missing_is_vdrl_test_done AS (
  -- Missing is_vdrl_test_done
  SELECT
    record_id,
    datetime_entry,
    'is_vdrl_test_done' AS variable,
    'Missing is_vdrl_test_done' AS issue,
    is_vdrl_test_done AS current_value
  FROM maternal_core
  WHERE (is_vdrl_test_done IS NULL OR TRIM(is_vdrl_test_done) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_vdrl_test_result AS (
  -- Missing vdrl_test_result (only when is_vdrl_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'vdrl_test_result' AS variable,
    'Missing vdrl_test_result (VDRL test done = Yes but no result recorded)' AS issue,
    vdrl_test_result AS current_value
  FROM maternal_core
  WHERE (vdrl_test_result IS NULL OR TRIM(vdrl_test_result) = '')
    AND is_vdrl_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 13:06:33'
),


missing_date_vdrl_test_done AS (
  -- Missing date_vdrl_test_done (only when is_vdrl_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_vdrl_test_done' AS variable,
    'Missing date_vdrl_test_done (VDRL test done = Yes but no date recorded)' AS issue,
    date_vdrl_test_done AS current_value
  FROM maternal_core
  WHERE (date_vdrl_test_done IS NULL OR TRIM(date_vdrl_test_done) = '')
    AND is_vdrl_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 13:06:33'
),

future_date_vdrl_test_done AS (
  -- Future date_vdrl_test_done (only when is_vdrl_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_vdrl_test_done' AS variable,
    'Future date_vdrl_test_done' AS issue,
    date_vdrl_test_done AS current_value
  FROM maternal_core
  WHERE date_vdrl_test_done IS NOT NULL
    AND TRIM(date_vdrl_test_done) != ''
    AND is_vdrl_test_done = '1'
    AND TRY_CAST(date_vdrl_test_done AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 13:06:33'
),


missing_is_hepatitis_b_test_done AS (
  -- Missing is_hepatitis_b_test_done
  SELECT
    record_id,
    datetime_entry,
    'is_hepatitis_b_test_done' AS variable,
    'Missing is_hepatitis_b_test_done' AS issue,
    is_hepatitis_b_test_done AS current_value
  FROM maternal_core
  WHERE (is_hepatitis_b_test_done IS NULL OR TRIM(is_hepatitis_b_test_done) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_hepatitis_b_test_result AS (
  -- Missing hepatitis_b_test_result (only when is_hepatitis_b_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'hepatitis_b_test_result' AS variable,
    'Missing hepatitis_b_test_result (Hepatitis B test done = Yes but no result recorded)' AS issue,
    hepatitis_b_test_result AS current_value
  FROM maternal_core
  WHERE (hepatitis_b_test_result IS NULL OR TRIM(hepatitis_b_test_result) = '')
    AND is_hepatitis_b_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 13:06:33'
),


missing_date_hepatitis_b_test_done AS (
  -- Missing date_hepatitis_b_test_done (only when is_hepatitis_b_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_hepatitis_b_test_done' AS variable,
    'Missing date_hepatitis_b_test_done (Hepatitis B test done = Yes but no date recorded)' AS issue,
    date_hepatitis_b_test_done AS current_value
  FROM maternal_core
  WHERE (date_hepatitis_b_test_done IS NULL OR TRIM(date_hepatitis_b_test_done) = '')
    AND is_hepatitis_b_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 13:06:33'
),

future_date_hepatitis_b_test_done AS (
  -- Future date_hepatitis_b_test_done (only when is_hepatitis_b_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_hepatitis_b_test_done' AS variable,
    'Future date_hepatitis_b_test_done' AS issue,
    date_hepatitis_b_test_done AS current_value
  FROM maternal_core
  WHERE date_hepatitis_b_test_done IS NOT NULL
    AND TRIM(date_hepatitis_b_test_done) != ''
    AND is_hepatitis_b_test_done = '1'
    AND TRY_CAST(date_hepatitis_b_test_done AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 13:06:33'
),


missing_is_ogtt_test_done AS (
  -- Missing is_ogtt_test_done
  SELECT
    record_id,
    datetime_entry,
    'is_ogtt_test_done' AS variable,
    'Missing is_ogtt_test_done' AS issue,
    is_ogtt_test_done AS current_value
  FROM maternal_core
  WHERE (is_ogtt_test_done IS NULL OR TRIM(is_ogtt_test_done) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_ogtt_result AS (
  -- Missing ogtt_result (only when is_ogtt_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'ogtt_result' AS variable,
    'Missing ogtt_result (OGTT test done = Yes but no result recorded)' AS issue,
    ogtt_result AS current_value
  FROM maternal_core
  WHERE (ogtt_result IS NULL OR TRIM(ogtt_result) = '')
    AND is_ogtt_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-06-17 15:44:37'
),

invalid_ogtt_result AS (
  -- ogtt_result out of range (expected 2-30 mmol/L)
  SELECT
    record_id,
    datetime_entry,
    'ogtt_result' AS variable,
    'ogtt_result out of range (expected 2-30 mmol/L)' AS issue,
    ogtt_result AS current_value
  FROM maternal_core
  WHERE ogtt_result IS NOT NULL
    AND TRIM(ogtt_result) != ''
    AND TRIM(ogtt_result) != 'NI'
    AND TRIM(ogtt_result) != 'ND'
    AND is_ogtt_test_done = '1'
    AND (
      TRY_CAST(ogtt_result AS DOUBLE) IS NULL
      OR TRY_CAST(ogtt_result AS DOUBLE) < 2
      OR TRY_CAST(ogtt_result AS DOUBLE) > 30
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-06-17 15:44:37'
),


missing_date_ogtt_test_done AS (
  -- Missing date_ogtt_test_done (only when is_ogtt_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_ogtt_test_done' AS variable,
    'Missing date_ogtt_test_done (OGTT test done = Yes but no date recorded)' AS issue,
    date_ogtt_test_done AS current_value
  FROM maternal_core
  WHERE (date_ogtt_test_done IS NULL OR TRIM(date_ogtt_test_done) = '')
    AND is_ogtt_test_done = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-06-17 15:44:37'
),

future_date_ogtt_test_done AS (
  -- Future date_ogtt_test_done (only when is_ogtt_test_done = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_ogtt_test_done' AS variable,
    'Future date_ogtt_test_done' AS issue,
    date_ogtt_test_done AS current_value
  FROM maternal_core
  WHERE date_ogtt_test_done IS NOT NULL
    AND TRIM(date_ogtt_test_done) != ''
    AND is_ogtt_test_done = '1'
    AND TRY_CAST(date_ogtt_test_done AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-06-17 15:44:37'
),


missing_is_on_arvs AS (
  -- Missing is_on_arvs (only when hiv_test_result = '1' i.e., HIV positive)
  SELECT
    record_id,
    datetime_entry,
    'is_on_arvs' AS variable,
    'Missing is_on_arvs (HIV positive but ARV status not recorded)' AS issue,
    is_on_arvs AS current_value
  FROM maternal_core
  WHERE (is_on_arvs IS NULL OR TRIM(is_on_arvs) = '')
    AND hiv_test_result = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-05 14:47:49'
),


missing_arvs_used AS (
  -- Missing arvs_used (only when is_on_arvs = '1')
  SELECT
    record_id,
    datetime_entry,
    'arvs_used' AS variable,
    'Missing arvs_used (On ARVs = Yes but no ARV type recorded)' AS issue,
    arvs_used AS current_value
  FROM maternal_core
  WHERE (arvs_used IS NULL OR TRIM(arvs_used) = '')
    AND is_on_arvs = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-05 14:47:49'
),


missing_date_arvs_initiation AS (
  -- Missing date_arvs_initiation (only when is_on_arvs = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_arvs_initiation' AS variable,
    'Missing date_arvs_initiation (On ARVs = Yes but no initiation date recorded)' AS issue,
    date_arvs_initiation AS current_value
  FROM maternal_core
  WHERE (date_arvs_initiation IS NULL OR TRIM(date_arvs_initiation) = '')
    AND is_on_arvs = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-05 14:47:49'
),

future_date_arvs_initiation AS (
  -- Future date_arvs_initiation (only when is_on_arvs = '1')
  SELECT
    record_id,
    datetime_entry,
    'date_arvs_initiation' AS variable,
    'Future date_arvs_initiation' AS issue,
    date_arvs_initiation AS current_value
  FROM maternal_core
  WHERE date_arvs_initiation IS NOT NULL
    AND TRIM(date_arvs_initiation) != ''
    AND is_on_arvs = '1'
    AND TRY_CAST(date_arvs_initiation AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-05 14:47:49'
),


missing_is_vdrl_positive_treatment AS (
  -- Missing is_vdrl_positive_treatment (only when vdrl_test_result = '1' i.e., VDRL positive)
  SELECT
    record_id,
    datetime_entry,
    'is_vdrl_positive_treatment' AS variable,
    'Missing is_vdrl_positive_treatment (VDRL positive but treatment status not recorded)' AS issue,
    is_vdrl_positive_treatment AS current_value
  FROM maternal_core
  WHERE (is_vdrl_positive_treatment IS NULL OR TRIM(is_vdrl_positive_treatment) = '')
    AND vdrl_test_result = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-06-03 13:00:24'
),


missing_is_bp_intervention AS (
  -- Missing is_bp_intervention
  SELECT
    record_id,
    datetime_entry,
    'is_bp_intervention' AS variable,
    'Missing is_bp_intervention' AS issue,
    is_bp_intervention AS current_value
  FROM maternal_core
  WHERE (is_bp_intervention IS NULL OR TRIM(is_bp_intervention) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_rbs_intervention AS (
  -- Missing is_rbs_intervention
  SELECT
    record_id,
    datetime_entry,
    'is_rbs_intervention' AS variable,
    'Missing is_rbs_intervention' AS issue,
    is_rbs_intervention AS current_value
  FROM maternal_core
  WHERE (is_rbs_intervention IS NULL OR TRIM(is_rbs_intervention) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_hb_intervention AS (
  -- Missing is_hb_intervention
  SELECT
    record_id,
    datetime_entry,
    'is_hb_intervention' AS variable,
    'Missing is_hb_intervention' AS issue,
    is_hb_intervention AS current_value
  FROM maternal_core
  WHERE (is_hb_intervention IS NULL OR TRIM(is_hb_intervention) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_iron_supplements AS (
  -- Missing is_iron_supplements
  SELECT
    record_id,
    datetime_entry,
    'is_iron_supplements' AS variable,
    'Missing is_iron_supplements' AS issue,
    is_iron_supplements AS current_value
  FROM maternal_core
  WHERE (is_iron_supplements IS NULL OR TRIM(is_iron_supplements) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_blood_transfusion AS (
  -- Missing is_blood_transfusion
  SELECT
    record_id,
    datetime_entry,
    'is_blood_transfusion' AS variable,
    'Missing is_blood_transfusion' AS issue,
    is_blood_transfusion AS current_value
  FROM maternal_core
  WHERE (is_blood_transfusion IS NULL OR TRIM(is_blood_transfusion) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_abnormal_us_intervened AS (
  -- Missing is_abnormal_us_intervened
  SELECT
    record_id,
    datetime_entry,
    'is_abnormal_us_intervened' AS variable,
    'Missing is_abnormal_us_intervened' AS issue,
    is_abnormal_us_intervened AS current_value
  FROM maternal_core
  WHERE (is_abnormal_us_intervened IS NULL OR TRIM(is_abnormal_us_intervened) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_antibiotics_last_4_wks AS (
  -- Missing is_antibiotics_last_4_wks
  SELECT
    record_id,
    datetime_entry,
    'is_antibiotics_last_4_wks' AS variable,
    'Missing is_antibiotics_last_4_wks' AS issue,
    is_antibiotics_last_4_wks AS current_value
  FROM maternal_core
  WHERE (is_antibiotics_last_4_wks IS NULL OR TRIM(is_antibiotics_last_4_wks) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_deworming_in_pregnancy AS (
  -- Missing is_deworming_in_pregnancy
  SELECT
    record_id,
    datetime_entry,
    'is_deworming_in_pregnancy' AS variable,
    'Missing is_deworming_in_pregnancy' AS issue,
    is_deworming_in_pregnancy AS current_value
  FROM maternal_core
  WHERE (is_deworming_in_pregnancy IS NULL OR TRIM(is_deworming_in_pregnancy) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_iron_given AS (
  -- Missing is_iron_given
  SELECT
    record_id,
    datetime_entry,
    'is_iron_given' AS variable,
    'Missing is_iron_given' AS issue,
    is_iron_given AS current_value
  FROM maternal_core
  WHERE (is_iron_given IS NULL OR TRIM(is_iron_given) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_folic_acid_given AS (
  -- Missing is_folic_acid_given
  SELECT
    record_id,
    datetime_entry,
    'is_folic_acid_given' AS variable,
    'Missing is_folic_acid_given' AS issue,
    is_folic_acid_given AS current_value
  FROM maternal_core
  WHERE (is_folic_acid_given IS NULL OR TRIM(is_folic_acid_given) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_calcium_given AS (
  -- Missing is_calcium_given
  SELECT
    record_id,
    datetime_entry,
    'is_calcium_given' AS variable,
    'Missing is_calcium_given' AS issue,
    is_calcium_given AS current_value
  FROM maternal_core
  WHERE (is_calcium_given IS NULL OR TRIM(is_calcium_given) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_multivitamins_given AS (
  -- Missing is_multivitamins_given
  SELECT
    record_id,
    datetime_entry,
    'is_multivitamins_given' AS variable,
    'Missing is_multivitamins_given' AS issue,
    is_multivitamins_given AS current_value
  FROM maternal_core
  WHERE (is_multivitamins_given IS NULL OR TRIM(is_multivitamins_given) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_other_supplements AS (
  -- Missing is_other_supplements
  SELECT
    record_id,
    datetime_entry,
    'is_other_supplements' AS variable,
    'Missing is_other_supplements' AS issue,
    is_other_supplements AS current_value
  FROM maternal_core
  WHERE (is_other_supplements IS NULL OR TRIM(is_other_supplements) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_supplements_given_other AS (
  -- Missing supplements_given_other when is_other_supplements = '1'
  SELECT
    record_id,
    datetime_entry,
    'supplements_given_other' AS variable,
    'Missing supplements_given_other (other supplements = Yes but no specification)' AS issue,
    supplements_given_other AS current_value
  FROM maternal_core
  WHERE (supplements_given_other IS NULL OR TRIM(supplements_given_other) = '')
    AND is_other_supplements = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_is_alcohol_present AS (
  -- Missing is_alcohol_present
  SELECT
    record_id,
    datetime_entry,
    'is_alcohol_present' AS variable,
    'Missing is_alcohol_present' AS issue,
    is_alcohol_present AS current_value
  FROM maternal_core
  WHERE (is_alcohol_present IS NULL OR TRIM(is_alcohol_present) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_cigarette_present AS (
  -- Missing is_cigarette_present
  SELECT
    record_id,
    datetime_entry,
    'is_cigarette_present' AS variable,
    'Missing is_cigarette_present' AS issue,
    is_cigarette_present AS current_value
  FROM maternal_core
  WHERE (is_cigarette_present IS NULL OR TRIM(is_cigarette_present) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_chewing_tobacco AS (
  -- Missing is_chewing_tobacco
  SELECT
    record_id,
    datetime_entry,
    'is_chewing_tobacco' AS variable,
    'Missing is_chewing_tobacco' AS issue,
    is_chewing_tobacco AS current_value
  FROM maternal_core
  WHERE (is_chewing_tobacco IS NULL OR TRIM(is_chewing_tobacco) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_oth_substances AS (
  -- Missing is_oth_substances
  SELECT
    record_id,
    datetime_entry,
    'is_oth_substances' AS variable,
    'Missing is_oth_substances' AS issue,
    is_oth_substances AS current_value
  FROM maternal_core
  WHERE (is_oth_substances IS NULL OR TRIM(is_oth_substances) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_substances_in_preg_other AS (
  -- Missing substances_in_preg_other when is_oth_substances = '1'
  SELECT
    record_id,
    datetime_entry,
    'substances_in_preg_other' AS variable,
    'Missing substances_in_preg_other (other substances = Yes but no specification)' AS issue,
    substances_in_preg_other AS current_value
  FROM maternal_core
  WHERE (substances_in_preg_other IS NULL OR TRIM(substances_in_preg_other) = '')
    AND is_oth_substances = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_other_meds_not_ind AS (
  -- Missing is_other_meds_not_ind
  SELECT
    record_id,
    datetime_entry,
    'is_other_meds_not_ind' AS variable,
    'Missing is_other_meds_not_ind' AS issue,
    is_other_meds_not_ind AS current_value
  FROM maternal_core
  WHERE (is_other_meds_not_ind IS NULL OR TRIM(is_other_meds_not_ind) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_other_meds_not_ind AS (
  -- Missing other_meds_not_ind when is_other_meds_not_ind = '1'
  SELECT
    record_id,
    datetime_entry,
    'other_meds_not_ind' AS variable,
    'Missing other_meds_not_ind (other medications not indicated = Yes but no specification)' AS issue,
    other_meds_not_ind AS current_value
  FROM maternal_core
  WHERE (other_meds_not_ind IS NULL OR TRIM(other_meds_not_ind) = '')
    AND is_other_meds_not_ind = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_other_interventions AS (
  -- Missing other_interventions
  SELECT
    record_id,
    datetime_entry,
    'other_interventions' AS variable,
    'Missing other_interventions' AS issue,
    other_interventions AS current_value
  FROM maternal_core
  WHERE (other_interventions IS NULL OR TRIM(other_interventions) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_count_pregs AS (
  -- Missing count_pregs
  SELECT
    record_id,
    datetime_entry,
    'count_pregs' AS variable,
    'Missing count_pregs' AS issue,
    count_pregs AS current_value
  FROM maternal_core
  WHERE (count_pregs IS NULL OR TRIM(count_pregs) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_count_pregs AS (
  -- count_pregs out of range (expected 1-25 pregnancies)
  SELECT
    record_id,
    datetime_entry,
    'count_pregs' AS variable,
    'count_pregs out of range (expected 1-25 pregnancies)' AS issue,
    count_pregs AS current_value
  FROM maternal_core
  WHERE count_pregs IS NOT NULL
    AND TRIM(count_pregs) != ''
    AND TRIM(count_pregs) != 'NI'
    AND (
      TRY_CAST(count_pregs AS INTEGER) IS NULL
      OR TRY_CAST(count_pregs AS INTEGER) < 1
      OR TRY_CAST(count_pregs AS INTEGER) > 25
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

missing_pregs_28w_alive AS (
  -- Missing pregs_28w_alive
  SELECT
    record_id,
    datetime_entry,
    'pregs_28w_alive' AS variable,
    'Missing pregs_28w_alive' AS issue,
    pregs_28w_alive AS current_value
  FROM maternal_core
  WHERE (pregs_28w_alive IS NULL OR TRIM(pregs_28w_alive) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_pregs_28w_alive AS (
  -- pregs_28w_alive out of range (expected 0-25)
  SELECT
    record_id,
    datetime_entry,
    'pregs_28w_alive' AS variable,
    'pregs_28w_alive out of range (expected 0-25)' AS issue,
    pregs_28w_alive AS current_value
  FROM maternal_core
  WHERE pregs_28w_alive IS NOT NULL
    AND TRIM(pregs_28w_alive) != ''
    AND TRIM(pregs_28w_alive) != 'NI'
    AND (
      TRY_CAST(pregs_28w_alive AS INTEGER) IS NULL
      OR TRY_CAST(pregs_28w_alive AS INTEGER) < 0
      OR TRY_CAST(pregs_28w_alive AS INTEGER) > 25
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_pregs_28w_miscarriage AS (
  -- Missing pregs_28w_miscarriage
  SELECT
    record_id,
    datetime_entry,
    'pregs_28w_miscarriage' AS variable,
    'Missing pregs_28w_miscarriage' AS issue,
    pregs_28w_miscarriage AS current_value
  FROM maternal_core
  WHERE (pregs_28w_miscarriage IS NULL OR TRIM(pregs_28w_miscarriage) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_pregs_28w_miscarriage AS (
  -- pregs_28w_miscarriage out of range (expected 0-25)
  SELECT
    record_id,
    datetime_entry,
    'pregs_28w_miscarriage' AS variable,
    'pregs_28w_miscarriage out of range (expected 0-25)' AS issue,
    pregs_28w_miscarriage AS current_value
  FROM maternal_core
  WHERE pregs_28w_miscarriage IS NOT NULL
    AND TRIM(pregs_28w_miscarriage) != ''
    AND TRIM(pregs_28w_miscarriage) != 'NI'
    AND (
      TRY_CAST(pregs_28w_miscarriage AS INTEGER) IS NULL
      OR TRY_CAST(pregs_28w_miscarriage AS INTEGER) < 0
      OR TRY_CAST(pregs_28w_miscarriage AS INTEGER) > 25
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_count_living_children AS (
  -- Missing count_living_children
  SELECT
    record_id,
    datetime_entry,
    'count_living_children' AS variable,
    'Missing count_living_children' AS issue,
    count_living_children AS current_value
  FROM maternal_core
  WHERE (count_living_children IS NULL OR TRIM(count_living_children) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_count_living_children AS (
  -- count_living_children out of range (expected 0-25)
  SELECT
    record_id,
    datetime_entry,
    'count_living_children' AS variable,
    'count_living_children out of range (expected 0-25)' AS issue,
    count_living_children AS current_value
  FROM maternal_core
  WHERE count_living_children IS NOT NULL
    AND TRIM(count_living_children) != ''
    AND TRIM(count_living_children) != 'NI'
    AND (
      TRY_CAST(count_living_children AS INTEGER) IS NULL
      OR TRY_CAST(count_living_children AS INTEGER) < 0
      OR TRY_CAST(count_living_children AS INTEGER) > 25
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_prev_preg_filled AS (
  -- Missing is_prev_preg_filled
  SELECT
    record_id,
    datetime_entry,
    'is_prev_preg_filled' AS variable,
    'Missing is_prev_preg_filled' AS issue,
    is_prev_preg_filled AS current_value
  FROM maternal_core
  WHERE (is_prev_preg_filled IS NULL OR TRIM(is_prev_preg_filled) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-20 10:53:16'
),


missing_is_cardiac_before_preg AS (
  -- Missing is_cardiac_before_preg
  SELECT
    record_id,
    datetime_entry,
    'is_cardiac_before_preg' AS variable,
    'Missing is_cardiac_before_preg' AS issue,
    is_cardiac_before_preg AS current_value
  FROM maternal_core
  WHERE (is_cardiac_before_preg IS NULL OR TRIM(is_cardiac_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_cardiac_during_preg AS (
  -- Missing is_cardiac_during_preg
  SELECT
    record_id,
    datetime_entry,
    'is_cardiac_during_preg' AS variable,
    'Missing is_cardiac_during_preg' AS issue,
    is_cardiac_during_preg AS current_value
  FROM maternal_core
  WHERE (is_cardiac_during_preg IS NULL OR TRIM(is_cardiac_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_is_cardiac_during_itp AS (
  -- Missing is_cardiac_during_itp
  SELECT
    record_id,
    datetime_entry,
    'is_cardiac_during_itp' AS variable,
    'Missing is_cardiac_during_itp' AS issue,
    is_cardiac_during_itp AS current_value
  FROM maternal_core
  WHERE (is_cardiac_during_itp IS NULL OR TRIM(is_cardiac_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_cardiac_during_post_del AS (
  -- Missing is_cardiac_during_post_del
  SELECT
    record_id,
    datetime_entry,
    'is_cardiac_during_post_del' AS variable,
    'Missing is_cardiac_during_post_del' AS issue,
    is_cardiac_during_post_del AS current_value
  FROM maternal_core
  WHERE (is_cardiac_during_post_del IS NULL OR TRIM(is_cardiac_during_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),


-- Hypertension Section
missing_is_htn_before_preg AS (
  SELECT record_id, datetime_entry, 'is_htn_before_preg' AS variable, 'Missing is_htn_before_preg' AS issue, is_htn_before_preg AS current_value
  FROM maternal_core
  WHERE (is_htn_before_preg IS NULL OR TRIM(is_htn_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_htn_during_preg AS (
  SELECT record_id, datetime_entry, 'is_htn_during_preg' AS variable, 'Missing is_htn_during_preg' AS issue, is_htn_during_preg AS current_value
  FROM maternal_core
  WHERE (is_htn_during_preg IS NULL OR TRIM(is_htn_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_htn_during_itp AS (
  SELECT record_id, datetime_entry, 'is_htn_during_itp' AS variable, 'Missing is_htn_during_itp' AS issue, is_htn_during_itp AS current_value
  FROM maternal_core
  WHERE (is_htn_during_itp IS NULL OR TRIM(is_htn_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_htn_during_post_del AS (
  SELECT record_id, datetime_entry, 'is_htn_during_post_del' AS variable, 'Missing is_htn_during_post_del' AS issue, is_htn_during_post_del AS current_value
  FROM maternal_core
  WHERE (is_htn_during_post_del IS NULL OR TRIM(is_htn_during_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Respiratory Section
missing_is_asthma_before_preg AS (
  SELECT record_id, datetime_entry, 'is_asthma_before_preg' AS variable, 'Missing is_asthma_before_preg' AS issue, is_asthma_before_preg AS current_value
  FROM maternal_core
  WHERE (is_asthma_before_preg IS NULL OR TRIM(is_asthma_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_asthma_during_preg AS (
  SELECT record_id, datetime_entry, 'is_asthma_during_preg' AS variable, 'Missing is_asthma_during_preg' AS issue, is_asthma_during_preg AS current_value
  FROM maternal_core
  WHERE (is_asthma_during_preg IS NULL OR TRIM(is_asthma_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_asthma_during_ipt AS (
  SELECT record_id, datetime_entry, 'is_asthma_during_ipt' AS variable, 'Missing is_asthma_during_ipt' AS issue, is_asthma_during_ipt AS current_value
  FROM maternal_core
  WHERE (is_asthma_during_ipt IS NULL OR TRIM(is_asthma_during_ipt) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_asthma_during_post_del AS (
  SELECT record_id, datetime_entry, 'is_asthma_during_post_del' AS variable, 'Missing is_asthma_during_post_del' AS issue, is_asthma_during_post_del AS current_value
  FROM maternal_core
  WHERE (is_asthma_during_post_del IS NULL OR TRIM(is_asthma_during_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Epilepsy Section
missing_is_epilepsy_before_preg AS (
  SELECT record_id, datetime_entry, 'is_epilepsy_before_preg' AS variable, 'Missing is_epilepsy_before_preg' AS issue, is_epilepsy_before_preg AS current_value
  FROM maternal_core
  WHERE (is_epilepsy_before_preg IS NULL OR TRIM(is_epilepsy_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_epilepsy_during_preg AS (
  SELECT record_id, datetime_entry, 'is_epilepsy_during_preg' AS variable, 'Missing is_epilepsy_during_preg' AS issue, is_epilepsy_during_preg AS current_value
  FROM maternal_core
  WHERE (is_epilepsy_during_preg IS NULL OR TRIM(is_epilepsy_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_epilepsy_during_itp AS (
  SELECT record_id, datetime_entry, 'is_epilepsy_during_itp' AS variable, 'Missing is_epilepsy_during_itp' AS issue, is_epilepsy_during_itp AS current_value
  FROM maternal_core
  WHERE (is_epilepsy_during_itp IS NULL OR TRIM(is_epilepsy_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_epilepsy_post_del AS (
  SELECT record_id, datetime_entry, 'is_epilepsy_post_del' AS variable, 'Missing is_epilepsy_post_del' AS issue, is_epilepsy_post_del AS current_value
  FROM maternal_core
  WHERE (is_epilepsy_post_del IS NULL OR TRIM(is_epilepsy_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Endocrine - Diabetes Section
missing_is_diabetes_before_preg AS (
  SELECT record_id, datetime_entry, 'is_diabetes_before_preg' AS variable, 'Missing is_diabetes_before_preg' AS issue, is_diabetes_before_preg AS current_value
  FROM maternal_core
  WHERE (is_diabetes_before_preg IS NULL OR TRIM(is_diabetes_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_diabetes_during_preg AS (
  SELECT record_id, datetime_entry, 'is_diabetes_during_preg' AS variable, 'Missing is_diabetes_during_preg' AS issue, is_diabetes_during_preg AS current_value
  FROM maternal_core
  WHERE (is_diabetes_during_preg IS NULL OR TRIM(is_diabetes_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_diabetes_during_itp AS (
  SELECT record_id, datetime_entry, 'is_diabetes_during_itp' AS variable, 'Missing is_diabetes_during_itp' AS issue, is_diabetes_during_itp AS current_value
  FROM maternal_core
  WHERE (is_diabetes_during_itp IS NULL OR TRIM(is_diabetes_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_diabetes_post_del AS (
  SELECT record_id, datetime_entry, 'is_diabetes_post_del' AS variable, 'Missing is_diabetes_post_del' AS issue, is_diabetes_post_del AS current_value
  FROM maternal_core
  WHERE (is_diabetes_post_del IS NULL OR TRIM(is_diabetes_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Endocrine - Thyroid Section
missing_is_thyroid_before_preg AS (
  SELECT record_id, datetime_entry, 'is_thyroid_before_preg' AS variable, 'Missing is_thyroid_before_preg' AS issue, is_thyroid_before_preg AS current_value
  FROM maternal_core
  WHERE (is_thyroid_before_preg IS NULL OR TRIM(is_thyroid_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_thyroid_during_preg AS (
  SELECT record_id, datetime_entry, 'is_thyroid_during_preg' AS variable, 'Missing is_thyroid_during_preg' AS issue, is_thyroid_during_preg AS current_value
  FROM maternal_core
  WHERE (is_thyroid_during_preg IS NULL OR TRIM(is_thyroid_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_thyroid_during_itp AS (
  SELECT record_id, datetime_entry, 'is_thyroid_during_itp' AS variable, 'Missing is_thyroid_during_itp' AS issue, is_thyroid_during_itp AS current_value
  FROM maternal_core
  WHERE (is_thyroid_during_itp IS NULL OR TRIM(is_thyroid_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_thyroid_post_del AS (
  SELECT record_id, datetime_entry, 'is_thyroid_post_del' AS variable, 'Missing is_thyroid_post_del' AS issue, is_thyroid_post_del AS current_value
  FROM maternal_core
  WHERE (is_thyroid_post_del IS NULL OR TRIM(is_thyroid_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Infection - STI Section
missing_is_sti_before_preg AS (
  SELECT record_id, datetime_entry, 'is_sti_before_preg' AS variable, 'Missing is_sti_before_preg' AS issue, is_sti_before_preg AS current_value
  FROM maternal_core
  WHERE (is_sti_before_preg IS NULL OR TRIM(is_sti_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_sti_during_preg AS (
  SELECT record_id, datetime_entry, 'is_sti_during_preg' AS variable, 'Missing is_sti_during_preg' AS issue, is_sti_during_preg AS current_value
  FROM maternal_core
  WHERE (is_sti_during_preg IS NULL OR TRIM(is_sti_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_sti_during_itp AS (
  SELECT record_id, datetime_entry, 'is_sti_during_itp' AS variable, 'Missing is_sti_during_itp' AS issue, is_sti_during_itp AS current_value
  FROM maternal_core
  WHERE (is_sti_during_itp IS NULL OR TRIM(is_sti_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_sti_post_del AS (
  SELECT record_id, datetime_entry, 'is_sti_post_del' AS variable, 'Missing is_sti_post_del' AS issue, is_sti_post_del AS current_value
  FROM maternal_core
  WHERE (is_sti_post_del IS NULL OR TRIM(is_sti_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Renal Section
missing_is_renal_before_preg AS (
  SELECT record_id, datetime_entry, 'is_renal_before_preg' AS variable, 'Missing is_renal_before_preg' AS issue, is_renal_before_preg AS current_value
  FROM maternal_core
  WHERE (is_renal_before_preg IS NULL OR TRIM(is_renal_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_renal_during_preg AS (
  SELECT record_id, datetime_entry, 'is_renal_during_preg' AS variable, 'Missing is_renal_during_preg' AS issue, is_renal_during_preg AS current_value
  FROM maternal_core
  WHERE (is_renal_during_preg IS NULL OR TRIM(is_renal_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_renal_during_itp AS (
  SELECT record_id, datetime_entry, 'is_renal_during_itp' AS variable, 'Missing is_renal_during_itp' AS issue, is_renal_during_itp AS current_value
  FROM maternal_core
  WHERE (is_renal_during_itp IS NULL OR TRIM(is_renal_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_renal_post_del AS (
  SELECT record_id, datetime_entry, 'is_renal_post_del' AS variable, 'Missing is_renal_post_del' AS issue, is_renal_post_del AS current_value
  FROM maternal_core
  WHERE (is_renal_post_del IS NULL OR TRIM(is_renal_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Haematology - Sickle Cell Section
missing_is_sickle_before_preg AS (
  SELECT record_id, datetime_entry, 'is_sickle_before_preg' AS variable, 'Missing is_sickle_before_preg' AS issue, is_sickle_before_preg AS current_value
  FROM maternal_core
  WHERE (is_sickle_before_preg IS NULL OR TRIM(is_sickle_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_sickle_during_preg AS (
  SELECT record_id, datetime_entry, 'is_sickle_during_preg' AS variable, 'Missing is_sickle_during_preg' AS issue, is_sickle_during_preg AS current_value
  FROM maternal_core
  WHERE (is_sickle_during_preg IS NULL OR TRIM(is_sickle_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_sickle_during_itp AS (
  SELECT record_id, datetime_entry, 'is_sickle_during_itp' AS variable, 'Missing is_sickle_during_itp' AS issue, is_sickle_during_itp AS current_value
  FROM maternal_core
  WHERE (is_sickle_during_itp IS NULL OR TRIM(is_sickle_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_sickle_post_del AS (
  SELECT record_id, datetime_entry, 'is_sickle_post_del' AS variable, 'Missing is_sickle_post_del' AS issue, is_sickle_post_del AS current_value
  FROM maternal_core
  WHERE (is_sickle_post_del IS NULL OR TRIM(is_sickle_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Neoplasia - Cervical Cancer Section
missing_is_cervical_before_preg AS (
  SELECT record_id, datetime_entry, 'is_cervical_before_preg' AS variable, 'Missing is_cervical_before_preg' AS issue, is_cervical_before_preg AS current_value
  FROM maternal_core
  WHERE (is_cervical_before_preg IS NULL OR TRIM(is_cervical_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_cervical_during_preg AS (
  SELECT record_id, datetime_entry, 'is_cervical_during_preg' AS variable, 'Missing is_cervical_during_preg' AS issue, is_cervical_during_preg AS current_value
  FROM maternal_core
  WHERE (is_cervical_during_preg IS NULL OR TRIM(is_cervical_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_cervical_during_itp AS (
  SELECT record_id, datetime_entry, 'is_cervical_during_itp' AS variable, 'Missing is_cervical_during_itp' AS issue, is_cervical_during_itp AS current_value
  FROM maternal_core
  WHERE (is_cervical_during_itp IS NULL OR TRIM(is_cervical_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_cervical_post_del AS (
  SELECT record_id, datetime_entry, 'is_cervical_post_del' AS variable, 'Missing is_cervical_post_del' AS issue, is_cervical_post_del AS current_value
  FROM maternal_core
  WHERE (is_cervical_post_del IS NULL OR TRIM(is_cervical_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Neoplasia - Breast Cancer Section
missing_is_breast_before_preg AS (
  SELECT record_id, datetime_entry, 'is_breast_before_preg' AS variable, 'Missing is_breast_before_preg' AS issue, is_breast_before_preg AS current_value
  FROM maternal_core
  WHERE (is_breast_before_preg IS NULL OR TRIM(is_breast_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_breast_during_preg AS (
  SELECT record_id, datetime_entry, 'is_breast_during_preg' AS variable, 'Missing is_breast_during_preg' AS issue, is_breast_during_preg AS current_value
  FROM maternal_core
  WHERE (is_breast_during_preg IS NULL OR TRIM(is_breast_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_breast_during_itp AS (
  SELECT record_id, datetime_entry, 'is_breast_during_itp' AS variable, 'Missing is_breast_during_itp' AS issue, is_breast_during_itp AS current_value
  FROM maternal_core
  WHERE (is_breast_during_itp IS NULL OR TRIM(is_breast_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_breast_post_del AS (
  SELECT record_id, datetime_entry, 'is_breast_post_del' AS variable, 'Missing is_breast_post_del' AS issue, is_breast_post_del AS current_value
  FROM maternal_core
  WHERE (is_breast_post_del IS NULL OR TRIM(is_breast_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

-- Mental Illness - Depression Section
missing_is_depression_before_preg AS (
  SELECT record_id, datetime_entry, 'is_depression_before_preg' AS variable, 'Missing is_depression_before_preg' AS issue, is_depression_before_preg AS current_value
  FROM maternal_core
  WHERE (is_depression_before_preg IS NULL OR TRIM(is_depression_before_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_depression_during_preg AS (
  SELECT record_id, datetime_entry, 'is_depression_during_preg' AS variable, 'Missing is_depression_during_preg' AS issue, is_depression_during_preg AS current_value
  FROM maternal_core
  WHERE (is_depression_during_preg IS NULL OR TRIM(is_depression_during_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_depression_during_itp AS (
  SELECT record_id, datetime_entry, 'is_depression_during_itp' AS variable, 'Missing is_depression_during_itp' AS issue, is_depression_during_itp AS current_value
  FROM maternal_core
  WHERE (is_depression_during_itp IS NULL OR TRIM(is_depression_during_itp) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_is_depression_post_del AS (
  SELECT record_id, datetime_entry, 'is_depression_post_del' AS variable, 'Missing is_depression_post_del' AS issue, is_depression_post_del AS current_value
  FROM maternal_core
  WHERE (is_depression_post_del IS NULL OR TRIM(is_depression_post_del) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-05-09 08:32:44'
),

missing_prev_year_of_delivery AS (
  -- Missing prev_year_of_delivery
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_year_of_delivery' AS variable,
    'Missing prev_year_of_delivery' AS issue,
    ppd.prev_year_of_delivery AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.prev_year_of_delivery IS NULL OR TRIM(ppd.prev_year_of_delivery) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_prev_year_of_delivery AS (
  -- prev_year_of_delivery out of range (expected 1975 to current year)
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_year_of_delivery' AS variable,
    'prev_year_of_delivery out of range (expected 1975 to current year)' AS issue,
    ppd.prev_year_of_delivery AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE ppd.prev_year_of_delivery IS NOT NULL
    AND TRIM(ppd.prev_year_of_delivery) != ''
    AND TRIM(ppd.prev_year_of_delivery) != 'NI'
    AND (
      TRY_CAST(ppd.prev_year_of_delivery AS INTEGER) IS NULL
      OR TRY_CAST(ppd.prev_year_of_delivery AS INTEGER) < 1975
      OR TRY_CAST(ppd.prev_year_of_delivery AS INTEGER) > EXTRACT(YEAR FROM CURRENT_DATE)
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_prev_gest AS (
  -- Missing prev_gest
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_gest' AS variable,
    'Missing prev_gest' AS issue,
    ppd.prev_gest AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.prev_gest IS NULL OR TRIM(ppd.prev_gest) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_prev_gest AS (
  -- prev_gest out of range (expected 1-45 weeks)
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_gest' AS variable,
    'prev_gest out of range (expected 1-45 weeks)' AS issue,
    ppd.prev_gest AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE ppd.prev_gest IS NOT NULL
    AND TRIM(ppd.prev_gest) != ''
    AND TRIM(ppd.prev_gest) != 'NI'
    AND TRIM(ppd.prev_gest) != 'INV'
    AND (
      TRY_CAST(ppd.prev_gest AS INTEGER) IS NULL
      OR TRY_CAST(ppd.prev_gest AS INTEGER) < 1
      OR TRY_CAST(ppd.prev_gest AS INTEGER) > 45
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_prev_birth_weight_g AS (
  -- Missing prev_birth_weight_g
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_birth_weight_g' AS variable,
    'Missing prev_birth_weight_g' AS issue,
    ppd.prev_birth_weight_g AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.prev_birth_weight_g IS NULL OR TRIM(ppd.prev_birth_weight_g) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),

invalid_prev_birth_weight_g AS (
  -- prev_birth_weight_g out of range (expected 200-6000 grams)
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_birth_weight_g' AS variable,
    'prev_birth_weight_g out of range (expected 200-6000 grams)' AS issue,
    ppd.prev_birth_weight_g AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE ppd.prev_birth_weight_g IS NOT NULL
    AND TRIM(ppd.prev_birth_weight_g) != ''
    AND TRIM(ppd.prev_birth_weight_g) != 'NI'
    AND (
      TRY_CAST(ppd.prev_birth_weight_g AS INTEGER) IS NULL
      OR TRY_CAST(ppd.prev_birth_weight_g AS INTEGER) < 200
      OR TRY_CAST(ppd.prev_birth_weight_g AS INTEGER) > 6000
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


missing_prev_mode_of_delivery AS (
  -- Missing prev_mode_of_delivery
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_mode_of_delivery' AS variable,
    'Missing prev_mode_of_delivery' AS issue,
    ppd.prev_mode_of_delivery AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.prev_mode_of_delivery IS NULL OR TRIM(ppd.prev_mode_of_delivery) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-07-03 11:21:46'
),


missing_prev_outcome AS (
  -- Missing prev_outcome
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'prev_outcome' AS variable,
    'Missing prev_outcome' AS issue,
    ppd.prev_outcome AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.prev_outcome IS NULL OR TRIM(ppd.prev_outcome) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-05-02 10:29:25'
),


-- Previous Pregnancy Complications
missing_is_prev_pet AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_pet' AS variable, 'Missing is_prev_pet' AS issue, ppd.is_prev_pet AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_pet IS NULL OR TRIM(ppd.is_prev_pet) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_aph AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_aph' AS variable, 'Missing is_prev_aph' AS issue, ppd.is_prev_aph AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_aph IS NULL OR TRIM(ppd.is_prev_aph) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_pph AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_pph' AS variable, 'Missing is_prev_pph' AS issue, ppd.is_prev_pph AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_pph IS NULL OR TRIM(ppd.is_prev_pph) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_ur AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_ur' AS variable, 'Missing is_prev_ur' AS issue, ppd.is_prev_ur AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_ur IS NULL OR TRIM(ppd.is_prev_ur) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_ppi AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_ppi' AS variable, 'Missing is_prev_ppi' AS issue, ppd.is_prev_ppi AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_ppi IS NULL OR TRIM(ppd.is_prev_ppi) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_ol AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_ol' AS variable, 'Missing is_prev_ol' AS issue, ppd.is_prev_ol AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_ol IS NULL OR TRIM(ppd.is_prev_ol) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_rp AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_rp' AS variable, 'Missing is_prev_rp' AS issue, ppd.is_prev_rp AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_rp IS NULL OR TRIM(ppd.is_prev_rp) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_mp AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_mp' AS variable, 'Missing is_prev_mp' AS issue, ppd.is_prev_mp AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_mp IS NULL OR TRIM(ppd.is_prev_mp) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_mis AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_mis' AS variable, 'Missing is_prev_mis' AS issue, ppd.is_prev_mis AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_mis IS NULL OR TRIM(ppd.is_prev_mis) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_nbc AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_nbc' AS variable, 'Missing is_prev_nbc' AS issue, ppd.is_prev_nbc AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_nbc IS NULL OR TRIM(ppd.is_prev_nbc) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_end AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_end' AS variable, 'Missing is_prev_end' AS issue, ppd.is_prev_end AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_end IS NULL OR TRIM(ppd.is_prev_end) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_prev_oth_complications AS (
  SELECT mc.record_id, mc.datetime_entry, 'is_prev_oth_complications' AS variable, 'Missing is_prev_oth_complications' AS issue, ppd.is_prev_oth_complications AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.is_prev_oth_complications IS NULL OR TRIM(ppd.is_prev_oth_complications) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_oth_complications AS (
  -- Missing oth_complications when is_prev_oth_complications = '1'
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'oth_complications' AS variable,
    'Missing oth_complications (other complications = Yes but no specification)' AS issue,
    ppd.oth_complications AS current_value
  FROM maternal_core mc
  INNER JOIN previous_pregnancy_details ppd ON mc.record_id = ppd.record_id
  WHERE (ppd.oth_complications IS NULL OR TRIM(ppd.oth_complications) = '')
    AND ppd.is_prev_oth_complications = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),


-- Second BP measurements
missing_second_bp_systolic AS (
  SELECT record_id, datetime_entry, 'second_bp_systolic' AS variable, 'Missing second_bp_systolic' AS issue, second_bp_systolic AS current_value
  FROM maternal_core
  WHERE (second_bp_systolic IS NULL OR TRIM(second_bp_systolic) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_second_bp_systolic AS (
  SELECT record_id, datetime_entry, 'second_bp_systolic' AS variable, 'second_bp_systolic out of range (expected 70-200 mm Hg)' AS issue, second_bp_systolic AS current_value
  FROM maternal_core
  WHERE second_bp_systolic IS NOT NULL
    AND TRIM(second_bp_systolic) != ''
    AND TRIM(second_bp_systolic) != 'NI'
    AND (
      TRY_CAST(second_bp_systolic AS INTEGER) IS NULL
      OR TRY_CAST(second_bp_systolic AS INTEGER) < 70
      OR TRY_CAST(second_bp_systolic AS INTEGER) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_second_bp_diastolic AS (
  SELECT record_id, datetime_entry, 'second_bp_diastolic' AS variable, 'Missing second_bp_diastolic' AS issue, second_bp_diastolic AS current_value
  FROM maternal_core
  WHERE (second_bp_diastolic IS NULL OR TRIM(second_bp_diastolic) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_second_bp_diastolic AS (
  SELECT record_id, datetime_entry, 'second_bp_diastolic' AS variable, 'second_bp_diastolic out of range (expected 40-120 mm Hg)' AS issue, second_bp_diastolic AS current_value
  FROM maternal_core
  WHERE second_bp_diastolic IS NOT NULL
    AND TRIM(second_bp_diastolic) != ''
    AND TRIM(second_bp_diastolic) != 'NI'
    AND (
      TRY_CAST(second_bp_diastolic AS INTEGER) IS NULL
      OR TRY_CAST(second_bp_diastolic AS INTEGER) < 40
      OR TRY_CAST(second_bp_diastolic AS INTEGER) > 120
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Fundal height
missing_fundal_height_wks AS (
  SELECT record_id, datetime_entry, 'fundal_height_wks' AS variable, 'Missing fundal_height_wks' AS issue, fundal_height_wks AS current_value
  FROM maternal_core
  WHERE (fundal_height_wks IS NULL OR TRIM(fundal_height_wks) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_fundal_height_wks AS (
  SELECT record_id, datetime_entry, 'fundal_height_wks' AS variable, 'fundal_height_wks out of range (expected 16-42 weeks)' AS issue, fundal_height_wks AS current_value
  FROM maternal_core
  WHERE fundal_height_wks IS NOT NULL
    AND TRIM(fundal_height_wks) != ''
    AND TRIM(fundal_height_wks) != 'NI'
    AND (
      TRY_CAST(fundal_height_wks AS INTEGER) IS NULL
      OR TRY_CAST(fundal_height_wks AS INTEGER) < 16
      OR TRY_CAST(fundal_height_wks AS INTEGER) > 42
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Foetal presentation
missing_foetal_presentation AS (
  SELECT record_id, datetime_entry, 'foetal_presentation' AS variable, 'Missing foetal_presentation' AS issue, foetal_presentation AS current_value
  FROM maternal_core
  WHERE (foetal_presentation IS NULL OR TRIM(foetal_presentation) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Foetal lie
missing_foetal_lie AS (
  SELECT record_id, datetime_entry, 'foetal_lie' AS variable, 'Missing foetal_lie' AS issue, foetal_lie AS current_value
  FROM maternal_core
  WHERE (foetal_lie IS NULL OR TRIM(foetal_lie) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Foetal station
missing_foetal_station AS (
  SELECT record_id, datetime_entry, 'foetal_station' AS variable, 'Missing foetal_station' AS issue, foetal_station AS current_value
  FROM maternal_core
  WHERE (foetal_station IS NULL OR TRIM(foetal_station) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_foetal_station AS (
  SELECT record_id, datetime_entry, 'foetal_station' AS variable, 'foetal_station out of range (expected 0-5 cm)' AS issue, foetal_station AS current_value
  FROM maternal_core
  WHERE foetal_station IS NOT NULL
    AND TRIM(foetal_station) != ''
    AND TRIM(foetal_station) != 'NI'
    AND (
      TRY_CAST(foetal_station AS INTEGER) IS NULL
      OR TRY_CAST(foetal_station AS INTEGER) < 0
      OR TRY_CAST(foetal_station AS INTEGER) > 5
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Foetal descent
missing_foetal_descent AS (
  SELECT record_id, datetime_entry, 'foetal_descent' AS variable, 'Missing foetal_descent' AS issue, foetal_descent AS current_value
  FROM maternal_core
  WHERE (foetal_descent IS NULL OR TRIM(foetal_descent) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_foetal_descent AS (
  SELECT record_id, datetime_entry, 'foetal_descent' AS variable, 'foetal_descent out of range (expected 0-5 /5)' AS issue, foetal_descent AS current_value
  FROM maternal_core
  WHERE foetal_descent IS NOT NULL
    AND TRIM(foetal_descent) != ''
    AND TRIM(foetal_descent) != 'NI'
    AND (
      TRY_CAST(foetal_descent AS INTEGER) IS NULL
      OR TRY_CAST(foetal_descent AS INTEGER) < 0
      OR TRY_CAST(foetal_descent AS INTEGER) > 5
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- FHR heard
missing_is_fhr_heard AS (
  SELECT record_id, datetime_entry, 'is_fhr_heard' AS variable, 'Missing is_fhr_heard' AS issue, is_fhr_heard AS current_value
  FROM maternal_core
  WHERE (is_fhr_heard IS NULL OR TRIM(is_fhr_heard) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Twin pregnancy
missing_is_twin_preg AS (
  SELECT record_id, datetime_entry, 'is_twin_preg' AS variable, 'Missing is_twin_preg' AS issue, is_twin_preg AS current_value
  FROM maternal_core
  WHERE (is_twin_preg IS NULL OR TRIM(is_twin_preg) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- FHR per minute (conditional on is_fhr_heard = '1')
missing_fhr_heard_per_min AS (
  SELECT record_id, datetime_entry, 'fhr_heard_per_min' AS variable, 'Missing fhr_heard_per_min (FHR heard = Yes but no rate recorded)' AS issue, fhr_heard_per_min AS current_value
  FROM maternal_core
  WHERE (fhr_heard_per_min IS NULL OR TRIM(fhr_heard_per_min) = '')
    AND is_fhr_heard = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_fhr_heard_per_min AS (
  SELECT record_id, datetime_entry, 'fhr_heard_per_min' AS variable, 'fhr_heard_per_min out of range (expected 80-200 bpm)' AS issue, fhr_heard_per_min AS current_value
  FROM maternal_core
  WHERE fhr_heard_per_min IS NOT NULL
    AND TRIM(fhr_heard_per_min) != ''
    AND TRIM(fhr_heard_per_min) != 'NI'
    AND is_fhr_heard = '1'
    AND (
      TRY_CAST(fhr_heard_per_min AS INTEGER) IS NULL
      OR TRY_CAST(fhr_heard_per_min AS INTEGER) < 80
      OR TRY_CAST(fhr_heard_per_min AS INTEGER) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- FHR per minute twin 2 (conditional on is_fhr_heard = '1' AND is_twin_preg = '1')
missing_fhr_heard_per_min_2 AS (
  SELECT record_id, datetime_entry, 'fhr_heard_per_min_2' AS variable, 'Missing fhr_heard_per_min_2 (Twin pregnancy & FHR heard but no rate for twin 2 recorded)' AS issue, fhr_heard_per_min_2 AS current_value
  FROM maternal_core
  WHERE (fhr_heard_per_min_2 IS NULL OR TRIM(fhr_heard_per_min_2) = '')
    AND is_fhr_heard = '1'
    AND is_twin_preg = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_fhr_heard_per_min_2 AS (
  SELECT record_id, datetime_entry, 'fhr_heard_per_min_2' AS variable, 'fhr_heard_per_min_2 out of range (expected 80-200 bpm)' AS issue, fhr_heard_per_min_2 AS current_value
  FROM maternal_core
  WHERE fhr_heard_per_min_2 IS NOT NULL
    AND TRIM(fhr_heard_per_min_2) != ''
    AND TRIM(fhr_heard_per_min_2) != 'NI'
    AND is_fhr_heard = '1'
    AND is_twin_preg = '1'
    AND (
      TRY_CAST(fhr_heard_per_min_2 AS INTEGER) IS NULL
      OR TRY_CAST(fhr_heard_per_min_2 AS INTEGER) < 80
      OR TRY_CAST(fhr_heard_per_min_2 AS INTEGER) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- FHR per minute twin 3 (conditional on is_fhr_heard = '1' AND is_twin_preg = '1')
missing_fhr_heard_per_min_3 AS (
  SELECT record_id, datetime_entry, 'fhr_heard_per_min_3' AS variable, 'Missing fhr_heard_per_min_3 (Twin pregnancy & FHR heard but no rate for twin 3 recorded)' AS issue, fhr_heard_per_min_3 AS current_value
  FROM maternal_core
  WHERE (fhr_heard_per_min_3 IS NULL OR TRIM(fhr_heard_per_min_3) = '')
    AND is_fhr_heard = '1'
    AND is_twin_preg = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_fhr_heard_per_min_3 AS (
  SELECT record_id, datetime_entry, 'fhr_heard_per_min_3' AS variable, 'fhr_heard_per_min_3 out of range (expected 80-200 bpm)' AS issue, fhr_heard_per_min_3 AS current_value
  FROM maternal_core
  WHERE fhr_heard_per_min_3 IS NOT NULL
    AND TRIM(fhr_heard_per_min_3) != ''
    AND TRIM(fhr_heard_per_min_3) != 'NI'
    AND is_fhr_heard = '1'
    AND is_twin_preg = '1'
    AND (
      TRY_CAST(fhr_heard_per_min_3 AS INTEGER) IS NULL
      OR TRY_CAST(fhr_heard_per_min_3 AS INTEGER) < 80
      OR TRY_CAST(fhr_heard_per_min_3 AS INTEGER) > 200
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),


-- Vaginal examination fields
missing_vaginal_dilatation_cm AS (
  SELECT record_id, datetime_entry, 'vaginal_dilatation_cm' AS variable, 'Missing vaginal_dilatation_cm' AS issue, vaginal_dilatation_cm AS current_value
  FROM maternal_core
  WHERE (vaginal_dilatation_cm IS NULL OR TRIM(vaginal_dilatation_cm) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_vaginal_dilatation_cm AS (
  SELECT record_id, datetime_entry, 'vaginal_dilatation_cm' AS variable, 'vaginal_dilatation_cm out of range (expected 0-10 cm)' AS issue, vaginal_dilatation_cm AS current_value
  FROM maternal_core
  WHERE vaginal_dilatation_cm IS NOT NULL
    AND TRIM(vaginal_dilatation_cm) != ''
    AND TRIM(vaginal_dilatation_cm) != 'NI'
    AND (
      TRY_CAST(vaginal_dilatation_cm AS INTEGER) IS NULL
      OR TRY_CAST(vaginal_dilatation_cm AS INTEGER) < 0
      OR TRY_CAST(vaginal_dilatation_cm AS INTEGER) > 10
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_vaginal_length_cm AS (
  SELECT record_id, datetime_entry, 'vaginal_length_cm' AS variable, 'Missing vaginal_length_cm' AS issue, vaginal_length_cm AS current_value
  FROM maternal_core
  WHERE (vaginal_length_cm IS NULL OR TRIM(vaginal_length_cm) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_vaginal_length_cm AS (
  SELECT record_id, datetime_entry, 'vaginal_length_cm' AS variable, 'vaginal_length_cm out of range (expected 0-10 cm)' AS issue, vaginal_length_cm AS current_value
  FROM maternal_core
  WHERE vaginal_length_cm IS NOT NULL
    AND TRIM(vaginal_length_cm) != ''
    AND TRIM(vaginal_length_cm) != 'NI'
    AND (
      TRY_CAST(vaginal_length_cm AS INTEGER) IS NULL
      OR TRY_CAST(vaginal_length_cm AS INTEGER) < 0
      OR TRY_CAST(vaginal_length_cm AS INTEGER) > 10
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_cervical_consistency AS (
  SELECT record_id, datetime_entry, 'cervical_consistency' AS variable, 'Missing cervical_consistency' AS issue, cervical_consistency AS current_value
  FROM maternal_core
  WHERE (cervical_consistency IS NULL OR TRIM(cervical_consistency) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

--missing_cervical_consistency_oth AS (
--  SELECT record_id, datetime_entry, 'cervical_consistency_oth' AS variable, 'Missing cervical_consistency_oth (cervical consistency = Other but no specification)' AS issue, cervical_consistency_oth AS current_value
--  FROM maternal_core
--  WHERE (cervical_consistency_oth IS NULL OR TRIM(cervical_consistency_oth) = '')
--    AND cervical_consistency = 'OTH'
--    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
-- ),

missing_cervical_position AS (
  SELECT record_id, datetime_entry, 'cervical_position' AS variable, 'Missing cervical_position' AS issue, cervical_position AS current_value
  FROM maternal_core
  WHERE (cervical_position IS NULL OR TRIM(cervical_position) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Uterine scars section
missing_is_uterine_scar AS (
  SELECT record_id, datetime_entry, 'is_uterine_scar' AS variable, 'Missing is_uterine_scar' AS issue, is_uterine_scar AS current_value
  FROM maternal_core
  WHERE (is_uterine_scar IS NULL OR TRIM(is_uterine_scar) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_uterine_scar_specify AS (
  SELECT record_id, datetime_entry, 'uterine_scar_specify' AS variable, 'Missing uterine_scar_specify (uterine scar = Yes but no specification)' AS issue, uterine_scar_specify AS current_value
  FROM maternal_core
  WHERE (uterine_scar_specify IS NULL OR TRIM(uterine_scar_specify) = '')
    AND is_uterine_scar = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_uterine_scar_specify_oth AS (
  SELECT record_id, datetime_entry, 'uterine_scar_specify_oth' AS variable, 'Missing uterine_scar_specify_oth (uterine scar specify = Other but no specification)' AS issue, uterine_scar_specify_oth AS current_value
  FROM maternal_core
  WHERE (uterine_scar_specify_oth IS NULL OR TRIM(uterine_scar_specify_oth) = '')
    AND uterine_scar_specify = 'OTH'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_count_uterine_scar AS (
  SELECT record_id, datetime_entry, 'count_uterine_scar' AS variable, 'Missing count_uterine_scar (uterine scar = Yes but no count recorded)' AS issue, count_uterine_scar AS current_value
  FROM maternal_core
  WHERE (count_uterine_scar IS NULL OR TRIM(count_uterine_scar) = '')
    AND is_uterine_scar = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_count_uterine_scar AS (
  SELECT record_id, datetime_entry, 'count_uterine_scar' AS variable, 'count_uterine_scar out of range (expected 1-10)' AS issue, count_uterine_scar AS current_value
  FROM maternal_core
  WHERE count_uterine_scar IS NOT NULL
    AND TRIM(count_uterine_scar) != ''
    AND TRIM(count_uterine_scar) != 'NI'
    AND is_uterine_scar = '1'
    AND (
      TRY_CAST(count_uterine_scar AS INTEGER) IS NULL
      OR TRY_CAST(count_uterine_scar AS INTEGER) < 1
      OR TRY_CAST(count_uterine_scar AS INTEGER) > 10
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- ROM section
missing_is_rom_at_adm AS (
  SELECT record_id, datetime_entry, 'is_rom_at_adm' AS variable, 'Missing is_rom_at_adm' AS issue, is_rom_at_adm AS current_value
  FROM maternal_core
  WHERE (is_rom_at_adm IS NULL OR TRIM(is_rom_at_adm) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_rom_duration_value AS (
  SELECT record_id, datetime_entry, 'rom_duration_value' AS variable, 'Missing rom_duration_value (ROM at admission = Yes but no duration recorded)' AS issue, rom_duration_value AS current_value
  FROM maternal_core
  WHERE (rom_duration_value IS NULL OR TRIM(rom_duration_value) = '')
    AND is_rom_at_adm = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_rom_duration_value AS (
  SELECT record_id, datetime_entry, 'rom_duration_value' AS variable, 'rom_duration_value out of range (expected 0-720 hours or 0-30 days)' AS issue, rom_duration_value AS current_value
  FROM maternal_core
  WHERE rom_duration_value IS NOT NULL
    AND TRIM(rom_duration_value) != ''
    AND TRIM(rom_duration_value) != 'NI'
    AND is_rom_at_adm = '1'
    AND TRY_CAST(rom_duration_value AS INTEGER) IS NULL
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_rom_duration_unit AS (
  SELECT record_id, datetime_entry, 'rom_duration_unit' AS variable, 'Missing rom_duration_unit (ROM duration recorded but no unit specified)' AS issue, rom_duration_unit AS current_value
  FROM maternal_core
  WHERE (rom_duration_unit IS NULL OR TRIM(rom_duration_unit) = '')
    AND is_rom_at_adm = '1'
    AND rom_duration_value IS NOT NULL
    AND TRIM(rom_duration_value) != ''
    AND TRIM(rom_duration_value) != 'NI'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Liquor section
missing_is_liquor_clear AS (
  SELECT record_id, datetime_entry, 'is_liquor_clear' AS variable, 'Missing is_liquor_clear' AS issue, is_liquor_clear AS current_value
  FROM maternal_core
  WHERE (is_liquor_clear IS NULL OR TRIM(is_liquor_clear) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_liquor_offensive AS (
  SELECT record_id, datetime_entry, 'is_liquor_offensive' AS variable, 'Missing is_liquor_offensive' AS issue, is_liquor_offensive AS current_value
  FROM maternal_core
  WHERE (is_liquor_offensive IS NULL OR TRIM(is_liquor_offensive) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_meconium_present AS (
  SELECT record_id, datetime_entry, 'is_meconium_present' AS variable, 'Missing is_meconium_present' AS issue, is_meconium_present AS current_value
  FROM maternal_core
  WHERE (is_meconium_present IS NULL OR TRIM(is_meconium_present) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_meconium_grade AS (
  SELECT record_id, datetime_entry, 'meconium_grade' AS variable, 'Missing meconium_grade (Meconium present = Yes but no grade recorded)' AS issue, meconium_grade AS current_value
  FROM maternal_core
  WHERE (meconium_grade IS NULL OR TRIM(meconium_grade) = '')
    AND is_meconium_present = '1'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Physical examination
missing_is_adm_physical_exam AS (
  SELECT record_id, datetime_entry, 'is_adm_physical_exam' AS variable, 'Missing is_adm_physical_exam' AS issue, is_adm_physical_exam AS current_value
  FROM maternal_core
  WHERE (is_adm_physical_exam IS NULL OR TRIM(is_adm_physical_exam) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),


-- Stage of labour at admission
missing_adm_stage_labour AS (
  SELECT record_id, datetime_entry, 'adm_stage_labour' AS variable, 'Missing adm_stage_labour' AS issue, adm_stage_labour AS current_value
  FROM maternal_core
  WHERE (adm_stage_labour IS NULL OR TRIM(adm_stage_labour) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Admitting clinician name
missing_admitting_clinician_name AS (
  SELECT record_id, datetime_entry, 'admitting_clinician_name' AS variable, 'Missing admitting_clinician_name' AS issue, admitting_clinician_name AS current_value
  FROM maternal_core
  WHERE (admitting_clinician_name IS NULL OR TRIM(admitting_clinician_name) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Date signing admitting clinician
missing_date_sign_admitting_clin AS (
  SELECT record_id, datetime_entry, 'date_sign_admitting_clin' AS variable, 'Missing date_sign_admitting_clin' AS issue, date_sign_admitting_clin AS current_value
  FROM maternal_core
  WHERE (date_sign_admitting_clin IS NULL OR TRIM(date_sign_admitting_clin) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

future_date_sign_admitting_clin AS (
  SELECT record_id, datetime_entry, 'date_sign_admitting_clin' AS variable, 'Future date_sign_admitting_clin' AS issue, date_sign_admitting_clin AS current_value
  FROM maternal_core
  WHERE date_sign_admitting_clin IS NOT NULL
    AND TRIM(date_sign_admitting_clin) != ''
    AND TRY_CAST(date_sign_admitting_clin AS DATE) > CURRENT_DATE
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Time signing admitting clinician
missing_time_sign_adm_clinician AS (
  SELECT record_id, datetime_entry, 'time_sign_adm_clinician' AS variable, 'Missing time_sign_adm_clinician' AS issue, time_sign_adm_clinician AS current_value
  FROM maternal_core
  WHERE (time_sign_adm_clinician IS NULL OR TRIM(time_sign_adm_clinician) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_time_sign_adm_clinician AS (
  SELECT record_id, datetime_entry, 'time_sign_adm_clinician' AS variable, 'Invalid time_sign_adm_clinician format (expected HH:MM 12hr or 24hr)' AS issue, time_sign_adm_clinician AS current_value
  FROM maternal_core
  WHERE time_sign_adm_clinician IS NOT NULL
    AND TRIM(time_sign_adm_clinician) != ''
    AND TRIM(time_sign_adm_clinician) != 'NI'
    AND NOT (
      regexp_matches(TRIM(time_sign_adm_clinician), '^(0?[1-9]|1[0-2]):[0-5][0-9]$')
      OR
      regexp_matches(TRIM(time_sign_adm_clinician), '^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
    )
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- AM/PM unit for admitting clinician time (only when time_sign_adm_clinician is present and not NI)
missing_adm_clin_sign_time AS (
  SELECT record_id, datetime_entry, 'adm_clin_sign_time' AS variable, 'Missing adm_clin_sign_time' AS issue, adm_clin_sign_time AS current_value
  FROM maternal_core
  WHERE (adm_clin_sign_time IS NULL OR TRIM(adm_clin_sign_time) = '')
    AND time_sign_adm_clinician IS NOT NULL
    AND TRIM(time_sign_adm_clinician) != ''
    AND TRIM(time_sign_adm_clinician) != 'NI'
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Monitoring chart present and filled
missing_is_monitoring_chart AS (
  SELECT record_id, datetime_entry, 'is_monitoring_chart' AS variable, 'Missing is_monitoring_chart' AS issue, is_monitoring_chart AS current_value
  FROM maternal_core
  WHERE (is_monitoring_chart IS NULL OR TRIM(is_monitoring_chart) = '')
    AND CAST(datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),


-- Labour monitoring fields (from labour_and_delivery_monitoring table)
missing_lbr_monitoring_date AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_monitoring_date' AS variable,
    'Missing lbr_monitoring_date' AS issue,
    ldm.lbr_monitoring_date AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_monitoring_date IS NULL OR TRIM(ldm.lbr_monitoring_date) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

future_lbr_monitoring_date AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_monitoring_date' AS variable,
    'Future lbr_monitoring_date' AS issue,
    ldm.lbr_monitoring_date AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_monitoring_date IS NOT NULL
    AND TRIM(ldm.lbr_monitoring_date) != ''
    AND TRY_CAST(ldm.lbr_monitoring_date AS DATE) > CURRENT_DATE
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_monitoring_time AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_monitoring_time' AS variable,
    'Missing lbr_monitoring_time' AS issue,
    ldm.lbr_monitoring_time AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_monitoring_time IS NULL OR TRIM(ldm.lbr_monitoring_time) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_monitoring_time AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_monitoring_time' AS variable,
    'Invalid lbr_monitoring_time format (expected HH:MM 12hr or 24hr)' AS issue,
    ldm.lbr_monitoring_time AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_monitoring_time IS NOT NULL
    AND TRIM(ldm.lbr_monitoring_time) != ''
    AND TRIM(ldm.lbr_monitoring_time) != 'NI'
    AND NOT (
      regexp_matches(TRIM(ldm.lbr_monitoring_time), '^(0?[1-9]|1[0-2]):[0-5][0-9]$')
      OR
      regexp_matches(TRIM(ldm.lbr_monitoring_time), '^([01]?[0-9]|2[0-3]):[0-5][0-9]$')
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_monitoring_time_unit AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_monitoring_time_unit' AS variable,
    'Missing lbr_monitoring_time_unit' AS issue,
    ldm.lbr_monitoring_time_unit AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_monitoring_time_unit IS NULL OR TRIM(ldm.lbr_monitoring_time_unit) = '')
    AND ldm.lbr_monitoring_time IS NOT NULL
    AND TRIM(ldm.lbr_monitoring_time) != ''
    AND TRIM(ldm.lbr_monitoring_time) != 'NI'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_monitoring_clinician_name AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'monitoring_clinician_name' AS variable,
    'Missing monitoring_clinician_name' AS issue,
    ldm.monitoring_clinician_name AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.monitoring_clinician_name IS NULL OR TRIM(ldm.monitoring_clinician_name) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Labour vitals
missing_lbr_bp_systolic AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_bp_systolic' AS variable,
    'Missing lbr_bp_systolic' AS issue,
    ldm.lbr_bp_systolic AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_bp_systolic IS NULL OR TRIM(ldm.lbr_bp_systolic) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_bp_systolic AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_bp_systolic' AS variable,
    'lbr_bp_systolic out of range (expected 50-200 mm Hg)' AS issue,
    ldm.lbr_bp_systolic AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_bp_systolic IS NOT NULL
    AND TRIM(ldm.lbr_bp_systolic) != ''
    AND TRIM(ldm.lbr_bp_systolic) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_bp_systolic AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_bp_systolic AS INTEGER) < 50
      OR TRY_CAST(ldm.lbr_bp_systolic AS INTEGER) > 200
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_bp_diastolic AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_bp_diastolic' AS variable,
    'Missing lbr_bp_diastolic' AS issue,
    ldm.lbr_bp_diastolic AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_bp_diastolic IS NULL OR TRIM(ldm.lbr_bp_diastolic) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_bp_diastolic AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_bp_diastolic' AS variable,
    'lbr_bp_diastolic out of range (expected 30-120 mm Hg)' AS issue,
    ldm.lbr_bp_diastolic AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_bp_diastolic IS NOT NULL
    AND TRIM(ldm.lbr_bp_diastolic) != ''
    AND TRIM(ldm.lbr_bp_diastolic) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_bp_diastolic AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_bp_diastolic AS INTEGER) < 30
      OR TRY_CAST(ldm.lbr_bp_diastolic AS INTEGER) > 120
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_spo AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_spo' AS variable,
    'Missing lbr_spo' AS issue,
    ldm.lbr_spo AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_spo IS NULL OR TRIM(ldm.lbr_spo) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_spo AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_spo' AS variable,
    'lbr_spo out of range (expected 50-100 %)' AS issue,
    ldm.lbr_spo AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_spo IS NOT NULL
    AND TRIM(ldm.lbr_spo) != ''
    AND TRIM(ldm.lbr_spo) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_spo AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_spo AS INTEGER) < 50
      OR TRY_CAST(ldm.lbr_spo AS INTEGER) > 100
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_resp_rate AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_resp_rate' AS variable,
    'Missing lbr_resp_rate' AS issue,
    ldm.lbr_resp_rate AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_resp_rate IS NULL OR TRIM(ldm.lbr_resp_rate) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_resp_rate AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_resp_rate' AS variable,
    'lbr_resp_rate out of range (expected 8-40 bpm)' AS issue,
    ldm.lbr_resp_rate AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_resp_rate IS NOT NULL
    AND TRIM(ldm.lbr_resp_rate) != ''
    AND TRIM(ldm.lbr_resp_rate) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_resp_rate AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_resp_rate AS INTEGER) < 8
      OR TRY_CAST(ldm.lbr_resp_rate AS INTEGER) > 40
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_temp AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_temp' AS variable,
    'Missing lbr_temp' AS issue,
    ldm.lbr_temp AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_temp IS NULL OR TRIM(ldm.lbr_temp) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_temp AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_temp' AS variable,
    'lbr_temp out of range (expected 30-45 °C)' AS issue,
    ldm.lbr_temp AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_temp IS NOT NULL
    AND TRIM(ldm.lbr_temp) != ''
    AND TRIM(ldm.lbr_temp) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_temp AS DOUBLE) IS NULL
      OR TRY_CAST(ldm.lbr_temp AS DOUBLE) < 30
      OR TRY_CAST(ldm.lbr_temp AS DOUBLE) > 45
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_heart_rate AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_heart_rate' AS variable,
    'Missing lbr_heart_rate' AS issue,
    ldm.lbr_heart_rate AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_heart_rate IS NULL OR TRIM(ldm.lbr_heart_rate) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_heart_rate AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_heart_rate' AS variable,
    'lbr_heart_rate out of range (expected 40-200 bpm)' AS issue,
    ldm.lbr_heart_rate AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_heart_rate IS NOT NULL
    AND TRIM(ldm.lbr_heart_rate) != ''
    AND TRIM(ldm.lbr_heart_rate) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_heart_rate AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_heart_rate AS INTEGER) < 40
      OR TRY_CAST(ldm.lbr_heart_rate AS INTEGER) > 200
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- FHR monitoring
missing_lbr_fhr_monitoring_method AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_monitoring_method' AS variable,
    'Missing lbr_fhr_monitoring_method' AS issue,
    ldm.lbr_fhr_monitoring_method AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_fhr_monitoring_method IS NULL OR TRIM(ldm.lbr_fhr_monitoring_method) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_fhr_present AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_fhr_present' AS variable,
    'Missing is_lbr_fhr_present' AS issue,
    ldm.is_lbr_fhr_present AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_fhr_present IS NULL OR TRIM(ldm.is_lbr_fhr_present) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_fhr_regularity AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_regularity' AS variable,
    'Missing lbr_fhr_regularity (FHR present = Yes but regularity not recorded)' AS issue,
    ldm.lbr_fhr_regularity AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_fhr_regularity IS NULL OR TRIM(ldm.lbr_fhr_regularity) = '')
    AND ldm.is_lbr_fhr_present = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_twin_preg AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_twin_preg' AS variable,
    'Missing is_lbr_twin_preg' AS issue,
    ldm.is_lbr_twin_preg AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_twin_preg IS NULL OR TRIM(ldm.is_lbr_twin_preg) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_fhr_bpm AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_bpm' AS variable,
    'Missing lbr_fhr_bpm (FHR present = Yes but no rate recorded)' AS issue,
    ldm.lbr_fhr_bpm AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_fhr_bpm IS NULL OR TRIM(ldm.lbr_fhr_bpm) = '')
    AND ldm.is_lbr_fhr_present = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_fhr_bpm AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_bpm' AS variable,
    'lbr_fhr_bpm out of range (expected 80-200 bpm)' AS issue,
    ldm.lbr_fhr_bpm AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_fhr_bpm IS NOT NULL
    AND TRIM(ldm.lbr_fhr_bpm) != ''
    AND TRIM(ldm.lbr_fhr_bpm) != 'NI'
    AND ldm.is_lbr_fhr_present = '1'
    AND (
      TRY_CAST(ldm.lbr_fhr_bpm AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_fhr_bpm AS INTEGER) < 80
      OR TRY_CAST(ldm.lbr_fhr_bpm AS INTEGER) > 200
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_fhr_bpm_2 AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_bpm_2' AS variable,
    'Missing lbr_fhr_bpm_2 (Twin pregnancy & FHR present but no rate for twin 2 recorded)' AS issue,
    ldm.lbr_fhr_bpm_2 AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_fhr_bpm_2 IS NULL OR TRIM(ldm.lbr_fhr_bpm_2) = '')
    AND ldm.is_lbr_fhr_present = '1'
    AND ldm.is_lbr_twin_preg = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_fhr_bpm_2 AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_bpm_2' AS variable,
    'lbr_fhr_bpm_2 out of range (expected 80-200 bpm)' AS issue,
    ldm.lbr_fhr_bpm_2 AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_fhr_bpm_2 IS NOT NULL
    AND TRIM(ldm.lbr_fhr_bpm_2) != ''
    AND TRIM(ldm.lbr_fhr_bpm_2) != 'NI'
    AND ldm.is_lbr_fhr_present = '1'
    AND ldm.is_lbr_twin_preg = '1'
    AND (
      TRY_CAST(ldm.lbr_fhr_bpm_2 AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_fhr_bpm_2 AS INTEGER) < 80
      OR TRY_CAST(ldm.lbr_fhr_bpm_2 AS INTEGER) > 200
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_fhr_bpm_3 AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_bpm_3' AS variable,
    'Missing lbr_fhr_bpm_3 (Twin pregnancy & FHR present but no rate for twin 3 recorded)' AS issue,
    ldm.lbr_fhr_bpm_3 AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_fhr_bpm_3 IS NULL OR TRIM(ldm.lbr_fhr_bpm_3) = '')
    AND ldm.is_lbr_fhr_present = '1'
    AND ldm.is_lbr_twin_preg = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_fhr_bpm_3 AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_fhr_bpm_3' AS variable,
    'lbr_fhr_bpm_3 out of range (expected 80-200 bpm)' AS issue,
    ldm.lbr_fhr_bpm_3 AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_fhr_bpm_3 IS NOT NULL
    AND TRIM(ldm.lbr_fhr_bpm_3) != ''
    AND TRIM(ldm.lbr_fhr_bpm_3) != 'NI'
    AND ldm.is_lbr_fhr_present = '1'
    AND ldm.is_lbr_twin_preg = '1'
    AND (
      TRY_CAST(ldm.lbr_fhr_bpm_3 AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_fhr_bpm_3 AS INTEGER) < 80
      OR TRY_CAST(ldm.lbr_fhr_bpm_3 AS INTEGER) > 200
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),


-- Abdominal exam fields
missing_lbr_foetal_presentation AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_foetal_presentation' AS variable,
    'Missing lbr_foetal_presentation' AS issue,
    ldm.lbr_foetal_presentation AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_foetal_presentation IS NULL OR TRIM(ldm.lbr_foetal_presentation) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_foetal_lie AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_foetal_lie' AS variable,
    'Missing lbr_foetal_lie' AS issue,
    ldm.lbr_foetal_lie AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_foetal_lie IS NULL OR TRIM(ldm.lbr_foetal_lie) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_foetal_station AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_foetal_station' AS variable,
    'Missing lbr_foetal_station' AS issue,
    ldm.lbr_foetal_station AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_foetal_station IS NULL OR TRIM(ldm.lbr_foetal_station) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_foetal_station AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_foetal_station' AS variable,
    'lbr_foetal_station out of range (expected 0-5 cm)' AS issue,
    ldm.lbr_foetal_station AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_foetal_station IS NOT NULL
    AND TRIM(ldm.lbr_foetal_station) != ''
    AND TRIM(ldm.lbr_foetal_station) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_foetal_station AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_foetal_station AS INTEGER) < 0
      OR TRY_CAST(ldm.lbr_foetal_station AS INTEGER) > 5
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_foetal_descent AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_foetal_descent' AS variable,
    'Missing lbr_foetal_descent' AS issue,
    ldm.lbr_foetal_descent AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_foetal_descent IS NULL OR TRIM(ldm.lbr_foetal_descent) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_foetal_descent AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_foetal_descent' AS variable,
    'lbr_foetal_descent out of range (expected 0-5 /5)' AS issue,
    ldm.lbr_foetal_descent AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_foetal_descent IS NOT NULL
    AND TRIM(ldm.lbr_foetal_descent) != ''
    AND TRIM(ldm.lbr_foetal_descent) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_foetal_descent AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_foetal_descent AS INTEGER) < 0
      OR TRY_CAST(ldm.lbr_foetal_descent AS INTEGER) > 5
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_contractions AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_contractions' AS variable,
    'Missing is_lbr_contractions' AS issue,
    ldm.is_lbr_contractions AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_contractions IS NULL OR TRIM(ldm.is_lbr_contractions) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Vaginal exam fields
missing_lbr_vaginal_dilatation_cm AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_vaginal_dilatation_cm' AS variable,
    'Missing lbr_vaginal_dilatation_cm' AS issue,
    ldm.lbr_vaginal_dilatation_cm AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_vaginal_dilatation_cm IS NULL OR TRIM(ldm.lbr_vaginal_dilatation_cm) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_vaginal_dilatation_cm AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_vaginal_dilatation_cm' AS variable,
    'lbr_vaginal_dilatation_cm out of range (expected 0-10 cm)' AS issue,
    ldm.lbr_vaginal_dilatation_cm AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_vaginal_dilatation_cm IS NOT NULL
    AND TRIM(ldm.lbr_vaginal_dilatation_cm) != ''
    AND TRIM(ldm.lbr_vaginal_dilatation_cm) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_vaginal_dilatation_cm AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_vaginal_dilatation_cm AS INTEGER) < 0
      OR TRY_CAST(ldm.lbr_vaginal_dilatation_cm AS INTEGER) > 10
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_vaginal_length_cm AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_vaginal_length_cm' AS variable,
    'Missing lbr_vaginal_length_cm' AS issue,
    ldm.lbr_vaginal_length_cm AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_vaginal_length_cm IS NULL OR TRIM(ldm.lbr_vaginal_length_cm) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

invalid_lbr_vaginal_length_cm AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_vaginal_length_cm' AS variable,
    'lbr_vaginal_length_cm out of range (expected 0-10 cm)' AS issue,
    ldm.lbr_vaginal_length_cm AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE ldm.lbr_vaginal_length_cm IS NOT NULL
    AND TRIM(ldm.lbr_vaginal_length_cm) != ''
    AND TRIM(ldm.lbr_vaginal_length_cm) != 'NI'
    AND (
      TRY_CAST(ldm.lbr_vaginal_length_cm AS INTEGER) IS NULL
      OR TRY_CAST(ldm.lbr_vaginal_length_cm AS INTEGER) < 0
      OR TRY_CAST(ldm.lbr_vaginal_length_cm AS INTEGER) > 10
    )
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_cervical_consistency_lbr AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'cervical_consistency_lbr' AS variable,
    'Missing cervical_consistency_lbr' AS issue,
    ldm.cervical_consistency_lbr AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.cervical_consistency_lbr IS NULL OR TRIM(ldm.cervical_consistency_lbr) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- missing_cervical_consistcy_lb_oth AS (
 -- SELECT
  --  mc.record_id,
  --  mc.datetime_entry,
  --  'cervical_consistcy_lb_oth' AS variable,
  --  'Missing cervical_consistcy_lb_oth (cervical consistency = Other but no specification)' AS issue,
 --   ldm.cervical_consistcy_lb_oth AS current_value
 -- FROM maternal_core mc
  -- INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  -- WHERE (ldm.cervical_consistcy_lb_oth IS NULL OR TRIM(ldm.cervical_consistcy_lb_oth) = '')
    -- AND ldm.cervical_consistency_lbr = 'OTH'
   -- AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
-- ),

missing_cervical_position_lbr AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'cervical_position_lbr' AS variable,
    'Missing cervical_position_lbr' AS issue,
    ldm.cervical_position_lbr AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.cervical_position_lbr IS NULL OR TRIM(ldm.cervical_position_lbr) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_vaginal_discharge AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_vaginal_discharge' AS variable,
    'Missing is_lbr_vaginal_discharge' AS issue,
    ldm.is_lbr_vaginal_discharge AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_vaginal_discharge IS NULL OR TRIM(ldm.is_lbr_vaginal_discharge) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_vaginal_disch_type AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_vaginal_disch_type' AS variable,
    'Missing lbr_vaginal_disch_type (vaginal discharge = Yes but no type recorded)' AS issue,
    ldm.lbr_vaginal_disch_type AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_vaginal_disch_type IS NULL OR TRIM(ldm.lbr_vaginal_disch_type) = '')
    AND ldm.is_lbr_vaginal_discharge = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_discharge_oth AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_discharge_oth' AS variable,
    'Missing lbr_discharge_oth (discharge type = Other but no specification)' AS issue,
    ldm.lbr_discharge_oth AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_discharge_oth IS NULL OR TRIM(ldm.lbr_discharge_oth) = '')
    AND ldm.lbr_vaginal_disch_type = 'OTH'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_liquor_clear AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_liquor_clear' AS variable,
    'Missing is_lbr_liquor_clear' AS issue,
    ldm.is_lbr_liquor_clear AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_liquor_clear IS NULL OR TRIM(ldm.is_lbr_liquor_clear) = '')
    AND ldm.lbr_vaginal_disch_type = '2'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_msl AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_msl' AS variable,
    'Missing is_lbr_msl' AS issue,
    ldm.is_lbr_msl AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_msl IS NULL OR TRIM(ldm.is_lbr_msl) = '')
    AND ldm.lbr_vaginal_disch_type = '2'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_msl_grade AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_msl_grade' AS variable,
    'Missing lbr_msl_grade (MSL = Yes but no grade recorded)' AS issue,
    ldm.lbr_msl_grade AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_msl_grade IS NULL OR TRIM(ldm.lbr_msl_grade) = '')
    AND ldm.is_lbr_msl = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_liq_smelling AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_liq_smelling' AS variable,
    'Missing is_lbr_liq_smelling' AS issue,
    ldm.is_lbr_liq_smelling AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_liq_smelling IS NULL OR TRIM(ldm.is_lbr_liq_smelling) = '')
    AND ldm.lbr_vaginal_disch_type = '2'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_stage_labour AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_stage_labour' AS variable,
    'Missing lbr_stage_labour' AS issue,
    ldm.lbr_stage_labour AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_stage_labour IS NULL OR TRIM(ldm.lbr_stage_labour) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

-- Interventions
missing_is_lbr_arm_performed AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_arm_performed' AS variable,
    'Missing is_lbr_arm_performed' AS issue,
    ldm.is_lbr_arm_performed AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_arm_performed IS NULL OR TRIM(ldm.is_lbr_arm_performed) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_augmented AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_augmented' AS variable,
    'Missing is_lbr_augmented' AS issue,
    ldm.is_lbr_augmented AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_augmented IS NULL OR TRIM(ldm.is_lbr_augmented) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_aug_oxitocin AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_aug_oxitocin' AS variable,
    'Missing is_lbr_aug_oxitocin (Labour augmented = Yes but oxytocin status not recorded)' AS issue,
    ldm.is_lbr_aug_oxitocin AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_aug_oxitocin IS NULL OR TRIM(ldm.is_lbr_aug_oxitocin) = '')
    AND ldm.is_lbr_augmented = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_lbr_induced AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_lbr_induced' AS variable,
    'Missing is_lbr_induced' AS issue,
    ldm.is_lbr_induced AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_lbr_induced IS NULL OR TRIM(ldm.is_lbr_induced) = '')
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_induction_type AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_induction_type' AS variable,
    'Missing lbr_induction_type (Labour induction = Yes but no induction type recorded)' AS issue,
    ldm.lbr_induction_type AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_induction_type IS NULL OR TRIM(ldm.lbr_induction_type) = '')
    AND ldm.is_lbr_induced = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_misoprostol_lbr AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_misoprostol_lbr' AS variable,
    'Missing is_misoprostol_lbr (Induction type = Prostaglandin but misoprostol status not recorded)' AS issue,
    ldm.is_misoprostol_lbr AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_misoprostol_lbr IS NULL OR TRIM(ldm.is_misoprostol_lbr) = '')
    AND ldm.lbr_induction_type = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_misoprostol_lbr_route AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'misoprostol_lbr_route' AS variable,
    'Missing misoprostol_lbr_route (Misoprostol = Yes but route not recorded)' AS issue,
    ldm.misoprostol_lbr_route AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.misoprostol_lbr_route IS NULL OR TRIM(ldm.misoprostol_lbr_route) = '')
    AND ldm.is_misoprostol_lbr = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_glandin_lbr AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_glandin_lbr' AS variable,
    'Missing is_glandin_lbr (Induction type = Prostaglandin but glandin status not recorded)' AS issue,
    ldm.is_glandin_lbr AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_glandin_lbr IS NULL OR TRIM(ldm.is_glandin_lbr) = '')
    AND ldm.lbr_induction_type = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_glandin_lbr_route AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'glandin_lbr_route' AS variable,
    'Missing glandin_lbr_route (Glandin = Yes but route not recorded)' AS issue,
    ldm.glandin_lbr_route AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.glandin_lbr_route IS NULL OR TRIM(ldm.glandin_lbr_route) = '')
    AND ldm.is_glandin_lbr = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_is_vagiprost_lbr AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'is_vagiprost_lbr' AS variable,
    'Missing is_vagiprost_lbr (Induction type = Prostaglandin but vagiprost status not recorded)' AS issue,
    ldm.is_vagiprost_lbr AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.is_vagiprost_lbr IS NULL OR TRIM(ldm.is_vagiprost_lbr) = '')
    AND ldm.lbr_induction_type = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_vagiprost_lbr_route AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'vagiprost_lbr_route' AS variable,
    'Missing vagiprost_lbr_route (Vagiprost = Yes but route not recorded)' AS issue,
    ldm.vagiprost_lbr_route AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.vagiprost_lbr_route IS NULL OR TRIM(ldm.vagiprost_lbr_route) = '')
    AND ldm.is_vagiprost_lbr = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_induction_uterotonics AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_induction_uterotonics' AS variable,
    'Missing lbr_induction_uterotonics (Labour induction = Yes but uterotonics type not recorded)' AS issue,
    ldm.lbr_induction_uterotonics AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_induction_uterotonics IS NULL OR TRIM(ldm.lbr_induction_uterotonics) = '')
    AND ldm.is_lbr_induced = '1'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),

missing_lbr_inductn_uterotonc_oth AS (
  SELECT
    mc.record_id,
    mc.datetime_entry,
    'lbr_inductn_uterotonc_oth' AS variable,
    'Missing lbr_inductn_uterotonc_oth (Uterotonics = Other but no specification)' AS issue,
    ldm.lbr_inductn_uterotonc_oth AS current_value
  FROM maternal_core mc
  INNER JOIN labour_and_delivery_monitoring ldm ON mc.record_id = ldm.record_id
  WHERE (ldm.lbr_inductn_uterotonc_oth IS NULL OR TRIM(ldm.lbr_inductn_uterotonc_oth) = '')
    AND ldm.lbr_induction_uterotonics = 'OTH'
    AND CAST(mc.datetime_entry AS TIMESTAMP) >= '2025-09-08 08:00:00'
),




























    -- combine all checks
    all_issues AS (
      SELECT * FROM missing_document_source
      UNION ALL
      SELECT * FROM missing_hosp_id
      UNION ALL
      SELECT * FROM missing_admission_type
      UNION ALL
      SELECT * FROM missing_mother_ip_no
      UNION ALL
      SELECT * FROM missing_mother_age
      UNION ALL
      SELECT * FROM invalid_mother_age
      UNION ALL
      SELECT * FROM missing_mother_county
      UNION ALL
      SELECT * FROM missing_mother_subcounty
      UNION ALL
      SELECT * FROM missing_admission_date
      UNION ALL
      SELECT * FROM future_admission_date
      UNION ALL
      SELECT * FROM missing_admission_time
      UNION ALL
      SELECT * FROM missing_admission_time_unit
      UNION ALL
      SELECT * FROM missing_mother_residence
      UNION ALL
      SELECT * FROM missing_marriage_status
      UNION ALL
      SELECT * FROM missing_education_level
      -- UNION ALL
      -- SELECT * FROM missing_nationality
      UNION ALL
      SELECT * FROM missing_mother_occupation
      UNION ALL
      SELECT * FROM missing_mother_occupation_other
      UNION ALL
      SELECT * FROM missing_payment_method
      UNION ALL
      SELECT * FROM missing_payment_other
      UNION ALL
      SELECT * FROM missing_is_referral
      UNION ALL
      SELECT * FROM missing_referral_type
      UNION ALL
      SELECT * FROM missing_referring_facility_level
      UNION ALL
      SELECT * FROM missing_referring_facility_name
      UNION ALL
      SELECT * FROM missing_referring_facility_other
      UNION ALL
      SELECT * FROM missing_is_consented
      UNION ALL
      SELECT * FROM missing_study_id
      UNION ALL
      SELECT * FROM invalid_study_id
      UNION ALL
      SELECT * FROM missing_registering_clerk
      UNION ALL
      SELECT * FROM missing_date_clerking
      UNION ALL
      SELECT * FROM future_date_clerking
      UNION ALL
      SELECT * FROM early_date_clerking
      UNION ALL
      SELECT * FROM missing_time_clerking
      UNION ALL
      SELECT * FROM invalid_time_clerking
      UNION ALL
      SELECT * FROM missing_clerking_time_unit
      UNION ALL
      SELECT * FROM missing_adm_resp_rate
      UNION ALL
      SELECT * FROM invalid_adm_resp_rate
      UNION ALL
      SELECT * FROM missing_adm_bp_systolic
      UNION ALL
      SELECT * FROM invalid_adm_bp_systolic
      UNION ALL
      SELECT * FROM missing_adm_bp_diastolic
      UNION ALL
      SELECT * FROM invalid_adm_bp_diastolic
      UNION ALL
      SELECT * FROM missing_adm_heart_rate
      UNION ALL
      SELECT * FROM invalid_adm_heart_rate
      UNION ALL
      SELECT * FROM missing_adm_spo2
      UNION ALL
      SELECT * FROM invalid_adm_spo2
      UNION ALL
      SELECT * FROM missing_adm_temp
      UNION ALL
      SELECT * FROM invalid_adm_temp
      UNION ALL
      SELECT * FROM missing_is_airway_not_patent
      UNION ALL
      SELECT * FROM missing_is_abnormal_resp_rate
      UNION ALL
      SELECT * FROM missing_is_vaginal_bleeding
      UNION ALL
      SELECT * FROM missing_is_abnormal_temp
      UNION ALL
      SELECT * FROM missing_is_unconscious
      UNION ALL
      SELECT * FROM missing_is_convulsing
      UNION ALL
      SELECT * FROM missing_is_epigastric_pain
      UNION ALL
      SELECT * FROM missing_is_abnormal_heart_rate
      UNION ALL
      SELECT * FROM missing_is_abnormal_f_heart_rate
      UNION ALL
      SELECT * FROM missing_is_headache
      UNION ALL
      SELECT * FROM missing_is_abnormal_systolic_bp
      UNION ALL
      SELECT * FROM missing_is_dysponea
      UNION ALL
      SELECT * FROM missing_is_rom_gt_18h
      UNION ALL
      SELECT * FROM missing_is_abnormal_diastolic_bp
      UNION ALL
      SELECT * FROM missing_is_visual_impairment
      UNION ALL
      SELECT * FROM missing_is_body_swelling
      UNION ALL
      SELECT * FROM missing_is_rom_early
      UNION ALL
      SELECT * FROM missing_is_other_obs_emergency
      UNION ALL
      SELECT * FROM missing_name_triaging_clinician
      UNION ALL
      SELECT * FROM missing_date_triaging
      UNION ALL
      SELECT * FROM future_date_triaging
      UNION ALL
      SELECT * FROM missing_time_triaging
      UNION ALL
      SELECT * FROM invalid_time_triaging
      UNION ALL
      SELECT * FROM missing_triaging_time_unit
      UNION ALL
      SELECT * FROM missing_date_lmp_complete_status
      UNION ALL
      SELECT * FROM missing_date_lmp
      UNION ALL
      SELECT * FROM future_date_lmp
      UNION ALL
      SELECT * FROM date_lmp_after_admission
      UNION ALL
      SELECT * FROM missing_date_edd_complete_status
      UNION ALL
      SELECT * FROM missing_date_edd
      -- UNION ALL
      -- SELECT * FROM future_date_edd
      UNION ALL
      SELECT * FROM date_edd_before_lmp
      UNION
      SELECT * FROM missing_parity_birth
      UNION ALL
      SELECT * FROM invalid_parity_birth
      UNION ALL
      SELECT * FROM missing_parity_miscarriages
      UNION ALL
      SELECT * FROM invalid_parity_miscarriages
      UNION ALL
      SELECT * FROM missing_gravid_count
      UNION ALL
      SELECT * FROM invalid_gravid_count
      UNION ALL
      SELECT * FROM missing_date_first_anc
      UNION ALL
      SELECT * FROM future_date_first_anc
      UNION ALL
      SELECT * FROM date_first_anc_after_admission
      UNION ALL
      SELECT * FROM missing_anc_clinic_name
      UNION ALL
      SELECT * FROM missing_anc_clinic_name_other
      UNION ALL
      SELECT * FROM missing_count_anc_visits
      UNION ALL
      SELECT * FROM invalid_count_anc_visits
      UNION ALL
      SELECT * FROM missing_is_anc_us
      UNION ALL
      SELECT * FROM missing_date_anc_us_first
      UNION ALL
      SELECT * FROM future_date_anc_us_first
      UNION ALL
      SELECT * FROM date_anc_us_first_after_admission
      UNION ALL
      SELECT * FROM missing_gestation
      UNION ALL
      SELECT * FROM invalid_gestation
      UNION ALL
      SELECT * FROM missing_is_gest_lmp
      UNION ALL
      SELECT * FROM missing_gestation_from_lmp
      UNION ALL
      SELECT * FROM invalid_gestation_from_lmp
      UNION ALL
      SELECT * FROM missing_is_gest_us
      UNION ALL
      SELECT * FROM missing_gestation_from_us
      UNION ALL
      SELECT * FROM invalid_gestation_from_us
      UNION ALL
      SELECT * FROM missing_is_pocus_used
      UNION ALL
      SELECT * FROM missing_mother_weight_kg
      UNION ALL
      SELECT * FROM invalid_mother_weight_kg
      UNION ALL
      SELECT * FROM missing_mother_height_cm
      UNION ALL
      SELECT * FROM invalid_mother_height_cm
      UNION ALL
      SELECT * FROM missing_mother_bmi
    UNION ALL
    SELECT * FROM invalid_mother_bmi
    UNION ALL
    SELECT * FROM missing_muac
    UNION ALL
    SELECT * FROM invalid_muac
    UNION ALL
    SELECT * FROM missing_is_lower_abd_pain
    UNION ALL
    SELECT * FROM missing_is_off_vag_discharge
    UNION ALL
    SELECT * FROM missing_is_diff_breathing
    UNION ALL
    SELECT * FROM missing_is_abd_pain_other
    UNION ALL
    SELECT * FROM missing_is_screen_tb
    UNION ALL
    SELECT * FROM missing_is_chest_pain
    UNION ALL
    SELECT * FROM missing_is_weight_loss
    UNION ALL
    SELECT * FROM missing_is_reduced_f_movements
    UNION ALL
    SELECT * FROM missing_is_vomiting
    UNION ALL
    SELECT * FROM missing_is_visual_changes
    UNION ALL
    SELECT * FROM missing_is_fever
    UNION ALL
    SELECT * FROM missing_is_painful_urination
    UNION ALL
    SELECT * FROM missing_is_cough_lt_2_wks
    UNION ALL
    SELECT * FROM missing_is_cough_gt_or_equal_2_wks
    UNION ALL
    SELECT * FROM missing_is_drainage_of_amn_fluid
    UNION ALL
    SELECT * FROM missing_is_oedema
    UNION ALL
    SELECT * FROM missing_is_other_complaint
    UNION ALL
    SELECT * FROM missing_date_drainage_of_amn_fluid
    UNION ALL
    SELECT * FROM future_date_drainage_of_amn_fluid
    UNION ALL
    SELECT * FROM date_drainage_after_admission
    UNION ALL
    SELECT * FROM missing_time_drainage_of_amn_fluid
    UNION ALL
    SELECT * FROM invalid_time_drainage_of_amn_fluid
    UNION ALL
    SELECT * FROM missing_time_drainage_units
   -- UNION ALL
   -- SELECT * FROM missing_oedema_location_oth
    UNION ALL
    SELECT * FROM missing_other_complaints_specify
    UNION ALL
    SELECT * FROM missing_hb_booking_level
    UNION ALL
    SELECT * FROM invalid_hb_booking_level
    UNION ALL
    SELECT * FROM missing_date_booking_hb
    UNION ALL
    SELECT * FROM future_date_booking_hb
    UNION ALL
    SELECT * FROM date_booking_hb_after_admission
    UNION ALL
    SELECT * FROM missing_rbs_current_level
    UNION ALL
    SELECT * FROM invalid_rbs_current_level
    UNION ALL
    SELECT * FROM missing_platelets_count
    UNION ALL
    SELECT * FROM invalid_platelets_count
    UNION ALL
    SELECT * FROM missing_wbc_count
    UNION ALL
    SELECT * FROM invalid_wbc_count
    UNION ALL
    SELECT * FROM missing_is_malaria_rdt
    UNION ALL
    SELECT * FROM missing_blood_group_gxm
    UNION ALL
    SELECT * FROM missing_blood_group_rh_gxm
    UNION ALL
    SELECT * FROM missing_is_anti_d_given
    UNION ALL
    SELECT * FROM missing_is_hiv_test_done
    UNION ALL
    SELECT * FROM missing_hiv_test_result
    UNION ALL
    SELECT * FROM missing_date_hiv_test_done
    UNION ALL
    SELECT * FROM future_date_hiv_test_done
    UNION ALL
    SELECT * FROM missing_is_current_hb_done
    UNION ALL
    SELECT * FROM missing_current_hb
    UNION ALL
    SELECT * FROM invalid_current_hb
    UNION ALL
    SELECT * FROM missing_date_current_hb
    UNION ALL
    SELECT * FROM future_date_current_hb
    UNION ALL
    SELECT * FROM missing_is_vdrl_test_done
    UNION ALL
    SELECT * FROM missing_vdrl_test_result
    UNION ALL
    SELECT * FROM missing_date_vdrl_test_done
    UNION ALL
    SELECT * FROM future_date_vdrl_test_done
    UNION ALL
    SELECT * FROM missing_is_hepatitis_b_test_done
    UNION ALL
    SELECT * FROM missing_hepatitis_b_test_result
    UNION ALL
    SELECT * FROM missing_date_hepatitis_b_test_done
    UNION ALL
    SELECT * FROM future_date_hepatitis_b_test_done
    UNION ALL
    SELECT * FROM missing_is_ogtt_test_done
    UNION ALL
    SELECT * FROM missing_ogtt_result
    UNION ALL
    SELECT * FROM invalid_ogtt_result
    UNION ALL
    SELECT * FROM missing_date_ogtt_test_done
    UNION ALL
    SELECT * FROM future_date_ogtt_test_done
    UNION ALL
    SELECT * FROM missing_is_on_arvs
    UNION ALL
    SELECT * FROM missing_arvs_used
    UNION ALL
    SELECT * FROM missing_date_arvs_initiation
    UNION ALL
    SELECT * FROM future_date_arvs_initiation
    UNION ALL
    SELECT * FROM missing_is_vdrl_positive_treatment
    UNION ALL
    SELECT * FROM missing_is_bp_intervention
    UNION ALL
    SELECT * FROM missing_is_rbs_intervention
    UNION ALL
    SELECT * FROM missing_is_hb_intervention
    UNION ALL
    SELECT * FROM missing_is_iron_supplements
    UNION ALL
    SELECT * FROM missing_is_blood_transfusion
    UNION ALL
    SELECT * FROM missing_is_abnormal_us_intervened
    UNION ALL
    SELECT * FROM missing_is_antibiotics_last_4_wks
    UNION ALL
    SELECT * FROM missing_is_deworming_in_pregnancy
    UNION ALL
    SELECT * FROM missing_is_iron_given
    UNION ALL
    SELECT * FROM missing_is_folic_acid_given
    UNION ALL
    SELECT * FROM missing_is_calcium_given
    UNION ALL
    SELECT * FROM missing_is_multivitamins_given
    UNION ALL
    SELECT * FROM missing_is_other_supplements
    UNION ALL
    SELECT * FROM missing_supplements_given_other
    UNION ALL
    SELECT * FROM missing_is_alcohol_present
    UNION ALL
    SELECT * FROM missing_is_cigarette_present
    UNION ALL
    SELECT * FROM missing_is_chewing_tobacco
    UNION ALL
    SELECT * FROM missing_is_oth_substances
    UNION ALL
    SELECT * FROM missing_substances_in_preg_other
    UNION ALL
    SELECT * FROM missing_is_other_meds_not_ind
    UNION ALL
    SELECT * FROM missing_other_meds_not_ind
    UNION ALL
    SELECT * FROM missing_other_interventions
    UNION ALL
    SELECT * FROM missing_count_pregs
    UNION ALL
    SELECT * FROM invalid_count_pregs
    UNION ALL
    SELECT * FROM missing_pregs_28w_alive
    UNION ALL
    SELECT * FROM invalid_pregs_28w_alive
    UNION ALL
    SELECT * FROM missing_pregs_28w_miscarriage
    UNION ALL
    SELECT * FROM invalid_pregs_28w_miscarriage
    UNION ALL
    SELECT * FROM missing_count_living_children
    UNION ALL
    SELECT * FROM invalid_count_living_children
    UNION ALL
    SELECT * FROM missing_is_prev_preg_filled
    UNION ALL
    SELECT * FROM missing_is_cardiac_before_preg
    UNION ALL
    SELECT * FROM missing_is_cardiac_during_preg
    UNION ALL
    SELECT * FROM missing_is_cardiac_during_itp
    UNION ALL
    SELECT * FROM missing_is_cardiac_during_post_del
    UNION ALL
    SELECT * FROM missing_is_htn_before_preg
    UNION ALL
    SELECT * FROM missing_is_htn_during_preg
    UNION ALL
    SELECT * FROM missing_is_htn_during_itp
    UNION ALL
    SELECT * FROM missing_is_htn_during_post_del
    UNION ALL
    SELECT * FROM missing_is_asthma_before_preg
    UNION ALL
    SELECT * FROM missing_is_asthma_during_preg
    UNION ALL
    SELECT * FROM missing_is_asthma_during_ipt
    UNION ALL
    SELECT * FROM missing_is_asthma_during_post_del
    UNION ALL
    SELECT * FROM missing_is_epilepsy_before_preg
    UNION ALL
    SELECT * FROM missing_is_epilepsy_during_preg
    UNION ALL
    SELECT * FROM missing_is_epilepsy_during_itp
    UNION ALL
    SELECT * FROM missing_is_epilepsy_post_del
    UNION ALL
    SELECT * FROM missing_is_diabetes_before_preg
    UNION ALL
    SELECT * FROM missing_is_diabetes_during_preg
    UNION ALL
    SELECT * FROM missing_is_diabetes_during_itp
    UNION ALL
    SELECT * FROM missing_is_diabetes_post_del
    UNION ALL
    SELECT * FROM missing_is_thyroid_before_preg
    UNION ALL
    SELECT * FROM missing_is_thyroid_during_preg
    UNION ALL
    SELECT * FROM missing_is_thyroid_during_itp
    UNION ALL
    SELECT * FROM missing_is_thyroid_post_del
    UNION ALL
    SELECT * FROM missing_is_sti_before_preg
    UNION ALL
    SELECT * FROM missing_is_sti_during_preg
    UNION ALL
    SELECT * FROM missing_is_sti_during_itp
    UNION ALL
    SELECT * FROM missing_is_sti_post_del
    UNION ALL
    SELECT * FROM missing_is_renal_before_preg
    UNION ALL
    SELECT * FROM missing_is_renal_during_preg
    UNION ALL
    SELECT * FROM missing_is_renal_during_itp
    UNION ALL
    SELECT * FROM missing_is_renal_post_del
    UNION ALL
    SELECT * FROM missing_is_sickle_before_preg
    UNION ALL
    SELECT * FROM missing_is_sickle_during_preg
    UNION ALL
    SELECT * FROM missing_is_sickle_during_itp
    UNION ALL
    SELECT * FROM missing_is_sickle_post_del
    UNION ALL
    SELECT * FROM missing_is_cervical_before_preg
    UNION ALL
    SELECT * FROM missing_is_cervical_during_preg
    UNION ALL
    SELECT * FROM missing_is_cervical_during_itp
    UNION ALL
    SELECT * FROM missing_is_cervical_post_del
    UNION ALL
    SELECT * FROM missing_is_breast_before_preg
    UNION ALL
    SELECT * FROM missing_is_breast_during_preg
    UNION ALL
    SELECT * FROM missing_is_breast_during_itp
    UNION ALL
    SELECT * FROM missing_is_breast_post_del
    UNION ALL
    SELECT * FROM missing_is_depression_before_preg
    UNION ALL
    SELECT * FROM missing_is_depression_during_preg
    UNION ALL
    SELECT * FROM missing_is_depression_during_itp
    UNION ALL
    SELECT * FROM missing_is_depression_post_del
    UNION ALL
    SELECT * FROM missing_prev_year_of_delivery
    UNION ALL
    SELECT * FROM invalid_prev_year_of_delivery
    UNION ALL
    SELECT * FROM missing_prev_gest
    UNION ALL
    SELECT * FROM invalid_prev_gest
    UNION ALL
    SELECT * FROM missing_prev_birth_weight_g
    UNION ALL
    SELECT * FROM invalid_prev_birth_weight_g
    UNION ALL
    SELECT * FROM missing_prev_mode_of_delivery
    UNION ALL
    SELECT * FROM missing_prev_outcome
    UNION ALL
    SELECT * FROM missing_is_prev_pet
    UNION ALL
    SELECT * FROM missing_is_prev_aph
    UNION ALL
    SELECT * FROM missing_is_prev_pph
    UNION ALL
    SELECT * FROM missing_is_prev_ur
    UNION ALL
    SELECT * FROM missing_is_prev_ppi
    UNION ALL
    SELECT * FROM missing_is_prev_ol
    UNION ALL
    SELECT * FROM missing_is_prev_rp
    UNION ALL
    SELECT * FROM missing_is_prev_mp
    UNION ALL
    SELECT * FROM missing_is_prev_mis
    UNION ALL
    SELECT * FROM missing_is_prev_nbc
    UNION ALL
    SELECT * FROM missing_is_prev_end
    UNION ALL
    SELECT * FROM missing_is_prev_oth_complications
    UNION ALL
    SELECT * FROM missing_oth_complications
    UNION ALL
    SELECT * FROM missing_second_bp_systolic
    UNION ALL
    SELECT * FROM invalid_second_bp_systolic
    UNION ALL
    SELECT * FROM missing_second_bp_diastolic
    UNION ALL
    SELECT * FROM invalid_second_bp_diastolic
    UNION ALL
    SELECT * FROM missing_fundal_height_wks
    UNION ALL
    SELECT * FROM invalid_fundal_height_wks
    UNION ALL
    SELECT * FROM missing_foetal_presentation
    UNION ALL
    SELECT * FROM missing_foetal_lie
    UNION ALL
    SELECT * FROM missing_foetal_station
    UNION ALL
    SELECT * FROM invalid_foetal_station
    UNION ALL
    SELECT * FROM missing_foetal_descent
    UNION ALL
    SELECT * FROM invalid_foetal_descent
    UNION ALL
    SELECT * FROM missing_is_fhr_heard
    UNION ALL
    SELECT * FROM missing_is_twin_preg
    UNION ALL
    SELECT * FROM missing_fhr_heard_per_min
    UNION ALL
    SELECT * FROM invalid_fhr_heard_per_min
    UNION ALL
    SELECT * FROM missing_fhr_heard_per_min_2
    UNION ALL
    SELECT * FROM invalid_fhr_heard_per_min_2
    UNION ALL
    SELECT * FROM missing_fhr_heard_per_min_3
    UNION ALL
    SELECT * FROM invalid_fhr_heard_per_min_3
    UNION ALL
    SELECT * FROM missing_vaginal_dilatation_cm
    UNION ALL
    SELECT * FROM invalid_vaginal_dilatation_cm
    UNION ALL
    SELECT * FROM missing_vaginal_length_cm
    UNION ALL
    SELECT * FROM invalid_vaginal_length_cm
    UNION ALL
    SELECT * FROM missing_cervical_consistency
    -- UNION ALL
    -- SELECT * FROM missing_cervical_consistency_oth
    UNION ALL
    SELECT * FROM missing_cervical_position
    UNION ALL
    SELECT * FROM missing_is_uterine_scar
    UNION ALL
    SELECT * FROM missing_uterine_scar_specify
    UNION ALL
    SELECT * FROM missing_uterine_scar_specify_oth
    UNION ALL
    SELECT * FROM missing_count_uterine_scar
    UNION ALL
    SELECT * FROM invalid_count_uterine_scar
    UNION ALL
    SELECT * FROM missing_is_rom_at_adm
    UNION ALL
    SELECT * FROM missing_rom_duration_value
    UNION ALL
    SELECT * FROM invalid_rom_duration_value
    UNION ALL
    SELECT * FROM missing_rom_duration_unit
    UNION ALL
    SELECT * FROM missing_is_liquor_clear
    UNION ALL
    SELECT * FROM missing_is_liquor_offensive
    UNION ALL
    SELECT * FROM missing_is_meconium_present
    UNION ALL
    SELECT * FROM missing_meconium_grade
    UNION ALL
    SELECT * FROM missing_is_adm_physical_exam
    UNION ALL
    SELECT * FROM missing_adm_stage_labour
UNION ALL
SELECT * FROM missing_admitting_clinician_name
UNION ALL
SELECT * FROM missing_date_sign_admitting_clin
UNION ALL
SELECT * FROM future_date_sign_admitting_clin
UNION ALL
SELECT * FROM missing_time_sign_adm_clinician
UNION ALL
SELECT * FROM invalid_time_sign_adm_clinician
UNION ALL
SELECT * FROM missing_adm_clin_sign_time
UNION ALL
SELECT * FROM missing_is_monitoring_chart
UNION ALL
SELECT * FROM missing_lbr_monitoring_date
UNION ALL
SELECT * FROM future_lbr_monitoring_date
UNION ALL
SELECT * FROM missing_lbr_monitoring_time
UNION ALL
SELECT * FROM invalid_lbr_monitoring_time
UNION ALL
SELECT * FROM missing_lbr_monitoring_time_unit
UNION ALL
SELECT * FROM missing_monitoring_clinician_name
UNION ALL
SELECT * FROM missing_lbr_bp_systolic
UNION ALL
SELECT * FROM invalid_lbr_bp_systolic
UNION ALL
SELECT * FROM missing_lbr_bp_diastolic
UNION ALL
SELECT * FROM invalid_lbr_bp_diastolic
UNION ALL
SELECT * FROM missing_lbr_spo
UNION ALL
SELECT * FROM invalid_lbr_spo
UNION ALL
SELECT * FROM missing_lbr_resp_rate
UNION ALL
SELECT * FROM invalid_lbr_resp_rate
UNION ALL
SELECT * FROM missing_lbr_temp
UNION ALL
SELECT * FROM invalid_lbr_temp
UNION ALL
SELECT * FROM missing_lbr_heart_rate
UNION ALL
SELECT * FROM invalid_lbr_heart_rate
UNION ALL
SELECT * FROM missing_lbr_fhr_monitoring_method
UNION ALL
SELECT * FROM missing_is_lbr_fhr_present
UNION ALL
SELECT * FROM missing_lbr_fhr_regularity
UNION ALL
SELECT * FROM missing_is_lbr_twin_preg
UNION ALL
SELECT * FROM missing_lbr_fhr_bpm
UNION ALL
SELECT * FROM invalid_lbr_fhr_bpm
UNION ALL
SELECT * FROM missing_lbr_fhr_bpm_2
UNION ALL
SELECT * FROM invalid_lbr_fhr_bpm_2
UNION ALL
SELECT * FROM missing_lbr_fhr_bpm_3
UNION ALL
SELECT * FROM invalid_lbr_fhr_bpm_3
UNION ALL
SELECT * FROM missing_lbr_foetal_presentation
UNION ALL
SELECT * FROM missing_lbr_foetal_lie
UNION ALL
SELECT * FROM missing_lbr_foetal_station
UNION ALL
SELECT * FROM invalid_lbr_foetal_station
UNION ALL
SELECT * FROM missing_lbr_foetal_descent
UNION ALL
SELECT * FROM invalid_lbr_foetal_descent
UNION ALL
SELECT * FROM missing_is_lbr_contractions
UNION ALL
SELECT * FROM missing_lbr_vaginal_dilatation_cm
UNION ALL
SELECT * FROM invalid_lbr_vaginal_dilatation_cm
UNION ALL
SELECT * FROM missing_lbr_vaginal_length_cm
UNION ALL
SELECT * FROM invalid_lbr_vaginal_length_cm
UNION ALL
SELECT * FROM missing_cervical_consistency_lbr
-- UNION ALL
-- SELECT * FROM missing_cervical_consistcy_lb_oth
UNION ALL
SELECT * FROM missing_cervical_position_lbr
UNION ALL
SELECT * FROM missing_is_lbr_vaginal_discharge
UNION ALL
SELECT * FROM missing_lbr_vaginal_disch_type
UNION ALL
SELECT * FROM missing_lbr_discharge_oth
UNION ALL
SELECT * FROM missing_is_lbr_liquor_clear
UNION ALL
SELECT * FROM missing_is_lbr_msl
UNION ALL
SELECT * FROM missing_lbr_msl_grade
UNION ALL
SELECT * FROM missing_is_lbr_liq_smelling
UNION ALL
SELECT * FROM missing_lbr_stage_labour
UNION ALL
SELECT * FROM missing_is_lbr_arm_performed
UNION ALL
SELECT * FROM missing_is_lbr_augmented
UNION ALL
SELECT * FROM missing_is_lbr_aug_oxitocin
UNION ALL
SELECT * FROM missing_is_lbr_induced
UNION ALL
SELECT * FROM missing_lbr_induction_type
UNION ALL
SELECT * FROM missing_is_misoprostol_lbr
UNION ALL
SELECT * FROM missing_misoprostol_lbr_route
UNION ALL
SELECT * FROM missing_is_glandin_lbr
UNION ALL
SELECT * FROM missing_glandin_lbr_route
UNION ALL
SELECT * FROM missing_is_vagiprost_lbr
UNION ALL
SELECT * FROM missing_vagiprost_lbr_route
UNION ALL
SELECT * FROM missing_lbr_induction_uterotonics
UNION ALL
SELECT * FROM missing_lbr_inductn_uterotonc_oth









    )

  SELECT *
  FROM all_issues
  WHERE CAST(datetime_entry AS TIMESTAMP) >= '{start_date}'
    AND CAST(datetime_entry AS TIMESTAMP) <= '{end_date}'
  ORDER BY record_id, variable
"))

# DBI::dbDisconnect(con)
