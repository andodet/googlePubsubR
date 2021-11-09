# Resource names
topic_name <- "test_topic"
sub_name <- "test_subscription"
snap_name <- "test_snapshot"

schema_name <- "test_schema"
schema_def <- list(
  type = "record",
  name = "myRecord",
  fields = list(
    list(
      name = "cost",
      type = "int",
      default = 200
    ),
    list(
      name = "object",
      type = "string",
      default = "blender"
    )
  )
)

msg <- list(cost = 12, object = "fork") %>%
  jsonlite::toJSON(auto_unbox = TRUE) %>%
  charToRaw() %>%
  base64enc::base64encode() %>%
  PubsubMessage()

# Some resource properties
labels = list(a = "1", b = "2")
retention_duration= 1800  # 30 min

skip_if_no_token <- function() {
  skip_on_cran()
  skip_on_travis()
}

if(file.exists("../../.gcp_creds.json")) {
  pubsub_auth(json_file = "../../.gcp_creds.json")
} else {
  message("No authentication file found for testing")
}
