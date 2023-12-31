#' lowess_all_gene_bins
#'
#' Loops through all bins and all M imputations, prepares DGE and design to run
#' voom_sx_sy, which fits gene-wise linear models and extracts log count size (sx)
#' and sqrt resudual standard deviations (sy) to make the lowess curve
#' @return All sx and sy values for lowess function across all M imputations.
#'
#' @include voom_sx_sy.R
#'
#' @keywords internal
lowess_all_gene_bins <- function(gene_intervals, DGE, imputed_data_list, m, voom_formula) {
    lowess_all_gene_bins <- foreach(i = seq(m), .combine = "rbind") %do% {
        foreach(gene_bin = seq(length(imputed_data_list)), .combine = "rbind") %do% {
            # Get imputed data for this gene bin and this M imputed dataset
            imputed_data <- complete(imputed_data_list[[gene_bin]], i)
            # Get DGE list for this gene interval
            alldg_bin <- DGE[as.numeric(gene_intervals[gene_bin, 1]):as.numeric(gene_intervals[gene_bin, 2]), ]
            design1 <- model.matrix(as.formula(voom_formula), imputed_data)
            # voom_sx_sy is the first half of the voom function to get sx and sy for lowess curve
            out <- voom_sx_sy(alldg_bin, design1, lib.size.all = DGE$samples$lib.size * DGE$samples$norm.factors)
        }
    }
}
