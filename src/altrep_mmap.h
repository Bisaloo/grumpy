#ifndef _GRUMPY_ALTREP_MMAP_H
#define _GRUMPY_ALTREP_MMAP_H

#include "grumpy.h"

// Create an ALTREP raw vector backed by a read-only mmap() of `path`,
// exposing `length` bytes starting at file offset `offset`.
SEXP grumpy_make_mmap_raw(SEXP path, SEXP offset, SEXP length);

// Register the ALTREP class and its methods. Called from R_init_grumpy().
void grumpy_init_mmap_altrep(DllInfo *info);

#endif /* _GRUMPY_ALTREP_MMAP_H */
