//
//  CountersSoundEffect.swift
//  Counters
//
//  Created by Javier Cala Uribe on 29/5/21.
//

import Foundation
import AVFoundation
import MediaPlayer

enum FileSoundEffect : String {
    case welcome, editing, error
}

class CountersSoundEffect : NSObject {
    
    // MARK: - Properties
    
    static let sharedInstance = CountersSoundEffect()

    var audioPlayer: AVAudioPlayer!
    
    func start(_ file: FileSoundEffect) {
        do {
            // Config AVAudioSession on device
            let audioSession = AVAudioSession.sharedInstance()
            audioSession.perform(NSSelectorFromString("setCategory:withOptions:error:"), with: AVAudioSession.Category.playAndRecord, with:[AVAudioSession.CategoryOptions.mixWithOthers])
            try audioSession.setActive(true)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
            
            // Config Volume System
            UIApplication.shared.beginReceivingRemoteControlEvents()
            
            // Play sound
            guard let pathFile = Bundle.main.path(forResource: file.rawValue, ofType: "mp3") else {
                return
            }
            let musicFile   = URL(fileURLWithPath: pathFile)
            try audioPlayer = AVAudioPlayer(contentsOf: musicFile)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.numberOfLoops = 0
            audioPlayer.play()
            
        } catch let error as NSError {
            Logger("AVAudioSession error: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        audioPlayer.stop()
    }
}
