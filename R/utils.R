# Unmarshal API response into an object
unmarshal_res <- function(object, res) {

  for(name in names(res)) {
    object[name] <- res[name]
  }

  return(object)
}

# Check if a resource name is already formatted
already_formatted <- function(x) {
  return(grepl("\\.*\\/.*\\/.*\\/.*", x))
}

# Recursively step down into list, removing all such objects
rmNullObs <- function(x) {
  x <- Filter(Negate(is.NullOb), x)
  lapply(x, function(x) if (is.list(x)) rmNullObs(x) else x)
}

# A helper function that tests whether an object is either NULL _or_
# a list of NULLs
is.NullOb <- function(x) is.null(x) | all(sapply(x, is.null))

# Value in seconds are to be suffixed with 's'
secs_to_str <- function(x) {
  paste0(x, "s")
}


#' Decode Pub/Sub message
#' 
#' Converts a Pub/Sub message into an object
#' 
#' @param x A base64 encoded string
#' 
#' @examples
#' \dontrun{
#' library(jsonlite)
#' 
#' pulled_msgs$receivedMessages$messages$data %>% 
#'   msg_decode() %>%
#'   fromJSON()
#' }
#'
#' @return A deserialized object
#' @export
msg_decode <- function(x) {
  x %>% 
    base64enc::base64decode() %>% 
    rawToChar()
}

#' Encode Pub/Sub message
#' 
#' Converts an object into a base64 string
#'
#' @param x A serializeable object
#' 
#' @examples
#' \dontrun{
#' library(jsonlite)
#'
#' mtcars %>% 
#'   toJSON(auto_unbox = TRUE) %>%
#'   msg_encode() %>% 
#'   PubsubMessage()
#' }
#'
#' @return `character` a base64 encoded string
#' @export
msg_encode <- function(x) {
  x %>% 
    charToRaw() %>%  
    base64enc::base64encode()
}

.ps_env <- new.env(parent = emptyenv())
#' Set GCP projectId
#'
#' @param project_id `character` A valid GCP projectId
#'
#' @examples
#' \dontrun{
#' ps_project_set("my-new-project")
#' # Do whatever...
#' # Jump back on the default project
#' ps_project_set(Sys.getenv("GCP_PROJECT"))
#' }
#'
#' @return `character` ProjectId string
#' @family Auth functions
#' @export
ps_project_set <- function(project_id) {
  if(project_id == "") {
    stop("You must pass a valid GCP projectId string")
  }
  .ps_env$project <- project_id
  cli::cli_alert_info("GCP project successfully set!")
  .ps_env$project
}

#' Get GCP projectId
#'
#' @return `character` A valid GCP projectId, defaults to `GCP_PROJECT` env var
#' @family Auth functions
#' @export
ps_project_get <- function() {
  # Fallback logic taken from `{googleCloudRunner/R/init.R}`
  if(!is.null(.ps_env$project)) {
    return(.ps_env$project)
  }

  if(Sys.getenv("GCP_PROJECT") != "") {
    .ps_env$project <- Sys.getenv("GCP_PROJECT")
  }
  if(is.null(.ps_env$project)) {
    stop("No projectId set - use ps_project_set() or set GCP_PROJECT env var",
         call. = FALSE
    )
  }

  return(.ps_env$project)
}

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL
