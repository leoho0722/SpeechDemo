//
//  SFSpeechRecognizer+Extensions.swift
//  SpeechDemo
//
//  Created by Leo Ho on 2024/3/15.
//

import Foundation
import Speech

extension SFSpeechRecognizer {
    
    class func requestAuthorization() async -> SFSpeechRecognizerAuthorizationStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }
}
