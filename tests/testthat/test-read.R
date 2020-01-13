context("read")
n_rows = nrow(readLines("test.svmlight"))
  
test_that("read basic", {
  m = read_svmlight("test.svmlight")
  expect_equal(names(m), c("x", "y"))
  expect_equal(nrow(m), n_rows)
})

test_that("read different formats", {
  formats = c("CsparseMatrix", "RsparseMatrix", "TsparseMatrix")
  for (f in formats) {
    m = read_svmlight("test.svmlight", type = f)
    expect_true(inherits(m$x, f))
  }
})

test_that("read file with empty rows", {
  ln = readLines("test-empty-rows.svmlight")
  # find max col
  all_vals = strsplit(ln, " ", fixed = T)
  all_vals = all_vals[grepl(":", all_vals)]
  all_vals = unlist(all_vals, recursive = F, use.names = F)
  all_vals = strsplit(all_vals, ":", fixed = T)
  all_vals = unlist(all_vals, recursive = F, use.names = F)
  # +1 because of 0-based indexing
  n_col_true = max(as.numeric(all_vals)) + 1
  
  n_row_true = length(ln)
  m = read_svmlight("test-empty-rows.svmlight", type = "RsparseMatrix")
  expect_equal(dim(m$x)[1], n_row_true)
  expect_equal(dim(m$x)[2], n_col_true)
})
