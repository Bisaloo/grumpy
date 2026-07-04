#include "bit64_conversion.h"


void uint32_to_int32(const void* in_buf, size_t n, void* out_buf) {
  
  R_xlen_t i;
  R_xlen_t n_overflow = 0;

  for (i = 0; i < n; i++) {
    if (((uint32_t *)in_buf)[i] > INT_MAX) {
      ((int32_t *)out_buf)[i] = INT_MIN;
      n_overflow++;
    } else {
      ((int32_t *)out_buf)[i] = ((uint32_t *)in_buf)[i];
    }
  }

  if (n_overflow > 0) {
    Rf_warning(
      "Integer overflow on %zu elements: converting 32bit unsigned integer to 32bit signed integer resulted in NA values", 
      n_overflow
    );
  }
  
}

void int64_to_int32(const void* in_buf, size_t n, void* out_buf, bool is_signed) {
  
  R_xlen_t i;
  R_xlen_t n_overflow = 0;
  R_xlen_t n_underflow = 0;
  
  if (is_signed) {
    for (i=0; i<n; i++) {
      if (((int64_t *)in_buf)[i] > INT_MAX) {
        ((int32_t *)out_buf)[i] = INT_MIN;
        n_overflow++;
      }
      else if (((int64_t *)in_buf)[i] < INT_MIN) {
        ((int32_t *)out_buf)[i] = INT_MIN;
        n_underflow++;
      } else {
        ((int32_t *)out_buf)[i] = ((int64_t *)in_buf)[i];
      }
    }
  } else {
    for (i=0; i<n; i++) {
      if (((uint64_t *)in_buf)[i] > INT_MAX) {
        ((int32_t *)out_buf)[i] = INT_MIN;
        n_overflow++;
      } else {
        ((int *)out_buf)[i] = ((uint64_t *)in_buf)[i];
      }
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
