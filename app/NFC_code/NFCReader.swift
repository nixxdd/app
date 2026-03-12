//
//  NFCReader.swift
//  app
//
//  Created by Foundation 34 on 10/03/26.
//

import Foundation
import CoreNFC
import SwiftUI
import Combine

class NFCReader: NSObject, ObservableObject, NFCNDEFReaderSessionDelegate {
    @Published var scannedText = "Ready to scan"
    @Published var lastScannedMedicineName: String? = nil
    
    var session: NFCNDEFReaderSession?

    func scan() {
        guard NFCNDEFReaderSession.readingAvailable else {
            scannedText = "NFC not supported on this device"
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the Carely tag."
        session?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // kept empty — triggers when scan sheet closes
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first,
              let text = record.wellKnownTypeTextPayload().0 else {
            DispatchQueue.main.async { self.scannedText = "No valid text found" }
            return
        }
        DispatchQueue.main.async {
            self.scannedText = text
            self.lastScannedMedicineName = text  // ← this triggers the onChange in the view
        }
    }
}
