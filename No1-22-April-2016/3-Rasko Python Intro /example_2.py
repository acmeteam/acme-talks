import unittest
import example_0

################## unit tests ##################

class myTest(unittest.TestCase):
    def setUp(self):
        #do something
        pass

    def tearDown(self):
        #do something else
        pass
        
    def test_someFunctionality(self):
        res = example_0.add0(2, 3)
        self.assertEqual(res, 6)

    def test_someOtherFunctionality(self):
        res = example_0.add1(2, 3)
        self.assertEqual(res, 5)
        

#if you use this file as a script ("run it"), implicitely defined variable __name__ will have a value: "__main__"
if __name__ == '__main__':
    suite = unittest.TestLoader().loadTestsFromTestCase(myTest)
    unittest.TextTestRunner(verbosity=2).run(suite)