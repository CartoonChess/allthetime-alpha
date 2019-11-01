//
//  Course.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

struct Course: Codable {
    let title, code, location, professor, startTime, endTime: String
    let days: [String]
    // API does not provide course descriptions at this time
    let description = "강의 설명 없음"

    enum CodingKeys: String, CodingKey {
        case code, location, professor
        case title = "lecture"
        case startTime = "start_time"
        case endTime = "end_time"
        case days = "dayofweek"
    }
}

// Responses return an array of items
struct Courses: Codable {
    let results: [Course]
    // scannedCount does not appear to have a use at this time
    let count, scannedCount: Int

    enum CodingKeys: String, CodingKey {
        case results = "Items"
        case count = "Count"
        case scannedCount = "ScannedCount"
    }
    
    static func fetch(code: String? = nil, completion: @escaping (Result<Courses, Error>) -> Void) {
        var baseURL = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers/lectures"
        if let code = code { baseURL += "?code=\(code)" }
        
        guard let url = URL(string: baseURL) else {
            print("Can't form API request with URL \"\(baseURL)\".")
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("QJuHAX8evMY24jvpHfHQ4pHGetlk5vn8FJbk70O6", forHTTPHeaderField: "x-api-key")
        // Content-Type: application/json

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                if let response = response as? HTTPURLResponse {
                    print("Response code \(response.statusCode): \(response.statusMessage)")
                }
                print("Error retrieving courses from backend.")
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(GeneralError.unknown))
                }
                return
            }

            // Get course data
            completion(getCourses(from: data))
        }.resume()
    }
    
    static func fetch(title: String) {
        // TODO: Implement
    }
    
    static func fetch(title: String, code: String) {
        // TODO: Implement fetching by both, for when user is searching
    }
    
    private static func getCourses(from data: Data) -> Result<Courses, Error> {
        let decoder = JSONDecoder()
        do {
            let courses = try decoder.decode(Courses.self, from: data)
            return .success(courses)
        } catch {
            print("Error decoding JSON data.")
            return .failure(error)
        }
    }
}


