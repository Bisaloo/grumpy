#include "grumpy.h"
#include "type_conversion.h"

static const R_CallMethodDef callMethods[] = {
  {"type_convert_int", (DL_FUNC) &type_convert_int, 2},
  {"type_convert_uint", (DL_FUNC) &type_convert_uint, 2},
  {"type_convert_float", (DL_FUNC) &type_convert_float, 2},
  {"type_convert_bool", (DL_FUNC) &type_convert_bool, 2},
  {"type_convert_string", (DL_FUNC) &type_convert_string, 2},
  {"type_convert_unicode", (DL_FUNC) &type_convert_unicode, 2},
  {NULL, NULL, 0}
};

void R_init_grumpy(DllInfo *info)
{
  R_registerRoutines(info, NULL, callMethods, NULL, NULL);
  R_useDynamicSymbols(info, TRUE);
}
