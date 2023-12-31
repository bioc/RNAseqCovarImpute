#' limmavoom_imputed_data_list_helper
#'
#' Loops through the imputed data list (output from "impute_by_gene_bin" function)
#' and runs limma-voom RNA seq analysis.
#' @return A dataframe with coefficient, standard error, sigma, and residual degrees of freedom values from limma-voom gene expression analysis. One row per gene and one set of values per imputed dataset.
#' @param gene_intervals Output from get_gene_bin_intervals function. A dataframe where each row contains the start (first col) and end (second col) values for each gene bin interval.
#' @param DGE A DGEList object.
#' @param imputed_data_list Output from impute_by_gene_bin.
#' @param m Number of imputed data sets.
#' @param voom_formula Formula for design matrix.
#'
#' @include voom_master_lowess.R
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate bind_cols as_tibble left_join pull
#' @importFrom foreach %do% foreach
#' @importFrom edgeR cpm
#' @importFrom mice mice quickpred complete
#' @importFrom stats model.matrix
#' @importFrom rlang .data
#' @importFrom limma normalizeBetweenArrays lmFit
#'
#' @keywords internal
limmavoom_imputed_data_list_helper <- function(gene_bin, gene_intervals, DGE, imputed_data_list, m, voom_formula, sx_sy) {
    # get mean-variance curve from all genes across all M imputations

    # get imputed data
    imputed_data <- imputed_data_list[[gene_bin]]
    # get dge list for this gene interval
    alldg_bin <- DGE[as.numeric(gene_intervals[gene_bin, 1]):as.numeric(gene_intervals[gene_bin, 2]), ]

    all_coef_se_within_bin <- foreach(i = seq(m), .combine = "left_join") %do% {
        # we have imputed data for a particular gene bin interval.
        # now we get the ith imputed data set within
        data_i <- complete(imputed_data, i)

        # run limmavoom
        design1 <- model.matrix(as.formula(voom_formula), data_i)

        voom1 <- voom_master_lowess(alldg_bin, design1, lib.size.all = DGE$samples$lib.size * DGE$samples$norm.factors, sx = sx_sy$sx, sy = sx_sy$sy)
        fit1 <- lmFit(voom1)

        # get coefficients unscaled SE, df residual, and sigma from fit1
        coef <- fit1$coefficients %>% as_tibble()
        SE_unscaled <- fit1$stdev.unscaled * fit1$sigma
        SE_unscaled <- as_tibble(SE_unscaled)
        degrees_freedom_residual <- fit1$df.residual
        sigma <- fit1$sigma

        output1 = foreach(lm_predictor = seq(coef), .combine = "left_join") %do% {
          res = tibble(probe = rownames(fit1),
                       coef = pull(coef[lm_predictor]),
                       SE_unscaled = pull(SE_unscaled[lm_predictor]),
                       sigma = sigma,
                       df_residual = degrees_freedom_residual)
          # rename fit values to include info on which imputed data they come from and which contrast from model
          colnames(res)[colnames(res) != "probe"] <- paste0(colnames(res)[colnames(res) != "probe"], ".", colnames(coef[lm_predictor]), ".", i)
          res
        }
        output1
    }
    return(all_coef_se_within_bin)
}
