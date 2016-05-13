//
//  PThreadLocker.swift
//  LockTest
//
//  Created by Andrija Milovanovic on 5/13/16.
//  Copyright © 2016 Endava. All rights reserved.
//

import Cocoa

public final class PThreadLocker {

    private var lock = pthread_rwlock_t()
    
    init() {
        let status = pthread_rwlock_init(&lock, nil)
        assert(status == 0)
    }
    deinit {
        let status = pthread_rwlock_destroy(&lock)
        assert(status == 0)
    }
    
    public func withReadLock<Return>(@noescape body: () throws -> Return) rethrows -> Return {
        pthread_rwlock_rdlock(&lock)
        defer {
            pthread_rwlock_unlock(&lock)
        }
        return try body()
    }
    public func withWriteLock<Return>(@noescape body: () throws -> Return) rethrows -> Return {
        pthread_rwlock_wrlock(&lock)
        defer {
            pthread_rwlock_unlock(&lock)
        }
        return try body()
    }
    public func withAttemptedReadLock<Return>(@noescape body: () throws -> Return) rethrows -> Return? {
        guard pthread_rwlock_tryrdlock(&lock) == 0 else { return nil }
        defer {
            pthread_rwlock_unlock(&lock)
        }
        return try body()
    }
}
