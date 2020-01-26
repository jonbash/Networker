//
//  Atomic.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

@propertyWrapper
struct Atomic<Value> {
    private lazy var queue: DispatchQueue = {
        let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
        return DispatchQueue(label: "\(appName).AtomicQueue.\(Value.self)")
    }()
    private var value: Value

    var wrappedValue: Value {
        mutating get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }

    init(_ wrappedValue: Value) {
        self.value = wrappedValue
    }

    mutating func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync {
            mutation(&value)
        }
    }
}

extension Atomic: Equatable where Value: Equatable {
    static func == (lhs: Atomic<Value>, rhs: Atomic<Value>) -> Bool {
        var (mutableLhs, mutableRhs) = (lhs, rhs)
        return mutableLhs.wrappedValue == mutableRhs.wrappedValue
    }
}
