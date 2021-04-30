//
//  StocksDataProvider.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import Foundation

protocol StocksDataProvider {
	func loadStocks(_ url: String?, completion: ((Result<Any, Error>)-> Void)?)
	func loadTickerDetails(_ticker: String, completion: ((Result<TickerInfo, Error>)-> Void)?)
	func loadStockBars(_ ticker: String, fromDate: Date, toDate: Date, completion:((Result<[TickerAggregate], Error>)-> Void)?)
}

protocol CancelableStockBarsLoading {
	func cancelLoadingStockBars(_ ticker: String)
}
