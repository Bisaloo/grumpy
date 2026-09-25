library(ps)
library(callr)

poll_peak_rss <- function(expr, interval_ms = 5) {
  pid <- Sys.getpid()
  stop_file <- tempfile()

  poller <- r_bg(
    func = function(pid, interval_ms, stop_file) {
      p <- ps::ps_handle(pid)
      peak <- 0
      repeat {
        if (file.exists(stop_file)) {
          break
        }
        rss <- tryCatch(
          ps::ps_memory_info(p)[["rss"]],
          error = function(e) NA_real_
        )
        if (is.na(rss)) {
          break
        }
        if (rss > peak) {
          peak <- rss
        }
        Sys.sleep(interval_ms / 1000)
      }
      peak
    },
    args = list(pid = pid, interval_ms = interval_ms, stop_file = stop_file)
  )

  Sys.sleep(0.05) # let poller start

  gc(verbose = FALSE)
  eval(substitute(expr), envir = parent.frame())
  gc(verbose = FALSE)

  Sys.sleep(0.05) # let poller record post-gc RSS
  writeLines("", stop_file) # signal poller to exit
  poller$wait() # wait for clean exit
  on.exit(unlink(stop_file), add = TRUE)

  poller$get_result()
}

# ---- run it -----------------------------------------------------------------

np <- reticulate::import("numpy")
f <- system.file("extdata", "test_large.npy", package = "grumpy")

baseline <- ps_memory_info()[["rss"]]
peak_grumpy <- poll_peak_rss(grumpy::read_npy(f))
peak_lazy_grumpy <- poll_peak_rss(grumpy::read_npy(f, lazy = TRUE))
peak_numpy <- poll_peak_rss(np$load(f))

cat(sprintf("baseline    RSS: %.1f MB\n", baseline / 1e6))
cat(sprintf("grumpy peak RSS: %.1f MB\n", peak_grumpy / 1e6))
cat(sprintf("grumpy lazy peak RSS: %.1f MB\n", peak_lazy_grumpy / 1e6))
cat(sprintf("numpy  peak RSS: %.1f MB\n", peak_numpy / 1e6))
cat(sprintf("grumpy increment: %.1f MB\n", (peak_grumpy - baseline) / 1e6))
cat(sprintf(
  "grumpy lazy increment: %.1f MB\n",
  (peak_lazy_grumpy - baseline) / 1e6
))
cat(sprintf("numpy  increment: %.1f MB\n", (peak_numpy - baseline) / 1e6))
