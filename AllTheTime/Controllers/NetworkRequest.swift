//
//  NetworkRequest.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

protocol NetworkRequestResponse: Codable {
    var message: String { get }
}

struct NetworkRequest {
    
    enum Method: String {
        case get = "GET"
        case post = "POST"
        case delete = "DELETE"
    }
    
    enum NetworkError: LocalizedError {
        case badURL(String)
        
        var errorDescription: String? {
            switch self {
            case .badURL(let urlString):
                return "Can't form API request with URL \"\(urlString)\""
            }
        }
    }
    
    static func execute(urlString: Keys.URLString,
                        queryType: Keys.QueryType? = nil,
                        query: String? = nil,
                        method: Method = .post,
                        postProperties: [String: String]? = nil,
                        completion: @escaping (Result<Data, Error>) -> Void) {
        
        checkAssertions(queryType: queryType, query: query, method: method, postProperties: postProperties)
        
        var urlString = urlString
        
        // Add the query, if applicable
        if let type = queryType,
            let query = query {
            urlString += "?\(type)=\(query)"
        }
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.badURL(urlString)))
            return
        }
        
        var request = URLRequest(url: url, usingAPI: true)
        request.httpMethod = method.rawValue
        
        // Encode JSON, if applicable
        if let properties = postProperties {
            do {
                let jsonData = try JSONEncoder().encode(properties)
                request.httpBody = jsonData
            } catch {
                completion(.failure(error))
                return
            }
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let response = response as? HTTPURLResponse {
                    print("Response code \(response.statusCode): \(response.statusMessage)")
                }
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(GeneralError.unknown))
                }
                return
            }
            
            // Return data to await custom actions
            completion(.success(data))
        }.resume()
    }
    
    private static func checkAssertions(queryType: Keys.QueryType? = nil,
                                 query: String? = nil,
                                 method: Method = .post,
                                 postProperties: [String: String]? = nil) {
        assert((queryType == nil) == (query == nil),
               "queryType and query must be specified together.")
        
        assert((method == .post && postProperties != nil) || (method != .post && postProperties == nil),
              "POST and JSON data must be specified together.")
    }
    
}
