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

    // TODO: refactor so there's not so many nested calls

    func fetch<DecodableModel: Decodable>(
        _ type: DecodableModel.Type,
        withRequest request: URLRequest,
        completion: @escaping (Result<DecodableModel, NetworkError>) -> Void
    ) -> DataTask? {
        return fetchData(withRequest: request) { [weak self] result in
            guard let self = self else { return }
            self.handleDataResult(result, completion: completion)
        }
    }

    func fetchOptional<DecodableModel: Decodable>(
        _ type: DecodableModel.Type,
        withRequest request: URLRequest,
        completion: @escaping (Result<DecodableModel?, NetworkError>) -> Void
    ) -> DataTask? {
        return fetchOptionalData(withRequest: request) { [weak self] result in
            guard let self = self else { return }
            self.handleOptionalDataResult(result, completion: completion)
        }
    }

    func fetchData(
        withRequest request: URLRequest,
        completion: @escaping (Result<Data, NetworkError>) -> Void
    ) -> DataTask? {
        return fetchOptionalData(withRequest: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if let data = data {
                    completion(.success(data))
                } else {
                    self.log("No data!")
                    completion(.failure(.noData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func fetchOptionalData(
        withRequest request: URLRequest,
        completion: @escaping (Result<Data?, NetworkError>) -> Void
    ) -> DataTask? {
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
            self.log("Passing on (possible) fetched data: \(String(describing: data))")
            completion(.success(data))
        }
    }

    // MARK: - Private

    private func handleDataResult<DecodableModel: Decodable>(
        _ result: Result<Data, NetworkError>,
        completion: @escaping (Result<DecodableModel, NetworkError>) -> Void
    ) {
        switch result {
        case .success(let data):
            do {
                let model = try self.decoder.decode(DecodableModel.self, from: data)
                completion(.success(model))
            } catch {
                completion(.failure(.dataCodingError(specifically: error, data: data)))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }

    private func handleOptionalDataResult<DecodableModel: Decodable>(
        _ result: Result<Data?, NetworkError>,
        completion: @escaping (Result<DecodableModel?, NetworkError>) -> Void
    ) {
        switch result {
        case .success(let data):
            guard let data = data else {
                completion(.success(nil))
                return
            }
            do {
                let model = try self.decoder.decode(DecodableModel.self, from: data)
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

    private func log<S: ExpressibleByStringLiteral>(_ string: S) {
        if verboseLogging {
            print("Networker: \(string)")
        }
    }
}
