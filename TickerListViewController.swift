//
//  TickerListViewController.swift
//  Stocks
//
//  Created by AP Yury Krainik on 4/29/21.
//

import UIKit

class TickerListViewController: UIViewController {

	// MARK: Properties

	@IBOutlet private weak var tickersTable: UITableView!

	private lazy var refreshControl: UIRefreshControl = {
		let control = UIRefreshControl()

		control.attributedTitle = NSAttributedString(string: NSLocalizedString("Fetching Data", comment: "Fetching Data"), attributes: [
			.foregroundColor: UIColor.black
		])

		return control
	}()

	private let openTicketSequeIdentifier = "openTicker"

	private var items: [Ticker] = []
	private var selectedTicker: Ticker?

	private var dataProvider = CancelableStocksDataProvider(dataProvider: PolygonStockDataProvider(apiKey: "_tZaJXNe3spmLlk15Fa39yeZDvcSEd6B"))

	private lazy var percentageFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2

		return formatter
	}()

	// MARK: Lifecycle

	override func viewDidLoad() {
		super.viewDidLoad()

		self.navigationController?.navigationBar.isHidden = true

		title = NSLocalizedString("Stocks", comment: "TickerList title")

		tickersTable.register(UINib(nibName: TickerTableCell.className, bundle: nil), forCellReuseIdentifier: TickerTableCell.className)
		tickersTable.register(UINib(nibName: LoadingTableViewCell.className, bundle: nil), forCellReuseIdentifier: LoadingTableViewCell.className)

		tickersTable.refreshControl = refreshControl
		tickersTable.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		if segue.identifier == openTicketSequeIdentifier {

			guard let secondViewController = segue.destination as? TickerViewController else {
				return
			}

			secondViewController.ticker = selectedTicker
			secondViewController.dataProvider = dataProvider
		}
	}

	// MARK: Actions

	private var requestEndpoint: String? = nil
	private var isLoading: Bool = false
	private var hasMoreToLoad: Bool = true

	@objc private func refreshData(_ sender: Any) {
		loadMore(nil, appendToExistingItems: false)
	}

	private func loadMore(_ url: String?, appendToExistingItems: Bool = true) {
		guard isLoading == false else {
			return
		}

		isLoading = true

		dataProvider.loadStocks(url) { response in
			switch response {
			case .success(let result):

				guard let tickersResponse = result as? PolygonTickersResponse else {
					return
				}

				let names = tickersResponse.items ?? []
				let nextURL = tickersResponse.nextUrl

				DispatchQueue.main.async {

					self.requestEndpoint = nextURL
					self.hasMoreToLoad = (nextURL != nil)

					self.isLoading = false

					if appendToExistingItems {
						self.items.append(contentsOf: names)

						let sections = self.tickersTable.numberOfSections

						var insertedRows: [IndexPath] = []

						if sections > 0 {
							let currentItemsCount = self.tickersTable.numberOfRows(inSection: 0)
							let addedItemCount = names.count

							for i in 0..<addedItemCount {
								insertedRows.append(IndexPath(row: currentItemsCount + i, section: 0))
							}
						}

						self.tickersTable.performBatchUpdates({

							if sections > 1 {
								self.tickersTable.deleteSections(IndexSet(arrayLiteral: 1), with: .automatic)
							}

							self.tickersTable.insertRows(at: insertedRows, with: .automatic)
						}) { _ in
							self.tickersTable.refreshControl?.endRefreshing()
						}
					} else {
						self.items = names
						self.tickersTable.reloadData()
						self.tickersTable.refreshControl?.endRefreshing()
					}
				}

			case .failure(let error):
				DispatchQueue.main.async {
					self.isLoading = false
					self.items = []
					self.tickersTable.reloadData()
					self.tickersTable.refreshControl?.endRefreshing()
					self.presentOKAlertWithMessage(error.localizedDescription, alertTitle: NSLocalizedString("Failed to load data", comment: "Failed to load data"), handler: nil)
				}
			}
		}
	}

	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let currentOffset = scrollView.contentOffset.y
		let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height

		if maximumOffset - currentOffset <= 50.0 {
			if hasMoreToLoad && !isLoading {
				loadMore(requestEndpoint)
			}
		}
	}
}

// MARK: - UITableViewDelegate

extension TickerListViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)

		guard indexPath.section == 0 else {
			return
		}

		selectedTicker = items[indexPath.row]

		performSegue(withIdentifier: openTicketSequeIdentifier, sender: self)
	}

	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {

		if indexPath.section != 0 {
			return
		}

		let ticker = items[indexPath.row]

		dataProvider.cancelLoadingStockBars(ticker.symbol)
	}
}

extension TickerListViewController: UITableViewDataSource {

	func numberOfSections(in tableView: UITableView) -> Int {
		if isLoading {
			return 2
		}

		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return items.count
		default:
			return 1
		}
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		switch indexPath.section {
		case 0:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: TickerTableCell.className, for: indexPath) as? TickerTableCell else {
				return UITableViewCell()
			}

			let ticker = items[indexPath.row]
			cell.configure(ticker)

			//Load data
			let tickerSymbol = ticker.symbol
			let endDate = Date()
			let startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate) ?? endDate

			dataProvider.loadStockBars(tickerSymbol, fromDate: startDate, toDate: endDate) { result in

				let result = result

				DispatchQueue.main.async {

					switch result {
					case .success(let aggregates):
						cell.configure(ticker, aggregates: aggregates, percentageFormatter: self.percentageFormatter)
					case .failure(let error):
						cell.configure(ticker, error: error)
					}
				}
			}

			return cell
		default:
			guard let cell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.className, for: indexPath) as? LoadingTableViewCell else {
				return UITableViewCell()
			}

			return cell
		}
	}
}


