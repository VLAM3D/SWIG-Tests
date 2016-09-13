import sys
import unittest
import swig_tests

class TestSwig(unittest.TestCase):
    def test_shared_ptr_of_vector(self):
        a = swig_tests.make_numbers()
        self.assertEqual(len(a),25)        
        b = swig_tests.make_numbers_ptr()
        self.assertEqual(len(b),25)
        self.assertEqual(list(a),list(b))
        self.assertEqual(str(type(b[0])),"<class 'int'>")
        c = swig_tests.make_patate_handles()
        self.assertEqual(len(c),37)
        swig_tests.check_patate(c[31])
        carotte = swig_tests.make_carotte("orange")
        self.assertIsNotNone(carotte)
        carotte_rouge = swig_tests.Carotte("rouge")
        swig_tests.say_hello(carotte_rouge)
        celeri = swig_tests.make_celeri()
        self.assertIsNotNone(celeri)
        swig_tests.say_hello_celeri(celeri)
        swig_tests.say_hello_celeri(None)
        swig_tests.say_hello_celeri_handle(celeri)
        swig_tests.say_hello_celeri_handle(None)
        navets = swig_tests.make_navets()
        for n in navets:
            swig_tests.check_navet(n)
        navets.push_back(swig_tests.make_shared_navet())
        navets.append(swig_tests.make_shared_navet())
        encore_navets = swig_tests.NavetVector(1,swig_tests.make_shared_navet())
        swig_tests.check_navet(None)
        shared_navet = swig_tests.make_shared_navet()
        swig_tests.check_navet(shared_navet)
        swig_tests.check_navet_shared_ptr(shared_navet)
        panier = swig_tests.Panier()
        panier.m_handle_navet = shared_navet
        panier.m_handle_navet = navets[0]
        panier.m_shared_navet = shared_navet
        for i in range(0,5):
            swig_tests.make_shared_navet()

        douzaine = swig_tests.make_pommes()
        douzaine.m_pommes[0].m_pepins = swig_tests.max_int()
        douzaine.m_pommes[0].m_coeurs = swig_tests.max_uint()
        for p in douzaine.m_pommes:
            print(p.m_pepins)

        panier_agr = swig_tests.make_agrumes()
        for o in panier_agr.m_oranges:
            print(o)

        for p in panier_agr.m_pamplemousses:
            print(p)

        for c in panier_agr.m_citrons:
            print(c)
        
        panier_agr.m_citrons = [1,2,3]
        panier_agr.m_citrons[0] = -345

        for c in panier_agr.m_citrons:
            print(c)

        chou = swig_tests.make_chou()
        swig_tests.check_chou(chou)
        swig_tests.check_chou_ptr(chou)
        swig_tests.check_chou_ptr(None)

        choux = swig_tests.ChouVector(5,chou)
        for c in choux:
            swig_tests.check_chou_val(c)

        choux.append(swig_tests.make_chou("Rouge"))
        swig_tests.make_choucroute(choux)

if __name__ == '__main__':
    # set defaultTest to invoke a specific test case
    unittest.main()

