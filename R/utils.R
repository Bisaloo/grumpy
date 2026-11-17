int32_to_uint32 <- function(int32) {
  int32 + (int32 < 0L) * (2^32)
}
