#' Get topic name
#'
#' @param x `character`, `Topic`
#'
#' @return (`character`)
#' @keywords internal
#' @noRd
as.topic_name <- function(x, project = ps_project_get()) {
  if (is.character(x) && x != "") {
    if (already_formatted(x)) {
      out <- x
    } else {
      out <- paste(c("projects", project, "topics", x), collapse = "/")
    }
    return(out)
  } else if (inherits(x, "Topic")) {
    if (already_formatted(x$name)) {
      out <- x$name
    } else {
      out <- paste(c("projects", project, "topics", x$name), collapse = "/")
    }
    return(out)
  } else if (is.null(x)) {
    return(NULL)
  } else {
    stop("Topic name is invalid!", call. = FALSE)
  }
}

#' Creates a pub/sub topic
#'
#' @param name `character`, `Topic` Required, topic name or instance of a topic object
#' @param labels `list` Key-value pairs for topic labels
#' @param message_retention_duration `numeric` Indicates the minimum duration (in seconds) to retain
#'  a message after it is published to the topic
#' @param message_storage_policy `MessageStorePolicy` An instance of a `MessageStorePolicy` object
#'   Policy constraining the set of Google Cloud Platform regions where messages published to the 
#'   topic may be stored
#' @param satisfies_pzs `logical` Reserved for future use.
#' @param schema_settings `SchemaSettings` An instance of a `SchemaSettings` object
#' @param kms_key_name `character` The resource name of the Cloud KMS CryptoKey to be used
#'  to protect access to messages published on this topic.
#'
#' @return A `Topic` object representing the freshly created topic
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions
#' @export
topics_create <- function(name,
                          labels = NULL,
                          kms_key_name = NULL,
                          satisfies_pzs = NULL,
                          message_storage_policy = NULL,
                          schema_settings = NULL,
                          message_retention_duration = NULL) {
  
  if(!is.null(message_retention_duration)) {
    message_retention_duration <- paste0(message_retention_duration, "s")
  }
  
  topic_name <- as.topic_name(name)
  topic <- Topic(
    labels                     = labels,
    kms_key_name               = kms_key_name,
    satisfies_pzs              = satisfies_pzs,
    message_storage_policy     = message_storage_policy,
    schema_settings            = schema_settings,
    message_retention_duration = message_retention_duration
  )

  url <- sprintf("https://pubsub.googleapis.com/v1/%s", topic_name)
  f <- googleAuthR::gar_api_generator(
    url, "PUT",
    data_parse_function = function(x) unmarshal_res(Topic(), x)
  )

  stopifnot(inherits(topic, "Topic"))

  res <- f(the_body = rmNullObs(topic))
  cli::cli_alert_success(sprintf("%s succesfully created", res$name))

  return(res)
}

#' Deletes a pub/sub topic
#'
#' @param topic `character`, `Topic` Required, topic name or instance of a `Topic` object
#' 
#' @return None, called for side effects
#' 
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions
#' @export
topics_delete <- function(topic) {
  topic <- as.topic_name(topic)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", topic)
  f <- googleAuthR::gar_api_generator(url, "DELETE", data_parse_function = function(x) x)

  invisible(f()) # No need to return an empty list
  cli::cli_alert_success(sprintf("%s succesfully deleted", topic))
}

#' Gets a topic configuration
#'
#' @param topic `character`, `Topic` Required, topic name or instance of a `Topic`
#' @return `Topic`, A `Topic` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions
#' @export
topics_get <- function(topic) {
  topic <- as.topic_name(topic)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", topic)

  f <- googleAuthR::gar_api_generator(
    url, "GET",
    data_parse_function = function(x) unmarshal_res(Topic(), x)
  )

  f()
}

#' Lists topics from project
#'
#' @param project `character` GCP project id
#' @param pageSize `numeric` Maximum number of topics to return
#' @param pageToken `character` The value returned by the last `ListTopicsResponse`; indicates
#'  that this is a continuation of a prior `ListTopics` call, and that the system should return the
#'  next page of data.
#'
#' @return A `list` of topics
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions
#' @export
topics_list <- function(project = ps_project_get(), pageSize = NULL,
                        pageToken = NULL) {
  url <- sprintf("https://pubsub.googleapis.com/v1/projects/%s/topics/", project)
  pars <- list(pageSize = pageSize, pageToken = pageToken)

  f <- googleAuthR::gar_api_generator(url, "GET",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) x
  )

  f()
}

#' Check if a topic exists
#'
#' @param topic `character`, `Topic` Required, topic name or instance of a topic object
#' @param project `character` GCP project id
#'
#' @return `logical`, TRUE if topic exists, FALSE otherwise
#' @family Topic functions
#' @export
topics_exists <- function(topic, project = ps_project_get()) {
  topic <- as.topic_name(topic)
  all_topics <- topics_list(project)
  if (any(grepl(topic, all_topics$topics$name))) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Updates an existing topic
#'
#' @param topic `character`, `Topic` Required, topic name or instance of a `Topic` object
#' @param labels `list` Key-value pairs for topic labels
#' @param kms_key_name `character` The resource name of the Cloud KMS CryptoKey to be used 
#'  to protect access to messages published on this topic.
#' @param schema_settings `SchemaSettings` An instance of a `SchemaSettings` object
#' @param satisfies_pzs `logical` Reserved for future use.
#' @param message_retention_duration `character` Indicates the minimum duration to retain
#'  a message after it is published to the topic.
#' @param message_storage_policy `MessageStoragePolicy` Policy constraining the set of Google Cloud 
#'  Platform regions where messages published to the topic may be stored.
#'
#' @return An instance of the patched `Topic`
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions
#' @export
topics_patch <- function(topic,
                         labels = NULL,
                         message_storage_policy = NULL,
                         kms_key_name = NULL,
                         schema_settings = NULL,
                         satisfies_pzs = NULL,
                         message_retention_duration = NULL) {

  # Build a patch request
  topic <- as.topic_name(topic)
  update_req <- UpdateObjectRequest(Topic(
    labels                     = labels,
    kms_key_name               = kms_key_name,
    satisfies_pzs              = satisfies_pzs,
    message_storage_policy     = message_storage_policy,
    schema_settings            = schema_settings,
    message_retention_duration = message_retention_duration
  ))
  stopifnot(inherits(update_req, "UpdateTopicRequest"))

  url <- sprintf("https://pubsub.googleapis.com/v1/%s", topic)

  # pubsub.projects.topics.patch
  f <- googleAuthR::gar_api_generator(
    url, "PATCH",
    data_parse_function = function(x) unmarshal_res(Topic(), x)
  )

  f(the_body = rmNullObs(update_req))
}

#' Adds one or more messages to the topic
#'
#' @param messages `list` Required, a list containing the messages to be published
#' @param topic `Topic`, `character` Required, an instance of a `Topic` object or a topic name
#'
#' @return A `character` vector containing message IDs
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions
#' @export
topics_publish <- function(messages, topic) {
  topic <- as.topic_name(topic)
  body <- list(messages = messages)
  url <- sprintf(
    "https://pubsub.googleapis.com/v1/%s:publish", topic
  )

  body <- rmNullObs(body)
  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)

  res <- f(the_body = body)
}

# #' Gets the access control policy for a resource. Returns an empty policy if the resource exists and does not have a policy set.
# #'
# #' @param resource REQUIRED: The resource for which the policy is being requested
# #' @param options.requestedPolicyVersion Optional
# #' @importFrom googleAuthR gar_api_generator
# #' @export
# topics_getIamPolicy <- function(resource, options.requestedPolicyVersion = NULL) {
#   url <- sprintf("https://pubsub.googleapis.com/v1/%s:getIamPolicy", resource)
#   # pubsub.projects.topics.getIamPolicy
#   pars <- list(options.requestedPolicyVersion = options.requestedPolicyVersion)
#   f <- googleAuthR::gar_api_generator(url, "GET",
#     pars_args = rmNullObs(pars),
#     data_parse_function = function(x) x
#   )
#   f()
# }

# #' Sets the access control policy on the specified resource. Replaces any existing policy. Can return `NOT_FOUND`, `INVALID_ARGUMENT`, and `PERMISSION_DENIED` errors.
# #'
# #' Set \code{options(googleAuthR.scopes.selected = c(https://www.googleapis.com/auth/cloud-platform, https://www.googleapis.com/auth/pubsub)}
# #' Then run \code{googleAuthR::gar_auth()} to authenticate.
# #' See \code{\link[googleAuthR]{gar_auth}} for details.
# #'
# #' @param SetIamPolicyRequest The \link{SetIamPolicyRequest} object to pass to this method
# #' @param resource REQUIRED: The resource for which the policy is being specified
# #' @importFrom googleAuthR gar_api_generator
# #' @family SetIamPolicyRequest functions
# #' @export
# topics_setIamPolicy <- function(SetIamPolicyRequest, resource) {
#   url <- sprintf("https://pubsub.googleapis.com/v1/%s:setIamPolicy", resource)
#   # pubsub.projects.topics.setIamPolicy
#   f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)
#   stopifnot(inherits(SetIamPolicyRequest, "gar_SetIamPolicyRequest"))
#
#   f(the_body = SetIamPolicyRequest)
# }

#' List attached subscriptions to a topic.
#'
#' @param topic `Topic`, `character` Required, an instance of a `Topic` object or a topic name
#' @param pageToken `character` The value returned by the last response; indicates that this is a continuation
#'  of a prior `topics_list_subscriptions()` paged call, and that the system should return the next
#'  page of data
#' @param pageSize `numeric` Maximum number of subscription names to return
#'
#' @return A `character` vector
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Topic functions 
#' @export
topics_list_subscriptions <- function(topic, pageToken = NULL, pageSize = NULL) {
  topic <- as.topic_name(topic)
  print(topic)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s/subscriptions", topic)
  pars <- list(pageToken = pageToken, pageSize = pageSize)
  f <- googleAuthR::gar_api_generator(
    url, "GET",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) x
  )

  res <- f()

  if(length(res) == 0) {
    out <- c()
  } else {
    out <- res$subscriptions
  }

  return(out)
}
