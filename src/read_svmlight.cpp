#include <Rcpp.h>
#include <vector>
#include <string>
#include <fstream>

using namespace Rcpp;

// Reads a sparse matrix from a SVMlight compatible file

// [[Rcpp::export]]
List read_svmlight_cpp(Rcpp::String filename, int zero_based = 1) {
  int index_start_with = 0;
  if(!zero_based) index_start_with = 1;
  
  std::vector<int> col_indices;
  std::vector<int> pointers;
  std::vector<double> x_values;
  std::vector<double> y_values;
  std::ifstream inputFile(filename.get_cstring());
  std::string line;
  
  int nrow = 0;
  int ncol = 0;
  int pointer_counter = 0;
  // foreach line
  while (!inputFile.eof()) {
    std::getline(inputFile, line);
    std::istringstream tokenStream( line );
    std::string token;
    pointers.push_back(pointer_counter);
    // first token = target value
    std::getline(tokenStream, token, ' ');
    
    // check eof - case for last line
    if(!tokenStream.eof()) {
      double target;
      sscanf(token.c_str(), "%lf", &target);
      y_values.push_back(target);
      nrow++;
    }
    
    // foreach token (id:value) in line 
    while (!tokenStream.eof()) {
        std::getline(tokenStream, token, ' ');
        int id;
        double value;
        sscanf(token.c_str(), "%d:%lf", &id, &value);
        // case when indices start from 1
        id = id - index_start_with;
        ncol = std::max(id, ncol); 
        x_values.push_back(value);
        
        col_indices.push_back(id);
        pointer_counter++;
    }
  }
  ncol++;

  S4 x("dgRMatrix");
  x.slot("p") = wrap(pointers);
  x.slot("j") = wrap(col_indices);
  x.slot("x") = wrap(x_values);
  x.slot("factors") = List::create();
  x.slot("Dim") = IntegerVector::create(nrow, ncol);
  x.slot("Dimnames") = List::create(R_NilValue, R_NilValue);
  return List::create( 
          _["x"] = x, 
          _["y"] = Rcpp::wrap(y_values)
          ) ;
}
