#' @useDynLib sparsio
#' @import Matrix
#' @import Rcpp
#' @import methods
#' 
#' @name svmlight
#' @title Fast svmlight reader and writer
#' @description Reads and writes svmlight files.
#' @param x input sparse matrix. Should inherit from \code{Matrix::sparseMatrix}.
#' @param y target values. Labels must be an integer or numeric of the same length as number of rows in \code{x}.
#' @param file string, path to svmlight file
#' @param type target class for sparse matrix. \code{CsparseMatrix} is default value because it 
#' is main in R's \code{Matrix} package. However internally matrix first read into \code{RsparseMatrix} 
#' and then coerced with \code{as()} to target type.
#' This is because \code{smvlight} format is essentially equal to \code{CSR} sparse matrix format.
#' @param zero_based \code{logical}, whether column indices in file are 0-based (\code{TRUE}) or 1-based (\code{FALSE}).
#' @param ncol number of columns in target matrix. \code{NULL} means that number of columns will be determined 
#' from file (as a maximum index). However it is possible that user expects matrix with a predefined number of columns, 
#' so function can override inherited from data value.
#' @examples 
#' library(Matrix)
#' library(sparsio)
#' i = 1:8
#' j = 1:8
#' v = rep(2, 8)
#' x = sparseMatrix(i, j, x = v)
#' y = sample(c(0, 1), nrow(x), replace = TRUE)
#' f = tempfile(fileext = ".svmlight")
#' write_svmlight(x, y, f)
#' x2 = read_svmlight(f, type = "CsparseMatrix")
#' identical(x2$x, x)
#' identical(x2$y, y)

#' @rdname svmlight
#' @export
read_svmlight = function(file, type = c("CsparseMatrix", "RsparseMatrix", "TsparseMatrix"), zero_based = TRUE, ncol = NULL) {
  stopifnot(is.logical(zero_based))
  type = match.arg(type)
  stopifnot(is.character(file) && length(file) == 1)
  if(!is.null(ncol)) {
    stopifnot(is.numeric(ncol) || length(ncol) != 1)
  }
  
  file = path.expand(file)
  if (!file.exists(file)) stop(sprintf("File %s does not exist.", file))
  res = read_svmlight_cpp(file, zero_based)
  
  if (!is.null(ncol)) {
    ncol_discovered = ncol(res$x)
    ncol_provided = as.integer(ncol)
    if (ncol_discovered > ncol_provided)
      stop(sprintf("input contais at least %d columns while user provided %d as 'ncol'", ncol_discovered, ncol_provided))
    res$x@Dim = c(nrow(res$x), ncol_provided)
  }
  
  if(type != "RsparseMatrix")
    res$x = as(res$x, type)

  res
}

#' @rdname svmlight
#' @export
write_svmlight = function(x, y = rep(0, nrow(x)), file, zero_based = TRUE) {
  stopifnot(inherits(x, "sparseMatrix"))
  stopifnot(is.logical(zero_based))
  stopifnot(is.numeric(y))
  stopifnot(length(y) == nrow(x))
  stopifnot(is.character(file) && length(file) == 1)
  
  file = path.expand(file)
  
  if(!inherits(x, "RsparseMatrix")) {
    x = try(as(x, "RsparseMatrix"))
    if(class(x) == "try-error")
      stop("can't convert input into 'RsparseMatrix' class in order to write it to svmlight")
  }
  
  write_svmlight_cpp(x, y, file, zero_based)
  invisible(TRUE)
}

