//
//  GMailProxy.swift
//  Hexmail
//
//  Created by Tancrède on 3/7/16.
//  Copyright © 2016 Hex. All rights reserved.
//

import Foundation






class MxGMailProxy : NSObject , MxMailboxProxy {
    
    
    private var mailboxId: MxMailbox.Id
    private var providerId: MxProvider.Id
    private var service: GTLServiceGmail
    
    private var connectCompletionHandler: MxConnectCompletionHandler?
    private var fetchLabelsCompletionHandler: MxFetchLabelsCompletionHandler?
    private var fetchMessagesInLabelCompletionHandler: MxFetchMessagesInLabelCompletionHandler?
    
    // Logs
//    static const DDLogLevel ddLogLevel = DDLogLevelVerbose

    
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
    
    
    init( providerId: MxProvider.Id, mailboxId: MxMailbox.Id){
        MxLog.verbose("... Processing");
        
        self.providerId = providerId;
        self.mailboxId = mailboxId;
        
        self.kKeychainItemName = self.kKeychainItemName + mailboxId.value
        
        // Initialize the Gmail API service & load existing credentials from the keychain if available.
        let service = GTLServiceGmail()
        self.service = service
        
        MxLog.verbose("... Done")
    }
    
    
    //MARK: - Login
    
    // Ensures that the Gmail API service is authorized
    func connect( completionHandler completionHandler: MxConnectCompletionHandler){
        MxLog.verbose("... Processing")
        
        self.connectCompletionHandler = completionHandler
        
        service.authorizer =
            GTMOAuth2WindowController.authForGoogleFromKeychainForName(
                kKeychainItemName
                , clientID:MxGMailProxy.kClientID
                , clientSecret:MxGMailProxy.kClientSecret)
    
        if (service.authorizer != nil || !service.authorizer.canAuthorize!){
    
            // Sign in
            MxLog.debug("Authenticating with Gmail...")
    
            // Display the authentication sheet
            let authController = GTMOAuth2WindowController.controllerWithScope(
                MxGMailProxy.scopes.joinWithSeparator(" ")
                , clientID:MxGMailProxy.kClientID
                , clientSecret:MxGMailProxy.kClientSecret
                , keychainItemName:kKeychainItemName
                , resourceBundle:nil)
    
            dispatch_async(dispatch_get_main_queue()) {
                authController.signInSheetModalForWindow(
                    nil
                    , delegate:self
                    , finishedSelector: #selector(MxGMailProxy.authenticationController(_:finishedWithAuth:error:)))
                }
    
        } else {
            MxLog.info("Already authenticated with Gmail... Proxy: \(getProviderId().value+"/"+getMailboxId().value)");
    
            // re emit the notification (just in case)
            connectCompletionHandler!(error: nil)
        }
        
        MxLog.verbose("... Done")
    }
    
    // Handle completion of the authorization process, and update the Gmail API
    // with the new credentials.
    func authenticationController(
        windowController: GTMOAuth2WindowController
        , finishedWithAuth authResult: GTMOAuth2Authentication
        , error: NSError?) {
            MxLog.verbose("... Processing")
    
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
    
                MxLog.error("Authenticating with Gmail failed... Proxy: \(getProviderId().value+"/"+getMailboxId().value)");
                MxLog.error(errorStr);
    
                service.authorizer = nil
    
                // emit notification
                connectCompletionHandler!(error: error)
    
            } else {
                // Authentication succeeded
    
                MxLog.info("Authenticating with Gmail succeeded... Proxy: \(getProviderId().value+"/"+getMailboxId().value)")
//                MxLog.debug("Access Token : \(authResult.accessToken)")
    
                // save the authentication object
                service.authorizer = authResult
    
                // emit notification
                connectCompletionHandler!(error: nil)
            }
            
        MxLog.verbose("... Done")
    }
    
    
    //MARK: - Fetch Labels
    
    func sendFetchLabelsRequest( completionHandler completionHandler: MxFetchLabelsCompletionHandler) {
        MxLog.verbose("... Processing")
        
        self.fetchLabelsCompletionHandler = completionHandler
    
        let query = GTLQueryGmail.queryForUsersLabelsList()
        
        service.executeQuery( query, delegate:self, didFinishSelector: #selector(MxGMailProxy.parseLabelsWithTicket(_:finishedWithObject:error:)))
        
        MxLog.verbose("... Done")
    }
    
    func parseLabelsWithTicket(
        ticket: GTLServiceTicket
        , finishedWithObject labelsResponse: GTLGmailListLabelsResponse
        , error: NSError?)
    {
        MxLog.verbose("... Processing")
        
        if let error = error {
            
            MxLog.error("Fetching labels failed...")
            MxLog.error(error.localizedDescription)
            
            fetchLabelsCompletionHandler!( labels: nil, error: error)
            
            return
        }
        
        var labels = MxLabels()
            
        if !labelsResponse.labels.isEmpty {
            MxLog.debug("Parsing labels...")
                
            for response in labelsResponse.labels as! [GTLGmailLabel] {
                
                let label = MxLabel(
                    id: MxLabel.Id(value: response.identifier),
                    name: response.name,
                    type: MxLabel.MxLabelOwnerType.SYSTEM,
                    mailboxId: mailboxId)
                    
                labels.append(label)
                
                MxLog.debug("Parsing labels... label: \(label)")
            }
        } else {
            MxLog.verbose( "No label found.")
        }
            
        fetchLabelsCompletionHandler!( labels: labels, error: nil)
        
        MxLog.verbose("... Done")
    }
    
    
    //MARK: - Fetch remote messages
    
    func sendFetchMessagesInLabelRequest(labelId labelId: MxLabel.Id, completionHandler: MxFetchMessagesInLabelCompletionHandler) {
        MxLog.verbose("...")
        
        self.fetchMessagesInLabelCompletionHandler = completionHandler
        
        let query = GTLQueryGmail.queryForUsersMessagesList()
        query.labelIds = [labelId.value]
        
        //    [query setLabelIds: labelsArray];
        
        service.executeQuery( query
            , delegate:self
            , didFinishSelector:#selector(MxGMailProxy.parseMessagesListWithTicket(_:finishedWithObject:error:)))
        
        MxLog.verbose("... Done")
    }
    
    func parseMessagesListWithTicket( ticket: GTLServiceTicket
        , finishedWithObject messagesResponse: GTLGmailListMessagesResponse
        , error: NSError?) {
            MxLog.verbose("...")
            
            if let error = error {
                
                MxLog.error("Fetching messages in label failed...")
                MxLog.error(error.localizedDescription)
                
                fetchMessagesInLabelCompletionHandler!( messages: nil, error: error)
                
                return
            }
            
            var messages = MxMessages()
            
            if ( !messagesResponse.messages.isEmpty){
                
                MxLog.verbose("Reading messages...")
                
                for response in messagesResponse.messages as [GTLGmailMessage] {
                    
                    MxLog.debug("Message:\(response)")
                    
                    let message = MxMessage(
                        id: MxMessage.Id( value: response.identifier),
                        value: "",
                        labelId: nil
                    )
                    messages.append( message)
                }
            } else {
                MxLog.verbose( "No message found.")
            }
            
            fetchMessagesInLabelCompletionHandler!( messages: messages, error: nil)
            
            MxLog.verbose("... Done")
    }
    
    
    //MARK: - Fetch remote threads
    
    func sendFetchThreadsRequest() {
    //    return [[NSArray alloc] init];
    }
    
    func didFetchThreadsHandler( selector: Selector, error: NSError) {
        //
    }

    
    //MARK: - Getters
    
    func getMailboxId() -> MxMailbox.Id {
        return mailboxId
    }
    
    func getProviderId() -> MxProvider.Id {
        return providerId
    }
}

