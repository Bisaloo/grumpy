#' Read a `.npz` file
#'
#' @param file Path to the `.npz` file
#' @param arrays Optional character vector of array names or numeric vector of
#'   indices to read from the `.npz` file. If `NULL` (the default), all arrays
#'   are read.
#'
#' @return A named list of arrays containing the data from the `.npz` file
#'
#' @importFrom utils unzip
#' @importFrom stats setNames
#'
#' @export
#'
#' @examples
#' read_npz(
#'   system.file("extdata", "test.npz", package = "grumpy")
#' )
#'
#' read_npz(
#'   system.file("extdata", "test.npz", package = "grumpy"),
#'   arrays = "x"
#' )
#'

read_npz <- function(file, arrays = NULL) {
  if (!file.exists(file)) {
    stop("File does not exist: ", file, call. = FALSE)
  }
  files <- unzip(file, list = TRUE)
  all_arrays <- sub("\\.npy$", "", files$Name)

  to_extract <- arrays %||% all_arrays
  if (is.numeric(to_extract)) {
    to_extract <- all_arrays[to_extract]
  }

  if (!all(to_extract %in% all_arrays)) {
    stop(
      "The following arrays are not present in the .npz file: ",
      paste(setdiff(to_extract, all_arrays), collapse = ", "),
      call. = FALSE
    )
  }

  # Read each .npy file in the .npz archive
  lapply(paste0(to_extract, ".npy"), function(name) {
    con <- unz(file, name, "rb")
    on.exit(close(con))
    read_npy(con)
  }) |>
    setNames(to_extract)
}
