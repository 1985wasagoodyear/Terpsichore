//
//  AudioWaveViewController.swift
//  Terpsikhore
//
//  Original by Tim Richardson on 2/25/2015
//  Retrieved from https://timrichardson.co/2015/02/microphone-input-wave-like-siri-using-swift/
//
//  Ported to Swift 5 by K Y on 1/9/20.
//

import UIKit
import AVFoundation
import SCSiriWaveformView

enum RecorderConstants {
    static let url: URL = URL(fileURLWithPath: "/dev/null")
    static let settings: [String: Any] = [
        AVSampleRateKey: 44100.0,
        AVFormatIDKey: kAudioFormatAppleLossless,
        AVNumberOfChannelsKey: 2,
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
    ]
}

final class AudioWaveViewController: UIViewController {
    
    // MARK: - UI Properties
    
    lazy var waveformView: SCSiriWaveformView = {
        let view = SCSiriWaveformView(frame: .zero)
        view.waveColor = .white
        view.primaryWaveLineWidth = 3.0
        view.secondaryWaveLineWidth = 1.0
        view.fillIn(self.view)
        return view
    }()
    
    var recorder: AVAudioRecorder = {
        let recorder: AVAudioRecorder
        do {
            recorder = try AVAudioRecorder(url: RecorderConstants.url,
                                           settings: RecorderConstants.settings)
        } catch {
            fatalError("Could not instantiate AVAudioRecorder")
        }
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        return recorder
    }()
    
    let session: AVAudioSession = .sharedInstance()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(waveformView)
        
        do {
            try session.setCategory(.playAndRecord)
        } catch {
            fatalError("Could not set category for AVAudioSession")
        }
        
        recorder.record()
        
        let displayLink: CADisplayLink = CADisplayLink(target: self,
                                                      selector: #selector(updateMeters))
        displayLink.add(to: .current, forMode: .common)
    }
    
    // MARK: - Custom Action Methods
    
    @objc func updateMeters() {
        recorder.updateMeters()
        let power: CGFloat = CGFloat(recorder.averagePower(forChannel: 0))/20
        let normalizedValue: CGFloat = pow(10, power)
        waveformView.update(withLevel: normalizedValue)
    }
    
}
