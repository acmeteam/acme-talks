import math
import functools as ft 

########################## classes ###########################
class A:
    
    def __init__(self, arg0):
        #class attribues
        self.attr0 = arg0
        self.attr1 = 3
    
    #this one can be used as static also ... 
    # a = A(), a.attr2 ... or A.attr2
    attr2 = 5 
    
    #"magic nethod" (implements operator +)
    def __add__(self, otherBject):
        #example implementation
        #send sum of both attr0 to the initialization
        newObject = A(self.attr0 + otherBject.attr0)
        #set newObject.attr1 as sum of both attr1
        newObject.attr1 = self.attr1 + otherBject.attr1
        return newObject
    
    #class method    
    def method_0(self):
        return 2 * self.attr0
  
# subclass
class B(A):
    
    #override
    def method_0(self):
        return 2 * self.attr0
    
    
    def method_1(self):
        return self.attr1 ** 2
        

########################## working with lists ###########################
#list with even numbers ... [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
l0 = list(range(0,20, 2))

#list with odd numbers ... [1, 3, 5, 7, 9, 11, 13, 15, 17, 19]
l1 = list(range(1,20, 2))

#list slicing [start:end:step]

#l1 -> [5, 7, 9]
sl0 = l1[2:5]

#l1 -> [1, 3, 5, 7, 9] (first 5)
sl1 = l1[:5]

#l1 -> [1, 3, 5, 7, 9] (last 5)
sl2 = l1[-5:]

#l1 -> [1, 5, 9, 13, 17] (every other, from the beginning to the end)
sl3 = l1[::2]


#zip -> [(0, 1),(2, 3),(4, 5),(6, 7),(8, 9),(10, 11),(12, 13),(14, 15),(16, 17),(18, 19)]
zp = list(zip(l0, l1))

#filter -> [3, 9, 15]
fl = list(filter(lambda x: x%3 == 0, l1))

#map -> [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
mp = list(map(lambda x: int(x/2), l0))

#reduce -> 100 ... sum of all elements
rd = ft.reduce(lambda a, b: a + b, l1)
#reduce, step-by-step:
#[1, 3, 5, 7, 9, 11, 13, 15, 17, 19] (a+b)-> [4, 5, 7, 9, 11, 13, 15, 17, 19]
#[4, 5, 7, 9, 11, 13, 15, 17, 19] (a+b)-> [9, 7, 9, 11, 13, 15, 17, 19]
#[9, 7, 9, 11, 13, 15, 17, 19] (a+b)->  [16, 9, 11, 13, 15, 17, 19]
# ...
# 100


#List Generator
def genList(start, end, step):
    num = start
    while num < end:
        yield num
        num += step
        
for i in genList(0, 5, 0.5):
    print(i)
   
# output :
# 0
# 0.5
# 1.0
# 1.5
# 2.0
# 2.5
# 3.0
# 3.5
# 4.0
# 4.5


#List Comperhension
cl = [math.sqrt(x) for x in range(0, 20) if x%3 == 0]
#this creates list of square roots of all numbers devidable by 3 in range from 0 to 20

