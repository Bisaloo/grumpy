#include "type_conversion.h"
#include <R_ext/Riconv.h>
#include <float.h>
#define R_DBL_EXACT_INT_MAX ((double)(1LL << DBL_MANT_DIG))  /* 2^53 */

SEXP type_convert(SEXP input, SEXP what, SEXP _n_bytes, SEXP dims, SEXP _endian) {
  const char *type = CHAR(STRING_ELT(what, 0));
  SEXP result;

  const int type_len = INTEGER(_n_bytes)[0];
  const R_xlen_t buf_len = xlength(input);
  const void* raw_buffer = RAW_RO(input);

  if (strcmp(type, "float") == 0)
    result = type_convert_float(raw_buffer, buf_len, type_len);
  else if (strcmp(type, "int") == 0)
    result = type_convert_int(raw_buffer, buf_len, type_len);
  else if (strcmp(type, "uint") == 0)
    result = type_convert_uint(raw_buffer, buf_len, type_len);
  else if (strcmp(type, "bool") == 0)
    result = type_convert_bool(raw_buffer, buf_len, type_len);
  else if (strcmp(type, "string") == 0)
    result = type_convert_string((const char*)raw_buffer, buf_len, type_len);
  else if (strcmp(type, "unicode") == 0)
    result = type_convert_unicode((const char*)raw_buffer, buf_len, type_len, _endian);
  else
    error("Unsupported data type: %s", type);

  PROTECT(result);
  if (!isNull(dims) && xlength(dims) > 0) {
    Rf_dimgets(result, dims);
  }
  UNPROTECT(1);

  return result;
}

SEXP type_convert_int(const void* raw_buffer, R_xlen_t buf_len, int type_len) {

  SEXP data;
  const R_xlen_t data_length = buf_len / type_len;
  R_xlen_t i;

  if (type_len == 1) {
    data = PROTECT(allocVector(INTSXP, data_length));
    int *p_data = INTEGER(data);
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const int8_t *)raw_buffer)[i];
    }
  } else if (type_len == 2) {
    data = PROTECT(allocVector(INTSXP, data_length));
    int *p_data = INTEGER(data);
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const int16_t *)raw_buffer)[i];
    }
  } else if (type_len == 4) {
    data = PROTECT(allocVector(INTSXP, data_length));
    int *p_data = INTEGER(data);
    memcpy(p_data, raw_buffer, buf_len);
    UNPROTECT(1);
    return(data);
  } else if (type_len == 8) {
    bool out_of_range = false;
    for (i = 0; i < data_length; i++) {
      if (((const int64_t *)raw_buffer)[i] > INT_MAX || ((const int64_t *)raw_buffer)[i] < INT_MIN) {
        out_of_range = true;
        break;
      }
    }
    if (out_of_range) {
      data = PROTECT(allocVector(REALSXP, data_length));
      double *p_data = REAL(data);
      for (i = 0; i < data_length; i++) {
        p_data[i] = (double)((const int64_t *)raw_buffer)[i];
      }
    } else {
      data = PROTECT(allocVector(INTSXP, data_length));
      int *p_data = INTEGER(data);
      for (i = 0; i < data_length; i++) {
        p_data[i] = ((const int64_t *)raw_buffer)[i];
      }
    }
  } else {
    Rf_error("%d byte signed integer values are not currently supported\n", type_len);
  }
  UNPROTECT(1);
  return(data);
}

SEXP type_convert_uint(const void* raw_buffer, R_xlen_t buf_len, int type_len) {

  SEXP data;
  const R_xlen_t data_length = buf_len / type_len;
  R_xlen_t i;

  if (type_len == 1) {
    data = PROTECT(allocVector(INTSXP, data_length));
    int *p_data = INTEGER(data);
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const uint8_t *)raw_buffer)[i];
    }
    UNPROTECT(1);
    return(data);
  } else if (type_len == 2) {
    data = PROTECT(allocVector(INTSXP, data_length));
    int *p_data = INTEGER(data);
    for (i = 0; i < data_length; i++) {
      p_data[i] = ((const uint16_t *)raw_buffer)[i];
    }
  } else if (type_len == 4) {
    bool out_of_range = false;
    for (i = 0; i < data_length; i++) {
      if (((const uint32_t *)raw_buffer)[i] > INT_MAX) {
        out_of_range = true;
        break;
      }
    }
    if (out_of_range) {
      // We follow base R's convention of converting out-of-range integers to double silently
      data = PROTECT(allocVector(REALSXP, data_length));
      double *p_data = REAL(data);
      for (i = 0; i < data_length; i++) {
        p_data[i] = (double)((const uint32_t *)raw_buffer)[i];
      }
    } else {
      data = PROTECT(allocVector(INTSXP, data_length));
      int *p_data = INTEGER(data);
      for (i = 0; i < data_length; i++) {
        p_data[i] = ((const uint32_t *)raw_buffer)[i];
      }
    }
  } else if (type_len == 8) {
    bool out_of_range = false;
    for (i = 0; i < data_length; i++) {
      if (((const uint64_t *)raw_buffer)[i] > INT_MAX) {
        out_of_range = true;
        break;
      }
    }
    if (out_of_range) {
      data = PROTECT(allocVector(REALSXP, data_length));
      double *p_data = REAL(data);
      for (i = 0; i < data_length; i++) {
        p_data[i] = (double)((const uint64_t *)raw_buffer)[i];
      }
      int n_inexact = 0;
      for (i = 0; i < data_length; i++) {
        if (p_data[i] > R_DBL_EXACT_INT_MAX) {
          n_inexact++;
        }
      }
      if (n_inexact > 0) {
        Rf_warning("%i values exceed 2^53 and may not be represented exactly as doubles", n_inexact);
      }
    } else {
      data = PROTECT(allocVector(INTSXP, data_length));
      int *p_data = INTEGER(data);
      for (i = 0; i < data_length; i++) {
        p_data[i] = ((const uint64_t *)raw_buffer)[i];
      }
    }
  } else {
    Rf_error("%d byte unsigned integer values are not currently supported\n", type_len);
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_float(const void* raw_buffer, R_xlen_t buf_len, int type_len) {

  double *p_data;
  SEXP data;
  const R_xlen_t data_length = buf_len / type_len;
  R_xlen_t i;

  data = PROTECT(allocVector(REALSXP, data_length));
  p_data = REAL(data);

  if(type_len == 2) {
    const uint16_t *mock_buffer = (const uint16_t *)raw_buffer;
    for (i = 0; i < data_length; i++) {
      p_data[i] = (double)float16_to_float64(mock_buffer[i]);
    }
  } else if(type_len == 4) {
    for (i = 0; i < data_length; i++) {
      p_data[i] = (double)((const float *)raw_buffer)[i];
    }
  } else if (type_len == 8) {
    memcpy(p_data, raw_buffer, buf_len);
  } else {
    error("%d byte floating point values are not currently supported\n", type_len);
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_bool(const void* raw_buffer, R_xlen_t buf_len, int type_len) {

  int *p_data;
  SEXP data;
  const R_xlen_t data_length = buf_len / type_len;
  R_xlen_t i;

  data = PROTECT(allocVector(LGLSXP, data_length));
  p_data = LOGICAL(data);

  for (i = 0; i < data_length; i++) {
    p_data[i] = ((const int8_t *)raw_buffer)[i];
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_string(const char* raw_buffer, R_xlen_t buf_len, int type_len) {

  const R_xlen_t data_length = buf_len / type_len;
  R_xlen_t i;
  SEXP data;

  data = PROTECT(allocVector(STRSXP, data_length));

  for (i = 0; i < data_length; i++) {
    const char *field = raw_buffer + i * type_len;
    const size_t len = strlen(field);
    // Read up to max length or NUL terminator.
    // We cannot do one without the other as strings may not be NUL terminated (truncated) and
    // mkCharLenCE complains about NUL characters in the string.
    if (len > (size_t)type_len)
      SET_STRING_ELT(data, i, mkCharLenCE(field, type_len, CE_NATIVE));
    else
      SET_STRING_ELT(data, i, mkCharCE(field, CE_NATIVE));
  }

  UNPROTECT(1);
  return(data);
}

SEXP type_convert_unicode(const char* raw_buffer, R_xlen_t buf_len, int type_len, SEXP _endian) {

  // n_bytes is the total bytes per string element (num_codepoints * 4).
  // Bytes are passed as-is from the file; we select UTF-32LE or UTF-32BE
  // based on the file's endianness so no R-side byte-swapping is needed.
  const R_xlen_t data_length = buf_len / type_len;
  R_xlen_t i;
  SEXP data;

  const char *endian = CHAR(STRING_ELT(_endian, 0));
  const char *utf32_enc = (strcmp(endian, "big") == 0) ? "UTF-32BE" : "UTF-32LE";

  // Worst case: 4 UTF-8 bytes per UTF-32 codepoint.
  char *utf8_buf = (char *)R_alloc(type_len + 1, 1);

  void *cd = Riconv_open("UTF-8", utf32_enc);
  if (cd == (void *)-1)
    error("Riconv_open failed: cannot convert UTF-32LE to UTF-8");

  data = PROTECT(allocVector(STRSXP, data_length));

  for (i = 0; i < data_length; i++) {
    const char *inbuf = raw_buffer + i * type_len;

    // Find the actual length: stop at the first null codepoint (4 zero bytes),
    // or at type_len if there is no null terminator.
    // This allows us to handle both fixed-length and null-terminated strings.
    size_t field_bytes = 0;
    while (field_bytes + 4 <= type_len) {
      uint32_t cp;
      memcpy(&cp, inbuf + field_bytes, 4);
      if (cp == 0) break;
      field_bytes += 4;
    }

    size_t inbytesleft = field_bytes;
    size_t outbytesleft = type_len; // safe upper bound
    char *outbuf = utf8_buf;

    Riconv(cd, &inbuf, &inbytesleft, &outbuf, &outbytesleft);
    *outbuf = '\0';

    SET_STRING_ELT(data, i, mkCharCE(utf8_buf, CE_UTF8));
  }
  Riconv_close(cd);

  UNPROTECT(1);
  return(data);
}