#' Get topic name
#'
#' @param x `character`, `Topic`
#'
#' @return `character`
#' @keywords internal
as.sub_name <- function(x, project = Sys.getenv("GCP_PROJECT")) {
  # Can it be done with a switch case?
  if (is.character(x) && x != "") {
    if (already_formatted(x)) {
      out <- x
    } else {
      out <- paste(c("projects", project, "subscriptions", x), collapse = "/")
    }
    return(out)
  } else if (inherits(x, "Subscription")) {
    if (already_formatted(x$name)) {
      out <- x$name
    } else {
      out <- paste(c("projects", project, "subscriptions", x$name), collapse = "/")
    }
    return(out)
  } else if (is.null(x)) {
    return(NULL)
  } else {
    stop("Subscription name is invalid!", call. = FALSE)
  }
}

#' Creates a subscription to a given topic
#'
#' @param name `character` Required, name of the subscription to be created
#' @param topic `Topic`, `character` Required, an instance of a `Topic` object or a string of the
#'   topic name
#' @param labels `list` Key-value pairs for snapshot labels
#' @param dead_letter_policy `DeadLetterPolicy` A policy object that specifies the conditions
#'   for dead lettering messages in this subscription
#' @param msg_retention_duration `character` How long to retain unacknowledged messages 
#'   in the subscription's backlog
#' @param retry_policy A policy that specifies how Pub/Sub retries message delivery for 
#'   this subscription
#' @param push_config `PushConfig` A `pushConfig` object
#' @param ack_deadline `numeric` The approximate amount of time (on a best-effort basis) Pub/Sub 
#'   waits for the subscriber to acknowledge receipt before resending the message.
#' @param expiration_policy `ExpirationPolicy` A policy that specifies the conditions for 
#'   this subscription's expiration
#' @param filter `character` An expression written in the Pub/Sub filter language
#' @param detached `logical` Indicates whether the subscription is detached from its topic
#' @param retain_acked_messages `logical` Indicates whether to retain acknowledged messages
#' @param enable_msg_ordering `logical` If true, messages published with the same orderingKey
#'  in PubsubMessage will be delivered to the subscribers in the order in which they are received 
#'  by the Pub/Sub system
#'  
#'  @return A `Subscription` object
#'
#' @importFrom googleAuthR gar_api_generator
subscriptions_create <- function(name,
                                 topic,
                                 dead_letter_policy = NULL,
                                 msg_retention_duration = NULL,
                                 labels = NULL,
                                 retry_policy = NULL,
                                 push_config = NULL,
                                 ack_deadline = NULL,
                                 expiration_policy = NULL,
                                 filter = NULL,
                                 detached = NULL,
                                 retain_acked_messages = NULL,
                                 enable_msg_ordering = NULL) {
  sub_name <- as.sub_name(name)
  topic_name <- as.topic_name(topic)

  subscription <- Subscription(
    topic                      = topic_name,
    dead_letter_policy         = dead_letter_policy,
    msg_retention_duration     = msg_retention_duration,
    labels                     = labels,
    retry_policy               = retry_policy,
    push_config                = push_config,
    ack_deadline               = ack_deadline,
    expiration_policy          = expiration_policy,
    filter                     = filter,
    detached                   = detached,
    retain_acked_msgs          = retain_acked_messages,
    enable_msg_ordering        = enable_msg_ordering
  )

  url <- sprintf("https://pubsub.googleapis.com/v1/%s", sub_name)
  f <- googleAuthR::gar_api_generator(
    url, "PUT",
    data_parse_function = function(x) unmarshal_res(Subscription(), x)
  )

  stopifnot(inherits(subscription, "Subscription"))

  res <- f(the_body = rmNullObs(subscription))
  cli::cli_alert_success(sprintf("%s succesfully created", res$name))

  return(res)
}

#' Deletes an existing subscription.
#'
#' All messages retained in the subscription will be immediately dropped. Calls to `Pull`
#' after deletion will return `NOT_FOUND`. After a subscription is deleted, a new one may
#' be created with the same name, but the new one has no association with the old subscription
#' or its topic unless the same topic is specified.
#'
#' @param subscription `character`, `Subscription` Required, subscription name or instance of
#'   a `Subscription` object
#' 
#' @importFrom googleAuthR gar_api_generator
#' @export
subscriptions_delete <- function(subscription) {
  sub_name <- as.sub_name(subscription)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", sub_name)
  f <- googleAuthR::gar_api_generator(url, "DELETE", data_parse_function = function(x) x)

  f()
  cli::cli_alert_success(sprintf("%s succesfully deleted", sub_name))
}

#' Gets the configuration details of a subscription.
#'
#' @param subscription `character`, `Subscription` Required, subscription name or instance of
#'   a `Subscription` object
#'
#' @return A `Subscription` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @export
subscriptions_get <- function(subscription) {
  sub_name <- as.sub_name(subscription)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", sub_name)
  f <- googleAuthR::gar_api_generator(
    url, "GET",
    data_parse_function = function(x) unmarshal_res(Subscription(), x)
  )

  f()
}

#' Detaches a subscription from a topic.
#'
#' @param subscription `character`, `Subscription` Required, subscription name or instance of
#'   a `Subscription` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @export
subscriptions_detach <- function(subscription) {
  sub_name <- as.sub_name(subscription)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s:detach", sub_name)
  # pubsub.projects.subscriptions.detach
  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)

  f()
  cli::cli_alert_success(sprintf("%s succesfully detached", sub_name))

  return(TRUE)
}

#' Lists matching subscriptions.
#'
#' @param project `character` Required, GCP project id
#' @param pageSize `numeric` Maximum number of subscriptions to return
#' @param pageToken `character` The value returned by the last `subscriptions_list`; 
#'   indicates that this is a continuation of a prior `subscriptions_list` call
#'
#' @return `data.frame`
#'
#' @importFrom googleAuthR gar_api_generator
#' @export
subscriptions_list <- function(project = Sys.getenv("GCP_PROJECT"),
                               pageSize = NULL, pageToken = NULL) {
  url <- sprintf("https://pubsub.googleapis.com/v1/projects/%s/subscriptions", project)
  pars <- list(pageSize = pageSize, pageToken = pageToken)

  f <- googleAuthR::gar_api_generator(url, "GET",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) as.data.frame(x)
  )

  f()
}

#' Pulls messages from the server.
#'
#' @param subscription `character`, `Subscription` Required, subscription where to pull
#'   messages from
#' @param max_messages `numeric` Maximum number of messages to return
#' 
#' @return A named `list` with pulled messages
#' @importFrom googleAuthR gar_api_generator
#' @family PullRequest functions
#' @export
subscriptions_pull <- function(subscription, max_messages = 100) {
  sub_name <- as.sub_name(subscription)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s:pull", sub_name)
  f <- googleAuthR::gar_api_generator(
    url, "POST",
    data_parse_function = function(x) x
  )

  f(the_body = list(maxMessages = max_messages))
}

#' Acknowledges the messages
#'
#' The Pub/Sub system can remove the relevant messages from the subscription.
#' Acknowledging a message whose ack deadline has expired may succeed, but such a message
#' may be redelivered later. Acknowledging a message more than once will not result in an error.
#'
#' @param ack_ids `character` A vector containing one or more message ackIDs
#' @param subscription `character`, `Subscription` Required, the subscription whose messages
#'   are being aknowledged
#'
#' @return `logical`
#' @importFrom googleAuthR gar_api_generator
#' @family AcknowledgeRequest functions
#' @export
subscriptions_ack <- function(ack_ids, subscription) {
  sub_name <- as.sub_name(subscription)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s:acknowledge", sub_name)
  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)

  res <- f(the_body = list(ackIds = ack_ids))

  if (length(res) == 0) {
    return(TRUE)
  }
}

#' Check if a subscription exists
#'
#' @param subscription `character`, `Subscription` Required, subscription name or instance of
#'   a `Subscription` object
#'
#' @return `logical`
#' @export
subscriptions_exists <- function(subscription) {
  sub_name <- as.sub_name(subscription)
  all_subs <- subscriptions_list()

  if (sub_name %in% all_subs$`subscriptions.name`) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

#' Updates an existing subscription.
#'
#' Certain properties of a subscription, such as its topic, are not modifiable.
#'
#' @param subscription `character`, `Subscription` Required, a subscription name or a 
#'   `Subscription` object
#' @param topic `character`, `Topic` Required, a topic name or a `Topic` object
#' @param labels `labels` Key value pairs
#' @param dead_letter_policy `DeadLetterPolicy` A `DeadLetterPolicy` object
#' @param msg_retention_duration `character` How long to retain unacknowledged messages 
#' @param retry_policy `RetryPolicy` policy that specifies how Pub/Sub retries message delivery
#'   for this subscription, can be built with \code{\link{RetryPolicy}}
#' @param push_config `PushConfig` Can be built with \code{\link{PushConfig}}
#' @param ack_deadline `numeric` amount of time (in seconds) Pub/Sub waits for the subscriber
#'   to acknowledge receipt before resending the message 
#' @param expiration_policy `ExpirationPolicy` specifies the conditions for this subscription's 
#'   expiration. Can be built with \code{\link{ExpirationPolicy}}
#' @param filter `character` An expression written in the Pub/Sub [filter language](https://cloud.google.com/pubsub/docs/filtering) 
#' @param detached `logical` Indicates whether the subscription is detached from its topic
#' @param retain_acked_msgs `character` Indicates whether to retain acknowledged messages
#' @param enable_ordering `logical`messages published with the same orderingKey in PubsubMessage
#'   will be delivered to the subscribers in the order in which they are received by the Pub/Sub system 
#'
#' @return An updated `Subscription` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @family UpdateSubscriptionRequest functions
#' @export
subscriptions_patch <- function(subscription,
                                topic,
                                labels = NULL,
                                dead_letter_policy = NULL,
                                msg_retention_duration = NULL,
                                retry_policy = NULL,
                                push_config = NULL,
                                ack_deadline = NULL,
                                expiration_policy = NULL,
                                filter = NULL,
                                detached = NULL,
                                retain_acked_msgs = NULL,
                                enable_ordering = NULL) {
  sub_name <- as.sub_name(subscription)
  topic_name <- as.topic_name(topic)

  # FIXME: could probably be more elegant
  update_req <- UpdateObjectRequest(Subscription(
    labels                     = labels,
    dead_letter_policy         = dead_letter_policy,
    msg_retention_duration     = msg_retention_duration,
    retry_policy               = retry_policy,
    push_config                = push_config,
    ack_deadline               = ack_deadline,
    expiration_policy          = expiration_policy,
    filter                     = filter,
    detached                   = detached,
    retain_acked_msgs          = retain_acked_msgs,
    enable_msg_ordering        = enable_ordering
  ))
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", sub_name)

  f <- googleAuthR::gar_api_generator(
    url, "PATCH",
    data_parse_function = function(x) unmarshal_res(Subscription(), x)
  )
  stopifnot(inherits(update_req, "UpdateSubscriptionRequest"))

  f(the_body = rmNullObs(update_req))
}

#' Seek a subscription to a point in timex
#' 
#' A subscription can be seeked to a point in time or to a given snapshot.
#' 
#' @param subscription `character`, `Subscription` Required, a snapshot name or a `Snapshot`
#'   object
#' @param time `character` A timestamp in RFC3339 UTC "Zulu" format
#' @param snapshot `character`, `Snapshot` A Snapshot name or a `Snapshot` object
#' 
#' @return `logical`
#'
#' @importFrom googleAuthR gar_api_generator
#' @family AcknowledgeRequest functions
#' @export
subscriptions_seek <- function(subscription, time = NULL, snapshot = NULL) {
  sub_name <- as.sub_name(subscription)
  snap_name <- as.snapshot_name(snapshot)

  req <- list(
    time = time,
    snapshot = snap_name
  )

  url <- sprintf("https://pubsub.googleapis.com/v1/%s:seek", sub_name)
  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)

  res <- f(the_body = req)

  if (length(res) == 0) {
    return(TRUE)
  }
}

#' Updates an existing subscription
#'
#' Certain properties of a subscription, such as its topic, are not modifiable.
#'
#' @param subscription `character`, `Subscription` A subscription name or `Subscription` object
#' @param ack_ids `character` A vector containing ackIDs. They can be acquired using  
#' @param ack_deadline `numeric` The new ack deadline (in seconds)
#' 
#' @return `logical`
#'
#' @importFrom googleAuthR gar_api_generator
#' @family UpdateSubscriptionRequest functions
#' @export
subscriptions_modify_ack_deadline <- function(subscription, ack_ids, ack_deadline) {
  sub_name <- as.sub_name(subscription)
  update_req <- list(
    ackIds = ack_ids,
    ackDeadlineSeconds = ack_deadline
  )
  url <- sprintf("https://pubsub.googleapis.com/v1/%s:modifyAckDeadline", sub_name)

  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)
  res <- f(the_body = rmNullObs(update_req))

  if (length(res) == 0) {
    return(TRUE)
  }
}

#' Modify PushConfig for a subscription
#'
#' @param subscription `character`, `Subscription` Required, a subscription name or a `Subscription`
#'   object
#' @param push_config `PushConfig` New PushConfig object, can be built using \code{\link{PushConfig}}
#'
#' @return `logical`
#' @export
subscriptions_modify_pushconf <- function(subscription, push_config) {
  sub_name <- as.sub_name(subscription)
  update_req <- list(
    pushConfig = push_config
  )
  url <- sprintf("https://pubsub.googleapis.com/v1/%s:modifyPushConfig", sub_name)

  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)
  res <- f(the_body = rmNullObs(update_req))

  if (length(res) == 0) {
    return(TRUE)
  }
}