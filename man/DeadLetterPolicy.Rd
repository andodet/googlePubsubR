% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/objects.R
\name{DeadLetterPolicy}
\alias{DeadLetterPolicy}
\title{Builds a DeadLetterPolicy Object}
\usage{
DeadLetterPolicy(max_delivery_attempts = NULL, dead_letter_topic = NULL)
}
\arguments{
\item{max_delivery_attempts}{\code{numeric} The maximum number of delivery attempts for any message}

\item{dead_letter_topic}{\code{character}, \code{Topic} The name of the topic to which dead letter
messages should be published}
}
\value{
\code{DeadLetterPolicy} object
}
\description{
Builds a DeadLetterPolicy Object
}
\seealso{
Other Object functions: 
\code{\link{DlqPolicy}()},
\code{\link{ExpirationPolicy}()},
\code{\link{MessageStoragePolicy}()},
\code{\link{PubsubMessage}()},
\code{\link{PushConfig}()},
\code{\link{RetryPolicy}()},
\code{\link{SchemaSettings}()},
\code{\link{Schema}()},
\code{\link{Snapshot}()},
\code{\link{Subscription}()},
\code{\link{Topic}()}
}
\concept{Object functions}
