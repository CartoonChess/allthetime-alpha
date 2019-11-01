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
    // MARK: - Properties
    
    var results: [Course]
    // scannedCount does not appear to have a use at this time
    let count, scannedCount: Int

    enum CodingKeys: String, CodingKey {
        case results = "Items"
        case count = "Count"
        case scannedCount = "ScannedCount"
    }
    
    // MARK: - Methods
    
    // MARK: Fetch
    
    enum QueryType: String {
        case title = "lecture"
        case code
    }
    
    /// Returns matching courses from the server if `query` and `queryType` are specified, otherwise returns all courses.
    static func fetch(queryType: QueryType? = nil, query: String? = nil, completion: @escaping (Result<Courses, Error>) -> Void) {
        assert((queryType == nil) == (query == nil), "queryType and query must be specified together.")
        
        var urlString = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers/lectures"
        
        // Add the query, if applicable
        if let type = queryType?.rawValue,
            let query = query {
            urlString += "?\(type)=\(query)"
        }
        
        guard let url = URL(string: urlString) else {
            print("Can't form API request with URL \"\(urlString)\".")
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
    
    private static func getCourses(from data: Data) -> Result<Courses, Error> {
        let decoder = JSONDecoder()
        do {
            var courses = try decoder.decode(Courses.self, from: data)
            // Typically we want the courses sorted by code
            courses.results.sort { $0.code < $1.code }
            return .success(courses)
        } catch {
            print("Error decoding JSON data.")
            return .failure(error)
        }
    }
    
    // MARK: Filter
    
    enum FilterDetail {
        case quick, normal, full
    }
    
    func filterResults(by searchTerms: String, filterDetail: FilterDetail = .normal) -> [Course] {
        results.filter {
            // Get properties against which search terms will be checked
            let properties = getProperties(of: $0, for: filterDetail)
            
            let terms = searchTerms.lowercased()
            
            for property in properties {
                if property.lowercased().contains(terms) { return true }
            }
            return false
        }
    }
    
    func filterResults<ViewModel: CourseViewModel>(by searchTerms: String, as type: ViewModel.Type) -> [ViewModel] {
        let results = filterResults(by: searchTerms)
        return results.map { ViewModel($0) }
    }
    
    private func getProperties(of course: Course, for filterDetail: FilterDetail) -> [String] {
        var properties = [course.title, course.code]
        switch filterDetail {
        case .quick:
            // Quick search includes ony title and code
            break
        case .full:
            // Full searches on everything (inlcudes normal, below)
            properties.append(contentsOf: [course.description, course.startTime, course.endTime])
            properties.append(contentsOf: course.days)
            fallthrough
        default:
            // Normal searches quick plus the following
            properties.append(contentsOf: [course.professor, course.location])
        }
        return properties
    }
}
