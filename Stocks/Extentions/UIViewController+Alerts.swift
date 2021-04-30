//
//  UIViewController+Alerts.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import UIKit

extension UIViewController {
	func presentOKAlertWithMessage(_ message: String, alertTitle: String = "", handler: ((UIAlertAction) -> Void)? = nil) {
		
		let alert = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: handler))
		
		present(alert, animated: true, completion: nil)
	}
}
