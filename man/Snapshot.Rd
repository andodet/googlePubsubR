% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/objects.R
\name{Snapshot}
\alias{Snapshot}
\title{Builds a Snapshot Object}
\usage{
Snapshot(topic = NULL, expire_time = NULL, name = NULL, labels = NULL)
}
\arguments{
\item{topic}{\code{character}, \code{Topic} The name of the topic from which this snapshot is
retaining messages}

\item{expire_time}{\code{character} The snapshot is guaranteed to exist up until this time}

\item{name}{\code{character} The name of the snapshot}

\item{labels}{\code{list} Key-value pairs for topic labels}
}
\value{
\code{Snapshot} object
}
\description{
Builds a Snapshot Object
}
\seealso{
Other Object functions: 
\code{\link{DeadLetterPolicy}()},
\code{\link{DlqPolicy}()},
\code{\link{ExpirationPolicy}()},
\code{\link{MessageStoragePolicy}()},
\code{\link{PubsubMessage}()},
\code{\link{PushConfig}()},
\code{\link{RetryPolicy}()},
\code{\link{SchemaSettings}()},
\code{\link{Schema}()},
\code{\link{Subscription}()},
\code{\link{Topic}()}
}
\concept{Object functions}
