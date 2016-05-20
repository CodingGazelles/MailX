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
    
    init(){
        super.init(reducer: MxAppReducer(), state: nil, middleware: [])
    }
    
    override func dispatch(action: Action) -> Any {
        MxLog.info("Dispatching action: \(action)")
        return super.dispatch(action)
    }
    
    override func dispatch(actionCreatorProvider: (state: State, store: Store<State>) -> Action?) -> Any {
        MxLog.info("Dispatching action creator: \(actionCreatorProvider)")
        return super.dispatch(actionCreatorProvider)
    }
    
    func initState() {
        MxLog.info("Initializing state")
        
        if let state = MxAppState.readSavedState() {
            
            dispatch( MxSetStateAction(state: state))
            
        } else {
            
            dispatch( MxSetPropertiesAction(properties: MxPropertiesState.readDefaultProperties()))
            
            dispatch( funcLoadSelectedMailbox)
            
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