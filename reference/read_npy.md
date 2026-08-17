# Read a `.npy` file

Read a `.npy` file

## Usage

``` r
read_npy(file, ...)
```

## Arguments

- file:

  Path to the `.npy` file

- ...:

  Ignored. Reserved for future use.

## Value

An array containing the data from the `.npy` file

## Examples

``` r
# Array of integers. NumPy "<i4" dtype
read_npy(
  system.file("extdata", "test_int32.npy", package = "grumpy")
)
#>  [1]  1  2  3  4  5  6  7  8  9 10 11 12

# Array of logicals. NumPy "|b1" dtype
read_npy(
  system.file("extdata", "test_bool.npy", package = "grumpy")
)
#>  [1]  TRUE FALSE  TRUE  TRUE FALSE FALSE  TRUE FALSE  TRUE  TRUE FALSE  TRUE

# Array of numerics. NumPy "<f8" dtype
read_npy(
  system.file("extdata", "test_float64.npy", package = "grumpy")
)
#>  [1]  1.500000e+00 -2.500000e+00  3.140000e+00  0.000000e+00 -1.000000e+00
#>  [6]  1.000000e+02 -1.000000e+02  1.000000e-03  1.000000e+06 -1.000000e+06
#> [11]  1.234568e+00 -9.876543e+00

# Array of strings. NumPy "<U" dtype
read_npy(
  system.file("extdata", "test_str_unicode.npy", package = "grumpy")
)
#>  [1] "¡Hola mundo!"      "Hej Världen!"      "Servus Woid!"     
#>  [4] "Hei maailma!"      "Xin chào thế giới" "Njatjeta Botë!"   
#>  [7] "Γεια σου κόσμε!"   "こんにちは世界"    "世界，你好！"     
#> [10] "Helló, világ!"     "Zdravo svete!"     "เฮลโลเวิลด์"        

# "Array" of lists. Numpy structured dtype
read_npy(
  system.file("extdata", "test_structured.npy", package = "grumpy")
)
#>      [,1]   [,2]   [,3]   [,4]  
#> [1,] list,3 list,3 list,3 list,3
#> [2,] list,3 list,3 list,3 list,3
```
