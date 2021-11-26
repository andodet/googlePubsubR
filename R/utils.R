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
#' mtcars %>% 
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
