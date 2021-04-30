//
//  PolygonTicker.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import Foundation

struct PolygonTicker: Ticker, Decodable {
	var symbol: String
	var name: String

	enum RootCodingKeys: String, CodingKey {
		case symbol = "ticker", name
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RootCodingKeys.self)

		symbol = try container.decode(String.self, forKey: .symbol)
		name = try container.decode(String.self, forKey: .name)
	}
}
