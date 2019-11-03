//
//  GeneralError.swift
//  AllTheTime
//
//  Created by Xcode on ’19/10/30.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import Foundation


/// Provides a simple "unknown error" message in generic cases. Must be called using `GeneralError.unknown`.
enum GeneralError: LocalizedError {
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .unknown:
            return "Unknown error"
        }
    }
}
