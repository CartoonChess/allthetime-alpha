//
//  Course.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

typealias DayNumber = Int
extension String {
    var dayNumber: DayNumber {
        switch self {
        case "월":
            return 0
        case "화":
            return 1
        case "수":
            return 2
        case "목":
            return 3
        case "금":
            return 4
        default:
            fatalError("Days must be one of the following: 월 화 수 목 금")
        }
    }
}
extension DayNumber {
    var string: String {
        switch self {
        case 0:
            return "월"
        case 1:
            return "화"
        case 2:
            return "수"
        case 3:
            return "목"
        case 4:
            return "금"
        default:
            fatalError("Day numbers must be between 0 and 4 inclusive.")
        }
    }
}

struct Course: Codable {
    let title, code, location, professor, startTime, endTime: String
    var dayStrings: [String]
    let dayNumbers: [DayNumber]
    // API does not provide course descriptions at this time
    let description = "강의 설명 없음"

    enum CodingKeys: String, CodingKey {
        case code, location, professor
        case title = "lecture"
        case startTime = "start_time"
        case endTime = "end_time"
        case dayStrings = "dayofweek"
    }
    
    init(from decoder: Decoder) throws {
        // Manually decode so we can assign day numbers
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Raw values from decode
        self.title = try container.decode(String.self, forKey: .title)
        self.code = try container.decode(String.self, forKey: .code)
        self.location = try container.decode(String.self, forKey: .location)
        self.professor = try container.decode(String.self, forKey: .professor)
        self.startTime = try container.decode(String.self, forKey: .startTime)
        self.endTime = try container.decode(String.self, forKey: .endTime)
        
        // Convert days to numbers
        self.dayStrings = try container.decode([String].self, forKey: .dayStrings)
        self.dayNumbers = self.dayStrings.map({ $0.dayNumber }).sorted()
        // Update strings with sorted version
        self.dayStrings = self.dayNumbers.map { $0.string }
    }
}

// Responses return an array of items
struct Courses: Codable {
    // MARK: - Properties
    
    var results: [Course]
    // scannedCount does not appear to have a use at this time
    private let count, scannedCount: Int

    enum CodingKeys: String, CodingKey {
        case results = "Items"
        case count = "Count"
        case scannedCount = "ScannedCount"
    }
    
    // MARK: - Methods
    
    // MARK: Fetch
    
    /// Returns matching courses from the server if `query` and `queryType` are specified, otherwise returns all courses.
    static func fetch(queryType: Keys.QueryType? = nil, query: String? = nil, completion: @escaping (Result<Courses, Error>) -> Void) {
        NetworkRequest.execute(urlString: Keys.URL.allCourses,
                               queryType: queryType,
                               query: query,
                               method: .get) {
            result in
                                
            switch result {
            case .success(let data):
                completion(getCourses(from: data))
            case .failure(let error):
                print("Failed to fetch courses: \(error.localizedDescription)")
            }
        }
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
            properties.append(contentsOf: course.dayStrings)
            fallthrough
        default:
            // Normal searches quick plus the following
            properties.append(contentsOf: [course.professor, course.location])
        }
        return properties
    }
}
