#include "grumpy.h"

#include "bit64_conversion.h"
#include "float16_conversion.h"

SEXP type_convert(SEXP input, SEXP what, SEXP _n_bytes, SEXP dims, SEXP _endian);
SEXP type_convert_int(const void* raw_buffer, R_xlen_t buf_len, int type_len);
SEXP type_convert_uint(const void* raw_buffer, R_xlen_t buf_len, int type_len);
SEXP type_convert_float(const void* raw_buffer, R_xlen_t buf_len, int type_len);
SEXP type_convert_bool(const void* raw_buffer, R_xlen_t buf_len, int type_len);
SEXP type_convert_string(const char* raw_buffer, R_xlen_t buf_len, int type_len);
SEXP type_convert_unicode(const char* raw_buffer, R_xlen_t buf_len, int type_len, SEXP _endian);
