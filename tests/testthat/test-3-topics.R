test_that("Gets and lists topics", {
  skip_on_cran()
  res_get <- topics_get(topic_name)
  res_list <- topics_list()
  res_exist <- topics_exists(topic_name)

  expect_s3_class(res_get, "Topic")
  expect_s3_class(res_list, "data.frame")
  expect_true(res_exist)
})

test_that("Topic gets patched", {
  skip_on_cran()
  res <- topics_patch(
    topic = topic_name,
    message_retention_duration = "2400s",
    labels = list(new_a = "a", new_b = "b")
  )

  expect_s3_class(res, "Topic")
  expect_equal(res$messageRetentionDuration, "2400s")
  expect_equal(res$labels$new_a, "a")  
  expect_equal(res$labels$new_b, "b")

})

test_that("Can publish to a topic", {
  skip_on_cran()
  
  msg <- PubsubMessage(data = base64enc::base64encode(serialize("hello", NULL)))
  expect_error(topics_publish(messages = msg, topic = topic_name), NA)
  
})

test_that("Topic lists subscriptions", {
  skip_on_cran()
  
  res <- topics_list_subscriptions(topic = topic_name)
  expect_true(length(res) > 0)
})