#' @export
#' @import DelayedArray methods
#' @importClassesFrom alabaster.matrix WrapperArraySeed
setClass("CalciteArraySeed", contains="WrapperArraySeed", slots=c(id="character"))

#' @export
#' @importClassesFrom DelayedArray DelayedArray
setClass("CalciteArray", contains="DelayedArray", slots=c(seed="CalciteArraySeed"))

#' @export
#' @importClassesFrom DelayedArray DelayedMatrix
setClass("CalciteMatrix", contains=c("DelayedMatrix", "CalciteArray"), slots=c(seed="CalciteArraySeed"))

#' The CalciteArray class
#'
#' The CalciteArray is a \pkg{DelayedArray} wrapper around a on-disk array downloaded from the calcite backend.
#' Specifically, it remembers the zircon ID that was used to download the array, which can be used to avoid a redundant write and upload in \code{\link{saveObject}} and \code{\link{uploadDirectory}}, respectively.
#' The actual heavy-lifting is done by forwarding all operations to the internal \pkg{DelayedArray}-compatible seed object,
#' which may be any of the usual classes, e.g., a HDF5ArraySeed, H5SparseMatrixSeed or any of its delayed operations.
#'
#' @param id String containing the calcite identifier, or a list containing the unpacked components of an identifier (from \code{\link{unpackID}}).
#' For \code{CalciteArray}, this can also be a CalciteArraySeed object.
#' @param seed A CalciteArraySeed object.
#' @param ... Further arguments to pass to the CalciteArraySeed constructor.
#'
#' @return
#' The \code{CalciteArraySeed} constructor returns a CalciteArraySeed object.
#'
#' The \code{CalciteArray} constructor and the \code{\link{DelayedArray}} method return a CalciteArray object (or a CalciteMatrix, for two dimensions).
#' 
#' @details
#' If \code{id} uses the \code{latest} version alias, this is automatically resolved to a full version by the \code{CalciteArraySeed} constructor.
#' This ensures that the version is explicitly pinned in downstream applications and when saving to file.
#' 
#' @docType class
#' @aliases
#' CalciteArray-class
#' CalciteMatrix-class
#' matrixClass,CalciteArray-method
#' DelayedArray,CalciteArraySeed-method
#' CalciteArraySeed-class
#' loadArray
#'
#' @examples
#' \dontshow{fun <- calcite:::.configure_cache()}
#' id <- "test:my_first_sce/assay-1/matrix.h5@v1"
#' mat <- CalciteArray(id)
#' mat
#' \dontshow{fun()}
#'
#' @name CalciteArray
NULL

#' @export
#' @rdname CalciteArray
#' @importFrom alabaster.matrix .createRawArraySeed
#' @importFrom alabaster.base acquireMetadata acquireFile
#' @importFrom zircon resolveLatestVersion
CalciteArraySeed <- function(id) {
    if (!is.list(id)) {
        unpacked <- unpackID(id)
    } else {
        unpacked <- id
        id <- do.call(packID, unpacked[c("project", "path", "version")])
    }

    if (unpacked$version == "latest") {
        unpacked$version <- resolveLatestVersion(unpacked$project, restURL())
        id <- do.call(packID, unpacked[c("project", "path", "version")])
    }

    proj <- new("CalciteHandler", project=unpacked$project, version=unpacked$version)
    info <- acquireMetadata(proj, unpacked$path)
    seed <- .createRawArraySeed(info, proj)

    new("CalciteArraySeed", id=id, seed=seed)
}

#' @export
#' @rdname CalciteArray
CalciteArray <- function(id, ...) {
    if (!is(id, "CalciteArraySeed")) {
        id <- CalciteArraySeed(id, ...)
    }
    DelayedArray(id)
}

#' @export
#' @rdname CalciteArray
setMethod("DelayedArray", "CalciteArraySeed", function(seed) new_DelayedArray(seed, Class="CalciteArray"))

#' @export
setMethod("matrixClass", "CalciteArray", function(x) "CalciteMatrix")

#' @export
loadArray <- function(info, project) {
    CalciteArray(list(project=project@project, path=info$path, version=project@version))
}
