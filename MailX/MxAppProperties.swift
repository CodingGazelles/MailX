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
    static let kPFE_Labels = "Labels"
    
    static let kPFE_Providers = "MailProviders"
    static let k_Provider_Name = "Name"
    static let k_Provider_Code = "Code"
    static let k_Provider_ProxyClassName = "ProxyClassName"
    static let k_Provider_Labels = "Labels"
    
    static let k_Label_Name = "Name"
    static let k_Label_Code = "Code"
    
    static let kPFE_Model_Name = "ModelName"
    static let kPFE_Model_Extension = "ModelExtension"
    
    
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
        guard let result = _rootDictionary[MxAppProperties.kPFE_Labels] else {
            return MxSystemLabels( labels: [String:[String:String]]())
        }
        return MxSystemLabels( labels: result as! [String:[String:String]])
    }
    
    func providers() -> [String:[String:AnyObject]] {
        guard let result = _rootDictionary[MxAppProperties.kPFE_Providers] else {
            return [String:[String:AnyObject]]()
        }
        return result as! [String:[String:AnyObject]]
    }
    
    func provider( providerCode providerCode: MxProviderCode) -> MxProviderProperties? {
        
        let properties = providers()[ providerCode.rawValue]
        
        guard (properties != nil) else {
            return nil
        }
        
        return MxProviderProperties( properties: properties!)
    }
    
    func modelName() -> String {
        guard let result = _rootDictionary[MxAppProperties.kPFE_Model_Name] else {
            return ""
        }
        return result as! String
    }
    
    func modelExtension() -> String {
        guard let result = _rootDictionary[MxAppProperties.kPFE_Model_Extension] else {
            return ""
        }
        return result as! String
    }
    
}

class MxProviderProperties {
    
    var proxyClassName: String
    var name: String
    var labels: [String:String]
    
    init( properties: [String:AnyObject]) {
        self.proxyClassName = properties[ MxAppProperties.k_Provider_ProxyClassName]! as! String
        self.name = properties[ MxAppProperties.k_Provider_Name]! as! String
        self.labels = properties[ MxAppProperties.k_Provider_Labels] as! [String:String]
    }
    
    func labelProviderCode( labelCode labelCode: MxLabelCode) -> String? {
        
        switch labelCode {
        
        case .SYSTEM( let code):
            return labels[ code.rawValue ]
        
        case .USER( let code):
            return labels[ code]
        }
        
    }
    
}

class MxSystemLabels {
    
    private var rootDictionary = [String:[String:String]]()
    
    private init( labels: [String:[String:String]]){
        rootDictionary = labels
    }
    
    func labelName( labelCode labelCode: MxLabelCode) -> String? {
        
        switch labelCode {
            
        case .SYSTEM( let code):
            return rootDictionary[code.rawValue]?[MxAppProperties.k_Label_Name]
            
            
        case .USER(let code):
            return rootDictionary[code]?[MxAppProperties.k_Label_Name]
        }
        
    }
}


