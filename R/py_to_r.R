# The header is a Python dict literal, e.g.
# {'descr': '<i4', 'fortran_order': False, 'shape': (3, 4), }

# The helpers below parse it without evaluating it since it may contain arbitrary
# code. See https://github.com/Bisaloo/grumpy/issues/33.

# Split on commas that are not inside nested parentheses or brackets
py_split_top_level <- function(x) {
  # (?x) allows comments and whitespace. `(*SKIP)(*FAIL)` makes the regex
  # consume nested groups without matching them, so only the remaining
  # (top-level) commas act as separators.
  sep <- r"((?x)
    (?<nested>                           # a balanced group, recursively
      \( (?: [^()\[\]] | (?&nested) )* \)  # ( ... )
      |
      \[ (?: [^()\[\]] | (?&nested) )* \]  # [ ... ]
    )
    (*SKIP)(*FAIL)                       # skip over it
    |
    ,\s*                                 # top-level comma, and any potential whitespace
  )"
  parts <- strsplit(x, sep, perl = TRUE)[[1L]]
  parts[nzchar(parts)]
}

# Parse the header dict into a named list of unparsed value strings
py_dict_to_r_list <- function(dict) {
  entries <- dict |>
    trimws() |>
    remove_surround("{", "}") |>
    py_split_top_level()

  # Entries look like "'key': value"
  colon <- regexpr(":", entries, fixed = TRUE)
  keys <- remove_surround(substr(entries, 1L, colon - 1L), "'", "'")
  values <- trimws(substring(entries, colon + 1L))
  as.list(setNames(values, keys))
}

# "(2, 3)" -> c(2, 3); "(3,)" -> 3; "()" -> numeric(0)
# "('a', '<i8')" with type = "character" -> c("a", "<i8")
py_tuple_to_r_c <- function(tuple, type = c("numeric", "character")) {
  parts <- tuple |>
    remove_surround("(", ")") |>
    strsplit("\\s*,\\s*", perl = TRUE) |>
    _[[1L]] |>
    remove_surround("'", "'")
  parts <- parts[nzchar(parts)]
  storage.mode(parts) <- type
  parts
}

# "[('a', '<i8'), ('b', '<f4')]" -> list(c("a", "<i8"), c("b", "<f4"))
py_list_to_r_list <- function(lst) {
  lst |>
    remove_surround("[", "]") |>
    py_split_top_level() |>
    lapply(py_tuple_to_r_c, type = "character")
}

# Strip `start` and `end` from the ends of `x`, when present
remove_surround <- function(x, start, end) {
  substr(x, startsWith(x, start) + 1L, nchar(x) - endsWith(x, end))
}
