test_that("Auth works", {
  skip_on_cran()
  skip_if_no_token()

  expect_true(googleAuthR::gar_has_token())
})
