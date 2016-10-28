cmake_minimum_required (VERSION 3.4)
project (eigen2numpy)

set (eigen2numpy_VERSION_MAJOR 0)
set (eigen2numpy_VERSION_MINOR 1)

find_package(SWIG REQUIRED)
include(${SWIG_USE_FILE})

find_package(PythonInterp REQUIRED)
message (STATUS "Using this Python interpreter: " ${PYTHON_EXECUTABLE})

find_package(PythonLibs REQUIRED)
include_directories(${PYTHON_INCLUDE_PATH})
include_directories(${CMAKE_CURRENT_SOURCE_DIR})

message (STATUS "Using this Python Lib: " ${PYTHON_LIBRARIES})

set(CMAKE_SWIG_FLAGS "")

# external python call to get its site_package path
# the python command must execute the desired python interpreter 
# mus replace the backslash by forward slash otherwise there's an error in swig_link_libraries
execute_process ( COMMAND python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib().replace('\\\\', '/'))" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE)

set(NUMPY_INCLUDE_DIR ${PYTHON_SITE_PACKAGES}/numpy/core/include)
set(NUMPY_LIB ${PYTHON_SITE_PACKAGES}/numpy/core/lib/npymath.lib)
message (STATUS "Eigen include path: " ${EIGEN3_INCLUDE_DIR} )
message (STATUS "Numpy include path: " ${NUMPY_INCLUDE_DIR} )
message (STATUS "Numpy lib: " ${NUMPY_LIB} )

include_directories(${EIGEN3_INCLUDE_DIR}) 
include_directories(${NUMPY_INCLUDE_DIR})
include_directories(${NUMPY_SWIG_DIR})
set_source_files_properties(SOURCE eigen2numpy.i PROPERTIES CPLUSPLUS ON)

# On windows the _WIN64 is autodefined by the compiler cl.exe when using the Win64 toolchain
if (${CMAKE_SIZEOF_VOID_P} EQUAL 8)
	set_source_files_properties(SOURCE eigen2numpy.i PROPERTIES SWIG_FLAGS "-D_WIN64")
endif()

# This preprocessor variable disables the automatic linking of pythonXY_d.lib to use the release version of python.lib
add_definitions(-DSWIG_PYTHON_INTERPRETER_NO_DEBUG) 

# With Visual Studio we need to turn off iterator debugging because we are linking against the release version of pythonXY.lib
if(MSVC)
	add_definitions(-D_ITERATOR_DEBUG_LEVEL=0)
endif()

swig_add_module(eigen2numpy python eigen2numpy.i)
swig_link_libraries(eigen2numpy ${PYTHON_LIBRARIES} ${NUMPY_LIB})

install(TARGETS ${SWIG_MODULE_eigen2numpy_REAL_NAME} DESTINATION bin)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/eigen2numpy.py DESTINATION bin)
install(FILES test_eigen2numpy.py DESTINATION bin)

if(MSVC)
    set_target_properties(${SWIG_MODULE_eigen2numpy_REAL_NAME} PROPERTIES COMPILE_FLAGS "/bigobj")
endif()
