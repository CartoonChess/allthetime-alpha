//
//  Memo.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

// Items from TimeTable call have only one property
struct Memo: Codable {
    // MARK: - Properties
    
    // Used without modification
    let title, body, courseCode: String
    // To be modified
    private let rawType: String
    private let dateString: String
    // Modified in init
    var date = Date()
    var type: MemoType = .study
    // Unneeded
    private let userKey: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case rawType = "type"
        case userKey = "user_key"
        case courseCode = "lecture_code"
        case body = "description"
        case dateString = "date"
    }
    
    enum MemoType: String {
        case assignment = "HOMEWORK"
        case exam = "EXAM"
        case study = "STUDY"
    }
    
    // MARK: - Methods
    
    init(from decoder: Decoder) throws {
        // Manually decode so we can assign some values
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Raw values from decode
        self.title = try container.decode(String.self, forKey: .title)
        self.rawType = try container.decode(String.self, forKey: .rawType)
        self.userKey = try container.decode(String.self, forKey: .userKey)
        self.courseCode = try container.decode(String.self, forKey: .courseCode)
        self.body = try container.decode(String.self, forKey: .body)
        self.dateString = try container.decode(String.self, forKey: .dateString)
        
        // Custom values
        self.date = Date(string: dateString)
        
        switch rawType {
        case "HOMEWORK":
            self.type = .assignment
        case "EXAM":
            self.type = .exam
        default:
            // Keep .study
            break
        }
    }
    
    /// Create a new memo to be sent to the server.
    init(title: String,
         body: String,
         type: MemoType,
         courseCode: String) {
        self.title = title
        self.body = body
        self.type = type
        self.courseCode = courseCode
        
        self.rawType = type.rawValue
        self.date = Date()
        self.dateString = date.string
        self.userKey = Keys.User.token
    }
}

struct MemoResponse: NetworkRequestResponse {
    let message: String
}

/// Contains only the courses to which the user has registered.
struct Memos: Codable {
    // MARK: - Properties
    private let results: [Memo]
    private let count, scannedCount: Int
    // Ordered by course + date
    var all: [String: [Memo]] = [:]

    enum CodingKeys: String, CodingKey {
        case results = "Items"
        case count = "Count"
        case scannedCount = "ScannedCount"
    }
    
    // MARK: - Methods
    
    // MARK: Fetch
    
    static func fetch(completion: @escaping (Result<Memos, Error>) -> Void) {
        NetworkRequest.execute(urlString: Keys.URL.memos,
                               queryType: Keys.Query.userKey,
                               query: Keys.User.token,
                               method: .get) {
            result in
            
            switch result {
            case .success(let data):
                completion(getMemos(from: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func getMemos(from data: Data) -> Result<Memos, Error> {
        do {
            var memos = try JSONDecoder().decode(Memos.self, from: data)
            // Group by course, and order by date
            memos.all = sort(memos)
            return .success(memos)
        } catch {
            return .failure(error)
        }
    }
    
    private static func sort(_ memos: Memos) -> [String: [Memo]]{
        var allMemos: [String: [Memo]] = [:]
        
        // Sort into courses
        for memo in memos.results {
            // Add memo to course's other memos, or else put memo alone in new course group
            if allMemos[memo.courseCode] != nil {
                allMemos[memo.courseCode]!.append(memo)
            } else {
                allMemos[memo.courseCode] = [memo]
            }
        }
        
        // Sort each course's memos by date
        for var course in allMemos {
            course.value.sort { $0.date < $1.date }
            allMemos[course.key] = course.value
        }
        
        return allMemos
    }
    
    // MARK: Add
    
    static func add(_ memo: Memo, completion: @escaping (Result<String, Error>) -> Void) {
        let postProperties = [
            "user_key": Keys.User.token,
            "code": memo.courseCode,
            "type": memo.type.rawValue,
            "title": memo.title,
            "description": memo.body,
            "date": memo.date.string
        ]

        NetworkRequest.execute(urlString: Keys.URL.memos,
                               method: .post,
                               postProperties: postProperties) {
            result in

            switch result {
            case .success(let data):
                completion(getResponse(from: data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private static func getResponse(from data: Data) -> Result<String, Error> {
        do {
            let response = try JSONDecoder().decode(TimeTableResponse.self, from: data)
            return .success(response.message)
        } catch {
            return .failure(error)
        }
    }
    
    // MARK: Check
    
    /// Returns memo types not yet associated with a course
    func unregisteredMemos(courseCode: String) -> [Memo.MemoType] {
        let memos = self.all[courseCode] ?? []
        
        var types: [Memo.MemoType] = []
        
        if memos.count > 0 {
            // Get possible memos
            if memos.first(where: { $0.type == .study }) == nil {
                types.append(.study)
            }
            if memos.first(where: { $0.type == .assignment }) == nil {
                types.append(.assignment)
            }
            if memos.first(where: { $0.type == .exam }) == nil {
                types.append(.exam)
            }
        } else {
            return [.study, .assignment, .exam]
        }
        
        return types
    }
    
}
