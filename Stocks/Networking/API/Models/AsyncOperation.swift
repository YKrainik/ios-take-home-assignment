//
//  AsyncOperation.swift
//  Stocks
//
//  Created by AP Yury Krainik on 5/1/21.
//

import Foundation

class AsyncOperation: Operation {
	public override var isAsynchronous: Bool {
		   return true
	   }

	   public override var isExecuting: Bool {
		   return state == .executing
	   }

	   public override var isFinished: Bool {
		   return state == .finished
	   }

	   public override func start() {
		   if self.isCancelled {
			   state = .finished
		   } else {
			   state = .ready
			   main()
		   }
	   }

	   open override func main() {
		   if self.isCancelled {
			   state = .finished
		   } else {
			   state = .executing
		   }
	   }

	   public func finish() {
		   state = .finished
	   }

	   // MARK: - State management

	   public enum State: String {
		   case ready = "Ready"
		   case executing = "Executing"
		   case finished = "Finished"
		   fileprivate var keyPath: String { return "is" + self.rawValue }
	   }

	   public var state: State {
		   get {
			   stateQueue.sync {
				   return stateStore
			   }
		   }
		   set {
			   let oldValue = state
			   willChangeValue(forKey: state.keyPath)
			   willChangeValue(forKey: newValue.keyPath)
			   stateQueue.sync(flags: .barrier) {
				   stateStore = newValue
			   }
			   didChangeValue(forKey: state.keyPath)
			   didChangeValue(forKey: oldValue.keyPath)
		   }
	   }

	   private let stateQueue = DispatchQueue(label: "AsynchronousOperation State Queue", attributes: .concurrent)

	   private var stateStore: State = .ready
}
