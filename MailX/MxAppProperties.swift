//
//  MxAppProperties.swift
//  MailX
//
//  Created by Tancrède on 5/20/16.
//  Copyright © 2016 rxdesign. All rights reserved.
//

import Foundation



class MxAppProperties {
    
    // Property file
    static let kFileName = "Properties"
    static let kFileType = "plist"
    
    // Property file entries
    static let kPFE_DefaultLabels = "DefaultLabels"
    static let kPFE_SystemLabels = "SystemLabels"
    
    // Dictionary of properties
    private var _rootDictionary = [String:AnyObject]()
    
    // shared instance
    static var sharedInstance = MxAppProperties(fileName: kFileName, fileType: kFileType)
    static func defaultProperties() -> MxAppProperties{
        return sharedInstance
    }
    
    private init(fileName: String, fileType: String){
        _rootDictionary = readProperties(fileName: fileName, fileType: fileType)
    }
    
    func readProperties(fileName fileName: String, fileType: String) -> [String:String] {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType) else {
            return [String:String]()
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return [String:String]()
        }
        
        return dict as! [String : String]
    }
    
    func defaultLabels() -> [String]{
        guard let result = _rootDictionary[MxAppProperties.kPFE_DefaultLabels] else {
            return [String]()
        }
        return result as! [String]
    }
    
    func systemLabels() -> [String:String] {
        guard let result = _rootDictionary[MxAppProperties.kPFE_SystemLabels] else {
            return [String:String]()
        }
        return result as! [String:String]
    }
    
}