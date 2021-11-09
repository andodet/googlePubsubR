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
