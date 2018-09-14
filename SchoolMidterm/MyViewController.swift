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
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var backwardsButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var sliderButton: NSLayoutConstraint!
    @IBOutlet weak var controllerButton: NSLayoutConstraint!
    
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var isPlaing = false
    var isMuted = false
    var isExpanded = false
    var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchButton.layer.borderWidth = 0.5
        searchButton.layer.borderColor = UIColor.lightGray.cgColor
        timeSlider.isEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds
    }
    
    
    
    @IBAction func sliderChange(_ sender: UISlider) {
        player?.seek(to: CMTimeMake(Int64(sender.value*1000), 1000))
    }
    
    
    @IBAction func search(_ sender: Any) {
        if let searchUrl = searchTxt.text {
            let url = URL(string: "\(searchUrl)")
            if let url = url {
                player = AVPlayer(url: url)
                player?.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
                addTimeObserver()
                playerLayer = AVPlayerLayer(player: player)
                playerLayer?.videoGravity = .resize
                videoView.layer.addSublayer(playerLayer!)
                statusLabel.isHidden = true
                timeSlider.isEnabled = true
            }
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
                searchTxt.text = nil
            }
        }
    }
    
    
    @IBAction func backwardsPressed(_ sender: UIButton) {
        setBackColor(button: backwardsButton)
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
            if isFullScreen == false {
                setVPlayColor(color: .black, button: playButton)
                
            } else {
                setVPlayColor(color: .white, button: playButton)
            }
        }
    }
    

    @IBAction func forwardPressed(_ sender: UIButton) {
        setforwardColor(button: forwardButton)
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
            if isFullScreen == false {
                setVolumeColor(color: .black, button: volumeButton)
                
            } else {
                setVolumeColor(color: .white, button: volumeButton)
            }
        }
    }
    
    
    @IBAction func fullScreenPressed(_ sender: UIButton) {
        if isExpanded == false {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                let value =  UIInterfaceOrientation.landscapeLeft.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
                self.isExpanded = true
                self.setFullScreenButton(button: self.fullScreenButton, color: .white)
            })
        } else {
            let value =  UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            self.isExpanded = false
            self.setFullScreenButton(button: self.fullScreenButton, color: .black)

        }
    }

    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        isFullScreen = UIDevice.current.orientation.isLandscape
        
        if isFullScreen == true {
            self.navigationController?.navigationBar.isHidden = true
            if player == nil {
                statusLabel.isHidden = false
                statusLabel.textColor = .white
                self.videoView.backgroundColor = .black
            }
            self.searchTxt.isHidden = true
            self.searchButton.isHidden = true
            setButtonColor(color: .white)
            sliderButton.constant = 10.0
            controllerButton.constant = 10.0
            currentTimeLabel.textColor = UIColor.white
            totalTimeLabel.textColor = UIColor.white
        } else {
            self.navigationController?.navigationBar.isHidden = false
            setButtonColor(color: .black)
            statusLabel.textColor = .black
            self.videoView.backgroundColor = .white
            self.searchTxt.isHidden = false
            self.searchButton.isHidden = false
            sliderButton.constant = 30.0
            controllerButton.constant = 30.0
            currentTimeLabel.textColor = UIColor.black
            totalTimeLabel.textColor = UIColor.black
        }
    }
    
    func setButtonColor(color: UIColor) {
        volumeButton.setImage(#imageLiteral(resourceName: "btn_volume_up").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        volumeButton.tintColor = color
        
        backwardsButton.setImage(#imageLiteral(resourceName: "btn_play_rewind").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        backwardsButton.tintColor = color
        
        playButton.setImage(#imageLiteral(resourceName: "btn_play").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        playButton.tintColor = color
        
        forwardButton.setImage(#imageLiteral(resourceName: "btn_play_forward").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        forwardButton.tintColor = color
    }
    
    
    func setVolumeColor(color: UIColor, button: UIButton) {
        if isFullScreen == true {
            
            if isMuted == false {
                button.setImage(#imageLiteral(resourceName: "btn_volume_off").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isMuted = true
                player?.isMuted = true
            } else {
                 button.setImage(#imageLiteral(resourceName: "btn_volume_up").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isMuted = false
                player?.isMuted = false
            }
            button.tintColor = color
        } else {
            if isMuted == false {
                button.setImage(#imageLiteral(resourceName: "btn_volume_off").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isMuted = true
                player?.isMuted = true
            } else {
                button.setImage(#imageLiteral(resourceName: "btn_volume_up").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isMuted = false
                player?.isMuted = false
            }
        }
        button.tintColor = color
    }
    
    func setBackColor(button: UIButton) {
        if isFullScreen == true {
            
            button.setImage(#imageLiteral(resourceName: "btn_play_rewind").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)

            button.tintColor = .white
        } else {
            
            button.setImage(#imageLiteral(resourceName: "btn_play_rewind").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            button.tintColor = .black
        }
    }
    
    func setforwardColor(button: UIButton) {
        if isFullScreen == true {
            
            button.setImage(#imageLiteral(resourceName: "btn_play_forward").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            
            button.tintColor = .white
        } else {
            
            button.setImage(#imageLiteral(resourceName: "btn_play_forward").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            button.tintColor = .black
        }
    }
    
    func setVPlayColor(color: UIColor, button: UIButton) {
        if isFullScreen == true {
            
            if isPlaing == false {
                button.setImage(#imageLiteral(resourceName: "btn_stop").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isPlaing = true
                player?.play()
            } else {
                button.setImage(#imageLiteral(resourceName: "btn_play").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isPlaing = false
                player?.pause()
            }
            button.tintColor = color
        } else {
            if isPlaing == false {
                button.setImage(#imageLiteral(resourceName: "btn_stop").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isPlaing = true
                player?.play()
            } else {
                button.setImage(#imageLiteral(resourceName: "btn_play").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
                isPlaing = false
                player?.pause()
            }
        }
        button.tintColor = color
    }
    
    func setFullScreenButton(button: UIButton, color: UIColor) {
        if isFullScreen == true {
            button.setImage(#imageLiteral(resourceName: "btn_fullScreen_exit").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            button.tintColor = color
        } else {
            button.setImage(#imageLiteral(resourceName: "btn_fullScreen").withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
            button.tintColor = color
        }
    }
}
