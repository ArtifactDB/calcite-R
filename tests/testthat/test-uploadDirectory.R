# Tests that the uploadDirectory function works as expected.
# library(testthat); library(calcite); source("setup-private.R"); source("test-uploadDirectory.R")

token <- Sys.getenv("GITHUB_TOKEN", NA)
if (is.na(token)) {
    skip("skipping upload tests because GITHUB_TOKEN is absent")
}

setAccessToken(token, cache=FALSE)
tmp <- tempfile()
dir.create(tmp)
df <- exampleObject()
saveObject(df, tmp, "my_first_df")

test_that("uploading works correctly for a new project", {
    v <- as.integer(Sys.time())
    uploadDirectory(tmp, "test2", v, expires=1)

    cache <- tempfile()
    stuff <- fetchObject(zircon::packID("test2", "my_first_df", v), cache=cache)

    expect_identical(stuff$X, df$X)
    expect_identical(stuff$Y, df$Y)

    anno <- objectAnnotation(stuff)
    expect_identical(anno[["_extra"]][["version"]], as.character(v))
    expect_type(anno[["_extra"]][["transient"]][["expires_in"]], "character")

    expect_true(length(zircon::getPermissions("test2", restURL())$owners) == 1L)
})

test_that("uploading works correctly for an existing project", {
    v <- as.integer(Sys.time())
    uploadDirectory(tmp, "test", v, expires=1)

    cache <- tempfile()
    stuff <- fetchObject(zircon::packID("test", "my_first_df", v), cache=cache)

    expect_identical(stuff$X, df$X)
    expect_identical(stuff$Y, df$Y)

    anno <- objectAnnotation(stuff)
    expect_identical(anno[["_extra"]][["version"]], as.character(v))
    expect_type(anno[["_extra"]][["transient"]][["expires_in"]], "character")

    # MD5 sum-based deduplication is turned on.
    expect_type(anno[["_extra"]][["link"]][["artifactdb"]], "character")
})
