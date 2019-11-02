//
//  TimeTable.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

//// Courses and TimeTable return identical results, minus the specific contents of `item`
//protocol CourseItemsContainer: Codable {
//    var count: Int { get }
//    var scannedCount: Int { get }
//}

// Items from TimeTable call have only one property
struct TimeTableItem: Codable {
    let courseCode: String
    
    enum CodingKeys: String, CodingKey {
        case courseCode = "lecture_code"
    }
}

struct TimeTableItem_: Codable {
    let courseCode: String
    
    enum CodingKeys: String, CodingKey {
        case courseCode = "lecture_code"
    }
}

/// Contains only the courses to which the user has registered.
struct TimeTable: Codable {
    private var items: [TimeTableItem]
    private let count, scannedCount: Int
    var courseCodes: [String] = []

    enum CodingKeys: String, CodingKey {
        case items = "Items"
        case count = "Count"
        case scannedCount = "ScannedCount"
    }
    
    init(from data: Data) throws {
        self = try JSONDecoder().decode(TimeTable.self, from: data)
        self.courseCodes = self.items.map { $0.courseCode }
    }
    
    static func fetch(completion: @escaping (Result<TimeTable, Error>) -> Void) {
        NetworkRequest.execute(urlString: Keys.URL.userCourses,
                               queryType: Keys.Query.userKey,
                               query: Keys.User.token,
                               method: .get) {
            result in
            
            switch result {
            case .success(let data):
                completion(getCourseCodes(from: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func getCourseCodes(from data: Data) -> Result<TimeTable, Error> {
        do {
            let timeTable = try TimeTable(from: data)
            return .success(timeTable)
        } catch {
            return .failure(error)
        }
    }
}
