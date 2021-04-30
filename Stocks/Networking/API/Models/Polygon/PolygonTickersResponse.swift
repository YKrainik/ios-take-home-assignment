//
//  PolygonTickersResponse.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import Foundation

struct PolygonTickersResponse: Decodable {
	var items: [PolygonTicker]?
	var nextUrl: String?

	enum RootCodingKeys: String, CodingKey {
		case results, nextURL = "next_url"
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RootCodingKeys.self)

		items = try container.decodeIfPresent(Array<PolygonTicker>.self, forKey: .results)
		nextUrl = try container.decodeIfPresent(String.self, forKey: .nextURL)
	}
}	
