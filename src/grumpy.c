#include "grumpy.h"
#include "type_conversion.h"

static const R_CallMethodDef callMethods[] = {
  {"type_convert", (DL_FUNC) &type_convert, 5},
  {NULL, NULL, 0}
};

void R_init_grumpy(DllInfo *info)
{
  R_registerRoutines(info, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(info, FALSE);
  R_forceSymbols(info, TRUE);
}
