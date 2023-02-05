#==============
# Chp 18 Memory
#==============

# help predict how much memory you'll need
# and how to make the most of your memeory

# can also faster your code as accidental copies 
  # are major causes  of slow code

# understand basic memory management
  # from individual R objs to functions, to larger block of code

# common tricks:
  # call gc() to free up memory
  # for loop are always slow

# 18.1
  # use object_size() to see how much memeory an obj occupies
  # as a lauching point to improve understanding of how R objs
    # are stored in memory

# 18.2
  # mem_used() and mem_change() 
    # understand how R allocates and frees memory

# 18.3 
  # lineprof package to understand how memory is allocated
    # and released in larger code blocks

# 18.4 
  # address() and refs()
    # R modifies in place and R modifies a copy


# prerequisites
install.packages("ggplot2")
install.packages("pryr")
devtools::install_github("hadley/lineprof", force = TRUE)


#--------------
# 18.1 Obj Size
#--------------

# use pryr::object_size()
  # tells you how many bytes of memory an obj occupies

library(pryr)
object_size(1:10)
# 680 B

object_size(mean)
# 1.13 kB

object_size(mtcars)
# 7.21 kB

# better than built_in object.size()
  # as it counts for shared elements within an obj
    # and includes the env's size


#----------
# ref
#---------
# seq_along and seq_len return an integer vector
seq_len(length.out = 7)
# [1] 1 2 3 4 5 6 7

str(mtcars$mpg)
# num [1:32]
seq_along(mtcars$mpg)
#  [1]  1  2  3  4  5  6  7  8  9 10 11 12 13
#[14] 14 15 16 17 18 19 20 21 22 23 24 25 26
#[27] 27 28 29 30 31 32


## Example:
  # use object_size() to systematically explore
    # the size of an int vector

  # computes and plots the memory usageof integer vector
  # ranging in length from 0 - 50

  # wrong expectation:
    # empty vector with memory size zero
    # memo size grows exponentially with length

sizes <- sapply(0:50, function(n) object_size(seq_len(n)))
plot(0:50, sizes, xlab = "Length", ylab = "sizes (bytes)",
     type = "s")
# even zero length vector occupies memory of size 48 bytes

object_size(numeric())
# 48 B

object_size(logical())
# 48 B

object_size(raw())
# 48 B

object_size(list())
# 48 B


## these 48 bytes store 4 components possessed by every 
  # R obj

# obj metadata: store base type (e.g., integer) and info
  # used to debugging and memo management

# two pointers: one to the next, one to the previous

# A pointer to the attributes

## All vectors have 3 additional components:
  # The length of the vector, 4 bytes
    # R could support 2^52 elmements
  # the true length of the vector 4 bytes; never used
    # except when the obj is hash table

  # the data (?? bytes). An empty vector has 0 byte of data
    # numeric vector occupies 8 bitys for every element
    # integer vectors 4
    # complex vectors 16


plot(0:50, sizes - 48, xlab = "Length", 
     ylab = "Bytes excluding overhead", type = "n")
lines(sizes - 48, type = "s")

abline(h = 0, col = "grey80")
abline(h = c(8, 16), col = "grey80")
abline(a = 0, b = 128, col = "grey90", lwd = 4)



## components can be shared across multiple objects
x <- 1:1e6
object_size(x)
# 680 B

y <- list(x, x, x)
object_size(y)
# 760 B

# but if there's no shared components, 
  # then have to add up individual components

x1 <- 1:1e6
y1 <- list(1:1e6, 1:1e6, 1:1e6, 1:1e6)
y2 <- list(x1, x1, x1, x1)

object_size(x1)
# 680 B

object_size(y1)
# 1.22 kB

object_size(y2) # use shared compoents save memo
# 760 B

object_size(x1, y1)
# 1.37 kB

object_size(x1) + object_size(y1) == object_size(x1, y1)
# [1] FALSE
object_size(x1) + object_size(y1)
# 1.90 kB

## string
  # each unique string stored in one place, 
    # so char. vectors take up less memo

object_size("mark briers")
# 120 B
object_size(rep("mark briers"), 10)
# 176 B



#--------------------------------------
# 18.2 Memo use and garbage collection
#--------------------------------------

install.packages("pryr")
library(pryr)

mem_used()
# 289 MB

# mem_change(code = for evaluation)
# tells how memory changes during code execution
# positive: increase in memory

mem_change(zz <- 1e6)
# 792 B
mem_change(rm(zz))
# -1.88 kB

mem_change(NULL)
# -3.01 kB

## R use garbage collection (GC) for unused objs
  # to return memory

# R automatically releases memory when an obj is no longer used
  # It does this by tracking how many names point to each obj
  # and when no names pointing to an obj, 
  # it deletes that obj


# create a big obj
mem_change(ss <- 1e6)
# -34.4 kB

# also point to 1e6 from yy
mem_change(yy <- ss)
# -1.91 kB

mem_change(rm(ss))
# 472 B

# no name points to 1e6, memory is freed
mem_change(rm(yy))
# -1.67 kB

## R will automatically call gc() itself whenever it needs to 
  # more space

# if you want to see what that is, 
  # call 
gcinfo(TRUE)
# [1] FALSE


## gc takes care of releasing objs that are no longer used
# BUT i do need to aware of possible memory leaks

# memory leaks occurs when you keep pointing to an obj
  # w/o realising it

# two main causes of memory leak
  # fomulas
  # closures
# as they both capture the enclosing env

# Examples:
  # in f1(), 1e6 is only referenced inside the function
  # why the function completes, the memory is returned
  # the net memory change is 0

  # in f2(), and f3()
  # both return objs that capture environments
  # so that x is NOT FREED when the function completes


f1 <- function(){
  x <- 1e6
  10
}

mem_change(c <- f1())
# -3.24 kB
object_size(c)
# 56 B


f2 <- function(){
  x <- 1e6
  a ~ b
}
mem_change(d <- f2())
# -4.94 kB
object_size(d)
# 896 B

f3 <- function(){
  x <- 1e6
  function() 10
}
mem_change(g <- f3)
# -9.92 kB
object_size(g)
# 3.81 kB


#---------------------------
# 18.4 Modification in place
#---------------------------
x <- 1:10
x[5] <- 10

# two possibilities: 
  # 1. R modifies x in place
  # 2. R copies x to a new location, modifies the copy
    # and then uses name x to point the new location

# to explore, use two tools from pryr package
  # address() : tell the variable location in memory
  # refs(): tell how many names point to that location

library(pryr)
x <- 1:10
address(x)
# [1] "0x7f90366d76e0"
refs(x)
# [1] 65535

y <- x

c(address(y), refs(y))
# [1] "0x7f90366d76e0" "65535" 

# refs is just an estimate  
  # can only differenciate between 1 and more than 1


# when refs is 1
  # modification will occur in place

# when refs is more than 1
  # R will make a copy, so other pointers to this obj
    # is not affected


# another useful function is tracemem()
  # prints a message every time the traced obj is copied

x <- 1:10
tracemem(x)
# [1] "<0x7f904647bb68>"
# the current location in memory of obj x
refs(x)
# [1] 65 so will copy to a new location and modify and
  # assign name x to the new location

x[5] <- 6L
#tracemem[0x7f904647bb68 -> 0x7f9020617d98]: 
# it moved from and to 


## Any primitive replacement function will modify in place
  # includes [[<-, [<-, attributes<-, names<-, levels<-

## all non-primitive functions increases refs.


# to avoid copies, rewrite your funcion in C++


#--------------
# 18.4.1 Loops
#--------------

# loops in R is slow
  # often because you modify a copy instead of 
    # modify in place. 

# example:
x <- data.frame(matrix(runif(100 * 1e4), ncol = 100))
Medians <- vapply(x, median, FUN.VALUE = numeric(1))
# since df is a list, each col is an element in the list
# vapply, each col of x go into the function median, 
  # and get one numeic output
  # so together 100 numeric
str(Medians)
# Named num [1:100]

for(i in seq_along(Medians)) {
  x[, i] <- x[, i] - Medians[i]
 }

# every iteration of the loop copies the df
# to see this 
system.time(for(i in 1:5) {
  x[, i]<- x[, i] - Medians[i]
  print(c(address(x), refs(x)))
})
#[1] "0x7f9015704080" "1"             
#[1] "0x7f90157043d0" "1"             
#[1] "0x7f9015704720" "1"             
#[1] "0x7f9015704a70" "1"             
#[1] "0x7f9035704080" "1"   

# every time x is moved to a new location 
  # because [<-.data.frame is NOT a primitive function

# can make this substaintially efficient by using a list
# instead of a data frame
  # since modifying a list using primitive functions
  # so all modifications will be in place

y <- as.list(x)

system.time(for(i in 1:5) {
  y[[i]] <- y[[i]] - Medians[i]
  print(c(address(y), refs(y)))
})
#[1] "0x7f90400e59f0" "1"             
#[1] "0x7f90400e59f0" "1"             
#[1] "0x7f90400e59f0" "1"             
#[1] "0x7f90400e59f0" "1"             
#[1] "0x7f90400e59f0" "1" 














































































