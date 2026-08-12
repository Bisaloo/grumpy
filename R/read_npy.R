#' Read a .npy file
#'
#' @param file Path to the .npy file
#' @param ... Ignored. Reserved for future use.
#'
#' @returns An array containing the data from the .npy file
#'
#' @export
#'
#' @examples
#' read_npy(
#'   system.file("extdata", "test.npy", package = "grumpy")
#' )

read_npy <- function(file, ...) {
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

  if (any(header$base_type == "py_object")) {
    stop(
      "This file contains a Python object array. ",
      "Reading .npy files with Python object arrays is not supported. ",
      "A common reason for this is when the file is saved with `np.save(..., allow_pickle=True)`. ",
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
    py_dict_to_r_list()

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
#' @returns A list containing the parsed data type information, including the base
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
        base_type = vapply(types, function(x) x$base_type, character(1L)),
        nbytes = vapply(types, function(x) x$nbytes, integer(1L)),
        endian = vapply(types, function(x) x$endian, character(1L))
      )
    )
  }
  if (startsWith(descr, "|S")) {
    return(
      list(
        base_type = "string",
        nbytes = as.integer(substring(descr, 3L)),
        endian = NA_character_
      )
    )
  }
  if (startsWith(descr, "<U") || startsWith(descr, ">U")) {
    charlen <- as.integer(substring(descr, 3L))
    return(
      list(
        base_type = "unicode",
        nbytes = charlen * 4L,
        endian = if (startsWith(descr, "<")) "little" else "big"
      )
    )
  }

  entry <- supported_types[[descr]]
  if (is.null(entry)) {
    stop("Unsupported data type: ", descr, call. = FALSE)
  }

  return(list(
    base_type = entry$base_type,
    nbytes = entry$nbytes,
    endian = entry$endian
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
#' @returns An R array containing the converted data, with the specified shape and
#'   data type.
#'
#' @export
#'
#' @examples
#' x <- matrix(c(3L, 6L, 2L, 1L, 12L, 0L), nrow = 2, ncol = 3)
#' x
#'
#' y <- writeBin(c(x), raw()) |>
#'   convert_bytes_to_array("int", shape = c(2L, 3L), size = 4L, endian = "little")
#' y
#' dim(y)
#' is.array(y)
#' storage.mode(y)
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
  res <- .Call(
    C_type_convert,
    bytes,
    what,
    size,
    shape,
    endian,
    PACKAGE = "grumpy"
  )

  return(res)
}

py_dict_to_r_list <- function(x) {
  x |>
    # Logicals
    gsub("\\bNone\\b", "NA", x = _) |>
    gsub("\\bTrue\\b", "TRUE", x = _) |>
    gsub("\\bFalse\\b", "FALSE", x = _) |>
    # Trailing commas (before closing brackets/braces)
    gsub(",\\s*([]})])", "\\1", x = _) |>
    # Dict (single-quoted) keys to list names.
    #   Keys are composed of:
    #   - anything that is not the quote itself or a backslash,
    #   - a backslash followed by any character (to allow for escaped quotes).
    gsub("'(([^'\\\\]|\\\\.)*)'\\s*:", "'\\1' =", x = _) |>
    # Dict (double-quoted) keys to list names.
    gsub('"(([^"\\\\]|\\\\.)*)"\\s*:', '"\\1" =', x = _) |>
    # Tuples to c(...)
    gsub("(", "c(", x = _, fixed = TRUE) |>
    # Lists to list(...)
    gsub("[", "list(", x = _, fixed = TRUE) |>
    gsub("{", "list(", x = _, fixed = TRUE) |>
    # Closing brackets/braces
    gsub("]", ")", x = _, fixed = TRUE) |>
    gsub("}", ")", x = _, fixed = TRUE) |>
    # Evaluate the resulting R expression
    parse(text = _) |>
    eval()
}
