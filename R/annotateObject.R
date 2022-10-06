#' Add calcite annotation
#'
#' Add calcite's required annotation to a Bioconductor \linkS4class{Annotated} object.
#'
#' @param x An \linkS4class{Annotated} object.
#' @param title String containing the object's title.
#' @param description String containing the description of the object.
#' @param maintainers List containing the identity of the maintainers.
#' Each entry may be a \code{\link{person}}-formatted string, or a list containing the \code{name} and \code{email} strings.
#' 
#' Alternatively, a character vector of \code{\link{person}}-formatted strings.
#' @param species An integer vector of NCBI taxonomy IDs for the species relevant to the data in \code{x}. 
#' @param genome List describing the genomes involved in constructing \code{x}.
#' Each entry should be a list containing:
#' \itemize{
#' \item \code{id}, a string containing the genome build ID (e.g., hg38, NCBIm37)
#' \item \code{type}, a string specifying the type of ID (e.g., UCSC, Ensembl)
#' }
#' Check out \url{https://artifactdb.github.io/calcite-schemas/array/v1.html#allOf_i0_genome} for details.
#' @param origin List describing the origin of \code{x}.
#' Each entry should be a list containing:
#' \itemize{
#' \item \code{source}, a string describing the source repository, e.g., PubMed, GEO, ArrayExpress.
#' \item \code{id}, a string containing an identifier within \code{source}.
#' }
#' Check out \url{https://artifactdb.github.io/calcite-schemas/array/v1.html#allOf_i0_origin} for details.
#' @param annotation List of calcite-relevant metadata.
#' 
#' @return 
#' For \code{annotateObject}, \code{x} is returned with extra fields in its \code{\link{metadata}}.
#'
#' For \code{objectAnnotation}, a list of calcite-relevant metadata is returned.
#'
#' For \code{setannotation}, \code{x} is returned after replacing the calcite-relevant metadata with \code{annotation}.
#' 
#' @examples
#' library(S4Vectors)
#' df <- DataFrame(X=1:10, Y=LETTERS[1:10], Z=factor(letters[1:10]))
#'
#' df <- annotateObject(df,
#'     title="FOO",
#'     description="I am a data frame",
#'     maintainers="Aaron Lun <infinite.monkeys.with.keyboards@gmail.com>",
#'     species=9606,
#'     genome=list(list(id="hg38", source="UCSC")),
#'     origin=list(list(source="PubMed", id="123456789"))
#' )
#'
#' anno <- objectAnnotation(df)
#' str(anno)
#'
#' anno$maintainers <- c(anno$maintainers, 
#'     list(list(name="Darth Vader", email="vader@empire.gov")))
#' df <- setAnnotation(df, anno)
#' 
#' @author Aaron Lun
#'
#' @export
#' @importFrom S4Vectors metadata<- metadata
annotateObject <- function(x, title, description, maintainers, species, genome, origin) {
    maintainers <- as.list(maintainers)
    for (m in seq_along(maintainers)) {
        if (is.character(maintainers[[m]])) {
            frag <- as.person(maintainers[[m]])
            maintainers[[m]] <- list(name = paste(frag$given, frag$family), email = frag$email)
        }
    }

    meta <- list(
        title=title,
        description=description,
        maintainers=maintainers,
        species=species,
        genome=genome,
        origin=origin,
        bioc_version=as.character(BiocManager::version())
    )

    setAnnotation(x, meta)
}

#' @export
#' @importFrom S4Vectors metadata
objectAnnotation <- function(x) metadata(x)[[".internal"]][["calcite"]]

#' @export
#' @importFrom S4Vectors metadata<- metadata
setAnnotation <- function(x, annotation) {
    meta <- metadata(x)
    if (!(".internal" %in% names(meta))) {
        meta[[".internal"]] <- list()        
    }
    meta[[".internal"]][["calcite"]] <- annotation
    metadata(x) <- meta
    x
}
