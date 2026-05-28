fetch_redcap_data <- function(
  api_token = NULL,
  redcap_url = NULL,
  batch_size = 100,
  interbatch_delay = 0.5,
  continue_on_error = FALSE,
  records = NULL,
  fields = NULL,
  forms = NULL,
  events = NULL,
  raw_or_label = "raw",
  raw_or_label_headers = "raw",
  export_checkbox_label = FALSE,
  export_survey_fields = FALSE,
  export_data_access_groups = FALSE,
  filter_logic = "",
  datetime_range_begin = as.POSIXct(NA),
  datetime_range_end = as.POSIXct(NA),
  blank_for_gray_form_status = FALSE,
  col_types = NULL,
  na = character(0),
  guess_type = FALSE,
  http_response_encoding = "UTF-8",
  verbose = TRUE,
  id_position = 1L
) {
  if (is.null(api_token) || nchar(api_token) == 0) {
    stop("api_token is required and cannot be NULL or empty.")
  }
  if (is.null(redcap_url) || nchar(redcap_url) == 0) {
    stop("redcap_url is required and cannot be NULL or empty.")
  }

  data <- REDCapR::redcap_read(
    batch_size = batch_size,
    interbatch_delay = interbatch_delay,
    continue_on_error = continue_on_error,
    redcap_uri = redcap_url,
    token = api_token,
    records = records,
    fields = fields,
    forms = forms,
    events = events,
    raw_or_label = raw_or_label,
    raw_or_label_headers = raw_or_label_headers,
    export_checkbox_label = export_checkbox_label,
    export_survey_fields = export_survey_fields,
    export_data_access_groups = export_data_access_groups,
    filter_logic = filter_logic,
    datetime_range_begin = datetime_range_begin,
    datetime_range_end = datetime_range_end,
    blank_for_gray_form_status = blank_for_gray_form_status,
    col_types = col_types,
    na = na,
    guess_type = guess_type,
    http_response_encoding = http_response_encoding,
    verbose = verbose,
    id_position = id_position
  )$data

  return(data)
}
