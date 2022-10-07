# This tests the object fetching function.
# library(testthat); library(calcite); source("test-fetchObject.R")

test_that("fetchObject works as expected without caching", {
    out <- fetchObject(exampleID(), cache=FALSE)

    expect_s4_class(out, "DFrame")
    expect_true(!is.null(out$X))
    expect_s4_class(out$AA, "DFrame")

    # Metadata is correctly restored.
    expect_identical(objectAnnotation(out)$species, 9606L)
    expect_identical(objectAnnotation(out)$maintainers[[1]]$name, "Aaron Lun")
})

test_that("fetchObject works as expected with caching", {
    tmp.dir <- tempfile()
    out <- fetchObject(exampleID(), cache=tmp.dir)
    expect_s4_class(out, "DFrame")

    # Cache got filled.
    f <- list.files(tmp.dir)
    expect_true(length(f) > 6)

    cache <- BiocFileCache::BiocFileCache(tmp.dir)
    hits <- BiocFileCache::bfcquery(cache, "metadata")
    hpath <- hits[1,"rpath",drop=TRUE]
    alt <- sub("Aaron Lun", "Darth Vader", readLines(hpath))
    write(alt, file=hpath)

    # Respects the cached value.
    out2 <- fetchObject(exampleID(), cache=cache)
    expect_identical(objectAnnotation(out2)$maintainers[[1]]$name, "Darth Vader")

    # Forcible updating resets cache.
    out3 <- fetchObject(exampleID(), cache=cache, force.update=TRUE)
    expect_identical(objectAnnotation(out3)$maintainers[[1]]$name, "Aaron Lun")
    expect_identical(out, out3)
})
