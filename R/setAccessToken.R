github.env <- new.env()

#' Get or set the GitHub access token
#'
#' Pretty much as the title says; calcite uses GitHub personal access tokens for user authentication.
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
#' accessTokenInfo(prompt=FALSE)
#'
#' @export
#' @importFrom zircon setGitHubToken
setAccessToken <- function(token, cache=TRUE) {
    setGitHubToken(token, 
        cache.env=github.env, 
        cache.path=if (cache) .token_cache_path() else NULL
    )
}

#' @export
#' @rdname setAccessToken
#' @importFrom zircon getGitHubTokenInfo
accessTokenInfo <- function(prompt=interactive()) {
    getGitHubTokenInfo(
        cache.env=github.env,
        cache.path=.token_cache_path(),
        prompt=prompt
    )
}

.token_cache_path <- function() {
    dir <- .cache_directory()
    file.path(dir, "token.txt")
}

#' @importFrom zircon useGitHubIdentities
.setup_github_identities <- function(cache=TRUE) {
    useGitHubIdentities(
        cache.env=github.env, 
        cache.path=if (cache) .token_cache_path() else NULL
    )
}
