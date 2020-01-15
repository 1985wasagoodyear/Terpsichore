//
//  AudioWaveViewController.swift
//  Terpsikhore
//
//  Original by Tim Richardson on 2/25/2015
//  Retrieved from https://timrichardson.co/2015/02/microphone-input-wave-like-siri-using-swift/
//
//  Ported to Swift 5, Xcode 11.3 by K Y on 1/9/20.
//

import UIKit
import SCSiriWaveformView
import RecordingService

extension TimeInterval {
    var string: String {
        let seconds = Int(self.truncatingRemainder(dividingBy: 60))
        let minutes = Int((self / 60).truncatingRemainder(dividingBy: 60))
        let hours = Int(self / 3600)
        return String(format: "%02d:%02d:%02d",
                      min(hours, 99),
                      minutes,
                      seconds)
    }
}

final class AudioWaveViewController: UIViewController {

    enum UIViewConstants {
        static let recordButtonHeight: CGFloat = 60.0
    }
    
    // MARK: - UI Properties
    
    @IBOutlet var recordingIndicatorView: UIView!
    @IBOutlet var recordingLengthLabel: UILabel!
    @IBOutlet var waveformView: SCSiriWaveformView! {
        didSet {
            waveformView.waveColor = .white
            waveformView.primaryWaveLineWidth = 3.0
            waveformView.secondaryWaveLineWidth = 1.0
        }
    }
    @IBOutlet var recordButton: UIButton! {
        didSet {
            let radi = UIViewConstants.recordButtonHeight
            let layer = recordButton.layer
            layer.cornerRadius = radi / 2.0
            recordButton.clipsToBounds = false
            layer.borderWidth = 5.0
            layer.borderColor = UIColor.black.cgColor
        }
    }
    
    lazy var service: RecordingService = {
       return RecordingService(self)
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - Setup Methods
    
    @IBAction func recordButtonAction(_ sender: Any) {
        if service.isRecording {
            service.stopRecording()
        } else {
            service.startRecording(queue: .main) { (interval) in
                self.recordingLengthLabel.text = interval.string
            }
        }
    }
}
 
extension AudioWaveViewController: RecordingServiceDelegate {
    
    // MARK: - Recording Functionality
    
    // called on refresh rate of the device
    func recorderDidUpdate(_ power: CGFloat) {
        waveformView.update(withLevel: power)
    }
    
}
