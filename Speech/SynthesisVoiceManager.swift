//
//  SynthesisVoiceManager.swift
//  Flavr
//
//  Created by Timon Fuß on 14.02.19.
//  Copyright © 2019 Timon Fuß. All rights reserved.
//

import Foundation
import AVFoundation

protocol SynthesisVoiceManagerDelegate {
    func speechDidFinish()
}

class SynthesisVoiceManager: NSObject {
    /// sharedInstance: the SynthesisVoiceManager singleton
    public static let sharedInstance = SynthesisVoiceManager()
    
    var speechDetection = SpeechDetectionManager.sharedInstance
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let voiceSynth = AVSpeechSynthesizer()
    var voiceToUse: AVSpeechSynthesisVoice?
    var speaksToDo : [String] = []
    
    var delegate: SynthesisVoiceManagerDelegate!
    
    override init(){
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.timerStopped(_ :)), name: NSNotification.Name(rawValue: "finish"), object: nil)
        voiceToUse = AVSpeechSynthesisVoice(language: "de-DE")
        self.voiceSynth.delegate = self
    }
    
    /**
     Voice-Synthesizer for system reactions
     - Parameter string: String for System speaking.
     */
    func speak(string: String) {
        let modString = transformMeasurmentsSpeakable(string: string)
        addToList(string: modString)
        if !voiceSynth.isSpeaking {
            let utterance = AVSpeechUtterance(string: speaksToDo[0])
            utterance.voice = voiceToUse
            utterance.rate = 0.5
            voiceSynth.speak(utterance)
        }
    }
    
    /**
     Transforms system answers to sound more natural
     - Parameter string: that should be transformed.
     */
    func transformMeasurmentsSpeakable (string: String) -> String{
        let range = NSMakeRange(0, string.count)
        let regex = try! NSRegularExpression(pattern: "([.][5]{1})", options: NSRegularExpression.Options.caseInsensitive)
        let modString = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: " einhalb")
        
        let regex2 = try! NSRegularExpression(pattern: "([.][0]{1})", options: NSRegularExpression.Options.caseInsensitive)
        let modString2 = regex2.stringByReplacingMatches(in: modString, options: [], range: range, withTemplate: " ")
        
        let modString3 = modString2.replacingOccurrences(of: "EL", with: "Esslöffel", options: .literal, range: nil)
        let modString4 = modString3.replacingOccurrences(of: " g ", with: "Gramm ", options: .literal, range: nil)
        let modString5 = modString4.replacingOccurrences(of: " 1 ", with: " ein ", options: .literal, range: nil)
         
        return modString5
    }
    
    /**
     Adding System Answers to queue
     - Parameter string: that should be added to system answering queue.
     */
    private func addToList(string : String) {
        if !speaksToDo.contains(string) {
            speaksToDo.append(string)
        }
    }
    
    /**
     Voice-Synthesizer for TimerModules
     - Parameter string: String for System speaking.
     */
    func speakTimer(string: String) {
        addToList(string: string)
        speechDetection.stopRecordingTimer()
        if !voiceSynth.isSpeaking {
            let utterance = AVSpeechUtterance(string: speaksToDo[0])
            utterance.voice = voiceToUse
            utterance.rate = 0.5
            voiceSynth.speak(utterance)
        }
    }
    
    /**
     Objective-C-/Notificationfunction that will be called after timer finished
     - Parameter notification: TimeModule that finished.
     */
    @objc func timerStopped(_ notification: Notification) {
        let data = notification.object as! TimeModule
        speakTimer(string: data.finishMessage)
    }
}

extension SynthesisVoiceManager: AVSpeechSynthesizerDelegate {
    
    /**
     Method that is called after system anwswer finished
     - Parameter synthesizer: The synthesizer speaking the utterance that this message applies to.
     - Parameter utterance: The utterance that has finished being spoken.
     */
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if speaksToDo.count > 0 {
            if speaksToDo[0].contains("Lass es dir schmecken"){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "recipeFinished"), object: nil)
            }
        }
        if !speaksToDo.isEmpty{
            speaksToDo.removeFirst()
        }
        if speaksToDo.count > 0 {
            speak(string: speaksToDo[0])
        }else {
            SpeechDetectionManager.sharedInstance.recordAndRecognizeSpeech()
        }
    }
}
