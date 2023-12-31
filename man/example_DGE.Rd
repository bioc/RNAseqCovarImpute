% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/example_DGE.R
\docType{data}
\name{example_DGE}
\alias{example_DGE}
\title{Simulated counts in DGE list}
\format{
\subsection{\code{example_DGE}}{

A DGElist with 500 genes and 500 samples
}
}
\usage{
data(example_DGE)
}
\value{
DGElist for 500 made up genes, ENS1-ENS500
}
\description{
The exact code used to generate these data are found in the Example_Data_for_RNAseqCovarImpute
vignette. In short, \code{example_data} contains 500 rows with data for variables x, y, and z, which
are continuous normally distributed, and a and b, which are binary variables. Missigness
was simulated for all variables other than x such that a complete case analysis would drop
24.2\% of participants. \code{example_DGE} contains random count data from the Poisson distribution
for 500 made up genes, ENS1-ENS500
}
\examples{
data(example_DGE)
}
\keyword{datasets}
