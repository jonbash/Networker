//
//  ConcurrentOperation.swift
//  Networker
//
//  Created by Jon Bash on 2020-01-26.
//  Copyright © 2020 Jon Bash. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {

    // MARK: - SubType

    enum State: String, Equatable {
        case isReady, isExecuting, isFinished
    }

    // MARK: - Properties

    private var _state: Atomic<State> = Atomic(State.isReady)
    var state: State {
        get { _state.wrappedValue }
        set { _state.wrappedValue = newValue }
    }

    // MARK: - Operation Override

    override dynamic var isReady: Bool { super.isReady && state == .isReady }
    override dynamic var isExecuting: Bool { state == .isExecuting }
    override dynamic var isFinished: Bool { state == .isFinished }
    override var isAsynchronous: Bool { true }
}
