//
//  ResultImp.swift
//  testErrors
//
//  Created by Rasko Gojkovic on 5/13/16.
//  Copyright © 2016 Plantronics. All rights reserved.
//

import Foundation

public enum MyResult<T, U> {
    case Success(T)
    case Failure(U)
    
    func then<V>(nextOperation:T -> MyResult<V, U>) -> MyResult<V, U> {
        switch self {
        case let .Failure(error): return .Failure(error)
        case let .Success(value): return nextOperation(value)
        }
    }
}