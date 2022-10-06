#' Save an object to file
#'
#' Save an object to a staging directory in preparation for upload.
#' Multiple objects may be saved inside the same staging directory,
#' though users should avoid saving an object inside another object's subdirectory (created by a previous \code{saveObject} call).
#'
#' @param x A supported Bioconductor object, with annotation added by \code{\link{annotateObject}}.
#' @param dir String containing a path to a staging directory.
#' @param path String containing the relative path inside the staging directory in which to save the object's contents.
#' This should not be nested inside any subdirectories created by previous \code{saveObject} calls.
#'
#' @return 
#' \code{x} is saved to the specified location, and \code{NULL} is invisibly returned.
#'
#' @author Aaron Lun
#'
#' @examples
#' # Making an exciting DataFrame.
#' library(S4Vectors)
#' df <- DataFrame(X=1:10, Y=LETTERS[1:10], Z=factor(letters[1:10]))
#' df$AA <- DataFrame(foo=runif(10), bar=rnorm(10))
#'
#' df <- annotateObject(df,
#'     title="FOO",
#'     description="I am a data frame",
#'     maintainers="LTLA <infinite.monkeys.with.keyboards@gmail.com>",
#'     species=9606,
#'     genome=list(list(id="hg38", source="UCSC")),
#'     origin=list(list(source="PubMed", id="123456789"))
#' )
#'
#' # Staging the DataFrame.
#' tmp <- tempfile()
#' dir.create(tmp)
#' saveObject(df, tmp, "df1")
#'
#' list.files(tmp, recursive=TRUE)
#'
#' @seealso
#' \code{\link{annotateObject}}, to add the mandatory annotation to all objects.
#'
#' \code{\link{uploadDirectory}}, to upload all objects to the calcite store.
#' 
#' @export
#' @importFrom alabaster.base .altStageObject .writeMetadata .createRedirection
#' @importFrom zircon uploadProject
saveObject <- function(x, dir, path) {
    olds <- .altStageObject(calciteStageObject)
    on.exit(.altStageObject(olds), add=TRUE)
    meta <- calciteStageObject(x, dir, path, child=FALSE)

    extras <- objectAnnotation(x)
    extras <- extras[setdiff(names(extras), "_extra")]
    meta <- c(meta, extras)
    meta$species <- I(meta$species)

    resource <- .writeMetadata(meta, dir)
    .writeMetadata(.createRedirection(dir, path, meta$path), dir)

    invisible(NULL)
}

#' @import methods
setGeneric("calciteStageObject", function(x, dir, path, child=FALSE, ...) standardGeneric("calciteStageObject"))

#' @importFrom alabaster.base stageObject 
setMethod("calciteStageObject", "ANY", function(x, dir, path, child=FALSE, ...) {
    meta <- stageObject(x, dir, path, child=child, ...)
    attr(meta[["$schema"]], "package") <- "calcite.schemas"
    meta 
})

#' @importFrom S4Vectors metadata<- metadata
setMethod("calciteStageObject", "Annotated", function(x, dir, path, child=FALSE, ...) {
    # Avoid staging the internal metadata.
    all.ints <- names(metadata(x)) == ".internal"
    metadata(x) <- metadata(x)[!all.ints]
    callNextMethod()
})

