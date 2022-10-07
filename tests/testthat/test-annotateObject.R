# This tests the various annotation utilities.
# library(testthat); library(calcite); source("test-annotate.R")

library(S4Vectors)
test_that("annotation utilities work as expected", {
    df <- exampleObject()
    expect_true(".internal" %in% names(metadata(df)))

    # Person is parsed properly.
    meta <- objectAnnotation(df)
    expect_identical(meta$maintainers[[1]]$name, "Aaron Lun")
    expect_match(meta$maintainers[[1]]$email, "@gmail.com")

    # Bioc version is obtained properly.
    expect_match(meta$bioc_version, "[0-9]\\.[0-9]{2}")

    # Annotation is wiped.
    wipe <- setAnnotation(df, NULL)
    expect_null(objectAnnotation(wipe))
})
