% Generated by roxygen2 (4.0.1): do not edit by hand
\name{gbifparser}
\alias{gbifparser}
\title{Parser for gbif data}
\usage{
gbifparser(input, fields = "minimal")
}
\arguments{
\item{input}{A list}

\item{fields}{(character) Default ('minimal') will return just taxon name, key, latitude, and
longitute. 'all' returns all fields. Or specify each field you want returned by name, e.g.
fields = c('name','latitude','altitude').}
}
\description{
Parser for gbif data
}
\keyword{internal}

