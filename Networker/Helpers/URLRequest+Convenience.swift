//
//  URLRequest+Convenience.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-24.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

extension URLRequest {
    init(withURL url: URL,
         method: HTTPMethod = .get,
         cachePolicy: CachePolicy = .useProtocolCachePolicy,
         timeoutInterval: TimeInterval = 60
    ) {
        self.init(url: url, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
        self.httpMethod = method.rawValue
    }
}
