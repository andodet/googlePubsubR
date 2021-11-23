#' Get snaphsot name
#'
#' @param x `character`, `Topic`
#'
#' @return `character`
#' @noRd
#' @keywords internal
as.snapshot_name <- function(x, project = Sys.getenv("GCP_PROJECT")) {
  if (is.character(x) && x != "") {
    if (already_formatted(x)) {
      out <- x
    } else {
      out <- paste(c("projects", project, "snapshots", x), collapse = "/")
    }
    return(out)
  } else if (inherits(x, "Snapshot")) {
    if (already_formatted(x$name)) {
      out <- x$name
    } else {
      out <- paste(c("projects", project, "snapshots", x$name), collapse = "/")
    }
    return(out)
  } else {
    stop("Snapshot name is invalid!", call. = FALSE)
  }
}

#' Creates a snapshot from the requested subscription
#'
#' Snapshots are used in [Seek](https://cloud.google.com/pubsub/docs/replay-overview) operations,
#' which allow you to manage message acknowledgments in bulk. That is, you can set the
#' acknowledgment state of messages in an existing subscription to the state captured by a snapshot.
#' If the snapshot already exists, returns `ALREADY_EXISTS`. If the requested subscription doesn't
#' exist, returns `NOT_FOUND`. If the backlog in the subscription is too old -- and the resulting
#' snapshot would expire in less than 1 hour -- then `FAILED_PRECONDITION` is returned.
#' See also the `Snapshot.expire_time` field. If the name is not provided in the request,
#' the server will assign a random name for this snapshot on the same project as the subscription,
#' conforming to the [resource name format](https://cloud.google.com/pubsub/docs/admin#resource_names).
#' The generated name is populated in the returned Snapshot object. Note that for REST API requests, you must
#'
#' @param subscription `Subscription`, `character` Required, an instance of a `Subscription`
#'  object or a subscription name
#' @param labels `list` Key-value pairs for snapshot labels
#' @param name `Snapshot`, `character` Required, an instance of a `Snapshot` object or a
#'   snapshot name
#'
#' @return  An instance of a `Snapshot` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Snapshot functions
#' @export
snapshots_create <- function(name, subscription, labels = NULL) {
  snap_name <- as.snapshot_name(name)
  snap_req <- list(
    subscription = as.sub_name(subscription),
    labels = labels
  )

  url <- sprintf("https://pubsub.googleapis.com/v1/%s", snap_name)
  f <- googleAuthR::gar_api_generator(
    url, "PUT",
    data_parse_function = function(x) unmarshal_res(Snapshot(), x)
  )

  f(the_body = rmNullObs(snap_req))
}

#' Removes an existing snapshot
#'
#' @param snapshot `Snapshot`, `character` Required, an instance of a `Snapshot` object or a
#'   object or a subscription name
#'   
#' @return None, called for side effects
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Snapshot functions
#' @export
snapshots_delete <- function(snapshot) {
  snap_name <- as.snapshot_name(snapshot)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", snap_name)
  # pubsub.projects.snapshots.delete
  f <- googleAuthR::gar_api_generator(url, "DELETE", data_parse_function = function(x) x)

  cli::cli_alert_success(sprintf("%s succesfully deleted", snap_name))
  f()
}

#' Lists the existing snapshots 
#' 
#' @param pageSize `numeric` Maximum number of snapshots to return
#' @param pageToken `character` The value returned by the last `ListSnapshotsResponse`;
#'   indicates that this is a continuation of a prior `ListSnapshots` call, and that the
#'   system should return the next page of data
#' @param project `character` a GCP project ID
#'
#' @return A `data.frame` containing all snapshots
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Snapshot functions
#' @export
snapshots_list <- function(project = Sys.getenv("GCP_PROJECT"), pageSize = NULL,
                           pageToken = NULL) {

  url <- sprintf("https://pubsub.googleapis.com/v1/projects/%s/snapshots", project)

  pars <- list(pageSize = pageSize, pageToken = pageToken)
  f <- googleAuthR::gar_api_generator(
    url, "GET",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) as.data.frame(x)
  )

  f()
}

#' Check if a snapshot exists
#'
#' @param snapshot `character`, `Snapshot` Required, snapshot name or an instance of a `Snapshot` object
#'
#' @return `logical` TRUE if snapshot exists
#' 
#' @family Snapshot functions 
#' @export
snapshots_exists <- function(snapshot) {
  snap_name <- as.snapshot_name(snapshot)
  all_snaps <- snapshots_list()

  if (snap_name %in% all_snaps$`snapshots.name`) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Gets the configuration details of a snapshot
#' 
#' @param snapshot `Snapshot`, `character` Required, an instance of a `Snapshot` object or a
#'   snapshot name
#'
#' @return An instance of a `Snapshot` object
#' @importFrom googleAuthR gar_api_generator
#' @export
snapshots_get <- function(snapshot) {
  snap_name <- as.snapshot_name(snapshot)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", snap_name)

  f <- googleAuthR::gar_api_generator(
    url, "GET",
    data_parse_function = function(x) unmarshal_res(Snapshot(), x)
  )

  f()
}

#' Updates an existing snapshot
#'  
#' @param snapshot `Snapshot`, `character` Required, an instance of a `Snapshot` object or a
#'   snapshot name
#' @param topic `character`, `Topic` Topic name or instance of a topic object
#' @param expire_time `string` The snapshot is guaranteed to exist up until this time.
#'   Must be formatted in RFC3339 UTC "Zulu" format
#' @param labels `list` Key-value pairs for topic labels
#' 
#' @return An instance the patched `Snapshot` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Snapshot functions
#' @export
snapshots_patch <- function(snapshot,
                            topic = NULL,
                            expire_time = NULL,
                            labels = NULL) {
  snap_name <- as.snapshot_name(snapshot)
  update_req <- UpdateObjectRequest(Snapshot(
    topic       = topic,
    expire_time = expire_time,
    labels      = labels
  ))

  url <- sprintf("https://pubsub.googleapis.com/v1/%s", snap_name)
  # pubsub.projects.snapshots.patch
  f <- googleAuthR::gar_api_generator(url, "PATCH",
    data_parse_function = function(x) unmarshal_res(Snapshot(), x)
  )
  stopifnot(inherits(update_req, "UpdateSnapshotRequest"))
  
  f(the_body = update_req)
}
