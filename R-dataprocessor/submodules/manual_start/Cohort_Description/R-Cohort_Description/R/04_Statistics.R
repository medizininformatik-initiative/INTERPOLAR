#' Summarise one expanded cohort result row
#'
#' @param values Logical case-level indicators or numeric case-level measurements.
#' @param patient_ids Patient identifiers aligned with values, used only internally
#'   to preserve within-patient dependence in the proportion confidence interval.
#' @param seed Reproducible bootstrap seed supplied by the analysis entry point.
#' @return One aggregate row with the thirteen result columns of the local table.
#'   Missing values are excluded from N and counted as Missing Information.
#'   Proportion intervals use Wilson for independent cases and a 2000-replicate
#'   patient-cluster percentile bootstrap for repeated cases. Quantiles use type 7.
summariseCohortValues <- function(values, patient_ids, seed) {
  if (length(values) != length(patient_ids) || anyNA(patient_ids)) {
    stop("Values require aligned, nonmissing patient identifiers.")
  }
  is_binary <- is.logical(values)
  present <- !is.na(values) & is.finite(as.numeric(values))
  x <- values[present]
  ids <- patient_ids[present]
  count <- length(x)
  result <- data.table::data.table(
    missing_information = sum(!present), N = count,
    n = if (is_binary) 0L else NA_integer_, proportion = NA_real_, ci_low = NA_real_, ci_high = NA_real_,
    median = NA_real_, q1 = NA_real_, q3 = NA_real_, mean = NA_real_, sd = NA_real_,
    min = NA_real_, max = NA_real_
  )
  if (!count) return(result)
  if (is_binary) {
    successes <- sum(x)
    p_hat <- successes / count
    if (!anyDuplicated(ids)) {
      z <- stats::qnorm(0.975)
      center <- (p_hat + z^2 / (2 * count)) / (1 + z^2 / count)
      radius <- z * sqrt(p_hat * (1 - p_hat) / count + z^2 / (4 * count^2)) /
        (1 + z^2 / count)
      bounds <- c(max(0, center - radius), min(1, center + radius))
    } else {
      # Restore the caller's RNG state, including absence of .Random.seed.
      had_seed <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
      if (had_seed) previous_seed <- get(".Random.seed", envir = .GlobalEnv)
      on.exit(
        {
          if (had_seed) assign(".Random.seed", previous_seed, envir = .GlobalEnv)
          else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE))
            rm(".Random.seed", envir = .GlobalEnv)
        },
        add = TRUE
      )
      set.seed(seed)
      groups <- split(as.integer(x), ids)
      totals <- lengths(groups)
      hits <- vapply(groups, sum, numeric(1))
      estimates <- replicate(2000L, {
        selected <- sample.int(length(groups), length(groups), replace = TRUE)
        sum(hits[selected]) / sum(totals[selected])
      })
      bounds <- stats::quantile(estimates, c(0.025, 0.975), type = 7, names = FALSE)
    }
    result[, `:=`(n = successes, proportion = p_hat, ci_low = bounds[1], ci_high = bounds[2])]
  } else {
    quantiles <- stats::quantile(x, c(0.25, 0.5, 0.75), type = 7, names = FALSE)
    result[, `:=`(
      median = quantiles[2], q1 = quantiles[1], q3 = quantiles[3],
      mean = mean(x), sd = stats::sd(x), min = min(x), max = max(x)
    )]
  }
  result
}
