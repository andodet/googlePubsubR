test_that("Gets and lists schemas", {
  skip_on_cran()
  
  res_get <- schemas_get(schema_name)
  res_list <- schemas_list()
  res_exist <- schemas_exists(schema_name)
  res_exist_fail <- schemas_exists("junk-name")

  expect_s3_class(res_get, "Schema")
  expect_s3_class(res_list, "data.frame")
  expect_true(res_exist)
  expect_false(res_exist_fail)
})

test_that("Schemas validates", {
  skip_on_cran()
  schema_def <- jsonlite::toJSON(schema_def, auto_unbox = TRUE)
  schema <- Schema(name = schema_name, type = "AVRO", definition = schema_def)
  
  expect_true(schemas_validate(schema = schema))
})

test_that("Validates message", {
  skip_on_cran()

  expect_true(
    schemas_validate_message(schema = schema_name, message = msg, encoding = "JSON")
  )
})
