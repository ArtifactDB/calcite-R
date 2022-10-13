# Check that the CalciteArray works as expected.
# library(testthat); library(calcite); source("test-CalciteArray.R")

fun <- calcite:::.configure_cache()

library(DelayedArray)
test_that("CalciteArraySeed constructors works as expected", {
    id <- "test:my_first_sce/assay-1/matrix.h5@v1"
    mat <- CalciteArray(id)
    expect_s4_class(mat, "CalciteArray")
    expect_s4_class(mat, "CalciteMatrix")
    expect_identical(seed(mat)@id, id)

    # Works with the seed in the constructor.
    mat2 <- CalciteArray(seed(mat))
    expect_identical(mat2, mat)

    # Resolves latest aliases.
#    lid <- "test:my_first_sce/assay-1/matrix.h5@latest"
#    lmat <- CalciteArray(lid)
#    expect_s4_class(lmat, "CalciteArray")
#    expect_identical(seed(lmat)@id, id)
})

library(DelayedArray)
test_that("CalciteArraySeed savers works as expected", {
    id <- "test:my_first_sce/assay-1/matrix.h5@v1"
    mat <- CalciteArray(id)

    obj <- List(thingy=mat)
    obj <- annotateObject(obj,
        title="FOO",
        description="I am a list",
        maintainers="Aaron Lun <infinite.monkeys.with.keyboards@gmail.com>",
        species=9606,
        genome=list(list(id="hg38", source="UCSC")),
        origin=list(list(source="PubMed", id="123456789"))
    )

    dir <- tempfile()
    dir.create(dir)
    saveObject(obj, dir, "bar")

    expect_identical(zircon::extractLinkedID(dir, "bar/child-1/array"), id)

    meta <- jsonlite::fromJSON(file.path(dir, "bar", "child-1", "array.json"))
    expect_identical(meta$path, "bar/child-1/array")
    expect_match(meta[["$schema"]], "sparse_matrix")
})

library(DelayedArray)
test_that("fetchObject redirects to the calcite loaders", {
    id <- "test:my_first_sce/assay-1/matrix.h5@v1"
    obj <- fetchObject(id)
    expect_s4_class(obj, "CalciteArray")
})

fun()

