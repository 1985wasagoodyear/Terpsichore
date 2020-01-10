//
//  RecordingService.swift
//  Terpsikhore
//
//  Created by K Y on 1/10/20.
//  Copyright © 2020 Yu. All rights reserved.
//

import Foundation
import AVFoundation

enum RecorderConstants {
    static let settings: [String: Any] = [
        AVSampleRateKey: 44100.0,
        AVFormatIDKey: kAudioFormatAppleLossless,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
    ]
}

public protocol RecordingServiceDelegate: AnyObject {
    func cannotRecord()
    func recorderDidUpdate(_ power: CGFloat)
}

public class RecordingService {
    
    let manager: FileManager
    let session: AVAudioSession = .sharedInstance()
    let dateFormatter: DateFormatter
    var currRecorder: AVAudioRecorder!
    private(set) public weak var delegate: RecordingServiceDelegate?
    // synchronize update changes to the refresh rate of the device
    lazy var displayLink: CADisplayLink = {
        return CADisplayLink(target: self,
                             selector: #selector(updateMeters))
    }()
    
    public var allRecordings: [URL] {
        do {
            return try manager.contentsOfDirectory(at: directory,
                                                   includingPropertiesForKeys: nil,
                                                   options: .skipsPackageDescendants)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    /// URL to folder of recordings
    let directory: URL
    
    public init(_ delegate: RecordingServiceDelegate) {
        self.delegate = delegate
        manager = FileManager.default
        dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ssZ"
        
        directory = manager
            .urls(for: .documentDirectory,
                  in: .userDomainMask)[0]
            .appendingPathComponent("Terpsikhore")
        
        // if the directory does not exist
        if manager.fileExists(atPath: directory.absoluteString) { return }
        
        // create that directory
        do {
            try manager.createDirectory(at: directory,
                                        withIntermediateDirectories: true,
                                        attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    public func startRecording() {
        if let recorder = currRecorder, recorder.isRecording {
            fatalError("`startRecording` called while there is a recording in-progress")
        }
                currRecorder = makeRecorder()
        session.requestRecordPermission { granted in
            if granted {
                self.startRecordingHelper()
            } else {
                // Present message to user indicating that recording
                // can't be performed until they change their preference
                // under Settings -> Privacy -> Microphone
                self.delegate?.cannotRecord()
            }
        }
    }
    
    public func stopRecording() {
        try? session.setActive(false)
        currRecorder.stop()
        displayLink.remove(from: .current, forMode: .common)
    }
    
}

// internal helper functions
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
            try session.setCategory(.playAndRecord)
        } catch {
            fatalError("Could not set category for AVAudioSession")
        }
        
        // start the recording
        recorder.record()
        displayLink.add(to: .current, forMode: .common)
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
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.recorderDidUpdate(normalizedValue)
        }
    }
    
    func newUrlForRecording() -> URL {
        let dateString = dateFormatter.string(from: Date())
        var url = directory.appendingPathComponent(dateString)
        var count: Int = 0
        
        // untested
        while manager.fileExists(atPath: url.absoluteString) == true {
            count += 1
            url = directory.appendingPathComponent(dateString + " (\(count))")
        }
        let strData: Data = "hello world".data(using: .utf8)!
        do {
            try strData.write(to: url)
        } catch {
            fatalError(error.localizedDescription)
        }
        print(url)
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
