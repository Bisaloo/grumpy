#include "bit64_conversion.h"


void uint32_to_int32(const void* restrict in_buf, size_t n, void* restrict out_buf) {

  const uint32_t* restrict in = (const uint32_t *)in_buf;
  int32_t* restrict out = (int32_t *)out_buf;
  R_xlen_t i;
  R_xlen_t n_overflow = 0;

  for (i = 0; i < n; i++) {
    if (in[i] > INT_MAX) {
      out[i] = INT_MIN; // NA
      n_overflow++;
    } else {
      out[i] = in[i];
    }
  }

  if (n_overflow > 0) {
    Rf_warning(
      "Integer overflow on %zu elements: converting 32bit unsigned integer to 32bit signed integer resulted in NA values", 
      n_overflow
    );
  }
  
}

void int64_to_int32(const void* restrict in_buf, size_t n, void* restrict out_buf) {

  int32_t* restrict out = (int32_t *)out_buf;
  R_xlen_t i;
  R_xlen_t n_overflow = 0;
  R_xlen_t n_underflow = 0;

  const int64_t* restrict in = (const int64_t *)in_buf;
  for (i=0; i<n; i++) {
    if (in[i] > INT_MAX) {
      out[i] = INT_MIN; // NA
      n_overflow++;
    }
    else if (in[i] < INT_MIN) {
      out[i] = INT_MIN; // NA
      n_underflow++;
    } else {
      out[i] = in[i];
    }
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

void uint64_to_int32(const void* restrict in_buf, size_t n, void* restrict out_buf) {

  const uint64_t* restrict in = (const uint64_t *)in_buf;
  int32_t* restrict out = (int32_t *)out_buf;
  R_xlen_t i;
  R_xlen_t n_overflow = 0;

  for (i=0; i<n; i++) {
    if (in[i] > INT_MAX) {
      out[i] = INT_MIN; // NA
      n_overflow++;
    } else {
      out[i] = in[i];
    }
  }

  if (n_overflow > 0) {
    Rf_warning(
      "Integer overflow on %zu elements: converting 64bit unsigned integer to 32bit signed integer resulted in NA values", 
      n_overflow
    );
  }
  
}
