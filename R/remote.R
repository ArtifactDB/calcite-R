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
#' @importFrom filelock unlock
.cache <- function(key, save) {
    cache <- remote.globals$cache.object
    encoded <- URLencode(key, reserved=TRUE)

    lck <- .lock_cache(cache)
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

    # Unlocking once all DB operations are finished, so that
    # we can save in parallel across processes.
    unlock(lck)
    lck <- NULL

    # Saving again if it doesn't exist, e.g., because the last 
    # download attempt was interrupted.
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

#' @importFrom filelock lock
.lock_cache <- function(cache) {
    lockfile <- file.path(bfccache(cache), "zircon-LOCK")
    lock(lockfile)
}

#' @importFrom tools R_user_dir
.setup_github_identities <- function() {
    dir <- R_user_dir("calcite")
    token.path <- file.path(dir, "token.txt")

    olda <- identityAvailable(function() TRUE)
    oldh <- identityHeaders(function() list(Authorization=paste0("Bearer ", token)))

    function() {
        identityAvailable(olda)
        identityHeaders(oldh)
    }
}


