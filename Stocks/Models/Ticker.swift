//
//  Ticker.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import Foundation

protocol Ticker {
	var symbol: String { get set }
	var name: String { get set }
}
