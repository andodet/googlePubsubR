# Script to delete dangling resources after an unsuccesfull test run

library(googlePubsubR)
library(cli)

topic_name <- "test_topic"
sub_name <- "test_subscription"
snap_name <- "test_snapshot"
schema_name <- "test_schema"

pubsub_auth(".gcp_creds.json")

cli_alert_info("Starting to cleanup test resources...")
if(topics_exists(topic_name)) {
  topics_delete(topic_name)
} else {
  cli_alert_warning(sprintf("%s not found, carrying on", topic_name))
}

if(snapshots_exists(snap_name)) {
  snapshots_delete(snap_name)
}else {
  cli_alert_warning(sprintf("%s not found, carrying on", snap_name))
}

if(subscriptions_exists(sub_name)) {
  subscriptions_delete(sub_name)
} else {
  cli_alert_warning(sprintf("%s not found, carrying on", sub_name))
}

if(schemas_exists(schema_name)) {
  schemas_delete(schema_name)
} else {
  cli_alert_warning(sprintf("%s not found, carrying on", schema_name))
}
