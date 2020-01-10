//
//  UIViewController+Utility.swift
//  Terpsikhore
//
//  Created by K Y on 1/10/20.
//  Copyright © 2020 Yu. All rights reserved.
//

import UIKit
import RecordingService

extension RecordingServiceDelegate where Self: UIViewController {
    func cannotRecord() {
        self.showSettings(title: "Your Microphone is Disabled",
                          message: "We need your mic")
    }
}

extension UIViewController {
    
    func showAlert(text: String) {
        let alert = UIAlertController(title: text,
                                      message: nil,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: text,
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSettings(title: String?, message: String? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let settings = UIAlertAction(title: "Settings",
                                     style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(settings)
        alert.addAction(cancel)
        alert.preferredAction = settings
        present(alert, animated: true, completion: nil)
    }

}
