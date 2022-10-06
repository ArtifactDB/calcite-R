#' @export
#' @importFrom zircon uploadProject
uploadDirectory <- function(dir, project, version, owners=NULL, viewers=NULL, public=TRUE) {
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

    uploadProject(dir, restURL(), project, version, permissions=permissions)
}
