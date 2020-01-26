//
//  FetchOperationManager.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class FetchOperationManager<FetchedModel: Decodable, Index: Hashable> {
    typealias CompletionBlock = (Result<FetchedModel?, NetworkError>) -> Void
    typealias RequestBuilder = (Index) -> URLRequest

    var dataMayBeNil: Bool = false
    var dataLoader: DataLoader = URLSession.shared
    var decoder: DataDecoder = JSONDecoder()

    private var requestBuilder: RequestBuilder
    private let cache = Cache<Index, FetchedModel>()
    private let fetchQueue = OperationQueue()
    private var fetchOperations = [Index: Operation]()

    init(model: FetchedModel.Type,
         index: Index.Type,
         requestBuilder: @escaping RequestBuilder
    ) {
        self.requestBuilder = requestBuilder
    }

    func fetchModel(forIndex index: Index, completion: @escaping CompletionBlock) {
        if let cachedModel = cache[index] {
            completion(.success(cachedModel))
            return
        }
        var error: NetworkError?
        let fetchOp = FetchOperation(request: requestBuilder(index),
                                     dataMayBeNil: dataMayBeNil,
                                     dataLoader: dataLoader)
        let cacheOp = BlockOperation { [weak self] in
            guard let self = self else { return }
            guard let result = fetchOp.result else {
                error = .other(specifically: nil)
                return
            }
            var possibleData: Data?
            switch result {
            case .success(let data):
                possibleData = data
            case .failure(let fetchError):
                error = fetchError
                return
            }

            guard let fetchedData = possibleData else {
                if self.dataMayBeNil {
                    self.cache[index] = nil
                } else {
                    error = .noData
                }
                return
            }

            if FetchedModel.self != Data.self {
                self.cache[index] = fetchedData as? FetchedModel
                return
            }

            do {
                let fetchedModel = try self.decoder.decode(FetchedModel.self, from: fetchedData)
                self.cache[index] = fetchedModel
            } catch let decodeError {
                error = .dataCodingError(specifically: decodeError, data: fetchedData)
            }
        }
        let completionOp = BlockOperation { [weak self] in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
            } else {
                let model: FetchedModel? = self.cache[index]
                completion(.success(model))
            }
            self.fetchOperations.removeValue(forKey: index)
        }

        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(cacheOp)

        fetchQueue.addOperation(fetchOp)
        fetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)

        fetchOperations[index] = fetchOp
    }
}
