//
//  MockLoader.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-25.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class MockLoader: DataLoader {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    var delay: TimeInterval = 0.5

    func dataTask(with request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) -> DataTask? {
        return MockTask(request: request,
                        receipt: MockResponse(
                            data: data,
                            response: response,
                            error: error),
                        delay: delay,
                        completion: completion)
    }
}
