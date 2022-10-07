# This tests that the token getter/setter works correctly.
# library(testthat); library(calcite); source("setup-private.R"); source("test-setAccessToken.R")

token <- Sys.getenv("GITHUB_TOKEN", NA)
if (is.na(token)) {
    skip("skipping authentication tests because GITHUB_TOKEN is absent")
}

cache.path <- calcite:::.token_cache_path()
cache.contents <- NULL
if (file.exists(cache.path)) {
    cache.contents <- readLines(cache.path)
}

test_that("token setting works correctly without caching", {
    unlink(cache.path)

    info <- setAccessToken(token, cache=FALSE)
    expect_type(info$name, "character")
    expect_type(info$token, "character")
    expect_type(info$expires, "double")

    expect_identical(info, accessTokenInfo(prompt=FALSE))
    expect_false(file.exists(cache.path))
})

test_that("token setting works correctly with caching", {
    info <- setAccessToken(token)
    expect_type(info$name, "character")
    expect_type(info$token, "character")
    expect_type(info$expires, "double")

    expect_identical(info, accessTokenInfo(prompt=FALSE))
    expect_true(file.exists(cache.path))

    # Wiping it in local memory.
    setAccessToken(NULL, cache=FALSE)
    expect_null(calcite:::globals$auth.info)

    # Fetches it from cache.
    expect_identical(info, accessTokenInfo(prompt=FALSE))
})

test_that("token wiping works correctly with caching", {
    write(file=cache.path, character(0))
    info <- setAccessToken(NULL)
    expect_null(accessTokenInfo(prompt=FALSE))
    expect_false(file.exists(cache.path)) # wipes the cached file.
    unlink(cache.path)
})

if (is.null(cache.contents)) {
    unlink(cache.path)
} else {
    writeLines(cache.contents, con=cache.path)
}
