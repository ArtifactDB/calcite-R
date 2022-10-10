#' @import methods
setClass("CalciteHandler", slots=c(project="character", version="character"))

#' @importFrom zircon getFile packID
#' @importFrom alabaster.base acquireFile
setMethod("acquireFile", "CalciteHandler", function(project, path) {
    id <- packID(project@project, path, project@version)
    getFile(id, url=restURL(), cache=.create_cache_function())
})

#' @importFrom zircon getFileMetadata packID
#' @importFrom alabaster.base acquireMetadata
setMethod("acquireMetadata", "CalciteHandler", function(project, path) {
    id <- packID(project@project, path, project@version)
    getFileMetadata(id, url=restURL(), cache=.create_cache_function(), follow.links=TRUE)
})

# Force filelock to be imported here; it's only Suggested by zircon for
# biocCache, but we need to make sure it's installed in order for biocCahe
# to run... so we need to stick it in the Imports somewhere.

#' @importFrom zircon biocCache
#' @importFrom filelock lock unlock
.create_cache_function <- function() {
    if (is.null(globals$cache.object)) {
        NULL
    } else {
        function(key, save) biocCache(globals$cache.object, key, save, update=globals$cache.update)
    }
}
