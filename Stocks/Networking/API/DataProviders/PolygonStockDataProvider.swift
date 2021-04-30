//
//  PolygonStockDataProvider.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import Foundation
import Alamofire

class PolygonStockDataProvider: StocksDataProvider {

	let apiKey: String

	init(apiKey: String) {
		self.apiKey = apiKey
	}

	func loadStocks(_ url: String?, completion: ((Result<Any, Error>) -> Void)?) {

		let key = apiKey
		let limit = 50

		let requestUrl = url ?? "https://api.polygon.io/v3/reference/tickers?active=true&sort=ticker&order=asc&limit=\(limit)&apiKey=\(apiKey)"

		AF.request(requestUrl, method: .get).response(queue: DispatchQueue.global(qos: .userInitiated)) { response in
			switch response.result {
			case .success(let data):

				let decoder = JSONDecoder()

				guard let data = data else {
					completion?(.failure(APIError.noData))
					return
				}

				do {
					var parsedResponse = try decoder.decode(PolygonTickersResponse.self, from: data)

					if var url = parsedResponse.nextUrl {
						url.append("&apiKey=\(key)")
						parsedResponse.nextUrl = url
					}

					completion?(.success(parsedResponse))
				} catch let error {
					completion?(.failure(error))
				}

			case .failure(let error):
				DispatchQueue.main.async {
					completion?(.failure(error))
				}
			}
		}
	}

	func loadTickerDetails(_ticker: String, completion: ((Result<TickerInfo, Error>)-> Void)?) {
		let requestUrl = "https://api.polygon.io/v1/meta/symbols/\(_ticker)/company?&apiKey=\(apiKey)"

		AF.request(requestUrl, method: .get).response(queue: DispatchQueue.global(qos: .userInitiated)) { response in
			switch response.result {
			case .success(let data):

				let decoder = JSONDecoder()

				guard let data = data else {
					completion?(.failure(APIError.noData))
					return
				}

				do {
					let parsedResponse = try decoder.decode(PolygonTickerInfo.self, from: data)
					completion?(.success(parsedResponse))
				} catch let error {
					completion?(.failure(error))
				}

			case .failure(let error):
				DispatchQueue.main.async {
					completion?(.failure(error))
				}
			}
		}
	}

	func loadStockBars(_ ticker: String, fromDate: Date, toDate: Date, completion:((Result<[TickerAggregate], Error>)-> Void)?) {
		let range = 15
		let timestamp = "minute"
		let limit = 120

		let startInterval = Int(fromDate.timeIntervalSince1970 * 1000)
		let endInterval = Int(toDate.timeIntervalSince1970 * 1000)

		let requestUrl = "https://api.polygon.io/v2/aggs/ticker/\(ticker)/range/\(range)/\(timestamp)/\(startInterval)/\(endInterval)?unadjusted=true&sort=asc&limit=\(limit)&apiKey=\(apiKey)"

//		print("Load bars request: \(requestUrl)")

		AF.request(requestUrl, method: .get).response(queue: DispatchQueue.global(qos: .userInitiated)) { response in
			switch response.result {
			case .success(let data):

				let decoder = JSONDecoder()

				guard let data = data else {
					completion?(.failure(APIError.noData))
					return
				}

				do {
					let parsedResponse = try decoder.decode(PolygonTickerAggregateResponse.self, from: data)

					if let errorMsg = parsedResponse.error {
						completion?(.failure(APIError.apiError(msg: errorMsg)))
					} else {
						completion?(.success(parsedResponse.results ?? []))
					}
				} catch let error {
					completion?(.failure(error))
				}

			case .failure(let error):
				DispatchQueue.main.async {
					completion?(.failure(error))
				}
			}
		}
	}
}
