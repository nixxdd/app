//
//  NFCWriter.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import Foundation
import CoreNFC
import SwiftUI
import Combine

/// A class responsible for writing string data to NFC tags.
/// It conforms to ObservableObject so it can easily publish UI updates (like alerts) back to your SwiftUI views.
class NFCWriter: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    
    // The active NFC scanning session managed by iOS
    @Published var session: NFCNDEFReaderSession?
    
    // Temporarily holds the packaged NDEF message until a tag is physically detected
    var messageToWrite: NFCNDEFMessage?
    
    // MARK: - UI Alert State
    // Variables to trigger native iOS alerts in your SwiftUI view
    @Published var showAlert = false
    @Published var alertMessage = ""

    /// Helper function to safely trigger UI alerts.
    /// Because NFC scanning happens on a background thread, any updates to the UI
    /// (like showing an alert) must be pushed back to the 'main' thread.
    private func sendAlert(_ message: String) {
        DispatchQueue.main.async {
            self.alertMessage = message
            self.showAlert = true
        }
    }

    // MARK: - Write Initialization
    /// Starts the NFC scanning process and prepares the text to be written.
    func write(text: String) {
        // 1. Double-check that the physical device supports NFC reading/writing
        guard NFCNDEFReaderSession.readingAvailable else {
            sendAlert("NFC is not supported on this device")
            return
        }

        // 2. Convert the plain text string into a standardized NDEF payload
        // NDEF (NFC Data Exchange Format) is the universal language for NFC tags.
        guard let textPayload = NFCNDEFPayload.wellKnownTypeTextPayload(
            string: text,
            locale: Locale(identifier: "en")
        ) else {
            sendAlert("Failed to format the text into an NDEF payload.")
            return
        }
        
        // 3. Package the payload into a complete NDEF Message
        messageToWrite = NFCNDEFMessage(records: [textPayload])

        // 4. Initialize and begin the native Apple NFC scanning sheet
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the medication tag to write."
        session?.begin()
    }

    // MARK: - NFC Delegate Methods (Error Handling)
    /// Called when the session fails or is closed by the user.
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // We filter out the specific error where the user intentionally taps "Cancel"
        // so we don't throw an unnecessary alert in their face.
        if let nfcError = error as? NFCReaderError, nfcError.code != .readerSessionInvalidationErrorUserCanceled {
            sendAlert("Session Error: \(nfcError.localizedDescription)")
        }
    }

    /// Required by the protocol, but left empty because we are scanning for physical tags,
    /// not just raw NDEF messages.
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {}

    // MARK: - NFC Delegate Methods (Tag Detection & Writing)
    /// Called the moment a physical NFC tag is detected by the iPhone.
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        // 1. Grab the first tag detected and ensure our message is ready
        guard let tag = tags.first, let message = messageToWrite else {
            session.invalidate(errorMessage: "Failed to locate tag or message.")
            sendAlert("Failed to locate tag or message.")
            return
        }
        
        // 2. Attempt to physically connect to the tag
        session.connect(to: tag) { (error: Error?) in
            if let error = error {
                session.invalidate(errorMessage: "Connection failed.")
                self.sendAlert("Connection Error: \(error.localizedDescription)")
                return
            }
            
            // 3. Query the tag to see if it is formatted and writable
            tag.queryNDEFStatus { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                
                if status == .readWrite {
                    // 4a. The tag is unlocked and ready! Attempt to write the message.
                    tag.writeNDEF(message) { (error: Error?) in
                        if let error = error {
                            session.invalidate(errorMessage: "Write failed.")
                            self.sendAlert("Write Error: \(error.localizedDescription)")
                        } else {
                            // Success! Show the Apple checkmark and trigger our custom success alert.
                            session.alertMessage = "Text successfully saved to tag!"
                            session.invalidate()
                            self.sendAlert("Success! The text was written to the tag.")
                        }
                    }
                } else if status == .readOnly {
                    // 4b. The tag has been permanently locked
                    session.invalidate(errorMessage: "Tag is locked.")
                    self.sendAlert("Error: This tag is read-only and cannot be overwritten.")
                } else {
                    // 4c. The tag is a raw chip that hasn't been formatted for NDEF yet
                    session.invalidate(errorMessage: "Tag not supported.")
                    self.sendAlert("Error: This tag does not support NDEF formatting.")
                }
            }
        }
    }
}
