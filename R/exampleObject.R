#' Example object and IDs for testing
#'
#' Make some example objects for testing.
#'
#' @return
#' For \code{exampleObject}, a \linkS4class{DFrame} is returned with annotation set by \code{\link{annotateObject}}.
#'
#' For \code{exampleID}, a string is returned containing an example ID.
#'
#' @author Aaron Lun
#' @examples
#' exampleObject()
#' exampleID()
#'
#' @export
#' @rdname examples
#' @importFrom S4Vectors DataFrame
#' @importFrom stats runif rnorm
exampleObject <- function() {
    df <- DataFrame(X=1:10, Y=LETTERS[1:10], Z=factor(letters[1:10]))
    df$AA <- DataFrame(foo=runif(10), bar=rnorm(10))

    df <- annotateObject(df,
        title="FOO",
        description="I am a data frame",
        maintainers="Aaron Lun <infinite.monkeys.with.keyboards@gmail.com>",
        species=9606,
        genome=list(list(id="hg38", source="UCSC")),
        origin=list(list(source="PubMed", id="123456789"))
    )

    df
}

#' @export
#' @rdname examples
exampleID <- function() {
    "test:df@v1"
}
