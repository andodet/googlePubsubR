library(googlePubsubR)
library(cli)

topic_name <- "shiny-topic"
sub_name <- "shiny-sub"
pubsub_auth()

# Create resources if they don't exist
if(!topics_exists(topic_name)) {
  cli_alert_info(sprintf("Topic %s not found, creating...", topic_name))
  shiny_topic <- topics_create(topic_name)
}

if(!subscriptions_exists(sub_name)) {
  cli_alert_info(sprintf("Subscription %s not found, creating...", sub_name))
  shiny_sub <- subscriptions_create(sub_name, topic_name) 
}
