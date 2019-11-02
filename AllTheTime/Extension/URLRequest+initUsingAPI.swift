//
//  URLRequest+initUsingAPI.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/02.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

extension URLRequest {
    init(url: URL, usingAPI: Bool) {
        self.init(url: url)
        if usingAPI { self.addValue(Keys.API.key, forHTTPHeaderField: Keys.API.header) }
        // Content-Type: application/json
    }
}
