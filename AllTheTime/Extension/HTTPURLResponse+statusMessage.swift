//
//  HTTPURLResponse+statusMessage.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    
    // These are custom to the app, not universal to all servers
    var statusMessage: String {
        switch self.statusCode {
        case 200: return "OK"
        case 400: return "Bad Request (User key or code error, or empty request)"
        case 403: return "Forbidden (API key, URL path or HTTP method error, or invalid user token)"
        case 409: return "Conflict (Data already exists or no matching parent data)"
        case 422: return "Unprocessable Entity (Data improperly formatted, or attempting to delete data that does not exist)"
        case 500: return "Internal Server Error"
        default: return "Unknown Response"
        }
    }
    
}
