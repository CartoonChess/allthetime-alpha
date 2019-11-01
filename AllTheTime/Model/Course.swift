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
    let description = "강의 설명 없음 Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Vitae suscipit tellus mauris a diam maecenas. Pharetra convallis posuere morbi leo. Metus aliquam eleifend mi in nulla posuere sollicitudin aliquam. Tristique magna sit amet purus gravida quis blandit. Velit aliquet sagittis id consectetur purus ut faucibus pulvinar elementum. Id nibh tortor id aliquet lectus proin nibh. Lobortis scelerisque fermentum dui faucibus in ornare quam. Ornare aenean euismod elementum nisi quis eleifend quam adipiscing. Et netus et malesuada fames ac turpis egestas integer eget. Cursus turpis massa tincidunt dui ut ornare lectus sit. Integer malesuada nunc vel risus commodo. In hac habitasse platea dictumst vestibulum. Penatibus et magnis dis parturient. At imperdiet dui accumsan sit amet. Vel risus commodo viverra maecenas accumsan lacus vel facilisis volutpat. At auctor urna nunc id cursus. Vehicula ipsum a arcu cursus vitae congue mauris rhoncus aenean. Dui sapien eget mi proin sed libero enim sed. Maecenas pharetra convallis posuere morbi./n/nPlacerat duis ultricies lacus sed turpis tincidunt id aliquet risus. Nulla posuere sollicitudin aliquam ultrices. Consectetur purus ut faucibus pulvinar. Aliquet nec ullamcorper sit amet risus nullam. Purus viverra accumsan in nisl nisi scelerisque eu. Feugiat in ante metus dictum at tempor commodo ullamcorper. Non arcu risus quis varius quam quisque id. Ipsum dolor sit amet consectetur adipiscing elit duis tristique sollicitudin. Fermentum dui faucibus in ornare quam viverra. Purus faucibus ornare suspendisse sed nisi. Non enim praesent elementum facilisis leo vel fringilla. Ut enim blandit volutpat maecenas. Feugiat nisl pretium fusce id velit ut tortor pretium viverra. Viverra ipsum nunc aliquet bibendum enim facilisis gravida neque. Dis parturient montes nascetur ridiculus mus mauris vitae ultricies. Dolor sit amet consectetur adipiscing elit duis tristique. Semper feugiat nibh sed pulvinar. Porttitor massa id neque aliquam vestibulum morbi. Vehicula ipsum a arcu cursus vitae congue. Nunc lobortis mattis aliquam faucibus./n/nRisus in hendrerit gravida rutrum quisque non tellus orci ac. Amet facilisis magna etiam tempor orci eu lobortis elementum. Tortor condimentum lacinia quis vel. Tellus cras adipiscing enim eu turpis. Ut ornare lectus sit amet est placerat in egestas. Sagittis aliquam malesuada bibendum arcu vitae. Gravida arcu ac tortor dignissim convallis aenean et tortor at. Turpis massa tincidunt dui ut ornare lectus sit. Leo duis ut diam quam nulla porttitor massa id neque. Pretium fusce id velit ut tortor pretium viverra suspendisse. Faucibus vitae aliquet nec ullamcorper sit amet risus nullam eget. At tellus at urna condimentum mattis. Sed id semper risus in. Auctor neque vitae tempus quam pellentesque. Egestas diam in arcu cursus euismod quis viverra nibh cras. Et pharetra pharetra massa massa ultricies mi. Est ante in nibh mauris cursus mattis molestie a. Id eu nisl nunc mi. Nisi vitae suscipit tellus mauris a diam maecenas. Mauris pharetra et ultrices neque ornare aenean euismod."

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
        if let code = code,
            !code.isEmpty { baseURL += "?code=\(code)" }
        
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


