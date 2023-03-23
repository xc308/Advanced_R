#========================
# Chp 20 R's C interface
#========================

# When R's base package written in C 
  # needs r's C API

# to see R's complete C API, 
  # look at the header file Rinternals.h


# to link C code to your current R session
  # use inline package
install.packages("inline")
library(inline)

# to find the C code associated with internal and primitive functions
install.packages("pryr")
library(pryr)


# also need a C compiler
# Xcode


#--------------------------------
# 20.1 Calling C functions from R
#--------------------------------

# require two pieces:
  # a C function 
  # an R wrapper that uses .Call()

# 

























