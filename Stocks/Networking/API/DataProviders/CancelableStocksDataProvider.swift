//
//  CancelableStocksDataProvider.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import Foundation

class CancelableStocksDataProvider: StocksDataProvider, CancelableStockBarsLoading {

	var dataProvider: StocksDataProvider
	private lazy var operationQueue: OperationQueue = {
		let operation = OperationQueue()
		operation.maxConcurrentOperationCount = 1

		return operation
	}()

	private lazy var operationMap: [String: Operation] = {
		return [:]
	} ()

	init(dataProvider: StocksDataProvider) {
		self.dataProvider = dataProvider
	}

	func loadStocks(_ url: String?, completion: ((Result<Any, Error>) -> Void)?) {
		dataProvider.loadStocks(url, completion: completion)
	}

	func loadTickerDetails(_ticker: String, completion: ((Result<TickerInfo, Error>) -> Void)?) {
		dataProvider.loadTickerDetails(_ticker: _ticker, completion: completion)
	}

	func loadStockBars(_ ticker: String, fromDate: Date, toDate: Date, completion: ((Result<[TickerAggregate], Error>) -> Void)?) {

		let operation = LoadStockBarsOperation(ticker: ticker, fromDate: fromDate, toDate: toDate, dataProvider: dataProvider)

		operation.completionBlock = { [unowned operation] in
			guard let result = operation.result else {
				return
			}

			//TODO: Remove from operation list

			completion?(result)
		}

		operationMap[ticker]?.cancel()
		operationMap[ticker] = operation

//		print("### OPERATION COUNT: \(operationQueue.operationCount)")
		operationQueue.addOperation(operation)
	}

	func cancelLoadingStockBars(_ ticker: String) {
		operationMap[ticker]?.cancel()
	}
}
