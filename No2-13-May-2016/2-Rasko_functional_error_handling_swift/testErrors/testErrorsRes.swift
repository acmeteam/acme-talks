//
//  testErrorsRes.swift
//  testErrors
//
//  Created by Rasko Gojkovic on 5/13/16.
//  Copyright © 2016 Plantronics. All rights reserved.
//

import Foundation
import Result


class TestErrorRes {
    
    func doTest(){
        let val = 1000
        
        let res = f0(val)
            .flatMap { (tempVal:Int) -> Result<Int, Greska> in
            
                print("temp = \(tempVal)") ; return self.f1(tempVal)
            
            }.flatMap{ (tempVal:Int) -> Result<Double, Greska> in
                
                print("temp = \(tempVal)") ; return self.f2(tempVal)
                
            }
        
        print("res = \(res)")
        
        
        switch res {
        case .Failure(Greska.ZASTOSEOVODESAVA(let val)):
            print("ZASTOSEOVODESAVA - \(val)")
        case .Failure(Greska.NEMOGUDAVERUJEM):
            print("NEMOGUDAVERUJEM")
        case .Failure(Greska.JAOMAJKO):
            print("JAOMAJKO")
        default:
            print("SUCCESS!!!")
        }
    }
    
    
    func f0(x: Int) -> Result<Int, Greska>{
        if x < 0 {
            return .Failure(Greska.ZASTOSEOVODESAVA(42))
        }
        return .Success(2 * x)
    }
    
    func f1(x: Int) -> Result<Int, Greska>{
        if x < 3 {
            return .Failure(Greska.NEMOGUDAVERUJEM)
        }
        return .Success(x - 3)
    }
    
    func f2(x: Int) -> Result<Double, Greska>{
        if x > 1000 {
            return .Failure(Greska.JAOMAJKO)
        }
        return .Success(Double(x) / 1000.0)
    }
    
}
