test_that("Deletes a topic", {
  skip_on_cran()
  expect_error(topics_delete(topic = topic_name), NA)
})

test_that("Deletes a subscription", {
  skip_on_cran()
  expect_error(subscriptions_delete(subscription = sub_name), NA)
})

test_that("Deletes a schema", {
  skip_on_cran()
  expect_error(schemas_delete(name = schema_name), NA)
})

test_that("Deletes a snapshot", {
  skip_on_cran()
  expect_error(snapshots_delete(snapshot = snap_name), NA)
})
