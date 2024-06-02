//
//  APIService.swift
//  eDictionary
//
//  Created by Nikhil Bhosale on 2024-06-01.
//

import Foundation

enum HTTPMethod: String {
    case get
    case post
    case put
    case patch
    case delete
}

enum APIError: Error {
    case invalidUrl
    case invalidHTTPURLResponse
    case statusCodeNotHandled
    case emptyData
}

protocol APIRequest {
    var baseURLPath: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var queryParameters: [String: String]? { get }
}

extension APIRequest {
    var url: URL? {
        guard var urlComponents = URLComponents(string: baseURLPath + path) else { return nil }
        if urlComponents.queryItems == nil || urlComponents.queryItems?.isEmpty == true {
            urlComponents.queryItems = queryParameters?.map { URLQueryItem(name: $0, value: $1) }
        } else if let queryParams = queryParameters, var queryItems = urlComponents.queryItems {
            queryItems.append(contentsOf: queryParams.map { URLQueryItem(name: $0, value: $1) })
            urlComponents.queryItems = queryItems
        }

        guard let url = urlComponents.url else { return nil }
        return url
    }

    var urlRequest: URLRequest {
        get throws {
            guard let url else {
                throw APIError.invalidUrl
            }
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            return request
        }
    }
}

protocol APIRequestDispatcherProtocol {
    func execute(apiRequest: APIRequest) async throws -> (Data?, URLResponse?)
}

final class APIRequestDispatcher: APIRequestDispatcherProtocol {
    public func execute(apiRequest: APIRequest) async throws -> (Data?, URLResponse?) {
        let request = try apiRequest.urlRequest
        return try await URLSession.shared.data(for: request)
    }
}

protocol APIServiceProtocol {
    var dispatcher: APIRequestDispatcherProtocol { get }

    func performRequest(_ apiRequest: APIRequest) async throws -> APIServiceResponse
}

extension APIServiceProtocol {
    func performRequest(_ apiRequest: APIRequest) async throws -> APIServiceResponse {
        let response = try await dispatcher.execute(apiRequest: apiRequest)
        guard let httpResponse = response.1 as? HTTPURLResponse, let statusCode = httpResponse.httpStatusCode else {
            throw APIError.invalidHTTPURLResponse
        }
        return APIServiceResponse(statusCode: statusCode, data: response.0)
    }
}

struct APIServiceResponse {
    let statusCode: HTTPStatusCode
    let data: Data?
}

extension APIServiceResponse {
    func parse<T: Decodable>(with strategy: JSONDecoder.KeyDecodingStrategy? = nil) throws -> T {
        guard let data else { throw APIError.emptyData }
        let decoder = JSONDecoder()
        if let strategy {
            decoder.keyDecodingStrategy = strategy
        }
        if T.self is String.Type, let parsed = String(data: data, encoding: .utf8) as? T {
            return parsed
        }
        return try decoder.decode(T.self, from: data)
    }
}
