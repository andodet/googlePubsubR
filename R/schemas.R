#' Creates a schema.
#' Get topic name
#'
#' @param x `character`, `Topic`
#'
#' @return `character`
#' @noRd
#' @keywords internal
as.schema_name <- function(x, project = ps_project_get()) {
  # Can it be done with a switch case?
  if (is.character(x) && x != "") {
    if (already_formatted(x)) {
      out <- x
    } else {
      out <- paste(c("projects", project, "schemas", x), collapse = "/")
    }
    return(out)
  } else if (inherits(x, "Schema")) {
    if (already_formatted(x$name)) {
      out <- x$name
    } else {
      out <- paste(c("projects", project, "schemas", x$name), collapse = "/")
    }
    return(out)
  } else {
    stop("Schema name is invalid!", call. = FALSE)
  }
}

#' Creates a schema
#'
#' @param name `character`, `Schema` Required, schema name or instance of a schema object
#' @param type `character` Type of the schema definition
#' @param definition `character` Required, the definition of the schema
#' @param project `character` GCP project id
#' 
#' @return  a `Schema` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Schema functions
#' @export
schemas_create <- function(name,
                           type = c("AVRO", "PROTOCOL_BUFFER", "TYPE_UNSPECIFIED"),
                           definition,
                           project = ps_project_get()) {
  schema_name <- as.schema_name(name)
  schema <- Schema(
    type       = type,
    definition = definition,
    name       = schema_name
  )
  parent <- sprintf("projects/%s", project)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s/schemas", parent)
  pars <- list(schemaId = name)

  f <- googleAuthR::gar_api_generator(url, "POST",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) unmarshal_res(Schema(), x)
  )
  stopifnot(inherits(schema, "Schema"))

  f(the_body = schema)
}

#' Validates a schema
#'
#' @param schema `Schema` Required, an instance of a `Schema` object
#' @param project `character` GCP project id
#' 
#' @return `logical` TRUE if successfully validated
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Schema functions
#' @export
schemas_validate <- function(schema, project = ps_project_get()) {
  parent <- sprintf("projects/%s", project)
  body <- list(
    schema = schema
  )
  url <- sprintf("https://pubsub.googleapis.com/v1/%s/schemas:validate", parent)
  # pubsub.projects.schemas.validate
  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)

  res <- f(the_body = body)

  if (length(res) == 0) {
    return(TRUE)
  }
}

#' Lists all schemas in a project
#'
#' @param pageSize `numeric` Maximum number of schemas to return
#' @param view `list` The set of Schema fields to return in the response
#' @param project `character` GCP project id
#' @param pageToken `character` The value returned by the last `ListSchemasResponse`; indicates that
#'   this is a continuation of a prior `ListSchemas` call, and that the system should return
#'   the next page of data
#'
#' @return A `data.frame` containing all schema objects and properties
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Schema functions
#' @export
schemas_list <- function(project = ps_project_get(), pageSize = NULL,
                         view = c("SCHEMA_VIEW_UNSPECIFIED", "BASIC", "FULL"), 
                         pageToken = NULL) {
  view <- match.arg(view)
  parent <- sprintf("projects/%s", project)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s/schemas", parent)

  pars <- list(pageSize = pageSize, view = view, pageToken = pageToken)
  f <- googleAuthR::gar_api_generator(url, "GET",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) as.data.frame(x)
  )

  f()
}

#' Check if a schema exists
#'
#' @param schema `character`, `Schema` Required, schema name or an instance of a `Schema` object
#'
#' @return `logical` TRUE if the schema exists
#' @family Schema functions
#' @export
schemas_exists <- function(schema) {
  schema_name <- as.schema_name(schema)
  all_schemas <- schemas_list()

  if (schema_name %in% all_schemas$`schemas.name`) {
    return(TRUE)
  } else {
    return(FALSE)
  }

}

#' Gets a schema
#'
#' @param schema `character`, `Schema` Required, schema name or an instance of a `Schema` object
#' @param view `character` The set of fields to return in the response
#'
#' @return  A `Schema` object
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Schema functions
#' @export
schemas_get <- function(schema,
                        view = c("SCHEMA_VIEW_UNSPECIFIED", "BASIC", "FULL")) {
  schema <- as.schema_name(schema)
  view <- match.arg(view)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", schema)

  pars <- list(view = view)
  f <- googleAuthR::gar_api_generator(url, "GET",
    pars_args = rmNullObs(pars),
    data_parse_function = function(x) unmarshal_res(Schema(), x)
  )

  f()
}

#' Deletes a schema
#'
#' @param name `character`, `Schema` Schema name or instance of a schema object
#' 
#' @return None, called for side effects
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Schema functions
#' @export
schemas_delete <- function(name) {
  schema_name <- as.schema_name(name)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s", schema_name)
  f <- googleAuthR::gar_api_generator(url, "DELETE", data_parse_function = function(x) x)
  
  invisible(f())
  cli::cli_alert_success(sprintf("%s succesfully deleted", schema_name))
}

#' Validates a message against a schema
#'
#' @param schema `character`, `Schema` Required, schema name or instance of a Schema object
#' @param message `PubsubMessage` Required, an instance of a `PubsubMessage`, can be created
#'   using \code{\link{PubsubMessage}}
#' @param encoding `character` The encoding of the message
#' @param project `character` A GCP project id
#' 
#' @return `logical` TRUE if successfully validated
#'
#' @importFrom googleAuthR gar_api_generator
#' @family Schema functions
#' @export
schemas_validate_message <- function(schema,
                                     message,
                                     encoding = c("ENCODING_UNSPECIFIED", "JSON", "BINARY"),
                                     project = ps_project_get()) {
  
  # API expects a base64 encoded string, extract it from the message object
  if (inherits(message, "PubsubMessage")) {
    message <- message$data
  }
  
  req <- ValidateMessageRequest(
    message = message,
    encoding = encoding
  )

  if (inherits(schema, "Schema")) {
    req$schema <- schema$definition
  } else {
    req$name <- as.schema_name(schema)
  }

  parent <- sprintf("projects/%s", project)
  url <- sprintf("https://pubsub.googleapis.com/v1/%s/schemas:validateMessage", parent)

  f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)
  stopifnot(inherits(req, "gar_ValidateMessageRequest"))

  res <- f(the_body = req)

  if (length(res) == 0) {
    return(TRUE)
  }
}

#' #' Returns permissions that a caller has on the specified resource. If the resource does not exist, this will return an empty set of permissions, not a `NOT_FOUND` error. Note: This operation is designed to be used for building permission-aware UIs and command-line tools, not for authorization checking. This operation may 'fail open' without warning.
#' #'
#' #' @param TestIamPermissionsRequest The \link{TestIamPermissionsRequest} object to pass to this method
#' #' @param resource REQUIRED: The resource for which the policy detail is being requested
#' #' @importFrom googleAuthR gar_api_generator
#' #' @family TestIamPermissionsRequest functions
#' #' @export
#' projects.schemas.testIamPermissions <- function(TestIamPermissionsRequest, resource) {
#'     url <- sprintf("https://pubsub.googleapis.com/v1/{+resource}:testIamPermissions",
#'         resource)
#'     # pubsub.projects.schemas.testIamPermissions
#'     f <- googleAuthR::gar_api_generator(url, "POST", data_parse_function = function(x) x)
#'     stopifnot(inherits(TestIamPermissionsRequest, "gar_TestIamPermissionsRequest"))
#'
#'     f(the_body = TestIamPermissionsRequest)
#'
#' }
