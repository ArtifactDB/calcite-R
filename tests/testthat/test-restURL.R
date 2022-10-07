# This tests that the restURL getter/setter works correctly.
# library(testthat); library(calcite); source("test-restURL.R")

test_that("restURL getter/setter works correctly", {
    existing <- restURL()
    expect_match(existing, "calcite")

    old <- restURL("https://foo")
    expect_identical(old, existing)
    expect_match(restURL(), "foo")

    restURL(old)
    expect_identical(restURL(), existing)
})
