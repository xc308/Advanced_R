#include <Rcpp.h>
using namespace Rcpp;

// Calling R functions with postional arguments is obvious

// [[Rcpp::export]]
f("y", 1);

// calling with named arguments, need special sytax:

f(_["x"] = "y", _["value"] = 1);



// You can include R code blocks in C++ files processed with sourceCpp
// (useful for testing and development). The R code will be automatically 
// run after the compilation.
//

/*** R
timesTwo(42)
*/
