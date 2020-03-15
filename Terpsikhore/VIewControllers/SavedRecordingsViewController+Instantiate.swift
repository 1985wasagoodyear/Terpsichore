//
//  SavedRecordingsViewController+Instantiate.swift
//  Created 3/15/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import UIKit
import RecordingService

extension SavedRecordingsViewController {
    static func instantiate(_ service: RecordingService? = nil) -> SavedRecordingsViewController {
        let identifier = "SavedRecordingsViewController"
        guard let recordingsVC = UIStoryboard
            .main
            .instantiateViewController(withIdentifier: identifier) as? SavedRecordingsViewController else {
                fatalError("FatalError - could not instantiate SavedRecordingsViewController")
        }
        recordingsVC.service = service
        return recordingsVC
    }
}
