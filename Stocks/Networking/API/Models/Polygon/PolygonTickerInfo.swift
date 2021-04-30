//
//  PolygonTickerInfo.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/30/21.
//

import Foundation

struct PolygonTickerInfo: TickerInfo, Decodable {
	var logo: String?
	var url: String?
	var description: String?
	var symbol: String?

	enum RootCodingKeys: String, CodingKey {
		case logo, url, description, symbol
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RootCodingKeys.self)

		logo = try container.decodeIfPresent(String.self, forKey: .logo)
		url = try container.decodeIfPresent(String.self, forKey: .url)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		symbol = try container.decodeIfPresent(String.self, forKey: .symbol)
	}
}
