% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/snapshots.R
\name{snapshots_patch}
\alias{snapshots_patch}
\title{Updates an existing snapshot}
\usage{
snapshots_patch(snapshot, topic = NULL, expire_time = NULL, labels = NULL)
}
\arguments{
\item{snapshot}{\code{Snapshot}, \code{character} Required, an instance of a \code{Snapshot} object or a
snapshot name}

\item{topic}{\code{character}, \code{Topic} Topic name or instance of a topic object}

\item{expire_time}{\code{string} The snapshot is guaranteed to exist up until this time.
Must be formatted in RFC3339 UTC "Zulu" format}

\item{labels}{\code{list} Key-value pairs for topic labels}
}
\value{
An instance the patched \code{Snapshot} object
}
\description{
Updates an existing snapshot
}
\seealso{
Other Snapshot functions: 
\code{\link{snapshots_create}()},
\code{\link{snapshots_delete}()},
\code{\link{snapshots_exists}()},
\code{\link{snapshots_list}()}
}
\concept{Snapshot functions}
