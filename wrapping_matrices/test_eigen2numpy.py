import unittest
import eigen2numpy
import numpy as np

class TestEigen2Numpy(unittest.TestCase):
    def test_import(self):
        pass

    def test_arg_in_arg_out(self):
        A = np.random.rand(5,6)
        B = np.empty(A.shape)
        eigen2numpy.function_with_argin_argout_matrixd(A,B)
        self.assertTrue(np.allclose(A,B))

    def test_arg_in_arg_out_single(self):
        A = np.random.rand(5,6).astype(np.float32)
        B = np.empty(A.shape,dtype=np.float32)
        eigen2numpy.function_with_argin_argout_matrixf(A,B)
        self.assertTrue(np.allclose(A,B))

    def test_arg_in_return_matrix(self):
        A = np.random.rand(51,63)
        B = eigen2numpy.function_returning_matrixd(A)
        self.assertEqual(A.shape, B.shape)        
        self.assertTrue(np.allclose(A,B))

if __name__ == '__main__':
    # set defaultTest to invoke a specific test case
    unittest.main()

