library(googlePubsubR)
library(shiny)
library(promises)
library(future)
library(jsonlite)
library(base64enc)
library(magrittr)

plan(multisession(workers = 2))
source("init.R")

# Generate and encode a random pubsub message
gen_msg <- function() {
  data.frame(
    col_a    = sample(1:10000, 1),
    col_b    = sample(1:10000, 1),
    fired_at = Sys.time()
  ) %>%
    as.list() %>%
    toJSON(auto_unbox = TRUE) %>%
    msg_encode() %>% 
    PubsubMessage()
}

# Pulls down messages from server and acks them
get_data <- function() {
  msgs <- subscriptions_pull(sub_name)

  if (length(msgs$receivedMessages) == 0) {
    out <- NULL
  } else {

    # Process messages and bind them to a dataframe, `lapply` is been used as multiple
    # multiple message might come out of a `subscription_pull` response if a queue has
    # formed for whatever reason
    out <- lapply(msgs$receivedMessages$message$data, function(msg) {
      msg %>%
        msg_decode() %>% 
        fromJSON(flatten = TRUE, simplifyDataFrame = TRUE) %>%
        as.data.frame()
    }) %>% do.call(rbind, .)

    # Ackonlewdge messages have been consumed
    subscriptions_ack(msgs$receivedMessages$ackId, subscription = sub_name)
  }

  return(out)
}

ui <- fluidPage(
  actionButton("send_msg", "Send a Pubsub Message!", icon = icon("bullhorn")),
  actionButton("flush_df", "Flush dataframe", icon = icon("trash")),
  tableOutput("messages_df"),
  includeMarkdown("readme.md")
)

server <- function(input, output, session) {
  # The output dataframe
  out_df <- reactiveValues(df = data.frame())
  output$messages_df <- renderTable({
    out_df$df
  })

  # Publish a new message and notify the user
  observeEvent(input$send_msg, {
    topics_publish(gen_msg(), topic_name)
    showNotification(
      paste("Message sent at", strftime(Sys.time()), sep = " "),
      duration = 3
    )
  })
  
  # Empty the output dataframe
  observeEvent(input$flush_df, {
    out_df$df <- data.frame()
  })

  # Set up a message consumer in background sessions (poll messages every 2 seconds)
  observe({
    invalidateLater(2000, session)

    future_promise({
      pubsub_auth() # Authenticated session is not passed to futures' env
      get_data()
    }) %>%
      then(function(res) {
        # Notify the user if new messages have been received
        if (!is.null(res)) {
          showNotification(
            paste("Message(s) received at", strftime(Sys.time()), sep = " "),
            duration = 3,
            type = "warning"
          )
          # Append to the reactive dataframe
          out_df$df <- rbind(out_df$df, res)
        }
      })

    # Hide the future, this is a fire and forget hack and allows avoid blocking
    # from https://stackoverflow.com/a/57922419/9046275
    return(NULL)
  })
}

shinyApp(ui, server)
