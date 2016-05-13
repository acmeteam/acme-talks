//
//  testErrors.swift
//  testErrors
//
//  Created by Rasko Gojkovic on 5/13/16.
//  Copyright © 2016 Plantronics. All rights reserved.
//

import Foundation


class TestErrorExc {
    
    func doTest(){
        
        return
        
        do{
            let val = 1000
            
            var temp = try f0(val) ; print("temp = \(temp)")
            
            temp = try f1(temp) ; print("temp = \(temp)")
            
            let res = try f2(temp) ; print("res = \(res)")
            
        }
        catch Greska.ZASTOSEOVODESAVA(let val){
            print("ZASTOSEOVODESAVA - \(val)")
        }
        catch Greska.NEMOGUDAVERUJEM{
            print("NEMOGUDAVERUJEM")
        }
        catch Greska.JAOMAJKO{
            print("JAOMAJKO")
        }
        catch is ErrorType{
            print("Sta li je ovo?")
        }

    }
    
    func f0(x: Int) throws -> Int{
        if x < 0 {
            throw Greska.ZASTOSEOVODESAVA(42)
        }
        return 2 * x
    }

    func f1(x: Int) throws -> Int{
        if x < 3 {
            throw Greska.NEMOGUDAVERUJEM
        }
        return x - 3
    }

    func f2(x: Int) throws -> Double{
        if x > 1000 {
            throw Greska.JAOMAJKO
        }
        return (Double(x) / 1000.0)
    }
    
}
