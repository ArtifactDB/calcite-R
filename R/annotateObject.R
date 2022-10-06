#' @export
#' @importFrom S4Vectors metadata<- metadata
annotateObject <- function(x, title, description, maintainers, species, genome, sources) {
    for (m in seq_along(maintainers)) {
        if (is.character(maintainers[[m]])) {
            frag <- as.person(m)
            maintainers[[m]] <- list(name = paste(frag$given, frag$family), email = frag$email)
        }
    }

    meta <- list(
        title=title,
        description=description,
        maintainers=maintainers,
        species=species,
        genome=genome,
        sources=sources
    )

    setObjectAnnotation(x, meta)
}

#' @export
#' @importFrom S4Vectors metadata
objectAnnotation <- function(x) metadata(x)[[".internal"]][["calcite"]]

#' @export
#' @importFrom S4Vectors metadata<- metadata
setObjectAnnotation <- function(x, annotation) {
    meta <- metadata(x)
    if (!(".internal" %in% names(meta))) {
        meta[[".internal"]] <- list()        
    }
    meta[[".internal"]][["calcite"]] <- annotation
    metadata(x) <- meta
    x
}
