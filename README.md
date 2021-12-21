# `googlePubsubR`

[![R-CMD-check-ascran](https://github.com/andodet/googlePubsubR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andodet/googlePubsubR/actions/workflows/R-CMD-check.yaml)
[![testthat](https://github.com/andodet/googlePubsubR/actions/workflows/testthat.yaml/badge.svg)](https://github.com/andodet/googlePubsubR/actions/workflows/testthat.yaml)
[![codecov](https://codecov.io/gh/andodet/googlePubsubR/branch/master/graph/badge.svg?token=OTBHY3F1KD)](https://app.codecov.io/gh/andodet/googlePubsubR)

This library offers an easy to use interface for the Google Pub/Sub REST API
(docs [here](https://cloud.google.com/pubsub/docs/reference/rest)).

Not an official Google product.

## Setup

You can install the package from CRAN or get the `dev` version from Github:
```r
install.packages("googlePubsubR")

# Or get the dev version from Github
devtools::install_github("andodet/googlePubsubR@dev")
```

In order to use the library, you will need:

* An active GCP project
* The Pub/Sub API correctly activated
* JSON credentials for a service account or another method of authentication (e.g token). You can pass the
path of the file as an argument to `pubsub_auth` or setting an `GCP_AUTH_FILE` env variable.
* A `GCP_PROJECT` env variable set with a valid GCP project id. Since `0.0.3`, GCP project id can also be set 
using `ps_project_set`.

## Usage

On a very basic level, the library can be used to publish messages, pull and acknowledge them.  
The following example shows how to:

1. Create topics and subscriptions
2. Encode a dataframe as a Pub/Sub message
3. Publish a message
4. Pull and decode messages from a Pub/Sub subscription
5. Delete resources

```r
library(googlePubsubR)
library(base64enc)
library(jsonlite)

# Authenticate 
pubsub_auth()

# Create resources
topic_readme <- topics_create("readme-topic")
sub_readme <- subscriptions_create("readme-sub", topic_readme)

# Prepare the message
msg <- mtcars %>%
  toJSON(auto_unbox = TRUE) %>%
  # Pub/Sub expects a base64 encoded string
  msg_encode() %>% 
  PubsubMessage() 

# Publish the message!
topics_publish(msg, topic_readme)

# Pull the message from server
msgs_pull <- subscriptions_pull(sub_readme)

msg_decoded <- msgs_pull$receivedMessages$message$data %>%
  msg_decode() %>% 
  fromJSON()

head(msg_decoded)

# Prints
# mpg cyl disp  hp drat    wt  qsec vs am gear carb
# Mazda RX4         21.0   6  160 110 3.90 2.620 16.46  0  1    4    4
# Mazda RX4 Wag     21.0   6  160 110 3.90 2.875 17.02  0  1    4    4
# Datsun 710        22.8   4  108  93 3.85 2.320 18.61  1  1    4    1
# Hornet 4 Drive    21.4   6  258 110 3.08 3.215 19.44  1  0    3    1
# Hornet Sportabout 18.7   8  360 175 3.15 3.440 17.02  0  0    3    2
# Valiant           18.1   6  225 105 2.76 3.460 20.22  1  0    3    1

# We can acknowledge that the message has been consumed
subscriptions_ack(msgs_pull$receivedMessages$ackId, sub_readme)
# [1] TRUE

# A subsequent pull will return no messages from the server
subscriptions_pull(sub_readme)
# named list()

# Cleanup resources
topics_delete(topic_readme)
subscriptions_delete(sub_readme)
```

## Use cases

The main use-cases for Pub/Sub messaging queue:

* Stream data into [Dataflow](https://cloud.google.com/dataflow) pipelines
* Trigger workflows hosted in Cloud Run or Cloud Functions
* Expand interactivity in Shiny dashboards (more on this [here](inst/shiny/consumer_example/readme.md)).
* Add event driven actions in [`{plumbr}`](https://www.rplumber.io/)

## Contributing

In order to contribute to `googlePubsubR` you'll need to go through the following steps:

1. Set up a GCP project and create a service account with Pub/Sub admin rights.
2. Download a JSON key for the newly created account. Naming the file `.gcp_creds.json` and placing
it in the package root folder will make it automatically gitignored.
3. Set up the following env vars (either through a tool like `direnv` or a `.Renviron` file).

    ```
    GCP_AUTH_FILE=<paht_to_json_auth_file>
    GCP_PROJECT=<gcp_project_id_string>
    ```
4. Check everything is set up correctly by running a test run via `devtools::test()`.
