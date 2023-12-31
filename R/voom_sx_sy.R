#' voom_sx_sy
#'
#' Modified voom function used by limma_voom-imputed_data_list function.
#' Allows input of bins of outcome genes while still accounting for the total library size
#' of all outcome genes, as the total library size is needed to calculate log-cpm values.
#' Returns just the sx and sy values needed for lowess curve. Adapted from limma::voom.
#' Code from limma covered by License: GPL (>=2)
#' @return Tibble with one col for sx and one for sy for lowess function.
#'
#' @keywords internal
voom_sx_sy <- function(counts, design=NULL, lib.size=NULL, normalize.method="none", block=NULL, correlation=NULL, weights=NULL, span=0.5, plot=FALSE, save.plot=FALSE, lib.size.all)
    # 	Linear modelling of count data with mean-variance modelling at the observation level.
    # 	Creates an EList object for entry to lmFit() etc in the limma pipeline.
    # 	Gordon Smyth and Charity Law
# 	Created 22 June 2011.  Last modified 1 May 2021.
{
    out <- list()

    # 	Extract counts from known data objects
    if (is(counts, "DGEList")) {
        out$genes <- counts$genes
        out$targets <- counts$samples
        if (is.null(design) && diff(range(as.numeric(counts$sample$group))) > 0) design <- model.matrix(~group, data = counts$samples)
        if (is.null(lib.size)) lib.size <- counts$samples$lib.size * counts$samples$norm.factors
        counts <- counts$counts
    } else {
        isExpressionSet <- suppressPackageStartupMessages(is(counts, "ExpressionSet"))
        if (isExpressionSet) {
            if (length(Biobase::fData(counts))) out$genes <- Biobase::fData(counts)
            if (length(Biobase::pData(counts))) out$targets <- Biobase::pData(counts)
            counts <- Biobase::exprs(counts)
        } else {
            counts <- as.matrix(counts)
        }
    }

    # 	Check counts
    n <- nrow(counts)
    if (n < 2L) stop("Need at least two genes to fit a mean-variance trend")
    m <- min(counts)
    if (is.na(m)) stop("NA counts not allowed")
    if (m < 0) stop("Negative counts not allowed")

    # 	Check design
    if (is.null(design)) {
        design <- matrix(1, ncol(counts), 1)
        rownames(design) <- colnames(counts)
        colnames(design) <- "GrandMean"
    }

    # 	Check lib.size
    if (is.null(lib.size)) lib.size <- colSums(counts)

    # 	Fit linear model to log2-counts-per-million
    y <- t(log2(t(counts + 0.5) / (lib.size + 1) * 1e6))
    y <- normalizeBetweenArrays(y, method = normalize.method)
    fit <- lmFit(y, design, block = block, correlation = correlation, weights = weights)
    if (is.null(fit$Amean)) fit$Amean <- rowMeans(y, na.rm = TRUE)

    # 	If no replication found, set all weight to 1
    NWithReps <- sum(fit$df.residual > 0L)
    if (NWithReps < 2L) {
        if (NWithReps == 0L) warning("The experimental design has no replication. Setting weights to 1.")
        if (NWithReps == 1L) warning("Only one gene with any replication. Setting weights to 1.")
        out$E <- y
        out$weights <- y
        out$weights[] <- 1
        out$design <- design
        if (is.null(out$targets)) {
            out$targets <- data.frame(lib.size = lib.size)
        } else {
            out$targets$lib.size <- lib.size
        }
        return(new("EList", out))
    }

    # 	Fit lowess trend to sqrt-standard-deviations by log-count-size
    sx <- fit$Amean + mean(log2(lib.size.all + 1)) - log2(1e6)
    sy <- sqrt(fit$sigma)
    allzero <- rowSums(counts) == 0
    if (any(allzero)) {
        sx <- sx[!allzero]
        sy <- sy[!allzero]
    }
    out_sx_sy <- tibble(sx = sx, sy = sy)
}
