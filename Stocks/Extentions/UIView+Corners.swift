//
//  UIView+Corners.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/30/21.
//

import UIKit

extension UIView {
	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}
