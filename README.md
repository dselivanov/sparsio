## sparsio

**sparsio** is an R package for **I/O** operations with sparse matrices. At the moment it provides **fast** `svmlight` reader and writer.

* `read_svmlight()`
* `write_svmlight()`

**The only dependency is `Rcpp`**

Package is not on CRAN yet, so you can install it with `devtools`:
```r
devtools::install_github("dselivanov/sparsio")
```

## Quick reference

```r
library(Matrix)
library(sparsio)
i = 1:8
j = 1:8
v = rep(2, 8)
x = sparseMatrix(i, j, x = v)
y = sample(c(0, 1), nrow(x), replace = TRUE)
f = tempfile(fileext = ".svmlight")
write_svmlight(x, y, f)
x2 = read_svmlight(f, type = "CsparseMatrix")
identical(x2$x, x)
identical(x2$y, y)
```