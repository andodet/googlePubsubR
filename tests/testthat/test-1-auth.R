test_that("Auth works", {
  skip_on_cran()
  skip_if_no_token()

  expect_true(googleAuthR::gar_has_token())
})

test_that("GCP project gets changed", {
  skip_on_cran()
  skip_if_no_token()

  project_id <- ps_project_set("testing")
  get_proj <- ps_project_get()
  
  expect_equal(project_id, "testing")
  expect_equal(get_proj, "testing")
  # Re-set it to env variable to keep on testing
  on.exit(ps_project_set(Sys.getenv("GCP_PROJECT")))
})

test_that("Setting GCP projectId as an empty string errors out", {
  skip_on_cran()
  skip_if_no_token()

  expect_error(ps_project_set(""))
})
