# Shamelessly taken from `{googleCloudStorageR}` https://github.com/cloudyr/googleCloudStorageR/blob/master/R/auth.R

#' Authenticate a Pub/Sub client
#'
#' @param json_file `character` Path of the JSON file containing credentials for a GCP service
#'   account
#' @param token `character` An existing authentication token
#' @param email `character` The email to default authentication to
#' 
#' @return None, called for side effects
#'
#' @import googleAuthR
#' @family Auth functions
#' @export
pubsub_auth <- function(json_file = Sys.getenv("GCP_AUTH_FILE"),
                        token = NULL,
                        email = NULL) {

  set_scopes()
  if(is.null(json_file)){
    gar_auth(token = token,
             email = email,
             package = "googlePubsubR")
  } else {
    gar_auth_service(json_file = json_file)
  }
}

set_scopes <- function(){
  required_scopes <- c("https://www.googleapis.com/auth/cloud-platform",
                       "https://www.googleapis.com/auth/pubsub")

  op <- getOption("googleAuthR.scopes.selected")
  if(is.null(op)){
    options(googleAuthR.scopes.selected = "https://www.googleapis.com/auth/pubsub")
  } else if(!any(op %in% required_scopes)) {
    print("Adding https://www.googleapis.com/auth/pubsub to scopes")
    options(googleAuthR.scopes.selected = c(op, "https://www.googleapis.com/auth/cloud-platform"))
  }
}
