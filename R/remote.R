remote.globals <- new.env()
remote.globals$url <- zircon::example.url # TODO: switch to the calcite backend.
remote.globals$cache.object <- NULL
remote.globals$cache.update <- FALSE
remote.globals$github.token <- NULL

#' @export    
restURL <- function(url) {
    prev <- remote.globals$url
    if (missing(url)) {
        prev
    } else {
        remote.globals$url <- url
        invisible(prev)
    }
}

#' @import methods
setClass("CalciteHandler", slots=c(project="character", version="character"))

#' @importFrom zircon getFile
setMethod("acquireFile", "CalciteHandler", function(project, path) {
    id <- packID(project@project, path, project@version)
    getFile(id, url=restURL(), cache=.create_cache_function())
})

#' @importFrom zircon getFile
setMethod("acquireMetadata", "CalciteHandler", function(project, path) {
    id <- packID(project@project, path, project@version)
    getFileMetadata(id, url=restURL(), cache=.create_cache_function())
})

#' @import BiocFileCache 
#' @importFrom utils URLencode
#' @importFrom filelock lock unlock
.cache <- function(key, save) {
    cache <- remote.globals$cache.object
    encoded <- URLencode(key, reserved=TRUE)

    lockfile <- file.path(bfccache(cache), "zircon-LOCK")
    lck <- lock(lockfile)
    on.exit({
        if (!is.null(lck)) {
            unlock(lck)
        }
    }, add=TRUE)
    hit <- bfcquery(cache, key, field="rname", exact=TRUE)

    must.fire <- FALSE
    if (nrow(hit) >= 1L) {
        if (nrow(hit) > 1L) {
            warning("detected and removed duplicate copies of '", key, "'")
            bfcremove(hit$rid[-1])
            hit <- hit[1,,drop=FALSE]
        }
        path <- hit$fpath
    } else {
        path <- bfcnew(cache, key)
        must.fire <- TRUE
    }

    unlock(lck)
    lck <- NULL

    # Acquiring a path lock so that processes don't use the downloaded file
    # after it started but before it's finished.
    path.lock <- paste0(path, "_zircon-LOCK")
    plock <- lock(path.lock)
    on.exit(unlock(plock), add=TRUE)

    if (must.fire || !file.exists(path)) {
        success <- FALSE
        on.exit({
            if (!success) {
                unlink(path, force=TRUE)
            }
        }, add=TRUE)
        save(path)
        success <- TRUE
    }

    path
}

.create_cache_function <- function() {
    if (is.null(remote.globals$cache.object)) {
        NULL
    } else {
        .cache
    }
}
