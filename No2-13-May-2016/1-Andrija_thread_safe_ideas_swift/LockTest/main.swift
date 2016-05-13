import Foundation

protocol Locker
{
    func executeWithReadLock<T>(block:()-> T) -> T
    func executeWithWriteLock<T>(block:()-> T) -> T
}

class MyLocker : Locker
{
    // let me use pthread implementation of locker ;).
    // Level of indirection is not needed, but I did that to addopt PTHreadLocker api to Locker protocol
    var pthreadLocker:PThreadLocker = PThreadLocker();
    func executeWithReadLock<T>(block:()-> T) -> T
    {
        return pthreadLocker.withReadLock({
            return block()
        })
    }
    func executeWithWriteLock<T>(block:()-> T) -> T
    {
        return pthreadLocker.withWriteLock({
            return block()
        })
    }
}

struct DataToProtect<T>
{
    var lastChangeDate:NSDate?
    var array:Array<T> = []
    var appendCount = 0
}

class Protector<T>
{
    var lock: Locker = MyLocker()
    var data:T
    
    init(_ datatoprotect:T) {
        self.data = datatoprotect
    }
    
    func getRead<U>(block:(T)-> U ) -> U {
        return self.lock.executeWithReadLock({
            return block(self.data)
        })
    }
    func getWrite<U>(block:(inout T)-> U ) -> U {
        return self.lock.executeWithWriteLock({
            return block(&self.data)
        })
    }
}

class ArrayListener<T>
{
    var protector = Protector(DataToProtect<T>())
    
    func getAppendCount() -> Int{
        return protector.getRead({ intdate in
            return intdate.appendCount
        })
    }
 
    func getLastChangeDate() -> NSDate? {
        return protector.getRead( { (intdate:DataToProtect<T>) in
           return intdate.lastChangeDate
        })
    }
    
    func append(item:T) -> (NSDate?, Int) {
        return protector.getWrite( { intdata in
            intdata.lastChangeDate = NSDate()
            intdata.array.append(item)
            intdata.appendCount += 1
            
            return (intdata.lastChangeDate, intdata.array.count)
        })
    }
}


// Version 2.....after protector is buid, this class is thread sage ;)
var arrayListener = ArrayListener<Int>()
arrayListener.append(1)
var va = arrayListener.append(2)
var lc = arrayListener.getLastChangeDate()

var arrayListener2 = ArrayListener<String>()
arrayListener2.append("andrija")




// Version 1
var lastChangeDate:NSDate?
var array:Array<Int> = []

array.append(1)
lastChangeDate = NSDate()
array.append(2)
lastChangeDate = NSDate()







