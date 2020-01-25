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

    // MARK: - Fetch

    func fetch<T: Decodable>(
        _ type: T.Type,
        fromURL url: URL,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetch(T.self, withRequest: URLRequest(url: url), completion: completion)
    }

    func fetch<T: Decodable>(
        _ type: T.Type,
        withRequest request: URLRequest,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetchOptional(T.self, withRequest: request) { result in
            switch result {
            case .success(let possibleModel):
                if let model = possibleModel {
                    completion(.success(model))
                } else {
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchOptional<T: Decodable>(
        _ type: T.Type,
        fromURL url: URL,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetchOptional(T.self, withRequest: URLRequest(url: url), completion: completion)
    }

    func fetchOptional<T: Decodable>(
        _ type: T.Type,
        withRequest request: URLRequest,
        completion: @escaping (Result<T?, NetworkError>) -> Void
    ) -> URLSessionDataTask {
        return fetchOptionalData(withRequest: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.success(nil))
                    return
                }
                do {
                    let model = try self.decoder.decode(T.self, from: data)
                    completion(.success(model))
                } catch {
                    completion(.failure(.dataCodingError(specifically: error, data: data)))
                }
            case .failure(let error):
                if error == .noData {
                    completion(.success(nil))
                } else {
                    completion(.failure(error))
                }
            }
        }
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

    // MARK: - Private

    private func log(_ string: String) {
        if verboseLogging {
            print(string)
        }
    }
}
