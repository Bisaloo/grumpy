## code to prepare `supported_types` dataset goes here
supported_types <- list(
  ">f2" = list(base_type = "float", nbytes = 2L, endian = "big"),
  "<f2" = list(base_type = "float", nbytes = 2L, endian = "little"),
  ">f4" = list(base_type = "float", nbytes = 4L, endian = "big"),
  "<f4" = list(base_type = "float", nbytes = 4L, endian = "little"),
  ">f8" = list(base_type = "float", nbytes = 8L, endian = "big"),
  "<f8" = list(base_type = "float", nbytes = 8L, endian = "little"),
  "|i1" = list(base_type = "int", nbytes = 1L, endian = NA_character_),
  ">i2" = list(base_type = "int", nbytes = 2L, endian = "big"),
  "<i2" = list(base_type = "int", nbytes = 2L, endian = "little"),
  ">i4" = list(base_type = "int", nbytes = 4L, endian = "big"),
  "<i4" = list(base_type = "int", nbytes = 4L, endian = "little"),
  ">i8" = list(base_type = "int", nbytes = 8L, endian = "big"),
  "<i8" = list(base_type = "int", nbytes = 8L, endian = "little"),
  "|u1" = list(base_type = "uint", nbytes = 1L, endian = NA_character_),
  ">u2" = list(base_type = "uint", nbytes = 2L, endian = "big"),
  "<u2" = list(base_type = "uint", nbytes = 2L, endian = "little"),
  ">u4" = list(base_type = "uint", nbytes = 4L, endian = "big"),
  "<u4" = list(base_type = "uint", nbytes = 4L, endian = "little"),
  ">u8" = list(base_type = "uint", nbytes = 8L, endian = "big"),
  "<u8" = list(base_type = "uint", nbytes = 8L, endian = "little"),
  "|?1" = list(base_type = "bool", nbytes = 1L, endian = NA_character_),
  "|b1" = list(base_type = "bool", nbytes = 1L, endian = NA_character_),
  "|O" = list(
    base_type = "py_object",
    nbytes = NA_integer_,
    endian = NA_character_
  )
) |>
  list2env(hash = TRUE, parent = emptyenv())

usethis::use_data(supported_types, internal = TRUE, overwrite = TRUE)
