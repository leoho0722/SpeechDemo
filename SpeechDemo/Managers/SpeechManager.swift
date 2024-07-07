//
//  SpeechManager.swift
//  SpeechDemo
//
//  Created by Leo Ho on 2024/3/15.
//

import Foundation
import Speech

protocol SpeechManagerDelegate: NSObjectProtocol {
    
    func speechManager(_ speechManager: SpeechManager, availabilityDidChange available: Bool)
    
    func speechManager(_ speechManager: SpeechManager, 
                       recognitionTaskResult result: SFSpeechRecognitionResult)
    
    func speechManager(_ speechManager: SpeechManager, recognitionTaskDidFailed error: any Error)
}

class SpeechManager: NSObject {
 
    weak var delegate: SpeechManagerDelegate?
    
    /// 語音識別器
    private let recognizer = SFSpeechRecognizer()
    
    /// 語音音訊緩衝區識別請求
    private var request: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    func configure() async {
        await authorization()
        recognizer?.delegate = self
    }
    
    private func authorization() async {
        let status = await SFSpeechRecognizer.requestAuthorization()
        switch status {
        case .notDetermined:
            print("使用者尚未同意授權")
        case .denied:
            print("使用者已拒絕授權")
        case .restricted:
            print("裝置功能受限")
        case .authorized:
            print("使用者已授權")
        @unknown default:
            print("未知的授權狀態")
        }
    }
    
    func startRecoding() async throws {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.record)
            try session.setMode(.measurement)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("啟用 AVAudioSession 失敗，Error: \(error)")
            throw error
        }

        guard let recognizer, request == nil else {
            return
        }
        
        recognitionTask = recognizer.recognitionTask(with: request!) { [unowned self] result, error in
            var isFinal = false
            
            if let result {
                isFinal = result.isFinal
                delegate?.speechManager(self, recognitionTaskResult: result)
            }
            
            if let error, isFinal {
                audioEngine.stop()
                audioEngine.inputNode.removeTap(onBus: 0)
                request = nil
                recognitionTask = nil
                delegate?.speechManager(self, recognitionTaskDidFailed: error)
            }
        }
        
        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        let (buffer, _) = await audioEngine.inputNode.installTap(onBus: 0,
                                                                 bufferSize: 1024,
                                                                 format: format)
        request?.append(buffer)
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("AVAudioEngine 無法啟動，Error: \(error)")
            throw error
        }
    }
}

extension SpeechManager: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, 
                          availabilityDidChange available: Bool) {
        delegate?.speechManager(self, availabilityDidChange: available)
    }
}
