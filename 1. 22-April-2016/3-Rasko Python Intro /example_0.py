import time

################## function decoration ##################

#decorator
def timed(f):
    def wrapper(a, b):
        time.clock()
        res = f(a, b)
        print("time: "+str(time.clock()))
        return res
    
    return wrapper
    
#decorated function
@timed
def add0(a, b):
    time.sleep(1)
    return a+b

#decorated function
@timed
def add1(a,b):
    time.sleep(1.3)
    return a+b
    