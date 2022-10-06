#====================
# Chp 7 oo field guide
#====================

install.packages("pryr")
library(pryr)

# R has 3 object-oriented systems + base types
# center to any object-oriented system are the 
  # concepts of "class" and "method"

# A "class" defines the behavior of objects by 
  # describing their attributes and their relationship
  # to other classes.

# The class is also used when selecting methods, functions
  # that behave differently depending on the class of 
  # their input;

# Classes are organized in a hierarchy:
  # for a child, if a method does not exist
  # then parents method is used instead;
  # the child also inherits parents' behavior.


# Three OO systems differ in how "classes" and "methods" 
  # are defined:

  # S3: 
    # implements generic-function OO
    # different from other language, i.e. JAVA, C++
      # which implement message-passing OO:
      # which sends messages (methods) to objects
      # and the objects decide which function to call. 

    # S3 is different, 
      # generic function decides which method to call
      # then computations are carried out via methods. 

    # S3 has no formal definition of class, very casual. 
    # e.g. canvas.drawRect("blue")    


  # S4:
    # more formal.
    # has a formal class defining representations and inheritance for each class
    # has special helper functions to define generics and methods
    # has multiple dispatch, so generic functions can
      # pick methods based on the class of any number of args, not just 1.
    # e.g. drawRect(canvas, "blue")


  # Reference classes (RC):
    # different from S3 and S4
    # implements message-passing OO, so methods belong to class
    # NOT functions. 
    # e.g. canvas$drawRect("blue"), $ seperates obj and methods
    








