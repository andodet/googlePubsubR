.onLoad <- function(libname, pkgname) {
  # Check if necessary env variables have been set
  if(Sys.getenv("GCP_PROJECT") == "") {
    cli::cli_alert_warning(
      "GCP_PROJECT environment not found, please set it up before starting!"
    )
  }

  if(Sys.getenv("GCP_AUTH_FILE") == "") {
    cli::cli_alert_warning(
      "GCP_AUTH_FILE environment not found, please set it up before authenticating"
    )
  }
}
