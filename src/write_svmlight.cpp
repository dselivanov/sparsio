#include <Rcpp.h>
#include <fstream>

using namespace Rcpp;

// Writes a sparse matrix to a SVMlight compatible file

// [[Rcpp::export]]
void write_svmlight_cpp(S4 x, NumericVector y,  Rcpp::String filename, int zero_based = 1) {
  int index_start_with = 0;
  if(!zero_based) index_start_with = 1;
  
  IntegerVector pointers = x.slot("p");
  IntegerVector col_indices = x.slot("j");
  NumericVector x_values = x.slot("x");
  IntegerVector dim = x.slot("Dim");
  int nr = dim[0];
  // int nc = dim[1];

  // open output file
  std::ofstream out;
  out.open(filename.get_cstring());

  // foreach row in CSR
  for (int i = 0; i < nr; i++) { 
    int p1 = pointers[i];
    int p2 = pointers[i + 1];
    out << y[i];
    for( int p = p1; p < p2; p++)
      // add index_start_with for the case when indices start from 1 (in some software like h2o)
      out << " " << col_indices[p] + index_start_with << ":" << x_values[p];
    out << std::endl;
  }
  out.close();
}
