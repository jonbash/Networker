//
//  Networker.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-24.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Combine

class Networker {

    // MARK: - Properties

    var dataLoader: DataLoader
    var decoder: DataDecoder

    var verboseLogging: Bool

    // MARK: - Init

    init(dataLoader: DataLoader = URLSession.shared,
         decoder: DataDecoder = JSONDecoder(),
         verboseLogging: Bool = false
    ) {
        self.dataLoader = dataLoader
        self.decoder = decoder
        self.verboseLogging = verboseLogging
    }

    func fetchData(
        fromURL url: URL,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetchData(withRequest: URLRequest(url: url), completion: completion)
    }

    func fetchData(
        withRequest request: URLRequest,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetchOptionalData(withRequest: request) { result in
            switch result {
            case .success(let data):
                if let data = data {
                    completion(.success(data))
                } else {
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchOptionalData(
        fromURL url: URL,
        completion: @escaping (Result<Data?, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetchOptionalData(withRequest: URLRequest(url: url),
                                 completion: completion)
    }

    func fetchOptionalData(
        withRequest request: URLRequest,
        completion: @escaping (Result<Data?, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return dataLoader.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                self.log("Error with request \(request): \(error)")
                completion(.failure(.other(specifically: error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode >= 200 && httpResponse.statusCode < 300
                else {
                    self.log("Bad or no response for request \(request)")
                    completion(.failure(.non200Response(response: response, data: data)))
                    return
            }

            completion(.success(data))
        }
    }

    private func log(_ string: String) {
        if verboseLogging {
            print(string)
        }
    }
}
