//
//  SavedRecordingsViewController.swift
//  Created 3/15/20
//  Using Swift 5.0
// 
//  Copyright © 2020 Yu. All rights reserved.
//
//  https://github.com/1985wasagoodyear
//

import UIKit
import RecordingService
import AVKit

protocol Transport {
    associatedtype Element
    func send(_ item: Element)
}

protocol URLTransport: AnyObject {
    func receive(_ item: URL)
}

class RecordingsTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    func commonInit() {
        textLabel?.textColor = .white
        backgroundColor = .clear
        selectionStyle = .none
    }
}

final class SavedRecordingsViewController: UIViewController {
    
    
    enum Constants {
        static let cellID = "RecordingsTableViewCell"
        static let timeUpdateInterval: TimeInterval = 1.0
    }
    
    // MARK: - Song Info Outlets
    
    @IBOutlet var nowPlayingLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(RecordingsTableViewCell.self,
                               forCellReuseIdentifier: Constants.cellID)
        }
    }
    
    // MARK: - Audio Player Control Buttons
    
    @IBOutlet var playButton: UIButton!
    @IBOutlet var fastForwardButton: UIButton!
    @IBOutlet var rewindButton: UIButton!
    
    // MARK: - Properties
    
    weak var delegate: URLTransport?
    var service: RecordingService?
    var player: AVAudioPlayer!
    var isPlaying: Bool = false
    
    lazy var recordings: [URL] = {
        self.service?.allRecordings ?? []
    }()
    
    var timer: DispatchSourceTimer!
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unsetPlayingUI()
    }
    
    // MARK: - Audio Player Control Actions
    
    @IBAction func playButtonAction(_ sender: Any) {
        if isPlaying == false {
            startPlaying()
        } else {
            stopPlaying()
        }
        isPlaying.toggle()
    }
    func startPlaying() {
        // TODO - check if not at end of song
        player.play()
        
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(wallDeadline: .now(),
                       repeating: Constants.timeUpdateInterval)
        
        timer.setEventHandler { [weak self] in
            guard let self = self,
                let label = self.timeLabel,
                let player = self.player
                else { return }
            print("curr: \(player.currentTime), dur: \(player.duration)")
            label.text = player.currentTime.string + " / " + player.duration.string
        }
        timer.resume()
        
        playButton.setTitle("PAUSE", for: .normal)
    }
    
    func stopPlaying() {
        player.pause()
        timer.cancel()
        
        playButton.setTitle("PLAY", for: .normal)
    }
    
    @IBAction func rewindButtonAction(_ sender: Any) {
    
    }
    
    @IBAction func fastForwardButtonAction(_ sender: Any) {
        
    }
    
}

extension SavedRecordingsViewController: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        unsetPlayingUI()
        isPlaying = false
        // TODO: - complete
    }
}

extension SavedRecordingsViewController {
    func setupPlaying(_ url: URL) {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            // TODO: - register handler for when song ends
            player.delegate = self
        } catch {
            print(error)
            unsetPlayingUI()
            return
        }
        
        setPlayingUI()
    }
    
    func setPlayingUI() {
        nowPlayingLabel.text = "Now playing... <title here>"
        timeLabel.text = player.currentTime.string + " / " + player.duration.string
        playButton.isEnabled = true
        rewindButton.isEnabled = true
        fastForwardButton.isEnabled = true
        // TODO: - 
    }
    
    /// unused?
    func unsetPlayingUI() {
        nowPlayingLabel.text = "Now playing..."
        timeLabel.text = "00:00:00 / 00:00:00"
        playButton.isEnabled = false
        rewindButton.isEnabled = false
        fastForwardButton.isEnabled = false
        
    }
}

extension SavedRecordingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return recordings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: Constants.cellID,
                                 for: indexPath) as? RecordingsTableViewCell else {
                                    fatalError("Could not make cell")
        }
        
        cell.textLabel?.text = recordings[indexPath.row].lastPathComponent
        return cell
    }
    
}

extension SavedRecordingsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let recording = recordings[indexPath.row]
        setupPlaying(recording)
        
    }
    
}
