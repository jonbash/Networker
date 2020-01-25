//
//  DataTask.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-25.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

protocol DataTask {
    var state: URLSessionTask.State { get }

    func resume()
    func cancel()
    func suspend()
}

extension URLSessionDataTask: DataTask {
}
