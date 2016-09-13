# SWIG-Tests
My personal sandbox for testing SWIG typemaps

Prerequistes:
- SWIG (I'm using the swigwin-3.0.8 build)
- numpy.i (Can be found in numpy github project)
- CMake (only if you want to use my file for help)

Here's the commands I use to build this with Visual Studio 2015. 
Adapt all the paths with yours. 
This is an out of folder CMake build, which is much cleaner than building in place. 

```
mkbuild
cmake .. -G "Visual Studio 14 2015 Win64" -DSWIG_DIR=C:\DEV\swigwin-3.0.8 -DSWIG_EXECUTABLE=C:\dev\swigwin-3.0.8\swig.exe -DNUMPY_SWIG_DIR=C:\dev\numpy\tools\swig -DCMAKE_INSTALL_PREFIX=..
```

Open the solution in the build folder and build the Install target. 
Go in the created bin folder and do:

```
python test_swig.py
``` 

However, the most useful result is to look at the generated swig_testsPYTHON_wrap.cxx to see the typemaps worked as expected. 
