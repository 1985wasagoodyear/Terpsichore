//
//  RecordingService+Helpers.swift
//  Created 3/15/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import Foundation
import AVFoundation

extension RecordingService {
    
    func startRecordingHelper() {
        
        guard let recorder = currRecorder else {
            fatalError("`prepare:` was never called before `startRecording`")
        }
        guard recorder.isRecording == false else {
            fatalError("`startRecording` was called while already recording")
        }
        
        // prepare AVAudioSession for playing & recording audio
        do {
            if #available(iOS 11.0, *) {
                try session.setCategory(.playAndRecord,
                                        mode: .default,
                                        policy: .default,
                                        options: .defaultToSpeaker)
            } else {
                try session.setCategory(.playAndRecord)
            }
        } catch {
            fatalError("Could not set category for AVAudioSession")
        }
        
        // start the recording
        recorder.record()
        displayLink.add(to: .current, forMode: .common)
        
        DispatchQueue.main.async {
            self.delegate?.recordingDidStart()
        }
    }
    
    @objc func updateMeters() {
        guard let recorder = currRecorder else {
            print("could not update, recorder was deinitialized")
            return
        }
        // refresh meter values
        recorder.updateMeters()
        
        // normalize the meter values
        let power: CGFloat = CGFloat(recorder.averagePower(forChannel: 0))/20
        let normalizedValue: CGFloat = pow(10, power)
        DispatchQueue.main.async {
            self.delegate?.recorderDidUpdate(normalizedValue)
        }
    }
    
    func newUrlForRecording() -> URL {
        let dateString = dateFormatter.string(from: Date())
        var url = directory.appendingPathComponent(dateString + ".m4a")
        var count: Int = 0
        
        // untested
        while manager.fileExists(atPath: url.absoluteString) == true {
            count += 1
            url = directory.appendingPathComponent(dateString + " (\(count))" + ".m4a")
        }
        return url
    }
    
    func makeRecorder() -> AVAudioRecorder {
        let recorder: AVAudioRecorder
        do {
            recorder = try AVAudioRecorder(url: newUrlForRecording(),
                                           settings: RecorderConstants.settings)
            try session.setActive(true)
        } catch {
            fatalError("Could not instantiate AVAudioRecorder")
        }
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        return recorder
    }
    
}
