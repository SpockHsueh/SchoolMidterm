//
//  MyViewController.swift
//  SchoolMidterm
//
//  Created by Spoke on 2018/9/14.
//  Copyright © 2018年 Spoke. All rights reserved.
//

import UIKit
import AVFoundation

class MyViewController: UIViewController {
    
    // outlet
    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var volumeButton: UIButton!
    
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaing = false
    var isMuted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds

    }
    
    
    @IBAction func sliderChange(_ sender: UISlider) {
    }
    
    
    @IBAction func search(_ sender: Any) {
        if let searchUrl = searchTxt.text {
            let url = URL(string: "\(searchUrl)")!
            player = AVPlayer(url: url)
            player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
            addTimeObserver()
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.videoGravity = .resize
            videoView.layer.addSublayer(playerLayer!)
        }
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue, using: { [weak self] time in
            guard let currentItem = self?.player?.currentItem else {return}
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(time: currentItem.currentTime())
        })
    }
    
    func getTimeString(time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours, minutes, seconds])
        } else {
            return String(format: "%02i:%02i", arguments: [minutes, seconds
                ])
        }
        
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if player != nil {
            if keyPath == "duration", let duration = player?.currentItem?.duration.seconds, duration > 0.0 {
                self.totalTimeLabel.text = getTimeString(time: player!.currentItem!.duration)
            }
        }
    }
    
    
    @IBAction func backwardsPressed(_ sender: UIButton) {
        if player != nil {
            guard let duration = player?.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(player!.currentTime())
            var newTime = currentTime - 10.0
            if newTime < 0 {
                newTime = 0
            }
            let time: CMTime = CMTimeMake(Int64(newTime*1000), 1000)
            player?.seek(to: time)

        }
    }
    
    
    @IBAction func playPressed(_ sender: UIButton) {
        
        if player != nil {
            if isPlaing == false {
                player!.play()
                isPlaing = true
                playButton.setImage(#imageLiteral(resourceName: "btn_stop"), for: .normal)
            } else {
                player!.pause()
                isPlaing = false
                playButton.setImage(#imageLiteral(resourceName: "btn_play"), for: .normal)
            }
        }
    }
    

    @IBAction func forwardPressed(_ sender: UIButton) {
        if player != nil {
            guard let duration = player?.currentItem?.duration else { return }
            let currentTime = CMTimeGetSeconds(player!.currentTime())
            let newTime = currentTime + 10.0
            if newTime < (CMTimeGetSeconds(duration) - 10.0) {
                let time: CMTime = CMTimeMake(Int64(newTime*1000), 1000)
                player?.seek(to: time)
            }
        }
    }
    
    
    @IBAction func volumePressed(_ sender: UIButton) {
        if player != nil {
            if isMuted == false {
                player?.isMuted = true
                isMuted = true
                self.volumeButton.setImage(#imageLiteral(resourceName: "btn_volume_off"), for: .normal)
            } else {
                player?.isMuted = false
                isMuted = false
                self.volumeButton.setImage(#imageLiteral(resourceName: "btn_volume_up"), for: .normal)
            }
        }
    }
    
    
    @IBAction func fullScreenPressed(_ sender: UIButton) {
    }
    
    
    
    



}
