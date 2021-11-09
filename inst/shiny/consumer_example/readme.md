## Resource setup

In order to run the shiny app in `inst/shiny/consumer_example/app.R`
you’ll need to setup your `GCP_PROJECT` as an environment variable
before running this example.  
Run the app from the root of the package:

    shiny::runApp("inst/shiny/consumer_example/")

Upon startup, the `inst/shiny/consumer_example/app.Rinit.R` file will
take care of creating the following resources:

-   A pubsub topic named `shiny-topic`
-   An associated pubsub subscription from where we’ll be polling and
    consuming messages, named `shiny-sub`

## Components

This app is composed by two main components:

**A producer**:

In this case, our producer will be an `actionButton` (on top of this
readme) that will trigger a `PubsubMessage` to be generated and sent to
the subscription, the message will contain the following fields:

    {
      "col_a": "int",    # A random integer
      "col_b": "int",    # A random integer
      "fired_at": "str"  # Timestamp at which the message was created
    }

**A consumer:**

This is the bulk of where the interesting things happen. The shiny app
will check whether new messages have been published to the subscription
every 2 seconds. In order not to block the user from sending new
messages (or keep interacting with sliders, inputs, etc. in a more
complex case), this will be done in a parallel R session using the
[`{promises}`](https://github.com/rstudio/promises) and
[`{future}`](https://github.com/HenrikBengtsson/future) packages.

    # Set up a message consumer in background sessions (poll messages every 2 seconds)
    observe({
      invalidateLater(20000, session)

      future_promise({
        pubsub_auth() # Authenticated session is not passed to futures' env
        get_data()
      }) %>%
        then(function(res) {
          # Notify the user if new messages have been received
          if (!is.null(res)) {
            showNotification(
              paste("Message received at", strftime(Sys.time()), sep = " "),
              duration = 3,
              type = "warning"
            )
          }

          # Append to the reactive dataframe
          out_df$df <- rbind(out_df$df, res)
        })

      # Hide the future, this is a fire and forget hack and allows avoid blocking
      # from https://stackoverflow.com/a/57922419/9046275
      return(NULL)
    })

The `get_data()` function takes care of:

1.  Pulling the messages from the Pub/Sub topic
2.  Convert the base64 encoded string and binding the results to a data
    frame
3.  Acknowledge the subscription the messages where consumed
    (effectively removing them from the subscription).

------------------------------------------------------------------------

The components described above interact according the behaviour
described by the diagram below:

    +---------------+   +---------------+     +------------------+        +--------------------+                                                                                                                                                   
    | actionButton  |-->| Pub/Sub Topic |     |Observe({promise})|------> |Output dataframe    |                                                                                                                                                   
    | (producer)    |   |               |     |(consumer)        |        |(reactiveValues(df) |                                                                                                                                                   
    +---------------+   +---------------+     +------------------+        +--------------------+                                                                                                                                                   
                              |                     ^     |                                                                                                                                                                                        
                        +-----v---------+           |     |                                                                                                                                                                                        
                        |Pub/Sub        |-----------+     |                                                                                                                                                                                        
                        |Subscription   |<----------------+                                                                                                                                                                                        
                        +---------------+                                                                                                                                                                                                          

### Todo

-   It would be nice to have the time to profile the whole thing (an
    idea could be to observe memory usage inside a docker container as I
    am not sure `profviz` is capable to handle multi-session shiny
    apps).
