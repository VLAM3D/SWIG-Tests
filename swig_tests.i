/* -*- C -*-  (not really, but good for syntax highlighting) */
/*
* swig_tests SWIG interface description file
*
* Copyright (C) 2016 by VLAM3D Software inc. https://www.vlam3d.com
*
* This code is licensed under the MIT license (MIT) (http://opensource.org/licenses/MIT)
*/  

%define DOCSTRING
"swig_tests Automatically generated documentation

The source of this text is in swig_tests.i the main SWIG_ interface file.
Use %feature(\"autodoc\") in the interface file to improve the documentation.
Please read SWIG_DOC_ 

.. _SWIG: http://www.swig.org/
.. _SWIG_DOC: http://www.swig.org/Doc1.3/Python.html#Python_nn65
"
%enddef 
 
%module(docstring=DOCSTRING) swig_tests

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

%}
%init 
%{
    import_array();
%}

%include <std_shared_ptr.i>; 

// from William S. Fulton answer in http://swig.10945.n7.nabble.com/Properly-wrapping-quot-static-const-char-quot-td11479.html
// we disable the const char * warning but we put a typemap to trigger a run-time error when trying to set it
#pragma SWIG nowarn=-451
%typemap(varin) const char * 
{
   SWIG_Error(SWIG_AttributeError,"Variable $symname is read-only.");
   SWIG_fail;
}  

%define %raii_struct(TYPE...)
    %typemap(in) const TYPE &
    (void *argp, int res = 0)
    {
        int newmem = 0;
        res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(std::shared_ptr<TYPE##RAII> *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
            %argument_fail(res, "$type", $symname, $argnum);
        }
        if (!argp) {
            %argument_nullref("$type", $symname, $argnum);
        }
        else {
            std::shared_ptr<TYPE##RAII> &ptr = *%reinterpret_cast(argp, std::shared_ptr<TYPE##RAII> *);
            $1 = &(ptr->m_nonRAIIobj);
        }
    }

    %typemap(in) TYPE 
    (void *argp, int res = 0)
    {
        int newmem = 0;
        res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(std::shared_ptr<TYPE##RAII> *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
            %argument_fail(res, "$type", $symname, $argnum);
        }
        if (!argp) {
            %argument_nullref("$type", $symname, $argnum);
        }
        else {
            std::shared_ptr<TYPE##RAII> &ptr = *%reinterpret_cast(argp, std::shared_ptr<TYPE##RAII> *);
            $1 = ptr->m_nonRAIIobj;
        }
    }

    %typemap(in) const std::vector<TYPE> &
    (void *argp, int res = 0, std::vector<TYPE> temp_vec)
    {
        int newmem = 0;
        res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(std::vector< std::shared_ptr<TYPE##RAII> > *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
            %argument_fail(res, "$type", $symname, $argnum);
        }
        if (!argp) {
            %argument_nullref("$type", $symname, $argnum);
        }
        else {
            std::vector< std::shared_ptr<TYPE##RAII> > &vec = *%reinterpret_cast(argp, std::vector< std::shared_ptr<TYPE##RAII> > *);
            temp_vec.resize(vec.size());
            std::transform(vec.begin(), vec.end(), temp_vec.begin(), [](const std::shared_ptr<TYPE##RAII> &ptr)->TYPE {return ptr->m_nonRAIIobj; });
            $1 = &temp_vec;
        }
    }

    %typemap(in) const std::shared_ptr<TYPE##RAII> &
    (void *argp, int res = 0, std::shared_ptr<TYPE##RAII> null_shared_ptr)
    {
        int newmem = 0;
        res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(std::shared_ptr<TYPE##RAII> *), %convertptr_flags, &newmem);
        if (!SWIG_IsOK(res)) {
            %argument_fail(res, "$type", $symname, $argnum);
        }
        if (!argp) {
            $1 = &null_shared_ptr;
        }
        else {
            $1 = %reinterpret_cast(argp, std::shared_ptr<TYPE##RAII> *);
        }
    }
%enddef

%define %ref_counted_handle(HANDLETYPE...)
    %typemap(in) HANDLETYPE
    (void *argp, int res = 0)
    {
        // try dumb handle first
        res = SWIG_ConvertPtr($input, &argp, $descriptor(HANDLETYPE##_T*), 0 | 0);
        if (!SWIG_IsOK(res)) 
        {
            int newmem = 0;     
            // then try std::shared_ptr
            res = SWIG_ConvertPtrAndOwn($input, &argp, $descriptor(std::shared_ptr<HANDLETYPE##_T> *), %convertptr_flags, &newmem);
            if (!SWIG_IsOK(res)) {
                %argument_fail(res, "$type", $symname, $argnum);
            }
            if (!argp) {
                %argument_nullref("$type", $symname, $argnum);
            }
            else {
                $1 = (%reinterpret_cast(argp, std::shared_ptr<HANDLETYPE##_T> *)->get());
                if (newmem & SWIG_CAST_NEW_MEMORY) delete %reinterpret_cast(argp, std::shared_ptr<HANDLETYPE##_T> *);
            }
        }
        else
        {
            $1 = %reinterpret_cast(argp, HANDLETYPE);
        }
    }

    %typemap(typecheck) HANDLETYPE
    {
        int res = SWIG_ConvertPtr($input, 0, $descriptor(HANDLETYPE##_T*), 0);
        if (!SWIG_IsOK(res))
        {
            res = SWIG_ConvertPtr($input, 0, $descriptor(std::shared_ptr<HANDLETYPE##_T> *), 0);
        }
        $1 = SWIG_CheckState(res);
    }
   
    // need to inform swig that HANDLETYPE is the same as HANDLETYPE_T*     
    %apply HANDLETYPE { HANDLETYPE##_T* };

    %template (HANDLETYPE##RefCounted)std::shared_ptr<HANDLETYPE##_T>;
%enddef

%define %carray_of_struct(TYPE...)
    %typemap(out) TYPE[ANY]
    {
        $result = PyList_New($1_dim0);
        for (int i = 0; i < $1_dim0; i++) {        
            auto p_obj = SWIG_NewPointerObj(SWIG_as_voidptr(&$1[i]), $descriptor(TYPE*), 0 | 0);
            PyList_SetItem($result, i, p_obj);
        }
    }
%enddef

%define in_array_typemap_macro(TYPE, CONVERT_API_FCT)
    %typemap(in) TYPE[ANY] (TYPE temp[$1_dim0]) {
        int i;
        if (!PySequence_Check($input)) {
            PyErr_SetString(PyExc_ValueError,"Expected a sequence");
            return NULL;
        }
        if (PySequence_Length($input) != $1_dim0) {
            PyErr_SetString(PyExc_ValueError,"Size mismatch. Expected $1_dim0 elements");
            return NULL;
        }
        for (i = 0; i < $1_dim0; i++) {
            PyObject *o = PySequence_GetItem($input,i);
            if (PyNumber_Check(o)) {
                temp[i] = static_cast<TYPE>(CONVERT_API_FCT(o));
            } else {
                PyErr_SetString(PyExc_ValueError,"Sequence elements must be numbers");      
                return NULL;
            }
        }
        $1 = temp;
    }

    %typemap(memberin) TYPE[ANY] {
        for (int i = 0; i < $1_dim0; i++) {
            $1[i] = $input[i];
        }
    }
%enddef

%define out_array_typemap_macro(TYPE, CPYTHON_API_TYPE, CONVERT_API_FCT)
    %typemap(out) TYPE[ANY]
    {
        $result = PyList_New($1_dim0);
        for (int i = 0; i < $1_dim0; i++) {        
            auto p_obj = CONVERT_API_FCT(static_cast<CPYTHON_API_TYPE>($1[i]));
            PyList_SetItem($result, i, p_obj);
        }
    }
%enddef

%define %carray_of_float(TYPE...)
    in_array_typemap_macro(TYPE, PyFloat_AsDouble)
    out_array_typemap_macro(TYPE, double, PyFloat_FromDouble)
%enddef

%define %carray_of_size_t(TYPE...)
    in_array_typemap_macro(TYPE, PyInt_AsLong)
    out_array_typemap_macro(TYPE, size_t, PyInt_FromSize_t)
%enddef

%define %carray_of_long(TYPE...)
    in_array_typemap_macro(TYPE, PyInt_AsLong)
    out_array_typemap_macro(TYPE, long, PyInt_FromLong)
%enddef

%carray_of_struct(Pomme)
%carray_of_float(Pamplemousse)
%carray_of_size_t(Orange)
%carray_of_long(Citron)
%raii_struct(Chou)

// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
// shared_ptr section : all wrapped std::shared_ptr<T>
// must be declared here first

%shared_ptr(std::vector<int>)
%shared_ptr(std::vector<HPatate>)
%shared_ptr(Carotte)
%shared_ptr(Celeri_T)

//
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

%include stl.i
%include "exception.i"
%include "std_pair.i"
%include "std_vector.i"
%include "std_map.i"
%include "std_string.i"
%include "std_wstring.i"   
%include "std_ios.i"
%include "typemaps.i"
 
%exception   
{ 
    try  
    {
        $action
    }
    catch (std::out_of_range& e) 
    {
        SWIG_exception(SWIG_IndexError,const_cast<char*>(e.what()));
    }
    catch (const std::exception& e) 
    {
        SWIG_exception(SWIG_RuntimeError, e.what());
    }
} 

%template (IntVector)std::vector<int>;

std::shared_ptr< std::vector<HPatate> > make_patate_handles();
void check_patate(HPatate hp);

%{
    struct HPatate_T;
    typedef HPatate_T* HPatate;

    namespace swig
    {
        template <>  struct traits< HPatate_T >
        {
            typedef pointer_category category;
            static const char* type_name() { return"HPatate_T"; }
        };
    }
%}

%inline 
%{
    std::vector<int> make_numbers()
    {
        return std::vector<int>(25, 576);
    }

    std::shared_ptr< std::vector<int> > make_numbers_ptr()
    {
        return std::shared_ptr< std::vector<int> >(new std::vector<int>(25, 576));
    } 
%}

%{
    std::shared_ptr< std::vector<HPatate> > make_patate_handles()
    {
        return std::shared_ptr< std::vector<HPatate> >(new std::vector<HPatate>(37, reinterpret_cast<HPatate>(0xDEADBEAF)));
    }

    void check_patate(HPatate hp)
    {
        std::cout << "Patate ptr value " << hp << std::endl;
    }
%}

%inline
%{
    class Carotte
    {
    public:
        Carotte(const std::string &couleur)
        :m_couleur(couleur)
        {

        }

        void hello() const
        {
            std::cout << "Je suis une carotte " << m_couleur << std::endl;
        }

    private:
        std::string m_couleur;
    };

    std::shared_ptr<Carotte> make_carotte(const std::string &couleur)
    {
        return std::make_shared<Carotte>(couleur);
    }

    void say_hello(const std::shared_ptr<Carotte> &c)
    {
        if (!c)
        {
            std::cout << "Pas de carotte" << std::endl;
            return;
        }

        c->hello();
    }

    struct Celeri_T
    {
        ~Celeri_T();
    private:
        Celeri_T();
    };

    typedef Celeri_T* Celeri;

    std::shared_ptr<Celeri_T> make_celeri()
    {
        return std::shared_ptr<Celeri_T>(reinterpret_cast<Celeri_T*>(0xDEADBEAF), [](Celeri_T* ptr) {});
    }

    void say_hello_celeri(const std::shared_ptr<Celeri_T> &c)
    {
        if (!c)
        {
            std::cout << "Pas de celeri" << std::endl;
            return;
        }

        std::cout << "Un celeri avec l'adresse " << c.get() << std::endl;
    }

    void say_hello_celeri_handle(Celeri c)
    {
        std::cout << "Un celeri avec l'adresse " << c << std::endl;
    }
%}

%ref_counted_handle(Navet)

%rename(_Chou) Chou;

%inline
%{
    #define MAX_UINT           (~0U)
    unsigned int max_uint()
    {
        return MAX_UINT;
    }

    int max_int()
    {
        return std::numeric_limits<int>::max();
    }

    struct Navet_T;   
    typedef Navet_T *Navet;
    std::vector<Navet> make_navets()
    {
        return std::vector<Navet>(3, reinterpret_cast<Navet_T*>(0xDEADBEAF));
    }

    void check_navet(Navet n)
    {
        if (!n)
        {
            std::cout << "Navet invisible" << std::endl;
            return;
        }

        std::cout << "Un navet avec l'adresse " << n << std::endl;
    }

    void check_navet_shared_ptr(const std::shared_ptr<Navet_T> &ptr)
    {
        if (!ptr)
        {
            std::cout << "Navet invisible" << std::endl;
            return;
        }

        std::cout << "Un navet avec l'adresse " << ptr.get() << std::endl;
    }

    std::shared_ptr<Navet_T> make_shared_navet()
    {
        return std::shared_ptr<Navet_T>(reinterpret_cast<Navet_T*>(0xDEADBEAF), [](Navet_T*){ std::cout << "Navet over" << std::endl; });
    }

    struct Panier
    {
        Navet m_handle_navet;
        std::shared_ptr<Navet_T> m_shared_navet;
    };

    struct Pomme
    {
        int m_pepins;
        unsigned int m_coeur;
    };

    struct DouzaineDePomme
    {
        Pomme m_pommes[12];
    };

    DouzaineDePomme make_pommes()
    {
        DouzaineDePomme la_douzaine;
        for (int i = 0; i < 12; ++i)
        {
            la_douzaine.m_pommes[i].m_coeur = 1;
            la_douzaine.m_pommes[i].m_pepins = i+1; 
        }
        return la_douzaine;
    }

    typedef unsigned long long Orange;
    typedef float Pamplemousse;
    typedef int Citron;

    struct PanierAgrumes
    {
        Orange m_oranges[7];
        Pamplemousse m_pamplemousses[5];
        Citron m_citrons[3];
    };

    PanierAgrumes make_agrumes()
    {
        PanierAgrumes panier;

        for (int i = 0; i < 7; ++i)
        {
            panier.m_oranges[i] = i * 100;
        }

        for (int i = 0; i < 5; ++i)
        {
            panier.m_pamplemousses[i] = static_cast<float>(i)* 3.14159f;
        }

        for (int i = 0; i < 3; ++i)
        {
            panier.m_citrons[i] = -i*3;
        }

        return panier;
    }

    struct Chou
    {
        const char * m_couleur;
    };

    struct ChouRAII
    {
        Chou m_nonRAIIobj;
        std::string m_str_couleur;
    };

    std::shared_ptr<ChouRAII> make_chou(const std::string &coul = "Vert")
    {
        std::shared_ptr<ChouRAII> chou(new ChouRAII);
        chou->m_str_couleur = coul;
        chou->m_nonRAIIobj.m_couleur = &chou->m_str_couleur[0];
        return chou;
    }

    void check_chou(const Chou &c)
    {
        std::cout << "Un chou " << c.m_couleur << std::endl;
    }

    void check_chou_val(Chou c)
    {
        std::cout << "Un chou " << c.m_couleur << std::endl;
    }

    void check_chou_ptr(const std::shared_ptr<ChouRAII> &c)
    {
        if (c)
        {
            std::cout << "Un chou " << c->m_nonRAIIobj.m_couleur << std::endl;
        }
        else
        {
            std::cout << "Chou nul" << std::endl;
        }
    }

    void make_choucroute(const std::vector<Chou> &choux)
    {
        if (choux.empty())
        {
            std::cout << "No chou" << std::endl;
            return;
        }

        for (auto c : choux)
        {
            check_chou(c);
        }
    }
%}

%template (HPatateVector)std::vector<HPatate>;
%template (Chou) std::shared_ptr<ChouRAII>;
%template (ChouVector) std::vector< std::shared_ptr<ChouRAII> >;
%template (NavetVector) std::vector<Navet>;




