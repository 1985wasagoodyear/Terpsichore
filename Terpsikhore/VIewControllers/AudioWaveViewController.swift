//
//  AudioWaveViewController.swift
//  Terpsikhore
//
//  Original by Tim Richardson on 2/25/2015
//  Retrieved from https://timrichardson.co/2015/02/microphone-input-wave-like-siri-using-swift/
//
//  Ported to, and heavily modified, to Swift 5, Xcode 11.3
//  by K Y on 1/9/20.
//

import UIKit
import SCSiriWaveformView
import RecordingService

final class AudioWaveViewController: UIViewController {

    /// constants for AudioWaveViewController's setup/UI/usage
    enum Constants {
        static let recordButtonHeight: CGFloat = 60.0
        static let isRecordingColor: UIColor = .red
        static let notRecordingColor: UIColor = .white
        static let blinkingInterval: TimeInterval = 0.75
        @available(iOS 13.0, *)
        static let savedRecordingsImage: UIImage? = UIImage(systemName: "folder")
        static let savedRecordingsText: String = "SAVED"
    }
    
    // MARK: - UI Properties
    
    @IBOutlet var recordingIndicatorView: UIView! {
        didSet {
            let view: UIView! = recordingIndicatorView
            view.backgroundColor = Constants.notRecordingColor
            view.roundify()
        }
    }
    @IBOutlet var recordingLengthLabel: UILabel!
    @IBOutlet var waveformView: SCSiriWaveformView! {
        didSet {
            waveformView.waveColor = .white
            waveformView.primaryWaveLineWidth = 3.0
            waveformView.secondaryWaveLineWidth = 1.0
            waveformView.layer.masksToBounds = false
            waveformView.clipsToBounds = false
        }
    }
    @IBOutlet var showSavedRecordingsButton: UIButton! {
        didSet {
            let btn: UIButton! = showSavedRecordingsButton
            var img: UIImage?
            var txt: String = ""
            if #available(iOS 13.0, *) {
                img = Constants.savedRecordingsImage
            } else {
                txt = Constants.savedRecordingsText
            }
            btn.setTitle(txt, for: .normal)
            btn.setImage(img, for: .normal)
        }
    }
    @IBOutlet var recordButton: UIButton! {
        didSet {
            let radi = Constants.recordButtonHeight
            let layer = recordButton.layer
            layer.cornerRadius = radi / 2.0
            recordButton.clipsToBounds = false
            layer.borderWidth = 5.0
            layer.borderColor = UIColor.white.cgColor
        }
    }
    
    lazy var service: RecordingService = {
       return RecordingService(self)
    }()
    
    var timer: DispatchSourceTimer!
    
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
    
    // MARK: - Navigation Methods
    
    @IBAction func showSavedRecordingsButtonAction(_ sender: Any) {
        let recordingsVC = SavedRecordingsViewController.instantiate(service)
        present(recordingsVC, animated: true, completion: nil)
    }
    
}
