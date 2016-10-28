// will put reusable macros heres
%define %matrix_typemaps(MATRIX_TYPE, DATA_TYPECODE, DIM_TYPE)

/************************/
/* Input Array Typemaps */
/************************/

// Typemap suite for (const MATRIX_TYPE& IN_MATRIX)

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY,
           fragment="NumPy_Macros")
  (const MATRIX_TYPE& IN_MATRIX)
{
  $1 = is_array($input) || PySequence_Check($input);
}

%typemap(in,
         fragment="NumPy_Fragments")
  (const MATRIX_TYPE& IN_MATRIX)
  (PyArrayObject* array=NULL, int is_new_object=0)
{
	npy_intp size[2] = { -1, -1 };
	array = obj_to_array_contiguous_allow_conversion($input, DATA_TYPECODE, &is_new_object);
	if (!array || !require_dimensions(array, 2) || !require_size(array, size, 2)) SWIG_fail;
	$1 = make_matrix(reinterpret_cast<MatrixTraits<MATRIX_TYPE>::ScalarType*>(array_data(array)), array_size(array,0), array_size(array,1));
}

%typemap(freearg)
  (const MATRIX_TYPE& IN_MATRIX)
{
	delete $1;
	if (is_new_object$argnum && array$argnum) {Py_DECREF(array$argnum);}
}

/***************************/
/* In-Place Array Typemaps */
/***************************/

// Typemap suite for (MATRIX_TYPE &INPLACE_MATRIX)

%typecheck(SWIG_TYPECHECK_DOUBLE_ARRAY,
           fragment="NumPy_Macros")
  (MATRIX_TYPE &INPLACE_MATRIX)
{
  $1 = is_array($input) && PyArray_EquivTypenums(array_type($input),DATA_TYPECODE);
}
%typemap(in,
         fragment="NumPy_Fragments")
  (MATRIX_TYPE &INPLACE_MATRIX)
  (PyArrayObject* array=NULL)
{
  array = obj_to_array_no_conversion($input, DATA_TYPECODE);
  if (!array || !require_dimensions(array,2) || !require_contiguous(array) || !require_native(array)) SWIG_fail;
  $1 = make_matrix(reinterpret_cast<MatrixTraits<MATRIX_TYPE>::ScalarType*>(array_data(array)), array_size(array,0), array_size(array,1));
}

%typemap(freearg)
  (MATRIX_TYPE &INPLACE_MATRIX)
{
	delete $1;
}

/***************************/
/* Out Array Typemaps	   */
/***************************/

%fragment("MatrixCapsule", "header")
{
    %#define MATRIX_CAPSULE_NAME "matrix_capsule"

    struct MatrixCapsule
    {
        Eigen::Matrix<double, Eigen::Dynamic, Eigen::Dynamic, Eigen::RowMajor> matrix;
    };

    void free_matrix_capsule(PyObject * cap)
    {
        auto *p_capsule = reinterpret_cast<MatrixCapsule*>(PyCapsule_GetPointer(cap, MATRIX_CAPSULE_NAME));
        if (p_capsule != nullptr)
        {
            delete p_capsule;
        }
    }
}

%typemap(out, 
		 optimal="1",
         fragment="NumPy_Fragments,MatrixCapsule")
  MATRIX_TYPE
  (PyArrayObject* array=NULL)
{
	auto p_cap = std::make_unique<MatrixCapsule>();
	p_cap->matrix = $1;
	npy_intp dims[2] = { p_cap->matrix.rows(), p_cap->matrix.cols() };
	PyObject* obj = PyArray_SimpleNewFromData(2, dims, DATA_TYPECODE, reinterpret_cast<void*>(p_cap->matrix.data()));
	PyArrayObject* array = (PyArrayObject*) obj;
	if (!array) SWIG_fail;	
	PyObject* cap = PyCapsule_New(reinterpret_cast<void*>(p_cap.release()), MATRIX_CAPSULE_NAME, free_matrix_capsule);
	PyArray_SetBaseObject(array,cap);
	$result = SWIG_Python_AppendOutput($result,obj);
}

%enddef    /* %matrix_typemaps() macro */
