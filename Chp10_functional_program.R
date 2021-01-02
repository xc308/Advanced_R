#******************************#
# Chp 10 Functional Programming
#*******************************#


#================#
# 10.1 Motivation
#================#

set.seed(2-1-2021)

df <- data.frame(replicate(6, sample(c(1:10, -99), 6, replace = TRUE)))
head(df, 2)
names(df) <- letters[1:6]
df
# want to replace -99 with NA


# principle: do not repeat yourself
  # can first write a function that fixes the missing value in a single vector


fix_missing <- function(x) {
  x[x == -99] <- NA
  x
}
df$a <- fix_missing(df$a)
df
df$f <- fix_missing(df$f)
df
# can mess up the name of the variable


# the function fix_missing knows how to fix a single vector
# lapply() knows how to do the same thing to each col of df


# lapply(x, f, ...)
  # x: a list
  # f: a function
  # ...: 
  # it applies f to each element of the list x, then return a new list

# lapply is called functional, as it takes a function as its arg

# so all we need is a little trick to get back a df rather a lsit
# just need to assign the lapply result to a df[]

df[] <- lapply(df, fix_missing) # as df is a list of named vectors
df

# The key idea is composition. 
  # take two simple functions, 
  # then compose then with a powerful technique


# But now if different cols use different code for missing values
# it's better to use closures, which is afunction that
  # that make and return functions.

missing_fixer <- function(na_val) {
  function(x) {
    x[x == na_val] <- NA
    x
  }
}

fix_missing_99 <- missing_fixer(-99)
fix_missing_999 <- missing_fixer(-999)


# want to compute the same set of numerical summeries for each varaible
# one approach: write a summary function then apply it to each col

summary_fun <- function(x) {
  c(mean(x), median(x), sd(x), mad(x), IQR(x))
 
}
rm(summary)
lapply(df, summary_fun)

# Error in quantile.default(as.numeric(x), c(0.25, 0.75), na.rm = na.rm,  : 
# missing values and NaN's not allowed if 'na.rm' is FALSE 


# to remove na, need to add na.rm = TRUE

summary_fun <- function(x) {
  c(mean(x, rm.na = TRUE), 
    median(x, rm.na = TRUE), 
    sd(x, rm.na = TRUE), 
    mad(x, rm.na = TRUE), 
    IQR(x, rm.na = TRUE))

}

# but the body part of the summary_fun is repeated
# so can write into a function again

summary_closure <- function(x) {
  funs <- c(mean, median, sd, mad, IQR)
  lapply(funs, function(f) f(x, rm.na = TRUE))
}































































