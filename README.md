

<!-- README.md is generated from README.qmd. Please edit that file -->

# grumpy

<!-- badges: start -->

<!-- badges: end -->

The grumpy R package provides a way to read NumPy’s `.npy` files into R.
It supports a wide range of data types and array shapes.

## Installation

You can install the development version of grumpy like so:

``` r
# install.packages("pak")
pak::pak("Bisaloo/grumpy")
```

## Example

``` r
library(grumpy)
read_npy(system.file("extdata", "test_2d.npy", package = "grumpy"))
#>      [,1] [,2] [,3]
#> [1,]    0    2    4
#> [2,]    1    3    5
```
