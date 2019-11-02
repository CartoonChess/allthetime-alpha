//
//  NetworkRequest.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

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
                        completion: @escaping (Result<Data, Error>) -> Void) {
        
        assert((queryType == nil) == (query == nil), "queryType and query must be specified together.")
        
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
        
        let request = URLRequest(url: url, usingAPI: true)

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
    
}
