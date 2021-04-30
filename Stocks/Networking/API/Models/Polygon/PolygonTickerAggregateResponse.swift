//
//  PolygonTickerAggregateResponse.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/30/21.
//

import Foundation

struct PolygonTickerAggregateResponse: Decodable {
	var results: [PolygonTickerAggregate]?
	var error: String?
}
