//
//  NSObject+Name.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import Foundation

extension NSObject {
	public class var className: String {
		return String(describing: self)
	}

	public var className: String {
		return String(describing: type(of: self))
	}
}
