//
//  Logs.swift
//  Hexmail
//
//  Created by Tancrède on 5/13/16.
//  Copyright © 2016 Rx Design. All rights reserved.
//

import Foundation

import CleanroomLogger



class MxLog {
    static func enable(){
        Log.enable()
    }
    static func verbose( message: String){
        Log.verbose?.message( message)
    }
    static func debug( message: String){
        Log.debug?.message(message)
    }
    static func info( message: String){
        Log.info?.message(message)
    }
    static func warn( message: String){
        Log.warning?.message(message)
    }
    static func error( message: String){
        Log.error?.message(message)
    }
}
