#include <Rcpp.h>
using namespace Rcpp;

// This is a basic implementation of lapply in C++


// [[Rcpp::export]]
List lapply1(List input, Function f) {
  int n = input.size();
  List out(n);
  
  for (int i; i < n; ++i) {
    out[i] = f(out[i]);
  }
  return out;
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R
timesTwo(42)
*/
