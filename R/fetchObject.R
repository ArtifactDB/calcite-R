#' @export
#' @importFrom alabaster.base acquireMetadata loadObject
#' @importFrom zircon unpackID
fetchObject <- function(id) {
    fun <- .setup_github_identities()
    on.exit(fun())

    unpacked <- unpackID(id)
    proj <- new("CalciteHandler", project=unpacked$project, version=unpacked$version)
    meta <- acquireMetadata(proj, unpacked$path)

    obj <- loadObject(meta, proj)

    blessed <- c(
        "title", 
        "description", 
        "maintainers",
        "species",
        "genome",
        "origin",
        "_extra"
    )

    setAnnotation(obj, meta[intersect(names(meta), names(blessed))])
}
