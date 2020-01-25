//
//  MockTask.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-25.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class MockTask: DataTask {
    internal init(
        request: URLRequest,
        receipt: MockResponse? = nil,
        delay: TimeInterval = 0.5,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) {
        self.request = request
        self.receipt = receipt
        self.delay = delay
        self.completion = completion
    }

    private(set) var request: URLRequest
    private var receipt: MockResponse?

    private var completion: (Data?, URLResponse?, Error?) -> Void

    private var delay: TimeInterval

    private(set) var state: URLSessionTask.State = .suspended

    func resume() {
        self.state = .running
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self, self.state == .running else { return }
            self.state = .completed
            self.completion(self.receipt?.data, self.receipt?.response, self.receipt?.error)
        }
    }

    func cancel() {
        self.state = .canceling
    }

    func suspend() {
        self.state = .suspended
    }
}
