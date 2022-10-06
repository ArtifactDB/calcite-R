#' @export
#' @importFrom alabaster.base stageObject .writeMetadata
#' @importFrom zircon uploadProject
saveObject <- function(x, dir, name, stage.only=FALSE, permissions=list()) {
    extras <- objectAnnotation(x)
    x <- .wipe_annotation(x)

    dir.create(dir, showWarnings=FALSE)
    meta <- stageObject(x, dir, name)

    meta <- c(meta, extras)
    meta$organism <- I(meta$organism)

    resource <- .writeMetadata(meta, dir)

    # TODO: create redirection here.
}
