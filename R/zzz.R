.onLoad <- function(libname, pkgname) {
  project <- Sys.getenv("GCP_PROJECT")
  if (project != "") {
    # TODO: warn user with a info cli
    options(googlePubsubR.project = project)
  } 
  # TODO: not found, link to instructions
}
