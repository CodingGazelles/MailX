//
//  MxStateStore.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation

import ReSwift



class MxStateStore: Store<MxAppState> {
    
    
    typealias MxActionCreator = (mxState: MxAppState, mxStore: MxStateStore) -> MxAction?
    typealias ReActionCreator = (state: State, store: Store<MxAppState>) -> Action?
    
    
    init(){
        super.init(reducer: MxAppReducer(), state: nil, middleware: [])
    }
    
    override func dispatch(action: Action) -> Any {
        MxLog.info("Dispatching action: \(action)")
        return super.dispatch(action)
    }
    
    func dispatch(mxActionCreator: (state: MxAppState, store: MxStateStore) -> MxAction?) -> Any {
        MxLog.info("Dispatching action creator: \(mxActionCreator)")
        
        let reActionCreator = {
            (state: State, store: Store<MxAppState>) -> Action? in
            
            let _state = state
            let _store = store as! MxStateStore
            let _action = mxActionCreator(state: _state, store: _store)
            
            return _action as? Action
        }
        
        return super.dispatch(reActionCreator)
    }
    
    func initState() {
        MxLog.info("Initializing state")
        
        if let state = MxAppState.readSavedState() {
            
            dispatch( MxSetStateAction(state: state))
            
        } else {
            
            dispatch( MxSetPropertiesAction(properties: MxPropertiesState.readDefaultProperties()))
            
            dispatch( loadMailboxes)
            
            dispatch( loadLabels)
            
//            dispatch( loadAllMessages)
            
        }
        
        
        
        
    }
    
    func loadLastSavedState() -> MxAppState {
        MxLog.info("Loading state")
        
        guard let state = MxAppState.readSavedState() else {
            
            var state = MxAppState()
            state.propertiesState = MxPropertiesState.readDefaultProperties()
            return state
            
        }
        
        return state
    }
    
    func saveState(){
        MxLog.info("Saving state")
        
        MxAppState.saveState()
    }
    
    
}