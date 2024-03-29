% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lib_table.R
\name{retainColumns}
\alias{retainColumns}
\title{Retain specified columns in a data table.}
\usage{
retainColumns(table, columnNames = NA)
}
\arguments{
\item{table}{A data table from which columns will be retained.}

\item{columnNames}{A character vector containing the names of columns to be retained.
If NA (default) then no column will be removed and the full input table will be returned.}
}
\value{
The data table with only the specified columns retained. The object is changed
by reference.
}
\description{
This function retains only the columns in a data table that are listed in the
provided 'columnNames'. All other columns will be removed from the data table.
}
\examples{
library(data.table)

# Create a sample data table
dt <- data.table(
  ID = 1:3,
  Name = c("John", "Alice", "Bob"),
  Age = c(25, 30, 22),
  Country = c("USA", "Canada", "UK")
)

# Specify the columns to be retained
columns_to_retain <- c("ID", "Name")

# Retain only the specified columns
dt <- retainColumns(dt, columns_to_retain)
print(dt)

}
