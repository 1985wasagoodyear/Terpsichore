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
        AVFormatIDKey: kAudioFormatMPEG4AAC, // mp3, previously kAudioFormatAppleLossless
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
    ]
}

public protocol RecordingServiceDelegate: AnyObject {
    func recordingDidStart()
    func recordingDidEnd()
    func cannotRecord()
    func recorderDidUpdate(_ power: CGFloat)
}

public typealias TimeIntervalHandler = (TimeInterval) -> Void

public class RecordingTimer {
    let update: TimeIntervalHandler
    let timer: DispatchSourceTimer
    let queue: DispatchQueue
    let updateInterval: TimeInterval
    let startDate: Date
    public init(queue: DispatchQueue,
                _ update: @escaping TimeIntervalHandler,
                _ updateInterval: TimeInterval = 1.0) {
        self.queue = queue
        self.update = update
        self.updateInterval = updateInterval
        self.startDate = Date()
        timer = DispatchSource.makeTimerSource()
        timer.schedule(wallDeadline: .now() + updateInterval,
                       repeating: updateInterval)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let difference = Date().timeIntervalSince(self.startDate)
            self.queue.async {
                update(difference)
            }
        }
        timer.resume()
    }
    deinit {
        // https://medium.com/over-engineering/a-background-repeating-timer-in-swift-412cecfd2ef9
        // ??
        timer.setEventHandler {}
        timer.cancel()
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        // timer.resume()
    }
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
    public var isRecording: Bool {
        return currRecorder?.isRecording ?? false
    }
    
    var timer: RecordingTimer?
    
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
    
    /// presently, `RecordingService` promises all `RecordingServiceDelegate` methods will be called on the main thread
    /// this is subject to change
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
    
    public func startRecording(queue: DispatchQueue, _ timeTracker: TimeIntervalHandler? = nil) {
        if let recorder = currRecorder, recorder.isRecording {
            fatalError("`startRecording` called while there is a recording in-progress")
        }
        if let tracker = timeTracker {
            timer = RecordingTimer(queue: queue, tracker)
        }
        currRecorder = makeRecorder()
        session.requestRecordPermission { granted in
            if granted {
                self.startRecordingHelper()
            } else {
                // Present message to user indicating that recording
                // can't be performed until they change their preference
                // under Settings -> Privacy -> Microphone
                
                DispatchQueue.main.async {
                    self.delegate?.cannotRecord()
                }
            }
        }
    }
    
    public func stopRecording() {
        try? session.setActive(false)
        currRecorder.stop()
        displayLink.remove(from: .current, forMode: .common)
        print("Recording completed, saved to:\n \(currRecorder.url.path)")
        timer = nil
        DispatchQueue.main.async {
            self.delegate?.recordingDidEnd()
        }
    }
    
}
