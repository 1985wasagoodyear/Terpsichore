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
    
    lazy var service: RecordingService = {
       return RecordingService(self)
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        service.startRecording()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        service.stopRecording()
    }
    
    // MARK: - Setup Methods
    
    func setupUI() {
        view.addSubview(waveformView)
    }
    
}
 
extension AudioWaveViewController: RecordingServiceDelegate {
    
    // MARK: - Recording Functionality
    
    // called on refresh rate of the device
    func recorderDidUpdate(_ power: CGFloat) {
        waveformView.update(withLevel: power)
    }
    
}
