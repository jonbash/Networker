//
//  Cache.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {
    private var cache: Atomic<[Key: Value]> = Atomic([Key: Value]())

    subscript(_ key: Key) -> Value? {
        get { value(forKey: key) }
        set { cache(newValue, forKey: key) }
    }

    func cache(_ value: Value?, forKey key: Key) {
        self.cache.wrappedValue[key] = value
    }

    func value(forKey key: Key) -> Value? {
        self.cache.wrappedValue[key]
    }

    func clear() {
        self.cache.wrappedValue.removeAll()
    }
}
