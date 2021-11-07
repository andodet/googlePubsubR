test_that("Gets and lists subscriptions", {
  skip_on_cran()
  res_get <- subscriptions_get(sub_name)
  res_list <- subscriptions_list()
  res_exist <- subscriptions_exists(sub_name)

  expect_s3_class(res_get, "Subscription")
  expect_type(res_list, "list")
  expect_true(res_exist)
})

test_that("Subscription gets patched", {
  skip_on_cran()
  res <- subscriptions_patch(
    subscription = sub_name,
    topic = topic_name,
    msg_retention_duration = "2400s",
    labels = list(new_a = "a", new_b = "b")
  )

  expect_s3_class(res, "Subscription")
  expect_equal(res$messageRetentionDuration, "2400s")
  expect_equal(res$labels$new_a, "a")
  expect_equal(res$labels$new_b, "b")
})

test_that("Pulls messages from a subscription", {
  skip_on_cran()
  msgs <- subscriptions_pull(sub_name)

  expect_s3_class(msgs$receivedMessages, "data.frame")
  expect_true(length(msgs$receivedMessages) > 1)
})

test_that("Aknowledges messages", {
  skip_on_cran()
  msgs <- subscriptions_pull(sub_name)
  res <- subscriptions_ack(msgs$receivedMessages$ackId, sub_name)

  expect_true(res)
})

test_that("Modifies the ack deadline ", {
  skip_on_cran()
  # Publish a message to the topic
  msg <- PubsubMessage(data = base64enc::base64encode(serialize("hello", NULL)))
  topics_publish(msg, topic_name)

  Sys.sleep(0.5)  # Sometimes pull fails
  msgs <- subscriptions_pull(sub_name)
  res <- subscriptions_modify_ack_deadline(
    sub_name, msgs$receivedMessages$ackId, 400
  )

  expect_true(res)
})

test_that("Subscription detaches", {
  skip_on_cran()
  res <- subscriptions_detach(sub_name)

  expect_true(res)
  # It is not possible to reattach a subscription to a topic, hence we need to delete
  # and recreate it for further testing.
  subscriptions_delete(sub_name)
  subscriptions_create(name = sub_name, topic = topic_name)
})
