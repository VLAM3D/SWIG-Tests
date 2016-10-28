/* -*- C -*-  (not really, but good for syntax highlighting) */
/*
* eigen2numpy SWIG interface description file
*
* Copyright (C) 2016 by VLAM3D Software inc. https://www.vlam3d.com
*
* This code is licensed under the MIT license (MIT) (http://opensource.org/licenses/MIT)
*/  

%define DOCSTRING
"eigen2numpy Automatically generated documentation

The source of this text is in eigen2numpy.i the main SWIG_ interface file.
Use %feature(\"autodoc\") in the interface file to improve the documentation.
Please read SWIG_DOC_ 

.. _SWIG: http://www.swig.org/
.. _SWIG_DOC: http://www.swig.org/Doc1.3/Python.html#Python_nn65
"
%enddef 
 
%module(docstring=DOCSTRING) eigen2numpy

%feature("autodoc", "3");

%{ 
#define SWIG_FILE_WITH_INIT  
%}

%include <numpy.i>

%{
#undef _DEBUG
#define _DEBUG 1

#include <exception>
#include <memory>
#include <vector>
#include <numpy/arrayobject.h>
#include <Eigen/Dense>
%}

%init 
%{
    import_array();
%}

%inline 
%{
	typedef Eigen::Map<Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> > MatrixD;
	typedef Eigen::Map<Eigen::Matrix<float, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> > MatrixF;

	template <typename MatrixType> struct MatrixTraits;
	
	template <>
	struct MatrixTraits<MatrixD>
	{
		typedef double ScalarType;
	};

	template <>
	struct MatrixTraits<MatrixF>
	{
		typedef float ScalarType;
	};
	
	template <typename T>
	Eigen::Map<Eigen::Matrix<T, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> >* make_matrix(T* ptr, npy_intp rows, npy_intp cols)
	{
		return new Eigen::Map<Eigen::Matrix<T, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> >(ptr, rows, cols);		
	}
%}

%include "matrix2numpy.i" 

%matrix_typemaps(MatrixF            , NPY_FLOAT    , int)
%matrix_typemaps(MatrixD            , NPY_DOUBLE   , int)

%apply (const MatrixD& IN_MATRIX) {(const MatrixD &input_matrix)};
%apply (MatrixD& INPLACE_MATRIX) {(MatrixD &output_matrix)};

%apply (const MatrixF& IN_MATRIX) {(const MatrixF &input_matrix)};
%apply (MatrixF& INPLACE_MATRIX) {(MatrixF &output_matrix)};

// Example functions
%inline
%{
	void function_with_argin_argout_matrixd(const MatrixD &input_matrix, MatrixD &output_matrix)
	{
		output_matrix = input_matrix;
	}

	void function_with_argin_argout_matrixf(const MatrixF &input_matrix, MatrixF &output_matrix)
	{
		output_matrix = input_matrix;
	}

	MatrixD function_returning_matrixd(const MatrixD &input_matrix)
	{
		return input_matrix;
	}
%}


