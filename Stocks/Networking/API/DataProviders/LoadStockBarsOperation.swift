//
//  LoadStockBarsOperation.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import Foundation

class LoadStockBarsOperation: AsyncOperation {

	var dataProvider: StocksDataProvider
	var ticker: String
	var fromDate: Date
	var toDate: Date

	var result: Result<[TickerAggregate], Error>?

	init(ticker: String, fromDate: Date, toDate: Date, dataProvider: StocksDataProvider) {
		self.ticker = ticker
		self.dataProvider = dataProvider
		self.fromDate = fromDate
		self.toDate = toDate
	}

	override func main() {
		if self.isCancelled {
			state = .finished
			return
		}

		dataProvider.loadStockBars(ticker, fromDate: fromDate, toDate: toDate) { result in
			if self.isCancelled {
				self.state = .finished
				return
			}

			self.result = result
			self.state = .finished
		}
	}
}
