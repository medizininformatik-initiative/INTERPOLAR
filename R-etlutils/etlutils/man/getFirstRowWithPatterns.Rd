% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lib_table.R
\name{getFirstRowWithPatterns}
\alias{getFirstRowWithPatterns}
\title{Get the index of the first row in a data table that matches specified patterns in its columns.}
\usage{
getFirstRowWithPatterns(table, patterns, grep = FALSE)
}
\arguments{
\item{table}{A data table to search for matching rows.}

\item{patterns}{A character vector of patterns to be matched in the columns of the table.}

\item{grep}{Logical, indicating whether to use \code{grepl} for pattern matching. Default is FALSE.}
}
\value{
The index of the first row that matches all the specified patterns, or -1 if not found.
}
\description{
This function searches for the first row in a data table that contains matches for a set of specified patterns
in its columns. If the number of patterns to be matched is greater than the number of columns, it returns -1.
}
\examples{
library(data.table)
table <- data.table(
  col1 = c('AAAA', 'A', 'AA', 'AAA'),
  col2 = c('BBBB', 'B', 'BB', 'BBB'),
  col3 = c('CCCC', 'C', 'CC', 'CCC'),
  col4 = c('DDDD', 'D', 'DD', 'DDD')
)

# Find the index of the first row that contains "BBB" and "DDD" in the data table
index <- getFirstRowWithPatterns(table, c('BBB', 'DDD'))
print(index) # Output should be 4

# Find the index of the first row that contains "BBB" or "DDD" in the data table using grepl
index <- getFirstRowWithPatterns(table, c('BBB', 'DDD'), TRUE)
print(index) # Output should be 1

}
