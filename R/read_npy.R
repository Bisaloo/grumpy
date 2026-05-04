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
      stop("File does not exist: ", file, call. = FALSE)
    }
    con <- file(file, "rb")
    on.exit(close(con))
  } else if (inherits(file, "connection")) {
    con <- file
  } else {
    stop(
      "Invalid bytes: file must be a character string or a connection.",
      call. = FALSE
    )
  }

  # Read the header
  magic_string <- readBin(con, "raw", n = 6L)
  if (!identical(magic_string, charToRaw("\x93NUMPY"))) {
    stop("Not a valid .npy file: ", file, call. = FALSE)
  }

  format_version <- readBin(
    con,
    "integer",
    n = 2L,
    size = 1L,
    endian = "little"
  )

  header_len <- if (format_version[1L] == 1L) {
    readBin(con, "integer", n = 1L, size = 2L, endian = "little")
  } else if (format_version[1L] %in% c(2L, 3L)) {
    readBin(con, "integer", n = 1L, size = 4L, endian = "little")
  } else {
    stop("Unsupported .npy version: ", format_version[1L], call. = FALSE)
  }

  header <- parse_npy_descr(readBin(con, "raw", n = header_len))

  # TODO: improve int64 support
  if (header$python_type %in% c("i", "u") && header$size == 8L) {
    warning(
      "64-bit integers may overflow when converted to R integers.",
      call. = FALSE
    )
  }

  # Read the data
  num_elements <- prod(header$shape)
  bytes <- readBin(con, "raw", n = num_elements * header$size)
  parse_npy_data(
    bytes,
    shape = header$shape,
    datatype = header$base_type,
    typesize = header$size,
    endian = header$endianness
  )
}

parse_npy_descr <- function(bytes) {
  header <- rawToChar(bytes)
  # FIXME: are we sure descr is always using the short formatting for dtypes?
  # (e.g. 'i4' instead of 'int32')
  descr <- regmatches(
    header,
    regexec(
      "['\"]descr['\"]\\s*:\\s*['\"]([<|>]?)([?bBiufcmMOSaUV])(\\d+)['\"]",
      header,
      perl = TRUE
    )
  )[[1L]]
  parsed_descr <- parse_npy_datatype(descr)

  # TODO: If I understand correctly, fortranarray in python are still displayed
  # the same way as regular arrays, but with a different order in memory.
  # It is not related to the way the data is stored in the file, nor the way
  # it appears to the user.
  # We just ignore it, at least for now.
  fortran_order <- as.logical(regmatches(
    header,
    regexec("['\"]fortran_order['\"]\\s*:\\s*(True|False)", header)
  )[[1L]][2L])
  shape <- regmatches(
    header,
    regexec("['\"]shape['\"]\\s*:\\s*\\(([^\\)]*)\\)", header)
  )[[1L]][2L]

  shape <- as.integer(strsplit(shape, ",\\s*")[[1L]])

  return(list(
    endianness = parsed_descr$endianness,
    python_type = parsed_descr$python_type,
    r_type = parsed_descr$r_type,
    base_type = parsed_descr$base_type,
    size = parsed_descr$size,
    fortran_order = fortran_order,
    shape = shape
  ))
}

parse_npy_datatype <- function(descr) {
  endianness <- if (descr[2L] %in% c("", "|")) {
    .Platform$endian
  } else {
    switch(
      descr[2L],
      `<` = "little",
      `>` = "big",
      stop("Invalid endianness in .npy file: ", descr[1L], call. = FALSE)
    )
  }
  python_type <- descr[3L]
  r_type <- switch(
    python_type,
    f = "numeric",
    i = "integer",
    u = "integer",
    `?` = "logical",
    b = "logical",
    a = "string",
    S = "string",
    U = "unicode",
    stop("Unsupported data type in .npy file: ", descr[1L], call. = FALSE)
  )
  base_type <- switch(
    python_type,
    f = "float",
    i = "int",
    u = "uint",
    `?` = "bool",
    b = "bool",
    a = "string",
    S = "string",
    U = "unicode"
  )

  size <- switch(
    python_type,
    f = as.integer(descr[4L]),
    i = as.integer(descr[4L]),
    u = as.integer(descr[4L]),
    `?` = 1L,
    b = 1L,
    a = as.integer(descr[4L]),
    S = as.integer(descr[4L]),
    U = as.integer(descr[4L]) * 4L
  )

  return(list(
    endianness = endianness,
    python_type = python_type,
    r_type = r_type,
    base_type = base_type,
    size = size
  ))
}

parse_npy_data <- function(bytes, shape, datatype, typesize, endian) {
  # FIXME: optimize this
  if (datatype != "unicode" && !is.na(endian) && endian != .Platform$endian) {
    ind <- rep_len(rev(seq_len(typesize)), length(bytes)) +
      (seq_along(bytes) - 1L) %/% typesize * typesize
    bytes <- bytes[ind]
  }

  res <- switch(
    datatype,
    float = .Call(
      C_type_convert_float,
      bytes,
      typesize
    ),
    int = .Call(
      C_type_convert_int,
      bytes,
      typesize
    ),
    uint = .Call(
      C_type_convert_uint,
      bytes,
      typesize
    ),
    bool = .Call(
      C_type_convert_bool,
      bytes,
      typesize
    ),
    string = .Call(
      C_type_convert_string,
      bytes,
      typesize
    ),
    unicode = .Call(
      C_type_convert_unicode,
      bytes,
      typesize,
      endian
    ),
    stop("Unsupported data type: ", datatype, call. = FALSE)
  )

  dim(res) <- shape

  return(res)
}
