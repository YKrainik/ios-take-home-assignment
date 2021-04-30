//
//  TickerTableCell+Configure.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import UIKit

extension TickerTableCell {
	func configure(_ ticker: Ticker) {
		tickerLabel.text = ticker.symbol

		indicatorView.backgroundColor = .red
		indicatorView.layer.cornerRadius = indicatorView.frame.width / 2.0
		indicatorView.layer.masksToBounds = true

		indicatorView.backgroundColor = .gray

		priceLabel.text = nil
		diffLabel.text = nil
	}

	func configure(_ ticker: Ticker, aggregates: [TickerAggregate], percentageFormatter: NumberFormatter) {
		configure(ticker)

		if let lastPrice = aggregates.lastPrice {
			priceLabel.text = "\(lastPrice)$"
		} else {
			priceLabel.text = nil
		}

		diffLabel.text = aggregates.formattedPeriodPercentageDiff(formatter: percentageFormatter)
		indicatorView.backgroundColor = indicatorColorView(by: aggregates.periodPercentageDiff, error: nil)
	}

	func configure(_ ticker: Ticker, error: Error) {
		configure(ticker)

		diffLabel.text = nil

		var errorText = error.localizedDescription

		if case APIError.apiError(let msg) = error {
			errorText = msg
		}

		//TODO: Just a quick fix to show more friendly text, when the request fails cause Plan's limit
		if errorText.hasPrefix("You\'ve exceeded the maximum requests per minute") {
			errorText = "Out of plan limit"
		}

		priceLabel.text = errorText
		indicatorView.backgroundColor = indicatorColorView(by: nil, error: error)
	}

	/**
	 Increased = green
	 Decreased = red
	 The same = black
	 Not clear/error = .gray
	*/
	private func indicatorColorView(by diff: Double?, error: Error?) -> UIColor {

		if error != nil {
			return .gray
		}

		if let diff = diff {
			if diff > 0 {
				return .green
			} else if diff == 0 {
				return .black
			} else {
				return .red
			}
		} else {
			return .gray
		}
	}
}

