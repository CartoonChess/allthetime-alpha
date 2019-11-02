//
//  PropertyKeys.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

/// Static strings used throughout the app
struct Keys {
    
    typealias URLString = String
    struct URL {
        private static let base = "https://k03c8j1o5a.execute-api.ap-northeast-2.amazonaws.com/v1/programmers/"
        static var allCourses: URLString { base + "lectures" }
        static var timeTable: URLString { base + "timetable" }
        static var memos: URLString { base + "memo" }
    }
    
    typealias QueryType = String
    struct Query {
        static let title: QueryType = "lecture"
        static let code: QueryType = "code"
        static let userKey: QueryType = "user_key"
    }
    
    struct API {
        static let key = "QJuHAX8evMY24jvpHfHQ4pHGetlk5vn8FJbk70O6"
        static let header = "x-api-key"
    }
    
    struct User {
        // Demo app is single-user
        static let token = "c7da787941750f09b1d7f46afb671cd4" // in 설명 as `token_key_grepp`
    }
    
}
