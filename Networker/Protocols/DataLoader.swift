//
//  DataLoader.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-24.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

protocol DataLoader {
    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> DataTask?
}

extension URLSession: DataLoader {
    func dataTask(
        with request: URLRequest,
        completion: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> DataTask? {
        return self.dataTask(with: request, completionHandler: completion)
    }
}
