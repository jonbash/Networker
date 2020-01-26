//
//  FetchOperation.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class FetchOperation: ConcurrentOperation {

    // MARK: Properties

    var request: URLRequest
    var result: Result<Data?, NetworkError>?

    var dataMayBeNil: Bool
    private let dataLoader: DataLoader
    private var dataTask: DataTask?

    // MARK: - Init

    init(request: URLRequest,
         dataMayBeNil: Bool = false,
         dataLoader: DataLoader = URLSession.shared
    ) {
        self.request = request
        self.dataLoader = dataLoader
        self.dataMayBeNil = dataMayBeNil

        super.init()
    }

    // MARK: - Methods

    override func start() {
        state = .isExecuting

        dataTask = dataLoader.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer { self.state = .isFinished }
            if self.isCancelled { return }

            if let error = error {
                self.result = .failure(.other(specifically: error))
                return
            }
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode >= 200 || httpResponse.statusCode <= 299
                else {
                    self.result = .failure(.non200Response(response: response, data: data))
                    return
            }
            if let data = data {
                self.result = .success(data)
            } else if self.dataMayBeNil {
                self.result = .success(nil)
            } else {
                self.result = .failure(.noData)
            }
        }
        dataTask?.resume()
    }

    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
