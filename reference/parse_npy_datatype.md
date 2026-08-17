# Parse a NumPy Array-protocol type strings

Parse a NumPy Array-protocol type strings

## Usage

``` r
parse_npy_datatype(descr)
```

## Arguments

- descr:

  A NumPy dtype description string, or a list of such strings for
  structured dtypes

## Value

A list containing the parsed data type information, including the base
type, the number of bytes, and the endianness

## Details

If a `list` is passed to `descr`, each element can be of length 1, or of
length 2 in which case the first element corresponds to the name of the
field and the second to its dtype.

## Examples

``` r
parse_npy_datatype(">i8")
#> $base_type
#> [1] "int"
#> 
#> $nbytes
#> [1] 8
#> 
#> $endian
#> [1] "big"
#> 
parse_npy_datatype("|b1")
#> $base_type
#> [1] "bool"
#> 
#> $nbytes
#> [1] 1
#> 
#> $endian
#> [1] NA
#> 
# A structured datatype where each element has 3 components, all integers,
# named "r", "g" and "b".
parse_npy_datatype(list(c("r", "<i8"), c("g", "<i8"), c("b", "<i8")))
#> $base_type
#> [1] "int" "int" "int"
#> 
#> $nbytes
#> [1] 8 8 8
#> 
#> $endian
#> [1] "little" "little" "little"
#> 
```
