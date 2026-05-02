#' Read a .npy file
#'
#' @param file Path to the .npy file
#'
#' @return An array containing the data from the .npy file
#'
#' @export
#'
#' @examples
#' read_npy(
#'   system.file("extdata", "test.npy", package = "grumpy")
#' )

read_npy <- function(file) {
  if (is.character(file)) {
    if (!file.exists(file)) {
      stop("File does not exist: ", file)
    }
    con <- file(file, "rb")
    on.exit(close(con))
  } else if (inherits(file, "connection")) {
    con <- file
  } else {
    stop("Invalid bytes: file must be a character string or a connection.")
  }

  # Read the header
  magic_string <- readBin(con, "raw", n = 6)
  if (!identical(magic_string, charToRaw("\x93NUMPY"))) {
    stop("Not a valid .npy file: ", file)
  }

  version <- readBin(con, "integer", n = 2, size = 1, endian = "little")

  header_len <- if (version[1] == 1) {
    readBin(con, "integer", n = 1, size = 2, endian = "little")
  } else if (version[1] %in% c(2, 3)) {
    readBin(con, "integer", n = 1, size = 4, endian = "little")
  } else {
    stop("Unsupported .npy version: ", version[1])
  }

  header <- parse_npy_descr(readBin(con, "raw", n = header_len))

  if (header$python_type == "u" && header$size > 2) {
    stop("Unsigned integers larger than 16 bits are not supported.")
  }
  # TODO: improve int64 support
  if (header$python_type == "i" && header$size == 8) {
    warning("64-bit integers may overflow when converted to R integers.")
  }

  # Read the data
  data <- parse_npy_data(
    con,
    shape = header$shape,
    datatype = header$base_type,
    signed = header$signed,
    typesize = header$size,
    endian = header$endianness
  )

  return(data)
}

parse_npy_descr <- function(bytes) {
  header <- rawToChar(bytes)
  # FIXME: are we sure descr is always using the short formatting for dtypes? (e.g. 'i4' instead of 'int32')
  descr <- regmatches(
    header,
    regexec(
      "['\"]descr['\"]\\s*:\\s*['\"]([<|>]?)([?bBiufcmMOSaUV])(\\d+)['\"]",
      header,
      perl = TRUE
    )
  )[[1]]
  parsed_descr <- parse_npy_datatype(descr)

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

  return(list(
    endianness = parsed_descr$endianness,
    python_type = parsed_descr$python_type,
    r_type = parsed_descr$r_type,
    base_type = parsed_descr$base_type,
    signed = parsed_descr$signed,
    size = parsed_descr$size,
    fortran_order = fortran_order,
    shape = shape
  ))
}

parse_npy_datatype <- function(descr) {
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
    "S" = "string",
    "U" = "unicode",
    stop("Unsupported data type in .npy file: ", descr[1])
  )
  signed <- python_type != "u"
  base_type <- switch(
    python_type,
    "f" = "float",
    "i" = "int",
    "u" = "uint",
    "b" = "bool",
    "S" = "string",
    "U" = "unicode"
  )

  size <- switch(
    python_type,
    "f" = as.integer(descr[4]),
    "i" = as.integer(descr[4]),
    "u" = as.integer(descr[4]),
    "b" = 1L,
    "S" = as.integer(descr[4]),
    "U" = as.integer(descr[4]) * 4L
  )

  return(list(
    endianness = endianness,
    python_type = python_type,
    r_type = r_type,
    base_type = base_type,
    signed = signed,
    size = size
  ))
}

parse_npy_data <- function(bytes, shape, datatype, signed, typesize, endian) {
  num_elements <- prod(shape)

  if (datatype == "unicode") {
    ints <- readBin(
      bytes,
      what = "integer",
      size = 4,
      n = num_elements * typesize / 4,
      endian = "little"
    )
    tmp <- split(
      ints,
      f = ceiling(seq_along(ints) / (typesize / 4))
    )
    data <- vapply(
      tmp,
      intToUtf8,
      FUN.VALUE = character(1),
      USE.NAMES = FALSE
    )
  } else if (datatype == "string") {
    ints <- readBin(
      bytes,
      what = "integer",
      size = 1,
      n = num_elements * typesize,
      endian = "little"
    )
    tmp <- split(
      ints,
      f = ceiling(seq_along(ints) / typesize)
    )
    data <- vapply(
      tmp,
      function(x) rawToChar(as.raw(x)),
      FUN.VALUE = character(1),
      USE.NAMES = FALSE
    )
  } else {
    # FIXME: optimize this
    bytes <- readBin(bytes, "raw", n = num_elements * typesize)
    if (!is.na(endian) && endian != .Platform$endian) {
      ind <- rep_len(rev(seq_len(typesize)), length(bytes)) +
        (seq_along(bytes) - 1L) %/% typesize * typesize
      bytes <- bytes[ind]
    }

    data <- .Call(
      paste0("type_convert_", datatype),
      bytes,
      typesize,
      PACKAGE = "grumpy"
    )
  }

  dim(data) <- shape

  return(data)
}
