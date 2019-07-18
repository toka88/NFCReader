//
//  NFCReader.swift
//  NFCReader
//
//  Created by Goran Tokovic on 7/18/19.
//

import CoreNFC

private enum NFCReaderError: Error {
    case sessionAlreadyStarted
    case sessionStopped

    var localizedDescription: String {
        switch self {
        case .sessionAlreadyStarted:
            return NSLocalizedString("NFC reader is already started.", comment: "")
        case .sessionStopped:
            return NSLocalizedString("NFC reader stopped.", comment: "")
        }
    }
}

@available(iOS 11.0, *)
public class NFCReader: NSObject {
    private var session: NFCNDEFReaderSession?
    private var completionBlock: ((Result<String, Error>) -> Void)?

    /// Singleton instance
    public static let shared: NFCReader = NFCReader()

    /// Check is NFC reading available
    public var readingAvailable: Bool {
        return NFCNDEFReaderSession.readingAvailable
    }

    /// Is reading active
    public var isReading: Bool {
        return completionBlock != nil
    }

    /// Stop NFC reader
    public func stopScanning() {
        session?.invalidate()
        session = nil
        completionBlock?(.failure(NFCReaderError.sessionStopped))
        completionBlock = nil
    }

    public func scanTag(completion:@escaping ((Result<String, Error>) -> Void)) {
        guard !isReading else {
            completion(.failure(NFCReaderError.sessionAlreadyStarted))
            return
        }

        session?.invalidate()
        completionBlock = completion
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.begin()
    }
}

@available(iOS 11.0, *)
extension NFCReader: NFCNDEFReaderSessionDelegate {
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        session.invalidate()
        DispatchQueue.main.async { [weak self] in
            self?.session = nil
            self?.completionBlock?(.failure(error))
            self?.completionBlock = nil
        }
    }

    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        var result = ""
        for payload in messages[0].records {
            if let text = String.init(data: payload.payload, encoding: .utf8) {
                result += text
            }
        }
        DispatchQueue.main.async { [weak self] in
            self?.session?.invalidate()
            self?.session = nil
            self?.completionBlock?(.success(result))
            self?.completionBlock = nil
        }
    }
}
