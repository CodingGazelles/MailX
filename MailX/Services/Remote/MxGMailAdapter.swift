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



class MxGMailAdapter : NSObject, MxMailboxAdapter {
    
    var mailbox: MxMailbox
    private var service: GTLServiceGmail
    
    private var connectCallback: MxConnectCallback?
    private var fetchLabelListCallback: MxFetchLabelListCallback?
    private var fetchMessageListCallback: MxFetchMessageListCallback?
    private var fetchMessageCallback: MxFetchMessageCallback?
    
    
    // For Google APIs, the scope strings are available
    // in the service constant header files.
    static let scopes = ["https://mail.google.com/"]
    
    
    // Typically, applications will hardcode the client ID and client secret
    // strings into the source code; they should not be user-editable nor visible.
    static let kClientID = "697586814863-70uhedocbv6vedb2kstbbbiflm2etmnn.apps.googleusercontent.com"
    static let kClientSecret = "lTLORrOlddFmQbeELo9jbcbB"
    
    
    // The application and service name to use for saving the auth tokens
    // to the keychain
    var kKeychainItemName = "MailX.Gmail Access Token.."
    
    
    init( mailbox: MxMailbox){
        
        self.mailbox = mailbox;
        self.kKeychainItemName = self.kKeychainItemName + mailbox.name!
        
        // Initialize the Gmail API service & load existing credentials from the keychain if available.
        let service = GTLServiceGmail()
        self.service = service
    }
    
    
    //MARK: - Login
    
    // Ensures that the Gmail API service is authorized
    func connect( callback callback: MxConnectCallback){
        
        MxLog.debug("Sending connection request to mailbox \(mailbox.email)")
        
        self.connectCallback = callback
        
        service.authorizer =
            GTMOAuth2WindowController.authForGoogleFromKeychainForName(
                kKeychainItemName
                , clientID:MxGMailAdapter.kClientID
                , clientSecret:MxGMailAdapter.kClientSecret)
    
        if (service.authorizer != nil || !service.authorizer.canAuthorize!) {
    
            // Sign in
            MxLog.debug("Authenticating in progress")
    
            // Display the authentication sheet
            let authController = GTMOAuth2WindowController.controllerWithScope(
                MxGMailAdapter.scopes.joinWithSeparator(" ")
                , clientID:MxGMailAdapter.kClientID
                , clientSecret:MxGMailAdapter.kClientSecret
                , keychainItemName:kKeychainItemName
                , resourceBundle:nil)
            
            (authController as! GTMOAuth2WindowController).shouldPersistUser = true
    
            dispatch_async(dispatch_get_main_queue()) {
                authController.signInSheetModalForWindow(
                    nil
                    , delegate:self
                    , finishedSelector: #selector(MxGMailAdapter.authenticationController(_:finishedWithAuth:error:)))
                }
    
        } else {
            
            MxLog.info("Already authenticated with to mailbox \(mailbox.email)");
    
            // re emit the notification (just in case)
            connectCallback!( error: nil)
        }
    }
    
    // Handle completion of the authorization process, and update the Gmail API
    // with the new credentials.
    func authenticationController(
        windowController: GTMOAuth2WindowController
        , finishedWithAuth authResult: GTMOAuth2Authentication
        , error: NSError?) {
        
        MxLog.debug("Receiving connection response from mailbox \(mailbox.email)")
    
            if (error != nil) {
                // Authentication failed (perhaps the user denied access, or closed the
                // window before granting access)
    
                var errorStr = error!.localizedDescription
                let responseData = error!.userInfo["data"] ?? "" // kGTMHTTPFetcherStatusDataKey
                
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
                connectCallback!( error: MxAdapterError.ProviderReturnedConnectionError(rootError: error!))
    
            } else {
                // Authentication succeeded
    
                MxLog.info("Authenticating with mailbox succeeded \(mailbox.email)")
//                MxLog.debug("Access Token : \(authResult.accessToken)")
    
                // save the authentication object
                service.authorizer = authResult
    
                // emit notification
                connectCallback!(error: nil)
            }
    }
    
    
    //MARK: - Fetch Labels
    
    func sendFetchLabelListRequest( callback callback: MxFetchLabelListCallback) {
        
        MxLog.debug("Sending fetch labels request to mailbox \(mailbox.email)")
        
        self.fetchLabelListCallback = callback
    
        let query = GTLQueryGmail.queryForUsersLabelsList()
        
        service.executeQuery(
            query,
            delegate:self,
            didFinishSelector: #selector(MxGMailAdapter.parseLabelsWithTicket(_:finishedWithObject:error:)))
    }
    
    func parseLabelsWithTicket(
        ticket: GTLServiceTicket
        , finishedWithObject labelsResponse: GTLGmailListLabelsResponse
        , error: NSError?){
        
        MxLog.debug("Received fetch labels response from \(mailbox.email)")
        
        guard error == nil else {
            
            let adapterError = MxAdapterError.ProviderReturnedFetchError(rootError: error!)
            
            MxLog.error("Fetching labels failed", error: adapterError)
            
            fetchLabelListCallback!( labels: nil, error: MxAdapterError.ProviderReturnedFetchError(rootError: adapterError))
            
            return
        }
        
        var labels = [MxLabelRemote]()
            
        if !labelsResponse.labels.isEmpty {
            MxLog.debug("Parsing labels")
            
            let systemLabels = MxAppProperties.defaultProperties().systemLabels()
            
            for response in labelsResponse.labels as! [GTLGmailLabel] {
                
                let label = MxLabelRemote()
                
                label.remoteId = MxRemoteId(value: response.identifier)
                label.code = MxLabelCode( code: response.identifier)
                label.name = systemLabels.labelName( labelCode: label.code) ?? response.name
                
                switch response.type {
                case "system":
                    label.ownerType = MxLabelOwnerType.SYSTEM
                    
                case "user":
                    label.ownerType = MxLabelOwnerType.USER
                    
                default:
                    label.ownerType = MxLabelOwnerType.UNDEFINED
                }
                
                labels.append(label)
                
                MxLog.debug("Parsed label \(label)")
            }
        } else {
            MxLog.debug( "No label found.")
        }
        
        fetchLabelListCallback!( labels: labels, error: nil)
    }
    
    
    //MARK: - Fetch remote messages
    
    func sendFetchMessageListInLabelsRequest(labelCodes labelCodes: [MxLabelCode], callback: MxFetchMessageListCallback) {
        
        MxLog.debug("Sending fetch message list request to mailbox \(mailbox.email)")
        
        self.fetchMessageListCallback = callback
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        query.labelIds = labelCodes.map{ code in
                return labelProviderCode(labelCode: code, providerCode: .GMAIL) ?? "NA"
        }
        
        //    [query setLabelIds: labelsArray];
        
        service.executeQuery( query
            , delegate:self
            , didFinishSelector:#selector(MxGMailAdapter.parseMessagesListWithTicket(_:finishedWithObject:error:)))
        
    }
    
    func parseMessagesListWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject messagesResponse: GTLGmailListMessagesResponse,
        error: NSError?) {
        
        MxLog.debug("Receiving fetch message list response from mailbox \(mailbox.email)")
            
            if let error = error {
                
                MxLog.error("Fetching messages failed...")
                MxLog.error(error.localizedDescription)
                
                fetchMessageListCallback!(
                    messages: nil,
                    error: MxAdapterError.ProviderReturnedConnectionError(rootError: error))
                
                return
            }
            
            var messages = [MxMessageRemote]()
            
            if ( !messagesResponse.messages.isEmpty){
                
                MxLog.verbose("Reading messages...")
                
                for response in messagesResponse.messages as! [GTLGmailMessage] {
                    
                    MxLog.debug("Message:\(response)")
                    
                    let message = MxMessageRemote()
                    message.remoteId = MxRemoteId( value: response.identifier)
                    
                    messages.append( message)
                    
                }
            } else {
                MxLog.verbose( "No message found.")
            }
            
            fetchMessageListCallback!( messages: messages, error: nil)
    }
    
    func sendFetchMessageRequest(messagesId messageId: MxRemoteId, callback: MxFetchMessageCallback) {
        
        MxLog.debug("Sending fetch message request to mailbox \(mailbox.email) \(messageId)")
        
        self.fetchMessageCallback = callback
        
        let query = GTLQueryGmail.queryForUsersMessagesGet()
        query.identifier = messageId.value
        
        service.executeQuery( query
            , delegate:self
            , didFinishSelector:#selector(MxGMailAdapter.parseMessageWithTicket(_:finishedWithObject:error:)))
    }
    
    
    func parseMessageWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject response: GTLGmailMessage ,
                           error: NSError?) {
        
        MxLog.debug("Receiving fetch message response from mailbox \(mailbox.email)")
        
        if let error = error {
            
            MxLog.error("Fetching message failed...")
            MxLog.error(error.localizedDescription)
            
            fetchMessageCallback!(
                message: nil,
                error: MxAdapterError.ProviderReturnedConnectionError(rootError: error))
            
            return
        }
        
        let message = MxMessageRemote()
        message.remoteId = MxRemoteId( value: response.identifier)
        message.snippet = response.snippet
        
        fetchMessageCallback!( message: message, error: nil)
    }
    
    
    //MARK: - Fetch remote threads
    
    func sendFetchThreadsRequest() {
    //    return [[NSArray alloc] init];
    }
    
    func didFetchThreadsHandler( selector: Selector, error: NSError) {
        //
    }

    

}

