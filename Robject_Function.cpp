#include <Rcpp.h>
using namespace Rcpp;

// This is a simple example of calling R functions in C++ using 
  // an object of type Function
  //

// [[Rcpp::export]]
RObject callWithOne(Function f) { //callWithOne need Function as input
  return f(1);
}


// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R
callWithOne(function(x) x+1) 
callWithOne(paste)
*/
