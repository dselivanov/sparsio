## sparsio

**sparsio** is a small (the only dependency is `Rcpp`) R package for **spars**e matrices **I**nput/**O**utput. It provides **fast** `svmlight` reader and writer.

* `read_svmlight()`
* `write_svmlight()`

## Quick reference

```r
library(Matrix)
library(sparsio)
N = 1e8
i = sample(1e5, N, T)
j = sample(1e5, N, T)
vals = runif(N)
x = sparseMatrix(i, j, x = vals)
print(object.size(x), units = "Gb")
# 1.1 Gb

y = sample(c(0, 1), nrow(x), replace = TRUE)
f = tempfile(fileext = ".svmlight")
system.time(write_svmlight(x, y, f))
# user  system elapsed 
# 68.014   2.785  70.899

file.size(f)/1e9
# 1.48135 Gb

system.time(x2 <- read_svmlight(f, type = "CsparseMatrix"))
# user  system elapsed 
# 55.021   2.803  57.892

all.equal(x2$x, x)
# "Mean relative difference: 4.636406e-07"
all.equal(x2$y, y)
# TRUE
```