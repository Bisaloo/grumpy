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
  if (any(header$base_type %in% c("uint", "int") & header$nbytes == 8L)) {
    warning(
      "64-bit integers may overflow when converted to R integers.",
      call. = FALSE
    )
  }

  # Read the data
  num_elements <- prod(header$shape)
  bytes <- readBin(con, "raw", n = sum(num_elements * header$nbytes))
  convert_bytes_to_array(
    bytes,
    what = header$base_type,
    shape = header$shape,
    size = header$nbytes,
    endian = header$endian
  )
}

parse_npy_descr <- function(bytes) {
  # TODO: If I understand correctly, fortranarray in python are still displayed
  # the same way as regular arrays, but with a different order in memory.
  # It is not related to the way the data is stored in the file, nor the way
  # it appears to the user.
  # We just ignore it, at least for now.
  header <- bytes |>
    rawToChar() |>
    convert_py_dict_to_json() |>
    jsonlite::fromJSON(simplifyMatrix = FALSE)

  parsed_descr <- parse_npy_datatype(header$descr)

  return(list(
    endian = parsed_descr$endian,
    base_type = parsed_descr$base_type,
    nbytes = parsed_descr$nbytes,
    fortran_order = header$fortran_order,
    shape = header$shape
  ))
}

#' Parse a NumPy Array-protocol type strings
#'
#' @param descr A NumPy dtype description string, or a list of such strings fo
#'   structured dtypes
#'
#' @return A list containing the parsed data type information, including the base
#'   type, the number of bytes, and the endianness
#'
#' @export
#'
#' @examples
#' parse_npy_datatype(">i8")
#' parse_npy_datatype("|b1")
#' parse_npy_datatype(list(c("r", "<i8"), c("g", "<i8"), c("b", "<i8")))
#'
parse_npy_datatype <- function(descr) {
  if (is.list(descr)) {
    # structured data type
    types <- lapply(descr, function(field) {
      parse_npy_datatype(field[[2]])
    })
    return(
      list(
        types,
        nbytes = vapply(types, function(x) x$nbytes, integer(1L)),
        base_type = vapply(types, function(x) x$base_type, character(1L)),
        endian = vapply(types, function(x) x$endian, character(1L))
      )
    )
  }
  descr_components <- regmatches(
    descr,
    regexec("^([<>|]?)([a-zA-Z])([0-9]*)$", descr)
  )[[1L]]
  endian <- if (descr_components[2L] %in% c("", "|")) {
    NA_character_
  } else {
    switch(
      descr_components[2L],
      `<` = "little",
      `>` = "big",
      stop(
        "Invalid endianness: ",
        descr_components[1L],
        call. = FALSE
      )
    )
  }
  python_type <- descr_components[3L]
  n <- as.integer(descr_components[4L])

  type_map <- list(
    f = list(base_type = "float", size = n),
    i = list(base_type = "int", size = n),
    u = list(base_type = "uint", size = n),
    `?` = list(base_type = "bool", size = 1L),
    b = list(base_type = "bool", size = 1L),
    a = list(base_type = "string", size = n),
    S = list(base_type = "string", size = n),
    U = list(base_type = "unicode", size = n * 4L),
    c = list(base_type = "complex", size = n),
    m = list(base_type = "timedelta", size = n),
    M = list(base_type = "datetime", size = n),
    V = list(base_type = "other", size = n),
    O = list(base_type = "py_object", size = NA_integer_)
  )

  entry <- type_map[[python_type]]
  if (is.null(entry)) {
    stop("Unsupported data type: ", descr_components[1L], call. = FALSE)
  }

  return(list(
    endian = endian,
    base_type = entry$base_type,
    nbytes = entry$size
  ))
}

#' Convert raw bytes to an R array based on the specified data type information
#'
#' This is a replacement for [readBin()] that can handle the various data types
#' and endianness specified in the .npy file header.
#'
#' @param bytes A raw vector containing the bytes to convert
#' @param what A character specifying the base type to convert to (e.g., `"float"`,
#'   `"int"`, `"string"`, etc.)
#' @param shape A numeric vector with desired shape of the output array
#' @param size A numeric value with the number of bytes per element for the
#'   specified type
#' @param endian The endianness of the data (`"little"`, `"big"`, or `NA` for
#'   single-byte types)
#'
#' @export
#'
#' @examples
#' x <- matrix(c(3L, 6L, 2L, 1L, 12L, 0L), nrow = 2, ncol = 3)
#' x
#'
#' writeBin(c(x), raw()) |>
#'   convert_bytes_to_array("int", shape = c(2L, 3L), size = 4L, endian = "little")
#'
convert_bytes_to_array <- function(bytes, what, shape, size, endian) {
  if (length(what) > 1L) {
    # structured datatype
    record_size <- sum(size)
    n_records <- prod(shape)

    # Byte offset of each field within one record
    field_start <- c(0L, cumsum(size)[-length(size)])

    # Convert each field via strided index extraction
    res_fields <- vector("list", length(what))
    for (i in seq_along(what)) {
      starts <- seq(
        field_start[[i]] + 1L,
        by = record_size,
        length.out = n_records
      )
      idx <- rep(starts, each = size[[i]]) + seq_len(size[[i]]) - 1
      res_fields[[i]] <- convert_bytes_to_array(
        bytes[idx],
        what = what[[i]],
        shape = NULL,
        size = size[[i]],
        endian = endian[[i]]
      )
    }

    # Final list-transpose
    res <- vector("list", n_records)
    for (j in seq_len(n_records)) {
      res[[j]] <- lapply(res_fields, `[[`, j)
    }
    dim(res) <- shape
    return(res)
  }

  if (is.na(endian)) {
    endian <- .Platform$endian
  }
  # FIXME: optimize this
  if (what != "unicode" && endian != .Platform$endian) {
    ind <- rep_len(rev(seq_len(size)), length(bytes)) +
      (seq_along(bytes) - 1L) %/% size * size
    bytes <- bytes[ind]
  }
  res <- switch(
    what,
    float = .Call(
      C_type_convert_float,
      bytes,
      size,
      shape,
      PACKAGE = "grumpy"
    ),
    int = .Call(
      C_type_convert_int,
      bytes,
      size,
      shape,
      PACKAGE = "grumpy"
    ),
    uint = .Call(
      C_type_convert_uint,
      bytes,
      size,
      shape,
      PACKAGE = "grumpy"
    ),
    bool = .Call(
      C_type_convert_bool,
      bytes,
      size,
      shape,
      PACKAGE = "grumpy"
    ),
    string = .Call(
      C_type_convert_string,
      bytes,
      size,
      shape,
      PACKAGE = "grumpy"
    ),
    unicode = .Call(
      C_type_convert_unicode,
      bytes,
      size,
      shape,
      endian,
      PACKAGE = "grumpy"
    ),
    stop("Unsupported data type: ", what, call. = FALSE)
  )

  return(res)
}

convert_py_dict_to_json <- function(dict_str) {
  dict_str |>
    gsub("'", '"', x = _, fixed = TRUE) |>
    gsub("None", "null", x = _, fixed = TRUE) |>
    gsub("True", "true", x = _, fixed = TRUE) |>
    gsub("False", "false", x = _, fixed = TRUE) |>
    gsub("(", "[", x = _, fixed = TRUE) |>
    gsub(")", "]", x = _, fixed = TRUE) |>
    gsub(",\\s*(}|\\])", "\\1", x = _) # trailing commas
}
