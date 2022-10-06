auth.globals <- new.env()
auth.globals$info <- NULL

#' @export
#' @importFrom httr GET add_headers content
login <- function(token) {
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

    } else {
        res <- GET("https://api.github.com/user", add_headers(Authorization=paste("Bearer ", token)))
        if (res$status_code >= 300) {
            stop("failed to verify this token with GitHub (status code ", out$status_code, ")")
        }
        expiry <- .process_expiry(res)
        name <- content(res)$login
    }

    writeLines(c(token, name, expiry), con=token.path)
    vals <- list(token=token, name=name, expires=expiry)
    auth.globals$info <- vals
    invisible(vals)
}

#' @export
accessTokenInfo <- function(prompt=interactive()) {
    vals <- auth.globals$info

    if (is.null(vals)) {
        if (!file.exists(token.path)) {
            rerun <- TRUE
        } else {
            lines <- readLines(token.path)
            vals <- list(token = lines[1], name = lines[2], expires = as.double(lines[3]))
            if (vals$expires > as.double(Sys.time())) {
                unlink(token.path)
                auth.globals$info <- NULL
                rerun <- TRUE
            }
        }
    } else {
        if (vals$expires > as.double(Sys.time())) {
            unlink(token.path)
            auth.globals$info <- NULL
            rerun <- TRUE
        }
    }

    if (rerun) {
        if (prompt) {
            vals <- login()
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

#' @importFrom getPass getPass
#' @importFrom tools R_user_dir
#' @importFrom httr GET
.setup_github_identities <- function() {
    dir <- R_user_dir("calcite")
    token.path <- file.path(dir, "token.txt")

    olda <- identityAvailable(function() !is.null(accessTokenInfo(prompt=FALSE)))
    oldh <- identityHeaders(function() list(Authorization=paste0("Bearer ", accessTokenInfo()$token)))

    function() {
        identityAvailable(olda)
        identityHeaders(oldh)
    }
}
