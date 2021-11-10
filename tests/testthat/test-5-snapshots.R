test_that("Gets and lists snapshots", {
  skip_on_cran()
  res_get <- snapshots_get(snap_name)
  res_list <- snapshots_list()
  res_exist <- snapshots_exists(snap_name)
  res_exist_fail <- snapshots_exists("junk-name")

  expect_s3_class(res_get, "Snapshot")
  expect_s3_class(res_list, "data.frame")
  expect_true(res_exist)
  expect_false(res_exist_fail)
})

test_that("Snapshot gets patched", {
  skip_on_cran()
  res <- snapshots_patch(
    snapshot = snap_name,
    # TODO: add expire_time update
    labels = list(new_a = "a", new_b = "b")
  )
  
  expect_s3_class(res, "Snapshot")
  expect_equal(res$labels$new_a, "a")
  expect_equal(res$labels$new_b, "b")
})

