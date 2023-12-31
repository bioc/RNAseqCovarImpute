% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/voom_sx_sy.R
\name{voom_sx_sy}
\alias{voom_sx_sy}
\title{voom_sx_sy}
\usage{
voom_sx_sy(
  counts,
  design = NULL,
  lib.size = NULL,
  normalize.method = "none",
  block = NULL,
  correlation = NULL,
  weights = NULL,
  span = 0.5,
  plot = FALSE,
  save.plot = FALSE,
  lib.size.all
)
}
\value{
Tibble with one col for sx and one for sy for lowess function.
}
\description{
Modified voom function used by limma_voom-imputed_data_list function.
Allows input of bins of outcome genes while still accounting for the total library size
of all outcome genes, as the total library size is needed to calculate log-cpm values.
Returns just the sx and sy values needed for lowess curve. Adapted from limma::voom.
Code from limma covered by License: GPL (>=2)
}
\keyword{internal}
