//
//  MxProxyTicket.swift
//  Hexmail
//
//  Created by Tancrède on 3/16/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation


class MxProxyTicket : NSOperation {
    
    var proxy: MxMailboxProxy
    
    enum State {
        case Ready, Executing, Finished, Cancelled
        func keyPath() -> String {
            switch self {
            case Ready:
                return "isReady"
            case Executing:
                return "isExecuting"
            case Finished:
                return "isFinished"
            case Cancelled:
                return "isCancelled"
            }
        }
    }
    
    var state = State.Ready {
        willSet {
            if newValue != state {
                willChangeValueForKey(newValue.keyPath())
                willChangeValueForKey(state.keyPath())
            }
        }
        didSet {
            if oldValue != state {
                didChangeValueForKey(oldValue.keyPath())
                didChangeValueForKey(state.keyPath())
            }
        }
    }
    
    override var ready: Bool {
        return super.ready && state == .Ready
    }
    
    override var executing: Bool {
        return state == .Executing
    }
    
    override var finished: Bool {
        return state == .Finished
    }
    
    override var asynchronous: Bool {
        return true
    }
    
    init( proxy: MxMailboxProxy) {
        self.proxy = proxy
    }
    
    override func start() {
        
        if (state == .Cancelled) {
            state = .Finished
        } else {
            state = .Executing
            self.main()
        }
        
    }
    
    override func cancel() {
        state = .Cancelled
    }
}