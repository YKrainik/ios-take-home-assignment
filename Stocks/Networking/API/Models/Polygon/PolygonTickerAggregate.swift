//
//  PolygonTickerAggregate.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/30/21.
//

import Foundation

struct PolygonTickerAggregate: TickerAggregate, Decodable {
	var openPrice: Double
	var highestPrice: Double
	var lowestPrice: Double
	var closePrice: Double
	var startTimeAggregate: Date

	enum RootCodingKeys: String, CodingKey {
		case openPrice = "o",
			 highestPrice = "h",
			 lowestPrice = "l",
			 closePrice = "c",
			 startTimeAggregate = "t"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RootCodingKeys.self)

		openPrice = try container.decode(Double.self, forKey: .openPrice)
		highestPrice = try container.decode(Double.self, forKey: .highestPrice)
		lowestPrice = try container.decode(Double.self, forKey: .lowestPrice)
		closePrice = try container.decode(Double.self, forKey: .closePrice)

		let timeInterval = try container.decode(TimeInterval.self, forKey: .startTimeAggregate)
		startTimeAggregate = Date(timeIntervalSince1970: timeInterval / 1000)
	}
}
