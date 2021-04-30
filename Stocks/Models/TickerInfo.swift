//
//  TickerInfo.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/30/21.
//

import Foundation

protocol TickerInfo {
	var logo: String? { get set }
	var url: String? { get set }
	var description: String? { get set }
	var symbol: String? { get set }
}
