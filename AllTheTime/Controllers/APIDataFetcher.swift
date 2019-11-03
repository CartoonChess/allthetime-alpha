//
//  APIDataFetcher.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

class APIDataFetcher {
    
    // MARK: - Properties
    
    private var courses: Courses?
    private var timeTable: TimeTable?
    private var memos: Memos?
    
    private var error: Error = GeneralError.unknown
    
    
    // MARK: - Methods
    
    /// Fetches all courses, user's time table, and memos.
    func fetchAll(completion: @escaping (Result<(Courses, TimeTable, Memos), Error>) -> Void) {
        // Create task group to wait for all API calls to finish
        let taskGroup = DispatchGroup()
        
        taskGroup.enter()
        fetchCourses { taskGroup.leave() }
        
        taskGroup.enter()
        fetchTimeTable { taskGroup.leave() }
        
        taskGroup.enter()
        fetchMemos { taskGroup.leave() }
        
        // Return when all tasks have completed
        taskGroup.notify(queue: .main) {
            if let courses = self.courses,
                let timeTable = self.timeTable,
                let memos = self.memos {
                completion(.success((courses, timeTable, memos)))
            } else {
                completion(.failure(self.error))
            }
        }
    }
    
    private func fetchCourses(completion: @escaping () -> Void) {
        Courses.fetch { result in
            switch result {
            case .success(let courses):
                print("Fetched courses.")
                self.courses = courses
            case .failure(let remoteError):
                self.error = remoteError
            }
            completion()
        }
    }
    
    private func fetchTimeTable(completion: @escaping () -> Void) {
        TimeTable.fetch { result in
            switch result {
            case .success(let timeTable):
                print("Fetched time table.")
                self.timeTable = timeTable
            case .failure(let remoteError):
                self.error = remoteError
            }
            completion()
        }
    }
    
    private func fetchMemos(completion: @escaping () -> Void) {
        Memos.fetch { result in
            switch result {
            case .success(let memos):
                print("Fetched memos.")
                self.memos = memos
            case .failure(let remoteError):
                self.error = remoteError
            }
            completion()
        }
    }
    
}
