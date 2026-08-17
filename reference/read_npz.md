# Read a `.npz` file

Read a `.npz` file

## Usage

``` r
read_npz(file)
```

## Arguments

- file:

  Path to the `.npz` file

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
```
