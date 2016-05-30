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
    
    static let kPFE_Providers = "MailboxProviders"
    static let k_Provider_Name = "Name"
    static let k_Provider_Id = "Id"
    static let k_Provider_ProxyClassName = "ProxyClassName"
    static let k_Provider_Labels = "Labels"
    
    static let k_Label_Name = "Name"
    static let k_Label_Code = "Code"
    
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
    
    func readProperties(fileName fileName: String, fileType: String) -> [String:AnyObject] {
        guard let path = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType) else {
            return [String:AnyObject]()
        }
        guard let dict = NSDictionary(contentsOfFile: path) else {
            return [String:AnyObject]()
        }
        
        return dict as! [String:AnyObject]
    }
    
    func defaultLabels() -> [String]{
        guard let result = _rootDictionary[MxAppProperties.kPFE_DefaultLabels] else {
            return [String]()
        }
        return result as! [String]
    }
    
    func systemLabels() -> MxSystemLabels {
        guard let result = _rootDictionary[MxAppProperties.kPFE_SystemLabels] else {
            return MxSystemLabels( labels: [String:[String:String]]())
        }
        return MxSystemLabels( labels: result as! [String:[String:String]])
    }
    
    func providers() -> [[String:AnyObject]] {
        guard let result = _rootDictionary[MxAppProperties.kPFE_Providers] else {
            return [[String:AnyObject]()]
        }
        return result as! [[String : AnyObject]]
    }
    
    func provider( providerId providerId: String) -> [String:AnyObject] {
        
        let format = "(\(MxAppProperties.k_Provider_Id) == %@)"
        let predicate = NSPredicate( format: format, providerId)
        let result = providers().filter{ predicate.evaluateWithObject($0) }
        
        return result[0]
    }
    
    func providerLabels( providerId providerId: String) -> [String:String] {
        return provider( providerId: providerId)[MxAppProperties.k_Provider_Labels] as! [String:String]
    }
    
}

class MxSystemLabels {
    
    private var rootDictionary = [String:[String:String]]()
    
    private init( labels: [String:[String:String]]){
        rootDictionary = labels
    }
    
    func labelName( labelCode labelCode: String) -> String {
        
        let result = rootDictionary[labelCode]![MxAppProperties.k_Label_Name]
        return result!
    }
}


