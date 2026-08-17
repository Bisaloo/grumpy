#' Read a `.npz` file
#'
#' @param file Path to the `.npz` file
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

read_npz <- function(file) {
  if (!file.exists(file)) {
    stop("File does not exist: ", file, call. = FALSE)
  }
  files <- unzip(file, list = TRUE)

  # Read each .npy file in the .npz archive
  lapply(files$Name, function(name) {
    con <- unz(file, name, "rb")
    on.exit(close(con))
    read_npy(con)
  }) |>
    setNames(gsub("\\.npy$", "", files$Name))
}
