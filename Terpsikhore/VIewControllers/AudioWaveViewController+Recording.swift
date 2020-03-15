//
//  AudioWaveViewController+Recording.swift
//  Terpsikhore
//
//  Created by K Y on 1/9/20.
//  Copyright © 2020 Yu. All rights reserved.
//

import UIKit
import RecordingService

extension AudioWaveViewController: RecordingServiceDelegate {
    
    // MARK: - Recording Functionality
    
    /// sets up timed blinking functionality
    func recordingDidStart() {
        showSavedRecordingsButton.isHidden = true
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(wallDeadline: .now(),
                       repeating: Constants.blinkingInterval)
        
        timer.setEventHandler { [weak self] in
            guard let self = self, let view = self.recordingIndicatorView else { return }
            view.backgroundColor = (view.backgroundColor == Constants.isRecordingColor)
                ? Constants.notRecordingColor
                : Constants.isRecordingColor
        }
        timer.resume()
    }
    
    /// cancels timed blinking functionality
    func recordingDidEnd() {
        recordingIndicatorView.backgroundColor = Constants.notRecordingColor
        showSavedRecordingsButton.isHidden = false
        timer.cancel()
        timer = nil
    }
    
    // called on refresh rate of the device
    func recorderDidUpdate(_ power: CGFloat) {
        waveformView.update(withLevel: power)
    }
    
}
