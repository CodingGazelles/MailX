//
//  GMailProxy.swift
//  Hexmail
//
//  Created by Tancrède on 3/7/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation

import GoogleAPIClient
import GTMOAuth2



enum MxBridgeError: MxException {
    case ProviderReturnedConnectionError( rootError: ErrorType)
    case ProviderReturnedFetchError( rootError: ErrorType)
}

class MxGMailBridge : NSObject, MxMailboxBridge {
    
    var mailbox: MxMailboxModel
    private var service: GTLServiceGmail
    
    private var connectCompletionHandler: MxConnectCompletionHandler?
    private var fetchLabelsCompletionHandler: MxFetchLabelsCompletionHandler?
    private var fetchMessagesInLabelCompletionHandler: MxFetchMessagesInLabelCompletionHandler?
    
    
    // For Google APIs, the scope strings are available
    // in the service constant header files.
    static let scopes = ["https://mail.google.com/"]
    
    
    // Typically, applications will hardcode the client ID and client secret
    // strings into the source code; they should not be user-editable nor visible.
    static let kClientID = "697586814863-70uhedocbv6vedb2kstbbbiflm2etmnn.apps.googleusercontent.com"
    static let kClientSecret = "lTLORrOlddFmQbeELo9jbcbB"
    
    
    // The application and service name to use for saving the auth tokens
    // to the keychain
    var kKeychainItemName = "Hexmail.Gmail Access Token.."
    
    
    init( mailbox: MxMailboxModel){
        MxLog.debug("Processing \(#function) with: \(mailbox)")
        
        self.mailbox = mailbox;
        
        self.kKeychainItemName = self.kKeychainItemName + mailbox.name
        
        // Initialize the Gmail API service & load existing credentials from the keychain if available.
        let service = GTLServiceGmail()
        self.service = service
    }
    
    
    //MARK: - Login
    
    // Ensures that the Gmail API service is authorized
    func connect( completionHandler completionHandler: MxConnectCompletionHandler){
        
        MxLog.debug("\(#function): sending connection request to mailbox \(mailbox.email)")
        
        self.connectCompletionHandler = completionHandler
        
        service.authorizer =
            GTMOAuth2WindowController.authForGoogleFromKeychainForName(
                kKeychainItemName
                , clientID:MxGMailBridge.kClientID
                , clientSecret:MxGMailBridge.kClientSecret)
    
        if (service.authorizer != nil || !service.authorizer.canAuthorize!){
    
            // Sign in
            MxLog.debug("Authenticating in progress")
    
            // Display the authentication sheet
            let authController = GTMOAuth2WindowController.controllerWithScope(
                MxGMailBridge.scopes.joinWithSeparator(" ")
                , clientID:MxGMailBridge.kClientID
                , clientSecret:MxGMailBridge.kClientSecret
                , keychainItemName:kKeychainItemName
                , resourceBundle:nil)
    
            dispatch_async(dispatch_get_main_queue()) {
                authController.signInSheetModalForWindow(
                    nil
                    , delegate:self
                    , finishedSelector: #selector(MxGMailBridge.authenticationController(_:finishedWithAuth:error:)))
                }
    
        } else {
            
            MxLog.info("Already authenticated with to mailbox \(mailbox.email)");
    
            // re emit the notification (just in case)
            connectCompletionHandler!( error: nil)
        }
    }
    
    // Handle completion of the authorization process, and update the Gmail API
    // with the new credentials.
    func authenticationController(
        windowController: GTMOAuth2WindowController
        , finishedWithAuth authResult: GTMOAuth2Authentication
        , error: NSError?) {
        
        MxLog.debug("\(#function): receiving connection request from mailbox \(mailbox.email)")
    
            if (error != nil) {
                // Authentication failed (perhaps the user denied access, or closed the
                // window before granting access)
    
                var errorStr = error!.localizedDescription
                let responseData = error!.userInfo["data"] // kGTMHTTPFetcherStatusDataKey
                
                if (responseData!.length() > 0) {
                    // Show the body of the server's authentication failure response
                    errorStr = String(initWithData:responseData, encoding:NSUTF8StringEncoding)
                } else {
                    let str = error!.userInfo[kGTMOAuth2ErrorMessageKey] as! String
                    if (str.characters.count > 0) {
                        errorStr = str
                    }
                }
    
                MxLog.error("Authentication to mailbox failed \(mailbox.email)");
                MxLog.error(errorStr);
    
                service.authorizer = nil
    
                // emit notification
                connectCompletionHandler!( error: MxBridgeError.ProviderReturnedConnectionError(rootError: error!))
    
            } else {
                // Authentication succeeded
    
                MxLog.info("Authenticating with mailbox succeeded \(mailbox.email)")
//                MxLog.debug("Access Token : \(authResult.accessToken)")
    
                // save the authentication object
                service.authorizer = authResult
    
                // emit notification
                connectCompletionHandler!(error: nil)
            }
    }
    
    
    //MARK: - Fetch Labels
    
    func sendFetchLabelsRequest( completionHandler completionHandler: MxFetchLabelsCompletionHandler) {
        MxLog.debug("Processing \(#function)")
        
        self.fetchLabelsCompletionHandler = completionHandler
    
        let query = GTLQueryGmail.queryForUsersLabelsList()
        
        service.executeQuery( query, delegate:self, didFinishSelector: #selector(MxGMailBridge.parseLabelsWithTicket(_:finishedWithObject:error:)))
    }
    
    func parseLabelsWithTicket(
        ticket: GTLServiceTicket
        , finishedWithObject labelsResponse: GTLGmailListLabelsResponse
        , error: NSError?){
        
        MxLog.debug("Processing \(#function)")
        
        if let error = error {
            
            MxLog.error("Fetching labels failed...")
            MxLog.error(error.localizedDescription)
            
            fetchLabelsCompletionHandler!( labels: nil, error: MxBridgeError.ProviderReturnedFetchError(rootError: error))
            
            return
        }
        
        var labels = [MxLabelModel]()
            
        if !labelsResponse.labels.isEmpty {
            MxLog.debug("Parsing labels...")
                
            for response in labelsResponse.labels as! [GTLGmailLabel] {
                
                let label = MxLabelModel(
                    UID: nil
                    , remoteId: MxLabelModel.Id(value: response.identifier)
                    , code: response.name
                    , name: ""
                    , ownerType: MxLabelOwnerType.SYSTEM
                    , mailboxUID: mailbox.UID)
                    
                labels.append(label)
                
                MxLog.debug("Parsing labels... label: \(label)")
            }
        } else {
            MxLog.verbose( "No label found.")
        }
            
        fetchLabelsCompletionHandler!( labels: labels, error: nil)
    }
    
    
    //MARK: - Fetch remote messages
    
    func sendFetchMessagesInLabelRequest(labelId labelId: MxLabelModel.Id, completionHandler: MxFetchMessagesInLabelCompletionHandler) {
        
        MxLog.debug("Processing \(#function)")
        
        self.fetchMessagesInLabelCompletionHandler = completionHandler
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        query.labelIds = [labelId.value]
        
        //    [query setLabelIds: labelsArray];
        
        service.executeQuery( query
            , delegate:self
            , didFinishSelector:#selector(MxGMailBridge.parseMessagesListWithTicket(_:finishedWithObject:error:)))
        
    }
    
    func parseMessagesListWithTicket( ticket: GTLServiceTicket
        , finishedWithObject messagesResponse: GTLGmailListMessagesResponse
        , error: NSError?) {
        
        MxLog.debug("Processing \(#function)")
            
            if let error = error {
                
                MxLog.error("Fetching messages in label failed...")
                MxLog.error(error.localizedDescription)
                
                fetchMessagesInLabelCompletionHandler!( messages: nil, error: MxBridgeError.ProviderReturnedConnectionError(rootError: error))
                
                return
            }
            
            var messages = [MxMessageModel]()
            
            if ( !messagesResponse.messages.isEmpty){
                
                MxLog.verbose("Reading messages...")
                
                for response in messagesResponse.messages as! [GTLGmailMessage] {
                    
                    MxLog.debug("Message:\(response)")
                    
                    let message = MxMessageModel(
                        UID: nil
                        , remoteId: MxMessageModelId( value: response.identifier)
                        , value: ""
                        , labelIds: [MxLabelModelId]()
                    )
                    messages.append( message)
                }
            } else {
                MxLog.verbose( "No message found.")
            }
            
            fetchMessagesInLabelCompletionHandler!( messages: messages, error: nil)
    }
    
    
    //MARK: - Fetch remote threads
    
    func sendFetchThreadsRequest() {
    //    return [[NSArray alloc] init];
    }
    
    func didFetchThreadsHandler( selector: Selector, error: NSError) {
        //
    }

    

}

