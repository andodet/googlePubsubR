test_that("Creates a schema", {
  skip_on_cran()
  schema_def <- jsonlite::toJSON(schema_def, auto_unbox = TRUE)
  res <- schemas_create(
    name = schema_name, definition = schema_def, type = "AVRO"
  )
  
  expect_s3_class(res, "Schema")
  expect_equal(res$name, as.schema_name(schema_name))
})

test_that("Creates a topic", {
  skip_on_cran()
  schema <- schemas_get(schema_name)
  topic_res <- topics_create(
    name = topic_name, labels = labels,
    message_retention_duration = retention_duration,
    schema_settings = SchemaSettings(encoding = "JSON", schema)
  )

  expect_s3_class(topic_res, "Topic")
})

test_that("Creates a subscription", {
  skip_on_cran()
  res <- subscriptions_create(name = sub_name, topic = topic_name)

  expect_s3_class(res, "Subscription")
  expect_equal(res$name, as.sub_name(sub_name))
})

test_that("Creates a snapshot", {
  skip_on_cran()
  res <- snapshots_create(
    name = snap_name, subscription = sub_name, labels = labels
  )

  expect_s3_class(res, "Snapshot")
  expect_equal(res$name, as.snapshot_name(snap_name))
})
