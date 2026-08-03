#include "type_conversion.h"
#include <R_ext/Riconv.h>


SEXP type_convert(SEXP input, SEXP what, SEXP _n_bytes, SEXP dims, SEXP _endian) {
  const char *type = CHAR(STRING_ELT(what, 0));
  SEXP result;

  if (strcmp(type, "float") == 0)
    result = type_convert_float(input, _n_bytes);
  else if (strcmp(type, "int") == 0)
    result = type_convert_int(input, _n_bytes);
  else if (strcmp(type, "uint") == 0)
    result = type_convert_uint(input, _n_bytes);
  else if (strcmp(type, "bool") == 0)
    result = type_convert_bool(input, _n_bytes);
  else if (strcmp(type, "string") == 0)
    result = type_convert_string(input, _n_bytes);
  else if (strcmp(type, "unicode") == 0)
    result = type_convert_unicode(input, _n_bytes, _endian);
  else
    error("Unsupported data type: %s", type);

  PROTECT(result);
  if (!isNull(dims) && xlength(dims) > 0) {
    Rf_dimgets(result, dims);
  }
  UNPROTECT(1);

  return result;
}

SEXP type_convert_int(SEXP input, SEXP _n_bytes) {

  const int n_bytes = INTEGER(_n_bytes)[0];
  const R_xlen_t length = xlength(input);
  const void* raw_buffer = RAW(input);

  int *p_data;
  SEXP data;
  const R_xlen_t data_length = length / n_bytes;
  R_xlen_t i;

  // space for the converted output
  data = PROTECT(allocVector(INTSXP, data_length));
  p_data = INTEGER(data);

  if(n_bytes == 1) {
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const int8_t *)raw_buffer)[i];
    }
  } else if(n_bytes == 2) {
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const int16_t *)raw_buffer)[i];
    }
  } else if(n_bytes == 4) {
    memcpy(p_data, raw_buffer, length);
  } else if (n_bytes == 8) {
    // for now we convert to 32bit int and overflow values are NA_integer
    int bit64conversion = 0;
    if (bit64conversion == 0) {
      int64_to_int32(raw_buffer, data_length, p_data);
    }
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_uint(SEXP input, SEXP _n_bytes) {

  const int n_bytes = INTEGER(_n_bytes)[0];
  const R_xlen_t length = xlength(input);
  const void* raw_buffer = RAW(input);

  int *p_data;
  SEXP data;
  const R_xlen_t data_length = length / n_bytes;
  R_xlen_t i;

  // space for the converted output
  data = PROTECT(allocVector(INTSXP, data_length));
  p_data = INTEGER(data);

  if(n_bytes == 1) {
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const uint8_t *)raw_buffer)[i];
    }
  } else if(n_bytes == 2) {
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const uint16_t *)raw_buffer)[i];
    }
  } else if(n_bytes == 4) {
    uint32_to_int32(raw_buffer, data_length, p_data);
  } else if (n_bytes == 8) {
    // for now we convert to 32bit int and overflow values are NA_integer
    int bit64conversion = 0;
    if (bit64conversion == 0) {
      uint64_to_int32(raw_buffer, data_length, p_data);
    }
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_float(SEXP input, SEXP _n_bytes) {

  const int n_bytes = INTEGER(_n_bytes)[0];
  const R_xlen_t length = xlength(input);
  const void* raw_buffer = RAW(input);

  R_xlen_t data_length, i;
  double *p_data;
  SEXP data;

  data_length  = length / n_bytes;
  data = PROTECT(allocVector(REALSXP, data_length));
  p_data = REAL(data);

  if(n_bytes == 2) {

    const uint16_t *mock_buffer = (const uint16_t *)raw_buffer;
    for (i = 0; i < data_length; i++) {
      p_data[i] = (double)float16_to_float64(mock_buffer[i]);
    }

  } else if(n_bytes == 4) {

    for (i = 0; i < data_length; i++) {
      p_data[i] = (double)((const float *)raw_buffer)[i];
    }

  } else if (n_bytes == 8) {
    memcpy(p_data, raw_buffer, length);
  } else {
    error("%d byte floating point values are not currently supported\n", n_bytes);
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_bool(SEXP input, SEXP _n_bytes) {

  const R_xlen_t length = xlength(input);
  const void* raw_buffer = RAW(input);

  int *p_data;
  R_xlen_t i;
  SEXP data;

  const R_xlen_t data_length = length;

  data = PROTECT(allocVector(LGLSXP, data_length));
  p_data = LOGICAL(data);

  for (i = 0; i < data_length; i++) {
    p_data[i] = ((const int8_t *)raw_buffer)[i];
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_string(SEXP input, SEXP _n_bytes) {

  const int n_bytes = INTEGER(_n_bytes)[0];
  const R_xlen_t length = xlength(input);
  const char* raw_buffer = (const char *)RAW(input);

  const R_xlen_t data_length = length / n_bytes;
  R_xlen_t i;
  SEXP data;

  data = PROTECT(allocVector(STRSXP, data_length));

  for (i = 0; i < data_length; i++) {
    const char *field = raw_buffer + i * n_bytes;
    // Check for R's NA_integer_ sentinel written by writeBin(NA_integer_, raw()).
    // Using memcpy + NA_INTEGER comparison is endian-agnostic.
    if (n_bytes >= 4) {
      int sentinel;
      memcpy(&sentinel, field, 4);
      if (sentinel == NA_INTEGER) {
        SET_STRING_ELT(data, i, NA_STRING);
        continue;
      }
    }
    const size_t len = strlen(field);
    // Read up to max length or NUL terminator.
    // We cannot do one without the other as strings may not be NUL terminated (truncated) and
    // mkCharLenCE complains about NUL characters in the string.
    if (len > (size_t)n_bytes)
      SET_STRING_ELT(data, i, mkCharLenCE(field, n_bytes, CE_NATIVE));
    else
      SET_STRING_ELT(data, i, mkCharCE(field, CE_NATIVE));
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_unicode(SEXP input, SEXP _n_bytes, SEXP _endian) {

  // n_bytes is the total bytes per string element (num_codepoints * 4).
  // Bytes are passed as-is from the file; we select UTF-32LE or UTF-32BE
  // based on the file's endianness so no R-side byte-swapping is needed.
  const size_t n_bytes = (size_t)INTEGER(_n_bytes)[0];
  const R_xlen_t length = xlength(input);
  const char *raw_buffer = (const char *)RAW(input);

  const R_xlen_t data_length = length / n_bytes;
  R_xlen_t i;
  SEXP data;

  const char *endian = CHAR(STRING_ELT(_endian, 0));
  const char *utf32_enc = (strcmp(endian, "big") == 0) ? "UTF-32BE" : "UTF-32LE";

  // Worst case: 4 UTF-8 bytes per UTF-32 codepoint.
  char *utf8_buf = (char *)R_alloc(n_bytes + 1, 1);

  void *cd = Riconv_open("UTF-8", utf32_enc);
  if (cd == (void *)-1)
    error("Riconv_open failed: cannot convert UTF-32LE to UTF-8");

  data = PROTECT(allocVector(STRSXP, data_length));

  for (i = 0; i < data_length; i++) {
    const char *inbuf = raw_buffer + i * n_bytes;
    // Check for R's NA_integer_ sentinel.
    if (n_bytes >= 4) {
      int sentinel;
      memcpy(&sentinel, inbuf, 4);
      if (sentinel == NA_INTEGER) {
        SET_STRING_ELT(data, i, NA_STRING);
        continue;
      }
    }

    // Find the actual length: stop at the first null codepoint (4 zero bytes),
    // or at n_bytes if there is no null terminator.
    // This allows us to handle both fixed-length and null-terminated strings.
    size_t field_bytes = 0;
    while (field_bytes + 4 <= n_bytes) {
      uint32_t cp;
      memcpy(&cp, inbuf + field_bytes, 4);
      if (cp == 0) break;
      field_bytes += 4;
    }

    size_t inbytesleft = field_bytes;
    size_t outbytesleft = n_bytes; // safe upper bound
    char *outbuf = utf8_buf;

    Riconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
    *outbuf = '\0';

    SET_STRING_ELT(data, i, mkCharCE(utf8_buf, CE_UTF8));
  }
  Riconv_close(cd);

  UNPROTECT(1);
  return(data);
}