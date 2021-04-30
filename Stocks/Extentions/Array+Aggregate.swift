//
//  Array+Aggregate.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import Foundation

extension Array where ArrayLiteralElement == TickerAggregate {
	var lastPrice: Double? {
		return last?.closePrice
	}

	var periodPercentageDiff: Double? {
		guard let startPrice = first?.openPrice ?? first?.closePrice,
			  let endPrise = last?.closePrice ?? last?.openPrice else {
			return nil
		}

		if startPrice == 0 {
			return nil
		}

		return ((endPrise - startPrice) * 100.0) / startPrice
	}

	func formattedPeriodPercentageDiff(formatter: NumberFormatter) -> String? {
		guard let periodPercentageDiff = periodPercentageDiff else {
			return nil
		}

		if periodPercentageDiff == 0 {
			return "0%"
		}

		guard let formated = formatter.string(from: NSNumber(value: periodPercentageDiff)) else {
			return nil
		}

		return "\(formated)%"
	}
}
