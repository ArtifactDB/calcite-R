#' Get or set the GitHub access token
#'
#' Pretty much as the title says.
#' calcite uses GitHub for user authentication.
#'
#' @param token String containing a GitHub personal access token.
#' If missing, the user will be prompted to supply a token.
#' If \code{NULL}, any existing tokens are cleared.
#' @param cache Logical scalar indicating whether the token should be cached to file for re-use in other R sessions.
#' If \code{FALSE}, the token is only kept in memory for the current session.
#' @param prompt Logical scalar indicating whether the user should be prompted to supply token details if no cached token exists.
#'
#' @return 
#' For \code{setAccessToken}, any non-\code{NULL} \code{token} (or its interactively supplied counterpart) will be cached in memory and/or on file, depending on \code{cache}.
#' A list is invisibly returned containing details about the token including its value, the corresponding user account and the expiry time.
#' If \code{token=NULL}, any cached token is cleared from file and memory, and \code{NULL} is invisibly returned.
#'
#' For \code{accessTokenInfo}, a list is returned containing the token details.
#' If \code{prompt=FALSE} and no cached token is present, \code{NULL} is returned.
#'
#' @author Aaron Lun
#'
#' @examples
#' \dontrun{setAccessToken()}
#'
#' accessTokenInfo(FALSE)
#'
#' @export
#' @importFrom httr GET add_headers content
setAccessToken <- function(token, cache=TRUE) {
    token.path <- .token_cache_path()
    if (!missing(token) && is.null(token)) {
        globals$auth.info <- NULL
        unlink(token.path)
        return(invisible(NULL))
    }

    expiry <- NULL
    name <- NULL
    if (missing(token)) {
        token <- getPass("Please generate a new Github personal access token.

1. Go to https://github.com/settings/tokens.
2. Click 'Generate new token'.
3. Give it a name and (optionally) set the desired expiry time.
4. Click 'Generate token'.
5. Copy and paste the token string below.

TOKEN: ")

        while (nchar(token)) {
            res <- GET("https://api.github.com/user", add_headers(Authorization=paste("Bearer ", token)))
            if (res$status_code < 300) {
                expiry <- .process_expiry(res)
                name <- content(res)$login
                break
            }
            token <- getPass("\nHmm... failed to verify this token with GitHub (status code ", out$status_code, "). Try again?\nTOKEN: ")
        }

        if (nchar(token) == 0) {
            stop("empty token supplied")
        }

    } else if (!is.null(token)) {
        res <- GET("https://api.github.com/user", add_headers(Authorization=paste("Bearer ", token)))
        if (res$status_code >= 300) {
            stop("failed to verify this token with GitHub (status code ", out$status_code, ")")
        }
        expiry <- .process_expiry(res)
        name <- content(res)$login
    }

    if (cache) {
        dir.create(dirname(token.path), showWarnings=FALSE, recursive=TRUE)
        writeLines(c(token, name, expiry), con=token.path)
    }
    vals <- list(token=token, name=name, expires=expiry)
    globals$auth.info <- vals
    invisible(vals)
}

#' @export
#' @rdname setAccessToken
accessTokenInfo <- function(prompt=interactive()) {
    vals <- globals$auth.info
    token.path <- .token_cache_path()

    rerun <- FALSE
    if (is.null(vals)) {
        if (!file.exists(token.path)) {
            rerun <- TRUE
        } else {
            lines <- readLines(token.path)
            vals <- list(token = lines[1], name = lines[2], expires = as.double(lines[3]))
            if (vals$expires <= as.double(Sys.time())) {
                unlink(token.path)
                globals$auth.info <- NULL
                rerun <- TRUE
            }
        }
    } else {
        if (vals$expires <= as.double(Sys.time())) {
            unlink(token.path)
            globals$auth.info <- NULL
            rerun <- TRUE
        }
    }

    if (rerun) {
        if (prompt) {
            vals <- setAccessToken()
        } else {
            return(NULL)
        }
    }

    vals
}

#' @importFrom httr headers
.process_expiry <- function(res) {
    expires <- headers(res)[["github-authentication-token-expiration"]]
    if (!is.null(expires)) {
        frags <- strsplit(expires, " ")[[1]]
        as.double(as.POSIXct(paste(frags[1], frags[2]), tz=frags[3]))
    } else {
        Inf
    }
}

.token_cache_path <- function() {
    dir <- .cache_directory()
    file.path(dir, "token.txt")
}

#' @importFrom getPass getPass
#' @importFrom zircon identityAvailable identityHeaders
#' @importFrom httr GET
.setup_github_identities <- function() {
    olda <- identityAvailable(function() !is.null(accessTokenInfo(prompt=FALSE)))
    oldh <- identityHeaders(function() list(Authorization=paste0("Bearer ", accessTokenInfo()$token)))

    function() {
        identityAvailable(olda)
        identityHeaders(oldh)
    }
}
