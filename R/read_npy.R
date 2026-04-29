#' Read a .npy file
#'
#' @param path Path to the .npy file
#'
#' @return An array containing the data from the .npy file
#'
#' @export
#'
#' @examples
#' read_npy(
#'   system.file("extdata", "test.npy", package = "grumpy")
#' )

read_npy <- function(path) {
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  con <- file(path, "rb")
  on.exit(close(con))

  # Read the header
  magic_string <- readBin(con, "raw", n = 6)
  if (!identical(magic_string, charToRaw("\x93NUMPY"))) {
    stop("Not a valid .npy file: ", path)
  }

  version <- readBin(con, "integer", n = 2, size = 1, endian = "little")

  header_len <- if (version[1] == 1) {
    readBin(con, "integer", n = 1, size = 2, endian = "little")
  } else if (version[1] %in% c(2, 3)) {
    readBin(con, "integer", n = 1, size = 4, endian = "little")
  } else {
    stop("Unsupported .npy version: ", version[1])
  }

  header <- rawToChar(readBin(con, "raw", n = header_len))

  # FIXME: are we sure descr is always using the short formatting for dtypes? (e.g. 'i4' instead of 'int32')
  descr <- regmatches(
    header,
    regexec(
      "['\"]descr['\"]\\s*:\\s*['\"]([<|>]?)([?bBiufcmMOSaUV])(\\d+)['\"]",
      header,
      perl = TRUE
    )
  )[[1]]
  endianness <- if (descr[2] %in% c("", "|")) {
    .Platform$endian
  } else {
    switch(
      descr[2],
      "<" = "little",
      ">" = "big",
      stop("Invalid endianness in .npy file: ", descr[1])
    )
  }
  python_type <- descr[3]
  r_type <- switch(
    python_type,
    "f" = "numeric",
    "i" = "integer",
    "u" = "integer",
    "b" = "logical",
    "S" = "integer",
    "U" = "integer",
    stop("Unsupported data type in .npy file: ", descr[1])
  )
  signed <- python_type != "u"

  size <- switch(
    python_type,
    "f" = as.integer(descr[4]),
    "i" = as.integer(descr[4]),
    "u" = as.integer(descr[4]),
    "b" = 1L,
    "S" = as.integer(descr[4]),
    "U" = as.integer(descr[4]) * 4L
  )

  # TODO: If I understand correctly, fortranarray in python are still displayed
  # the same way as regular arrays, but with a different order in memory.
  # It is not related to the way the data is stored in the file, nor the way
  # it appears to the user.
  # We just ignore it, at least for now.
  fortran_order <- as.logical(regmatches(
    header,
    regexec("['\"]fortran_order['\"]\\s*:\\s*(True|False)", header)
  )[[1]][2])
  shape <- regmatches(
    header,
    regexec("['\"]shape['\"]\\s*:\\s*\\(([^\\)]*)\\)", header)
  )[[1]][2]
  shape <- as.integer(strsplit(shape, ",\\s*")[[1]])

  # Read the data
  num_elements <- prod(shape)

  if (python_type %in% "U") {
    ints <- readBin(
      con,
      what = "integer",
      size = 4,
      n = num_elements * size / 4,
      endian = endianness
    )
    tmp <- split(
      ints,
      f = ceiling(seq_along(ints) / (size / 4))
    )
    data <- vapply(
      tmp,
      intToUtf8,
      FUN.VALUE = character(1),
      USE.NAMES = FALSE
    )
  } else if (python_type == "S") {
    ints <- readBin(
      con,
      what = "integer",
      size = 1,
      n = num_elements * size,
      endian = endianness
    )
    tmp <- split(
      ints,
      f = ceiling(seq_along(ints) / size)
    )
    data <- vapply(
      tmp,
      function(x) rawToChar(as.raw(x)),
      FUN.VALUE = character(1),
      USE.NAMES = FALSE
    )
  } else {
    data <- readBin(
      con,
      what = r_type,
      n = num_elements,
      size = size,
      signed = signed,
      endian = endianness
    )
  }

  dim(data) <- shape

  return(data)
}
