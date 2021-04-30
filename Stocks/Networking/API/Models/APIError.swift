//
//  APIError.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import Foundation

enum APIError: Error {
	case noData
	case apiError(msg: String)
}
