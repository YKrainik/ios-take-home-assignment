//
//  TickerAggregate.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/30/21.
//

import Foundation

protocol TickerAggregate {
	var openPrice: Double { get set }
	var highestPrice: Double { get set }
	var lowestPrice: Double { get set }
	var closePrice: Double { get set }
	var startTimeAggregate: Date { get set}
}
