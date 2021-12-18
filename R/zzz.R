.onLoad <- function(libname, pkgname) {
  # Check if necessary env variables have been set
  ps_project_get()

  if(Sys.getenv("GCP_AUTH_FILE") == "") {
    cli::cli_alert_warning(
      "googlePubsubR: GCP_AUTH_FILE environment variable not found, please set it up before
      authenticating")
  }
}
