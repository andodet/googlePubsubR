test_that("Gets and lists schemas", {
  skip_on_cran()
  
  res_get <- schemas_get(schema_name)
  res_list <- schemas_list()
  res_exist <- schemas_exists(schema_name)

  expect_s3_class(res_get, "Schema")
  expect_s3_class(res_list, "data.frame")
  expect_true(res_exist)
})

test_that("Schemas validates", {
  skip_on_cran()
  schema_def <- jsonlite::toJSON(schema_def, auto_unbox = TRUE)
  schema <- Schema(name = schema_name, type = "AVRO", definition = schema_def)
  
  expect_true(schemas_validate(schema = schema))
})

test_that("Validates message", {
  skip_on_cran()
  
  # TODO: this seems convoluted, check if it does make sense to simplify the message
  # interface.
  msg <- list(cost = 100, object = "fork")
  msg <- jsonlite::toJSON(msg, auto_unbox = TRUE)
  msg <- base64enc::base64encode(charToRaw(msg))
  
  expect_true(
    schemas_validate_message(schema = schema_name, message = msg, encoding = "JSON")
  )
})
