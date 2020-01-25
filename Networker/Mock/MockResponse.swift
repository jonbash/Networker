//
//  MockResponse.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-25.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

struct MockResponse {
    var data: Data?
    var response: URLResponse?
    var error: Error?

    init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }
}
