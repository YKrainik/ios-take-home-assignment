//
//  TickerViewController.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import UIKit
import Charts

class TickerViewController: UIViewController {

	// MARK: Properties

	@IBOutlet private weak var tickerTitleLabel: UILabel!
	@IBOutlet private weak var chartBgView: UIView!
	@IBOutlet private weak var lastPriceLabel: UILabel!
	@IBOutlet private weak var changePriceLabel: UILabel!

	@IBOutlet private weak var descriptionTitleLabel: UILabel!
	@IBOutlet private weak var descriptionLabel: UILabel!

	@IBOutlet private weak var chartView: LineChartView!

	@IBOutlet private weak var backButton: UIButton!
	@IBOutlet private weak var refreshButton: UIButton!

	var ticker: Ticker?
	var dataProvider: StocksDataProvider?

	var tickerInfo: TickerInfo?

	private lazy var percentageFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2

		return formatter
	}()

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		tickerTitleLabel.textColor = .white
		tickerTitleLabel.text = ticker?.symbol

		chartBgView.backgroundColor = UIColor(named: "tickerDetailsTopBg")

		backButton.setTitle("Back", for: .normal)
		backButton.setTitleColor(.white, for: .normal)

		refreshButton.setTitle("Refresh", for: .normal)
		refreshButton.setTitleColor(.white, for: .normal)

		descriptionTitleLabel.text = nil
		lastPriceLabel.text = nil
		changePriceLabel.text = nil

		chartView.backgroundColor = .white
		chartView.delegate = self

		chartView.xAxis.gridLineDashLengths = [1, 5]
		chartView.xAxis.gridLineDashPhase = 0

		let leftAxis = chartView.leftAxis
		leftAxis.removeAllLimitLines()
		leftAxis.axisMaximum = 200
		leftAxis.axisMinimum = 0
		leftAxis.gridLineDashLengths = [1, 5]

		chartView.legend.form = .line

		refreshPressed(self)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		chartView.roundCorners(corners: .allCorners, radius: 10)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if #available(iOS 13.0, *) {

			if let keyWindow = UIApplication.shared.windows.filter({$0.isKeyWindow}).first,
			   let statusBarManager = keyWindow.windowScene?.statusBarManager {

				let statusBar =  UIView()
				statusBar.frame = statusBarManager.statusBarFrame
				statusBar.tag = 100
				statusBar.backgroundColor = UIColor(named: "tickerDetailsTopBg")
				keyWindow.addSubview(statusBar)
			}
		} else {
			let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
			statusBar?.backgroundColor = .green
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.viewWithTag(100)?.removeFromSuperview()
	}

	// MARK: Private

	private func setChartData(_ aggregates: [TickerAggregate]) {

		if aggregates.count == 0 {
			chartView.data = nil
			chartView.setNeedsDisplay()
			return
		}

		let values = aggregates.enumerated().compactMap { index, result in
			return ChartDataEntry(x: Double(index), y: result.closePrice)
		}

		let lowestPrice = aggregates.compactMap{ $0.lowestPrice }.reduce(Double.greatestFiniteMagnitude) { min($0, $1) }

		let highestPrice = aggregates.compactMap{ $0.highestPrice }.reduce(0) { max($0, $1) }

		let leftAxis = chartView.leftAxis
		leftAxis.removeAllLimitLines()
		leftAxis.axisMaximum = highestPrice * 1.1
		leftAxis.axisMinimum = lowestPrice * 0.9

		let set = LineChartDataSet(entries: values, label: ticker?.symbol ?? "")
		set.drawIconsEnabled = false
//		set.drawCirclesEnabled = false
//		set.drawValuesEnabled = false

		set.fillAlpha = 1

		let data = LineChartData(dataSet: set)

		chartView.data = data
		chartView.setNeedsDisplay()

		if let lastPrice = aggregates.lastPrice {
			lastPriceLabel.text = "LastPrice: \(lastPrice)$"
		} else {
			lastPriceLabel.text = "LastPrice: -"
		}

		if let formatedPercentage = aggregates.formattedPeriodPercentageDiff(formatter: percentageFormatter) {
			changePriceLabel.text = "Price Change \(formatedPercentage)"
		} else {
			changePriceLabel.text = "Price Change -"
		}
	}

	private func loadTickerDetails(completion: (() -> Void)? = nil) {
		guard let ticker = ticker, let dataProvider = dataProvider else {
			completion?()
			return
		}

		let dispatchGroup = DispatchGroup()
		dispatchGroup.enter()
		dispatchGroup.enter()

		dataProvider.loadTickerDetails(_ticker: ticker.symbol) { [weak self] response in
			switch response {
			case .success(let tickerInfo):

				let info = tickerInfo

				DispatchQueue.main.async {
					self?.tickerInfo = info
					self?.updateUI()
					dispatchGroup.leave()
				}
			case .failure(let error):

				DispatchQueue.main.async {
					self?.handleAPIError(error)
					dispatchGroup.leave()
				}
			}
		}

		let endDate = Date()
		let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate) ?? endDate

		dataProvider.loadStockBars(ticker.symbol, fromDate: startDate, toDate: endDate) { [weak self] response in
			switch response {
			case .success(let aggregates):

				let updatedAggregates = aggregates

				DispatchQueue.main.async {
					self?.setChartData(updatedAggregates)
					dispatchGroup.leave()
				}
			case .failure(let error):

				DispatchQueue.main.async {
					self?.chartView.setNeedsDisplay()
					self?.handleAPIError(error)
					dispatchGroup.leave()
				}
			}
		}

		dispatchGroup.notify(queue: DispatchQueue.main) {
			completion?()
		}
	}

	private func handleAPIError(_ error: Error) {

		var errorText = error.localizedDescription

		if case APIError.apiError(let msg) = error {
			errorText = msg
		}

		descriptionTitleLabel.text = NSLocalizedString("Failed to load data", comment: "Failed to load data")
		descriptionLabel.text = errorText
	}

	private func updateUI() {

		guard let description = tickerInfo?.description else {
			descriptionTitleLabel.text = nil
			descriptionLabel.text = nil
			return
		}

		descriptionTitleLabel.text = NSLocalizedString("Description", comment: "Description title")
		descriptionLabel.text = description
	}

	// MARK: Actions

	@IBAction private func backPressed(_ sender: Any) {
		navigationController?.popViewController(animated: true)
	}

	@IBAction private func refreshPressed(_ sender: Any) {
		refreshButton.isEnabled = false
		refreshButton.setTitle("Loading...", for: .normal)

		loadTickerDetails { [weak self] in
			DispatchQueue.main.async {
				self?.refreshButton.isEnabled = true
				self?.refreshButton.setTitle("Refresh", for: .normal)
			}
		}
	}
}

extension TickerViewController: ChartViewDelegate {

}
