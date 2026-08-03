#include "grumpy.h"

static inline void uint32_to_int32(const void* restrict in_buf, size_t n, void* restrict out_buf) {

  const uint32_t* restrict in = (const uint32_t *)in_buf;
  int32_t* restrict out = (int32_t *)out_buf;
  R_xlen_t i;

  // This needs to be done in two passes to allow for auto-vectorization of the conversion loop by
  // the compiler.
  for (i = 0; i < n; i++) {
    out[i] = (in[i] > INT_MAX) ? INT_MIN : (int32_t)in[i];
  }

  R_xlen_t n_overflow = 0;
  for (i = 0; i < n; i++) {
    n_overflow += (in[i] > INT_MAX);
  }

  if (n_overflow > 0) {
    Rf_warning(
      "Integer overflow on %zu elements: converting 32bit unsigned integer to 32bit signed integer resulted in NA values", 
      n_overflow
    );
  }
  
}

static inline void int64_to_int32(const void* restrict in_buf, size_t n, void* restrict out_buf) {

  const int64_t* restrict in = (const int64_t *)in_buf;
  int32_t* restrict out = (int32_t *)out_buf;
  R_xlen_t i;

  // This needs to be done in two passes to allow for auto-vectorization of the conversion loop by
  // the compiler.
  for (i = 0; i < n; i++) {
    out[i] = (in[i] > INT_MAX || in[i] < INT_MIN) ? INT_MIN : (int32_t)in[i];
  }
  
  R_xlen_t n_overflow = 0;
  R_xlen_t n_underflow = 0;
  for (i = 0; i < n; i++) {
    n_overflow += (in[i] > INT_MAX);
    n_underflow += (in[i] < INT_MIN);
  }

  if (n_overflow > 0) {
    Rf_warning(
      "Integer overflow on %zu elements: converting 64bit integer to 32bit integer resulted in NA values", 
      n_overflow
    );
  }
  if (n_underflow > 0) {
    Rf_warning(
      "Integer underflow on %zu elements: converting 64bit integer to 32bit integer resulted in NA values",
      n_underflow
    );
  }

}

static inline void uint64_to_int32(const void* restrict in_buf, size_t n, void* restrict out_buf) {

  const uint64_t* restrict in = (const uint64_t *)in_buf;
  int32_t* restrict out = (int32_t *)out_buf;
  R_xlen_t i;

  // This needs to be done in two passes to allow for auto-vectorization of the conversion loop by
  // the compiler.
  for (i = 0; i < n; i++) {
    out[i] = (in[i] > INT_MAX) ? INT_MIN : (int32_t)in[i];
  }

  R_xlen_t n_overflow = 0;
  for (i = 0; i < n; i++) {
    n_overflow += (in[i] > INT_MAX);
  }

  if (n_overflow > 0) {
    Rf_warning(
      "Integer overflow on %zu elements: converting 64bit unsigned integer to 32bit signed integer resulted in NA values", 
      n_overflow
    );
  }

}
