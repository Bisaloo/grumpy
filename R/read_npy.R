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
  if (any(header$base_type %in% c("uint", "int") & header$size == 8L)) {
    warning(
      "64-bit integers may overflow when converted to R integers.",
      call. = FALSE
    )
  }

  # Read the data
  num_elements <- prod(header$shape)
  bytes <- readBin(con, "raw", n = sum(num_elements * header$size))
  parse_npy_data(
    bytes,
    shape = header$shape,
    datatype = header$base_type,
    typesize = header$size,
    endian = header$endianness
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
    endianness = parsed_descr$endianness,
    base_type = parsed_descr$base_type,
    size = parsed_descr$size,
    fortran_order = header$fortran_order,
    shape = header$shape
  ))
}

parse_npy_datatype <- function(descr) {
  if (is.list(descr)) {
    # structured data type
    types <- lapply(descr, function(field) {
      parse_npy_datatype(field[[2]])
    })
    return(
      list(
        types,
        size = vapply(types, function(x) x$size, integer(1L)),
        base_type = vapply(types, function(x) x$base_type, character(1L)),
        endianness = vapply(types, function(x) x$endianness, character(1L))
      )
    )
  }
  descr_components <- regmatches(
    descr,
    regexec("^([<>|]?)([a-zA-Z])([0-9]*)$", descr)
  )[[1L]]
  endianness <- if (descr_components[2L] %in% c("", "|")) {
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
  base_type <- switch(
    python_type,
    f = "float",
    i = "int",
    u = "uint",
    `?` = "bool",
    b = "bool",
    a = "string",
    S = "string",
    U = "unicode",
    c = "complex",
    m = "timedelta",
    M = "datetime",
    V = "other",
    O = "py_object",
    stop(
      "Unsupported data type: ",
      descr_components[1L],
      call. = FALSE
    )
  )

  size <- switch(
    python_type,
    f = as.integer(descr_components[4L]),
    i = as.integer(descr_components[4L]),
    u = as.integer(descr_components[4L]),
    `?` = 1L,
    b = 1L,
    a = as.integer(descr_components[4L]),
    S = as.integer(descr_components[4L]),
    U = as.integer(descr_components[4L]) * 4L,
    O = NA_real_
  )

  return(list(
    endianness = endianness,
    base_type = base_type,
    size = size
  ))
}

parse_npy_data <- function(bytes, shape, datatype, typesize, endian) {
  if (length(datatype) > 1L) {
    # structured datatype
    field <- rep_len(
      rep(
        seq_along(typesize),
        typesize
      ),
      length.out = length(bytes)
    )

    res <- vector("list", prod(shape))
    for (i in seq_along(datatype)) {
      raw_field <- bytes[field == i]
      field_converted <- parse_npy_data(
        raw_field,
        shape = NULL,
        datatype = datatype[[i]],
        typesize = typesize[[i]],
        endian = endian[[i]]
      )
      res <- mapply(
        function(x, y) c(x, list(y)),
        res,
        field_converted,
        SIMPLIFY = FALSE
      )
    }
  } else {
    endian <- if (is.na(endian)) {
      .Platform$endian
    } else {
      endian
    }
    # FIXME: optimize this
    if (datatype != "unicode" && endian != .Platform$endian) {
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
  }

  dim(res) <- shape

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
