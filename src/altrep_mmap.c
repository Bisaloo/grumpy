#include "altrep_mmap.h"

#include <R_ext/Altrep.h>
#include <string.h>

// FIXME: we only support POSIX mmap() for now.
// Windows has a different API (CreateFileMapping / MapViewOfFile) and would 
// require a separate implementation.
#ifndef _WIN32
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>
#define GRUMPY_HAVE_MMAP 1
#endif

// ALTREP raw vector backed by a read-only mmap() of a slice of a file.
//
// Having a file-backed, lazy read of raw data is useful in the cases when
// we don't need to do anything transformation (e.g., int32).
//
// It could also be helpful in the future if we ever implement an `index`
// argument to `read_npy()` that allows reading a subset of the data. 

typedef struct {
  void *addr;      // mmap base address (page-aligned)
  size_t map_len;  // bytes mapped (offset rounded down + length)
  size_t skip;     // bytes to skip within the mapping to reach the logical start
  R_xlen_t length; // logical length exposed to R
} grumpy_mmap_info;

static R_altrep_class_t grumpy_mmap_raw_class;

static void grumpy_mmap_xptr_finalize(SEXP xp) {
  grumpy_mmap_info *info = (grumpy_mmap_info *) R_ExternalPtrAddr(xp);
  if (info == NULL) return;
#ifdef GRUMPY_HAVE_MMAP
  if (info->addr != NULL && info->addr != MAP_FAILED) {
    munmap(info->addr, info->map_len);
  }
#endif
  free(info);
  R_ClearExternalPtr(xp);
}

static R_xlen_t grumpy_mmap_length(SEXP x) {
  const grumpy_mmap_info *info = (grumpy_mmap_info *) R_ExternalPtrAddr(R_altrep_data1(x));
  return info->length;
}

static void *grumpy_mmap_dataptr(SEXP x, Rboolean writeable) {
  const grumpy_mmap_info *info = (grumpy_mmap_info *) R_ExternalPtrAddr(R_altrep_data1(x));
  return (char *) info->addr + info->skip;
}

static const void *grumpy_mmap_dataptr_or_null(SEXP x) {
  return grumpy_mmap_dataptr(x, FALSE);
}

static Rbyte grumpy_mmap_elt(SEXP x, R_xlen_t i) {
  const Rbyte *p = (const Rbyte *) grumpy_mmap_dataptr_or_null(x);
  return p[i];
}

static R_xlen_t grumpy_mmap_get_region(SEXP x, R_xlen_t start, R_xlen_t n, Rbyte *buf) {
  const Rbyte *p = (const Rbyte *) grumpy_mmap_dataptr_or_null(x);
  R_xlen_t len = grumpy_mmap_length(x);
  R_xlen_t ncopy = (start + n > len) ? (len - start) : n;
  memcpy(buf, p + start, ncopy);
  return ncopy;
}

void grumpy_init_mmap_altrep(DllInfo *info) {
  grumpy_mmap_raw_class = R_make_altraw_class("grumpy_mmap_raw", "grumpy", info);

  R_set_altrep_Length_method(grumpy_mmap_raw_class, grumpy_mmap_length);
  R_set_altvec_Dataptr_method(grumpy_mmap_raw_class, grumpy_mmap_dataptr);
  R_set_altvec_Dataptr_or_null_method(grumpy_mmap_raw_class, grumpy_mmap_dataptr_or_null);
  R_set_altraw_Elt_method(grumpy_mmap_raw_class, grumpy_mmap_elt);
  R_set_altraw_Get_region_method(grumpy_mmap_raw_class, grumpy_mmap_get_region);
}

SEXP grumpy_make_mmap_raw(SEXP path_, SEXP offset_, SEXP length_) {
#ifndef GRUMPY_HAVE_MMAP
  error("mmap-backed reading is not supported on this platform");
#else
  const char *path = CHAR(STRING_ELT(path_, 0));
  double offset = REAL(offset_)[0];
  double length = REAL(length_)[0];

  if (offset < 0 || length < 0)
    error("offset and length must be non-negative");

  int fd = open(path, O_RDONLY);
  if (fd < 0)
    error("Cannot open file for mmap: %s", path);

  long page_size = sysconf(_SC_PAGE_SIZE);
  size_t page_offset = ((size_t) offset) % page_size;
  off_t map_start = (off_t) offset - (off_t) page_offset;
  size_t map_len = (size_t) length + page_offset;

  void *addr = mmap(NULL, map_len, PROT_READ, MAP_PRIVATE, fd, map_start);
  // The fd is not needed once mapped.
  close(fd);

  if (addr == MAP_FAILED)
    error("mmap() failed for file: %s", path);

  grumpy_mmap_info *map_info = malloc(sizeof(grumpy_mmap_info));
  if (map_info == NULL) {
    munmap(addr, map_len);
    error("Failed to allocate mmap bookkeeping struct");
  }
  map_info->addr = addr;
  map_info->map_len = map_len;
  map_info->skip = page_offset;
  map_info->length = (R_xlen_t) length;

  SEXP xp = PROTECT(R_MakeExternalPtr(map_info, R_NilValue, R_NilValue));
  R_RegisterCFinalizerEx(xp, grumpy_mmap_xptr_finalize, TRUE);
  SEXP ans = PROTECT(R_new_altrep(grumpy_mmap_raw_class, xp, R_NilValue));
  UNPROTECT(2);

  return ans;
#endif /* GRUMPY_HAVE_MMAP */
}
