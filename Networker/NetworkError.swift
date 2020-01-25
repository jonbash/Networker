//
//  NetworkError.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-24.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

enum NetworkError: Error {
    case noData
    case badData(data: Data?)
    case dataCodingError(specifically: Error?, data: Data?)
    case non200Response(response: URLResponse?, data: Data?)
    case other(specifically: Error)
}

extension NetworkError: Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch lhs {
        case .noData:
            return rhs == .noData
        case .badData:
            if case .badData = rhs { return true } else { return false }
        case .dataCodingError(let codingError, _):
            if case .dataCodingError(let rhCodingError, _) = rhs,
                codingError?.localizedDescription == rhCodingError?.localizedDescription {
                return true
            } else { return false }
        case .non200Response(let response, _):
            if case .non200Response(let rhResponse, _) = rhs,
                response == rhResponse {
                return true
            } else { return false }
        case .other(let specificError):
            if case .other(let rhError) = rhs,
                specificError.localizedDescription == rhError.localizedDescription {
                return true
            } else { return false }
        }
    }
}
