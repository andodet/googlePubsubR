tidy_message <- function(..., prefix = "\n", initial = "") {
  packageStartupMessage(strwrap(..., prefix = prefix, initial = initial))
}

.onAttach <- function(libname, pkgname) {
  # Check if necessary env variables have been set
  if(Sys.getenv("GCP_PROJECT") == "") {
    tidy_message(
      "GCP_AUTH_FILE environment variable not found, please set it up 
      before authenticating"
    )
  }
  

  if(Sys.getenv("GCP_AUTH_FILE") == "") {
    tidy_message(
      "GCP_AUTH_FILE environment variable not found, please set it up before
      authenticating"
    )
  }
}
