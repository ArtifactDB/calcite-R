#' Upload a staging directory to the calcite store
#' 
#' Upload a staging directory to the calcite backend.
#' The directory should contain objects saved with \code{\link{saveObject}}.
#'
#' @param dir String containing a path to a staging directory.
#' @param project String containing the name of the project.
#' @param version String containing the version of the project.
#' @param owners Character vector of GitHub user names of project owners.
#' Defaults to the currently authenticated user from \code{\link{setAccessToken}}.
#' @param viewers Character vector of GitHub user names of allowed viewers.
#' @param public Logical scalar indicating whether the project should be public.
#' @param expires Integer scalar specifying the expiry date for this version of the project.
#' If \code{NULL}, the uploaded version will not expire.
#' @param collapse.md5.duplicates Logical scalar indicating whether duplicated files with the same MD5 checksum should be collapsed.
#'
#' @return \code{NULL} is invisibly returned on success.
#'
#' @author Aaron Lun
#'
#' @examples
#' tmp <- tempfile()
#' dir.create(tmp)
#'
#' # Saving multiple objects to a directory.
#' df <- exampleObject()
#' saveObject(df, tmp, "my_first_df")
#'
#' df2 <- exampleObject()
#' saveObject(df, tmp, "a_second_df")
#'
#' # Uploading it to the backend (requires authentication):
#' \dontrun{uploadDirectory(tmp, "FOO", "BAR", expires=1)}
#'
#' @seealso
#' \code{\link{saveObject}}, to save objects to the staging directory.
#'
#' \code{\link{fetchObject}}, to fetch an object from the calcite backend. 
#'
#' @export
#' @importFrom zircon uploadProject
uploadDirectory <- function(dir, project, version, owners=NULL, viewers=NULL, public=TRUE, expires=NULL, collapse.md5.duplicates=TRUE) {
    fun <- .setup_github_identities()
    on.exit(fun())

    if (is.null(owners)) {
        owners <- accessTokenInfo()$name
    }
    permissions <- list(
        owners = as.character(owners),
        viewers = as.character(viewers),
        read_access = if (public) "public" else "viewers" 
    )

    uploadProject(dir, 
        url=restURL(), 
        project=project, 
        version=version, 
        permissions=permissions, 
        expires=expires,
        auto.dedup.md5=collapse.md5.duplicates
    )
}
