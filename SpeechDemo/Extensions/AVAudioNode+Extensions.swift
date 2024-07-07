//
//  AVAudioNode+Extensions.swift
//  SpeechDemo
//
//  Created by Leo Ho on 2024/3/15.
//

import AVFAudio
import Foundation

extension AVAudioNode {
    
    func installTap(onBus bus: AVAudioNodeBus,
                    bufferSize: AVAudioFrameCount,
                    format: AVAudioFormat?) async -> (AVAudioPCMBuffer, AVAudioTime) {
        await withCheckedContinuation { continuation in
            installTap(onBus: bus, bufferSize: bufferSize, format: format) { buffer, time in
                continuation.resume(returning: (buffer, time))
            }
        }
    }
}
