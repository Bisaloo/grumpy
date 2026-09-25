# Read a `.npz` file

Read a `.npz` file

## Usage

``` r
read_npz(file, arrays = NULL)
```

## Arguments

- file:

  Path to the `.npz` file

- arrays:

  Optional character vector of array names or numeric vector of indices
  to read from the `.npz` file. If `NULL` (the default), all arrays are
  read.

## Value

A named list of arrays containing the data from the `.npz` file

## Examples

``` r
read_npz(
  system.file("extdata", "test.npz", package = "grumpy")
)
#> $x
#> [1] 1 2 3
#> 
#> $y
#> [1] 4 5 6
#> 

read_npz(
  system.file("extdata", "test.npz", package = "grumpy"),
  arrays = "x"
)
#> $x
#> [1] 1 2 3
#> 
```
