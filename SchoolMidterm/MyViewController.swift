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
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    
    @IBAction func sliderChange(_ sender: UISlider) {
    }
    
    
    @IBAction func search(_ sender: Any) {
        if let searchUrl = searchTxt.text {
            let url = URL(string: "\(searchUrl)")!
            player = AVPlayer(url: url)
            player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
        }
        
    }
    
    func addTimeObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        
        player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            
            guard let currentItem = self?.player.currentItem else { return }
            
            self?.timeSlider.minimumValue = 0
            self?.timeSlider.maximumValue = Float(currentItem.duration.seconds)
            self?.timeSlider.value = Float(currentItem.currentTime().seconds)
            self?.currentTimeLabel.text = self?.getTimeString(time: currentItem.currentTime())
        }
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
    
    
    @IBAction func backwardsPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func playPressed(_ sender: UIButton) {
    }
    

    @IBAction func forwardPressed(_ sender: UIButton) {
    }
    
    
    @IBAction func volunePressed(_ sender: UIButton) {
    }
    
    
    @IBAction func fullScreenPressed(_ sender: UIButton) {
    }
    
    
    
    



}
